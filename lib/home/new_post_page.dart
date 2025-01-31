import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frame/home/timeline_page.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:uuid/uuid.dart';

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
    if(_images!.length != null){
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images!.length;
      });
    }
  }
  //戻る
  void _backImage() {
    if(_images!.length != null){
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
    final Uint8List? pickedFiles = await ImagePickerWeb.getImageAsBytes();
    if (pickedFiles != null) {
        _images!.add(pickedFiles);
        setState(() {
          _currentIndex =  _images!.length - 1;
          errorMessage = '';
        });
    }
  }


  //投稿をFirestoreに登録　//ユーザーごとに分けて保存するかすべてをまとめて保存か？
  Future<void> setFirestore ()async{
    final user = FirebaseAuth.instance.currentUser;
    String v4Uuid = uuid.v4();
    if (user != null) {
      debugPrint('セットします');
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
  }

  Future<void> uploadImages() async {
    for (var image in _images!) {
      try {
        // Firebase Storageへのアップロード
        Reference ref = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = ref.putData(image);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // アップロードされた画像のURLをリストに追加
        _imageUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        // 画面の幅に応じて画像の幅を調整 (例)
        final imageWidth = constraints.maxWidth * 0.7; // 画面幅の50%
        //以下にUI
        return  Scaffold(
          body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:Container(
                  alignment: Alignment.center,
                  width: imageWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        //投稿写真
                      //複数写真表示
                      Container(
                        width: imageWidth*0.7,
                        padding: EdgeInsets.all(30),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: GestureDetector(
                            child: (_images != null || _images!.isNotEmpty)
                                && (_images!.length > _currentIndex && _currentIndex >= 0)
                                ? Image.memory(_images![_currentIndex])
                                : Text('No image selected.'),


                            onTap:(){
                              _pickMultiImage();
                            },
                          ),
                        ),
                      ),


                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                        child: Row(
                          children: [
                            SizedBox(width: 40),
                            //戻る
                            ElevatedButton(
                              onPressed: _backImage,
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),),
                              child: Icon(Icons.arrow_back),
                            ),
                            //次へ
                            ElevatedButton(
                              onPressed: _nextImage,
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),),
                              child: Icon(Icons.arrow_forward),
                            ),
                            //削除
                            ElevatedButton(
                              onPressed: (){
                                if(_images!.isNotEmpty){
                                  _images?.removeAt(_currentIndex);
                                  setState(() {});}
                                },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),),
                              child: Icon(Icons.delete),
                            ),
                            //追加
                            ElevatedButton(
                              onPressed: _pickMultiImage,
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),),
                              child: Icon(Icons.add_a_photo),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 100,vertical: 20),
                        child: Column(
                              children: [
                                SizedBox(width: 20),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, //  これを追加
                                  children: [
                                    ///キャプション（初期状態で３行ぐらいにしたい）
                                    Row(
                                      children: [
                                        Icon(Icons.edit_note),
                                        SizedBox(width: 8),
                                        Expanded(
                                            child: TextFormField(
                                              minLines: 4,// 任意の行数に設定可能
                                              maxLines: 6,
                                              controller: _captionController,
                                              decoration: InputDecoration(
                                                hintText: 'Add a caption',
                                                border: OutlineInputBorder(),
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
                                        children: _tags.toList().map((tag) => Chip(label: Text('#$tag')) ).toList(),
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    Row(
                                      children: [
                                        Icon(Icons.tag),
                                        SizedBox(width: 8),
                                        Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                hintText: 'Tag',
                                                border: OutlineInputBorder(),
                                              ),
                                              controller: _tagsController,
                                            ),
                                        ),
                                        SizedBox(width: 5),
                                        ElevatedButton(
                                            onPressed: (){
                                              if(_tagsController.text != ''){
                                                _addTag();
                                              }
                                            },
                                            child: Text('タグを追加')
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30),

                                Visibility(
                                    visible: errorMessage != '',
                                    child: Text(errorMessage)
                                ),

                                SizedBox(height: 10),

                            ElevatedButton(
                              child: Text('投稿'),
                              onPressed: ()async{
                                if(_images!.isEmpty /*|| _images == null*/){
                                  setState(() {
                                    errorMessage = '投稿したい画像を選択しましょう！';
                                  });
                                  debugPrint('空白です');
                                }else{
                                  await uploadImages();
                                  setFirestore();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return TimelinePage();
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
        ),
        );
      },
    );
  }
}