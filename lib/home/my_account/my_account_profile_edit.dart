import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frame/home/my_account/my_account_top.dart';
import 'package:frame/ui_widgets/bottom_bar.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:universal_html/html.dart';
import 'package:image/image.dart' as img;

class MyAccountProfileEdit extends StatefulWidget {

  final String iconImageUrl ;
  final String backgroundImageUrl ;
  final String userId;
  final String userName;
  final String userBio ;
  final String userLink ;


  const MyAccountProfileEdit({
    super.key,
    required this.iconImageUrl,
    required this.backgroundImageUrl,
    required this.userId,
    required this.userName,
    required this.userBio,
    required this.userLink
  });

  @override
  State<MyAccountProfileEdit> createState() => _MyAccountProfileEditState();
}

class _MyAccountProfileEditState extends State<MyAccountProfileEdit> {
  //画面に表示される者たち（一旦の書き換えする場合ここが変わり、最後にこれを登録する）
  Uint8List? uintBackImage;
  Uint8List? uintIconImage;

  //コントローラー
  late String changedBackgroundImage;
  late String changedIconImage;
  late TextEditingController _userNameController;
  late TextEditingController _userBioController ;
  late TextEditingController _userLinkController;
  late TextEditingController _userIdController ;

  @override
  void initState() {
    super.initState();
    changedBackgroundImage = widget.backgroundImageUrl;
    changedIconImage = widget.iconImageUrl;
    _userNameController = TextEditingController(text: widget.userName);
    _userBioController = TextEditingController(text: widget.userBio);
    _userLinkController = TextEditingController(text: widget.userLink);
    _userIdController = TextEditingController(text: widget.userId);
  }



  /*@override
  void initState() {
    super.initState();
    // Firestoreからユーザー情報を取得
    getUserData();
  }
  
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data()! as Map<String, dynamic>;
        if (userData.isNotEmpty)
        setState(() {
          backgroundImageUrl = userData['backgroundImage'] ?? '';
          iconImageUrl = userData['iconImage'] ?? '';
          userId = userData['userId'] ?? 'ユーザーIDが見つかりません';
          userName = userData['userName'] ?? 'ユーザー名が未設定です';
          userBio = userData['userBio'] ?? 'Bioが未設定です';
          userLink = userData['userLink'] ?? 'リンクが未設定です';
        });
      }
    } else {
      return null;
    }
  }*/


  //すべての変更内容をユーザーのFirestoreに登録する
  Future<void> saveChanged (Uint8List? uintBackImage,Uint8List? uintIconImage)async{
    // 背景アップロード
    if (uintBackImage != null) {
      //Storageにアップロード
      final ref = FirebaseStorage.instance.ref().child(
          'images/${DateTime.now()}.jpg');
      await ref.putBlob(uintBackImage);
      // アップロードされた画像のダウンロードURLを取得;
      String downloadUrl = await ref.getDownloadURL();
      setState(() {
        changedBackgroundImage = downloadUrl;
      });
    }
    //アイコンアップロード
    if(uintIconImage != null){
      //Storageにアップロード
      final ref = FirebaseStorage.instance.ref().child(
          'images/${DateTime.now()}.jpg');
      await ref.putBlob(uintIconImage);
      // アップロードされた画像のダウンロードURLを取得;
      String downloadUrl = await ref.getDownloadURL();
      setState(() {
        changedIconImage = downloadUrl;
      });
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      debugPrint('セットします');
      await FirebaseFirestore.instance.collection('users').doc(user.uid)
          .update({
        'backgroundImage':changedBackgroundImage,
        'iconImage': changedIconImage,
        'userName': _userNameController.text,
        'userId': _userIdController.text,
        'userBio': _userBioController.text,
        'userLink': _userLinkController.text,
      });
    }
  }

  void pickImage(String key)async{
    final Uint8List? pickedFile = await ImagePickerWeb.getImageAsBytes();
    if (pickedFile != null) {
      //Uint8List形式のバイトデータをデコードし、Imageオブジェクトとして返します
      final originalImage = img.decodeImage(pickedFile);
      // リサイズ処理 (例: 幅800pxにリサイズ,高さは、元の画像の縦横比を維持して自動的に調整)
      final resizedImage = img.copyResize(originalImage!, width: 800);
      final jpgBytes = img.encodeJpg(resizedImage);

      setState(() {
        (key == 'backImage')
        ? uintBackImage = jpgBytes
        : uintIconImage = jpgBytes;
       });
    }
  }


