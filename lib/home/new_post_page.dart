
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frame/home/timeline_page.dart';
import 'package:frame/navigation_rail.dart';
//import 'package:frame/ui_widgets/main_page.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;

class NewPostPage extends StatefulWidget{
  const NewPostPage({super.key});

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage>{

  //画面表示に利用 （一旦の書き換えする場合ここが変わり、最後にこれを登録する）
  List<Uint8List>? _images = [];//あとで動画＆複数画像
  List<String> _imageUrls = []; //FirestoreのURL受け取り用
  List<String> _tags = []; //tagってこんな感じで保存して後から検索出来るの？
  String errorMessage = '';


  //コントローラー
  final _captionController = TextEditingController();
  final _tagsController = TextEditingController();
//投稿ID作成用
  var uuid = Uuid();



  //複数写真のインデックス
  int _currentIndex = 0;
  //次へ
  void _nextImage() {
    if(_images?.length != null){
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images!.length;
      });
    }
  }
  //戻る
  void _backImage() {
    if(_images?.length != null){
      setState(() {
        _currentIndex = (_currentIndex - 1) % _images!.length;
      });
    }
  }

  //入力されたタグをリストに追加
  void _addTag() {
    setState(() {
      _tags.add(_tagsController.text);
    });
  }


//選択された画像を画面に表示する（複数）//追加してくスタイル
  Future<void> _pickMultiImage() async {
    //処理中はサークルインジケーター
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(
            color: Colors.black.withOpacity(0.5), // 半透明のバリア
            dismissible: false, // タッチでバリアを消せないようにする
          ),
          Center(
              child: Column(
                children: [
                  //テキストのデザインに難あり
                  Text('ローディング中',
                    style:TextStyle(
                        color: Colors.white,
                        fontSize: 30
                    ) ,),
                  CircularProgressIndicator(), // インジケーター
                ],
              )
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    try{
      final Uint8List? pickedFile = await ImagePickerWeb.getImageAsBytes();
      if (pickedFile != null) {
        //Uint8List形式のバイトデータをデコードし、Imageオブジェクトとして返します
        final originalImage = img.decodeImage(pickedFile);
        // リサイズ処理 (例: 幅800pxにリサイズ,高さは、元の画像の縦横比を維持して自動的に調整)
        final resizedImage = img.copyResize(originalImage!, width: 800);
        final jpgBytes = img.encodeJpg(resizedImage);

        _images!.add(jpgBytes);
        setState(() {
          _currentIndex =  _images!.length - 1;
          errorMessage = '';
        });
      }}catch(e){
      return print('$e');
    }finally{
      // インジケーターを非表示にする
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry? _overlayEntry;

  //投稿をFirestoreに登録　//ユーザーごとに分けて保存するかすべてをまとめて保存か？
  Future<void> setFirestore ()async{
    // インジケーターを表示
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(
            color: Colors.black.withOpacity(0.5), // 半透明のバリア
            dismissible: false, // タッチでバリアを消せないようにする
          ),
          Center(
              child: Column(
                children: [
                  Text('ローディング中',
                    style:TextStyle(
                        color: Colors.white,
                        fontSize: 30
                    ) ,),
                  CircularProgressIndicator(), // インジケーター
                ],
              )
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);

    try{
      //画像のアップロード
      for (var image in _images!) {
        try {
          // Firebase Storageへのアップロード
          //Storageの参照を取得
          Reference ref = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
          UploadTask uploadTask = ref.putData(image);
          TaskSnapshot snapshot = await uploadTask;
          //StrageのURLを取得
          String downloadUrl = await snapshot.ref.getDownloadURL();

          // アップロードされた画像のURLをリストに追加
          _imageUrls.add(downloadUrl);
        } catch (e) {
          print('Error uploading image: $e');
        }
      }
      //Firestoreに登録
      final user = FirebaseAuth.instance.currentUser;
      String v4Uuid = uuid.v4();
      if (user != null) {
        return
          await FirebaseFirestore.instance.collection('posts').doc(v4Uuid)
              .set({
            'userUid': user.uid,
            'imageUrl': _imageUrls,
            'caption': _captionController.text,
            'createdAt': FieldValue.serverTimestamp(),
            'like': 0,
            'bookmark':0,
            'postId':v4Uuid,
            'tags': _tags
          });
      }
    }catch(e){
      print('エラー: $e');
    }finally {
      // インジケーターを非表示にする
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  /*Future<void> uploadImages() async {
    for (var image in _images!) {
      try {
        // Firebase Storageへのアップロード
        //Storageの参照を取得
        Reference ref = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        UploadTask uploadTask = ref.putData(image);
        TaskSnapshot snapshot = await uploadTask;
        //StrageのURLを取得
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // アップロードされた画像のURLをリストに追加
        _imageUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {

    return  Column(
        children: [
          const Text('新規投稿',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ) ,),
          const Divider(
            thickness: 4,
            color: Colors.grey,
          ),
          Expanded(
          child:SingleChildScrollView(
                  child:
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:Container(
                        alignment: Alignment.center,
                        //width: imageWidth,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //投稿写真
                              //１ブロック
                              Container(
                                color: Colors.black26,
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: SizedBox(
                                    width:  MediaQuery.of(context).size.width*0.4,
                                    height:  MediaQuery.of(context).size.height*0.4,
                                    child:Container(
                                      color: Colors.white30,
                                      child: (_images != [] && _images!.length > 0)
                                          ? Image.memory(_images![_currentIndex])
                                          : Container(),//Expanded(child: ColoredBox(color: Colors.black26))
                                    )

                                  /*//全体画像
                              Positioned(
                                  child:Image.memory(_images![_currentIndex] as Uint8List)
                              ),
                              //グラデで背景を白く
                              Positioned(
                                  child: child
                              ),
                              //トリミング後の画像
                              Positioned(
                                  child: Image.memory(_images![_currentIndex] as Uint8List)
                              )
                              //トリミング黒枠
                              Positioned(
                                  child: child
                              ),*/





                                  /*(_images != null || _images!.isNotEmpty)
                              && (_images!.length > _currentIndex && _currentIndex >= 0)
                          //image型はキャストすれば使っていいの？
                              ? Image.memory(_images![_currentIndex] as Uint8List)
                              : Text('画像を選択してください'),*/
                                ),
                              ),



                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 40),
                                    //戻る
                                    ElevatedButton(
                                      onPressed: _backImage,
                                      style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        backgroundColor: Colors.white
                                      ),
                                      child: Icon(Icons.arrow_back,color:Colors.black,),
                                    ),
                                    //次へ
                                    ElevatedButton(
                                      onPressed: _nextImage,
                                      style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          backgroundColor: Colors.white
                                      ),
                                      child: Icon(Icons.arrow_forward,color:Colors.black),
                                    ),
                                    //削除
                                    ElevatedButton(
                                      onPressed: (){
                                        if(_images!.isNotEmpty){
                                          _images?.removeAt(_currentIndex);
                                          setState(() {});}
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: CircleBorder(),),
                                      child: Icon(Icons.delete,color:Colors.black),
                                    ),
                                    //追加
                                    ElevatedButton(
                                      onPressed: _pickMultiImage,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: CircleBorder(),),
                                      child: Icon(Icons.add_a_photo,color:Colors.black,),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 100,vertical: 10),
                                child: Column(
                                  children: [
                                    SizedBox(width: 20),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, //  これを追加
                                      children: [
                                        ///キャプション（初期状態で３行ぐらいにしたい）
                                        Row(
                                          children: [
                                            Icon(Icons.edit_note,color: Colors.white,),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: TextFormField(
                                                minLines: 4,// 任意の行数に設定可能
                                                maxLines: 6,
                                                controller: _captionController,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.grey)),
                                                  hintText: 'Add a caption',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        ///タグ
                                        Container(
                                          padding: EdgeInsets.only(left: 30),
                                          child: Wrap(
                                            spacing: 3.0,
                                            runSpacing: 2.0,
                                            children: _tags.toList().map((tag) =>
                                                Chip(label: Text('#$tag',)) )
                                                .toList(),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.tag,color: Colors.white,),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: TextField(
                                                //cursorColor: Colors.white,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.grey)),
                                                  hintText: 'Tag',
                                                ),
                                                controller: _tagsController,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white
                                                ),
                                                onPressed: ()async{
                                                  if(_tagsController.text != ''){
                                                    _addTag();
                                                  }
                                                  _tagsController.clear();
                                                },
                                                child: Text('タグを追加',style: TextStyle(color: Colors.black),)
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),

                                    Visibility(
                                        visible: errorMessage != '',
                                        child: Text(errorMessage,style: TextStyle(color: Colors.white),)
                                    ),

                                    SizedBox(height: 10),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white
                                      ),
                                        child: Text('投稿',style: TextStyle(color: Colors.black),),
                                        onPressed: ()async{
                                          if(_images!.isEmpty /*|| _images == null*/){
                                            setState(() {
                                              errorMessage = '投稿したい画像を選択しましょう！';
                                            });
                                            debugPrint('空白です');
                                          }else{
                                            await setFirestore();
                                            Navigator.push(context,
                                              MaterialPageRoute(builder: (context) {
                                                return NavigationRailPart(widgetUI:TimelinePage());
                                              }),
                                            );
                                          }
                                        }
                                    )
                                  ],
                                ),
                              ),
                            ]
                        ),
                      )
                  ),
                )
          )
        ]);

  }
}