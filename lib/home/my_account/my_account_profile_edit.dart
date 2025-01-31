//import 'dart:html';
//import 'package:universal_html/html.dart' as html;
import 'dart:js_interop';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frame/ui_widgets/bottom_bar.dart';
import 'package:universal_html/html.dart';

class MyAccountProfileEdit extends StatefulWidget {
  const MyAccountProfileEdit({super.key});

  @override
  State<MyAccountProfileEdit> createState() => _MyAccountProfileEditState();
}

class _MyAccountProfileEditState extends State<MyAccountProfileEdit> {

  //コントローラー
  final _userNameController = TextEditingController();
  final _userBioController = TextEditingController();
  final _userLinkController = TextEditingController();
  final _userIdController = TextEditingController();
  //final _passwordController = TextEditingController();


  //画面に表示される者たち（一旦の書き換えする場合ここが変わり、最後にこれを登録する）
  String iconImageUrl = '';
  String backgroundImageUrl = '' ;
  String userId = '';
  String userName = '';
  String userBio = '';
  String userLink ='';

  @override
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
  }


  //すべての変更内容をユーザーのFirestoreに登録する
  Future<void> setT ()async{
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint('セットします');
      await FirebaseFirestore.instance.collection('users').doc(user.uid)
          .update({
        'backgroundImage':backgroundImageUrl,
        'iconImage': iconImageUrl,
        'userName': _userNameController.text,
        'userId': _userIdController.text,
        'userBio': _userBioController.text,
        'userLink': _userLinkController.text,
      });
    }
  }

  //写真変更したら動く（imageUrlを変更する）
  Future<void> uploadImage(String imageUrlKey) async {
    ///まずネイティブかWebか
    if (kIsWeb) { // Webの場合
      // ファイル選択ダイアログを表示
      final picker = FileUploadInputElement();
      picker.click();
      picker.onChange.listen((event) async {
        // null チェックと、ファイルが選択されているかどうかのチェック
        final selectedFiles = picker.files;
        if (selectedFiles != null && selectedFiles.isNotEmpty) {
          final file = selectedFiles.first;
          // ファイルの処理
          //Storageにアップロード
          final ref = FirebaseStorage.instance.ref().child(
              'images/${DateTime.now()}.jpg');
          await ref.putBlob(file);
          // アップロードされた画像のダウンロードURLを取得
          //final downloadURL = await ref.getDownloadURL();
          //debugPrint('Download URL: $downloadURL');
          if (imageUrlKey == 'backgroundImage') {
            backgroundImageUrl = await ref.getDownloadURL();
            debugPrint('backsetcomp!');
          } if(imageUrlKey == 'iconImage'){
            iconImageUrl = await ref.getDownloadURL();
            debugPrint('iconsetconp!');
          }
          else {
          }
          setState(() {
            // 非同期処理が完了した後に、setState() を呼び出して UI を更新
          });
        } else {
          // ファイルが選択されていない場合の処理
          debugPrint('ファイルが選択されていません');
        }
      });
    } else {
      // ネイティブアプリの場合、Fileオブジェクトを使ってアップロードを行う
      debugPrint('ネイティブアプリのコードは準備中です');
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
                              ///アセット内のローカルな写真を設定、トップ写真＆スワイプで固定写真表示
                              ///ここは写真投稿が出来たら作ろう！

                              Stack(
                                children: [

                                  ///プロフ背景写真　グラデ薄く＋中央に追加アイコン
                                  Container(
                                    width: imageWidth*0.7,
                                    padding: EdgeInsets.all(30),
                                    child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child:backgroundImageUrl.isEmpty
                                            ? const Text('画像を選択してください')
                                            : CachedNetworkImage(
                                          imageUrl: backgroundImageUrl,
                                          placeholder: (context, url) => const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) => SelectableText('画像の読み込みに失敗しました: $error'),
                                        )
                                      //child: Image.network(backgroundImageUrl, fit: BoxFit.cover),
                                    ),
                                  ),


                                  ///グラデーション係
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 200, // グラデーションの高さを調整
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent, Colors.white],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text('ここにテキスト', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ),

                                  ///編集ボタン係(後でやる：サイズを画面に合わせる)
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle, // 形状を円形に
                                        color: Colors.grey.shade100, // 背景色を好きな色に変更
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed:()async{
                                          uploadImage('backgroundImage');
                                          debugPrint('9');
                                        },
                                      ),
                                    ),

                                  ),
                                ],

                              ),

                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 100,vertical: 20),
                                child: Column(

                                  children: [
                                    Row(
                                      children: [

                                        //アイコンを設定　（グラデ薄く＋中央に追加アイコン）stackか？
                                        GestureDetector(
                                          //uploadImage();で画像をアップロードし、setStateでURLを設定
                                          onTap: ()async{
                                            uploadImage('iconImage');
                                          },

                                          child: CircleAvatar(
                                            radius: 50,
                                            backgroundImage:  CachedNetworkImageProvider(iconImageUrl),
                                          ),
                                        ),

                                        SizedBox(width: 20),

                                        //　idと名前をアイコンの横へ
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start, //  これを追加
                                          children: [
                                            ///id（フォント、サイズ、色の調整が必要）
                                            Row(
                                              children: [
                                                Icon(Icons.person),
                                                SizedBox(width: 8),
                                                SizedBox(
                                                  width: 300,
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      hintText: 'ユーザーidを入力してください',
                                                      labelText: userId,
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    controller: _userIdController,
                                                  ),
                                                )
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
                                                      labelText: userName,
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    controller: _userNameController,
                                                    /*onChanged: (value){
                                                        userName = value;
                                                    },*/
                                                  ),
                                                ),
                                              ],
                                            )

                                          ],
                                        )
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
                                              labelText: userBio,
                                              border: OutlineInputBorder(),
                                            ),
                                            controller: _userBioController,
                                            /*onChanged: (value){
                                                userBio = value;
                                            },*/
                                          ),
                                        ),
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
                                              labelText: userLink,
                                              border: OutlineInputBorder(),
                                            ),
                                            controller: _userLinkController,
                                            /*onChanged: (value){
                                                userLink = value;
                                            },*/
                                          ),
                                        )
                                      ],
                                    ),

                                  ],
                                ),
                              ),


                              Text(backgroundImageUrl),
                              Text(iconImageUrl),
                              Text(_userNameController.text),
                              Text(_userBioController.text),
                              Text(_userIdController.text),
                              Text(_userLinkController.text),


                              /*imageUrl.isEmpty
                                    ? const Text('画像を選択してください')
                                    : CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => SelectableText('画像の読み込みに失敗しました: $error'),
                                )*/

                              ///アルバム
                              ///時系列の投稿表示
                              ///ここは写真投稿が出来たら作ろう！
                            ],
                          ),
                        ),
                      )
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: setT,
              child: Icon(Icons.add_a_photo),
            ),
            bottomNavigationBar: BottomBar(),
          );
        },
      );
  }
}