  //写真変更したら動く（imageUrlを変更する）
  Future<void> uploadImage(Uint8List? uintBackImage,Uint8List? uintIconImage) async {
      // 背景アップロード
      if (uintBackImage != null) {
          //Storageにアップロード
          final ref = FirebaseStorage.instance.ref().child(
              'images/${DateTime.now()}.jpg');
          await ref.putBlob(uintBackImage);
          // アップロードされた画像のダウンロードURLを取得;
          String downloadUrl = await ref.getDownloadURL();
          setState(() {
            changedBackgroundImage = downloadUrl;
          });
      }
      //アイコンアップロード
      if(uintIconImage != null){
        //Storageにアップロード
        final ref = FirebaseStorage.instance.ref().child(
            'images/${DateTime.now()}.jpg');
        await ref.putBlob(uintIconImage);
        // アップロードされた画像のダウンロードURLを取得;
        String downloadUrl = await ref.getDownloadURL();
        setState(() {
          changedIconImage = downloadUrl;
        });
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
                          color: Colors.white70,
                          alignment: Alignment.center,
                          width: imageWidth,
                          child: Column(

                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              ///アセット内のローカルな写真を設定、トップ写真＆スワイプで固定写真表示
                              ///ここは写真投稿が出来たら作ろう！

                              Stack(
                                children: [
                                  ///ヘッダー画像
                                  Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: (uintBackImage != null)//三項演算子を使う
                                          //背景画像を変更した場合
                                              ?MemoryImage(uintBackImage!)
                                          //設定してない場合（元の背景画像or初期画像）
                                              : (changedBackgroundImage != '')
                                              ?NetworkImage(changedBackgroundImage)
                                              :AssetImage('assets/images/S__207101993.jpg'),// 初期画像
                                          fit: BoxFit.cover
                                      ),
                                    ),
                                  ),

                                  ///薄もや＆GestureDetector係
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      child: Container(
                                        height: 150, // グラデーションの高さを調整
                                        color: Colors.white24,
                                      ),
                                      onTap: (){
                                        pickImage('backImage');
                                      }
                                    ),
                                  ),

                                ],
                              ),

                              Container(
                                //padding: EdgeInsets.symmetric(horizontal: 100,vertical: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [

                                        //アイコンを設定　（グラデ薄く＋中央に追加アイコン）stackか？
                                        SizedBox(
                                          width: 210,
                                          child: GestureDetector(
                                            onTap: ()async{
                                              pickImage('iconImage');
                                            },
                                            child: (uintIconImage != null)
                                                ?CircleAvatar(
                                                radius: 100,
                                                backgroundImage: MemoryImage(uintIconImage!))
                                                :(changedIconImage != '')
                                                  ?CircleAvatar(
                                                    radius: 100,
                                                    backgroundImage: CachedNetworkImageProvider(changedIconImage))
                                                  :CircleAvatar(
                                                    radius: 100, // アイコンの半径
                                                    child: Icon(Icons.person), ),// 初期アイコン,
                                          ),
                                        ),

                                        SizedBox(width: 20),

                                        //　idと名前をアイコンの横へ
                                        SizedBox(
                                          width: 400,
                                             child: Column(
                                          //crossAxisAlignment: CrossAxisAlignment.start, //  これを追加
                                          children: [
                                            ///id（フォント、サイズ、色の調整が必要）
                                            Row(
                                              children: [
                                                Icon(Icons.person),
                                                SizedBox(width: 8),
                                          SizedBox(
                                            width: 300,
                                            child:TextField(
                                                  decoration: InputDecoration(
                                                    hintText: 'ユーザーidを入力してください',
                                                    //labelText: userId,
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  controller: _userIdController,
                                                ),)
                                              ],
                                            ),
                                            ///名前（フォント、サイズ、色の調整が必要）
                                            Row(
                                              children: [

                                                Icon(Icons.person),
                                                SizedBox(width: 8),
                                                SizedBox(
                                                  width: 300,
                                                  child: TextField(
                                                  decoration: InputDecoration(
                                                    hintText: '名前を入力してください',
                                                    //labelText: userName,
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  controller: _userNameController,
                                                  /*onChanged: (value){
                                                        userName = value;
                                                    },*/
                                                  )
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 30),

                                            ///bio　（フォント、サイズ、色の調整,複数行にできる必要）
                                            Row(
                                              children: [
                                                Icon(Icons.info),
                                                SizedBox(width: 8),
                                                SizedBox(
                                                  width: 300,
                                                  child: TextField(
                                                  decoration: InputDecoration(
                                                    hintText: 'Bioを入力してください',
                                                    //labelText: userBio,
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  controller: _userBioController,
                                                  /*onChanged: (value){
                                                userBio = value;
                                            },*/
                                                ),)
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.person),
                                                SizedBox(width: 8),
                                                SizedBox(
                                                  width: 300,
                                                  child: TextField(
                                                  decoration: InputDecoration(
                                                    hintText: 'ユーザーリンクを入力してください',
                                                   // labelText: userLink,
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  controller: _userLinkController,
                                                  /*onChanged: (value){
                                                userLink = value;
                                            },*/
                                                ),)
                                              ],
                                            ),

                                          ],
                                        )
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              ElevatedButton(
                                  onPressed:()async{
                                    await saveChanged(uintBackImage, uintIconImage);
                                    Navigator.pushNamed(context, '/my_account_top');
                                  },
                                  child: Text('保存')
                              )

                              ///アルバム
                              ///時系列の投稿表示
                              ///ここは写真投稿が出来たら作ろう！
                            ],
                          ),
                        ),
                      )
                  ),
            bottomNavigationBar: BottomBar(),
          );
        },
      );
  }
}


