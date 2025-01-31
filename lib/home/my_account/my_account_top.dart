import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frame/ui_widgets/bottom_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frame/ui_widgets/posts_gridview_part.dart';
import 'package:universal_html/html.dart';



class MyAccountTopPage extends StatefulWidget {
  const MyAccountTopPage({super.key});

  @override
  State<MyAccountTopPage> createState() => _MyAccountTopPageState();
}

class _MyAccountTopPageState extends State<MyAccountTopPage> {

  //画面に表示される者たち（一旦の書き換えする場合ここが変わり、最後にこれを登録する）
  Map<String, dynamic> userData = {};
  String iconImageUrl = '';
  String backgroundImageUrl = '' ;
  String userId = '';
  String userName = '';
  String userBio = '';
  String userLink ='';

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

    } else {
      return null;
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
  Widget build(BuildContext build) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 画面の幅に応じて画像の幅を調整 (例)
        final imageWidth = constraints.maxWidth * 0.7; // 画面幅の50%
        return Scaffold(
                  body: FutureBuilder<DocumentSnapshot?>(
                    future: getUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        userData  = snapshot.data?.data()! as Map<String, dynamic>;
                        backgroundImageUrl = userData['backgroundImage'] ?? '';
                        iconImageUrl = userData['iconImage'] ?? '';
                        userId = userData['userId'] ?? 'ユーザーIDが見つかりません';
                        userName = userData['userName'] ?? 'ユーザー名が未設定です';
                        userBio = userData['userBio'] ?? 'Bioが未設定です';
                        userLink = userData['userLink'] ?? 'リンクが未設定です';

                        return SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child:Column(

                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ///アセット内のローカルな写真を設定、トップ写真＆スワイプで固定写真表示
                                  ///ここは写真投稿が出来たら作ろう！

                                  Stack(
                                    children: [
                                      //背景画像
                                      Container(
                                        width: imageWidth,
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: Image.network(backgroundImageUrl, fit: BoxFit.cover),
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

                                      //プロフィール係(後でやる：サイズを画面に合わせる)
                                      Positioned(
                                          bottom: 0,
                                          left: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child:Column(
                                              crossAxisAlignment: CrossAxisAlignment.start, //  これを追加
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 50,
                                                      backgroundImage: NetworkImage(iconImageUrl),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(height: 16),

                                                /// アイコンと情報
                                                ///id（フォント、サイズ、色の調整が必要）
                                                Row(
                                                  children: [
                                                    Icon(Icons.person),
                                                    SizedBox(width: 8),
                                                    Text(userId),
                                                  ],
                                                ),
                                                ///名前（フォント、サイズ、色の調整が必要）
                                                Row(
                                                  children: [
                                                    Icon(Icons.person),
                                                    SizedBox(width: 8),
                                                    Text(userName),
                                                  ],
                                                ),

                                                ///bio　（フォント、サイズ、色の調整,複数行にできる必要）
                                                Row(
                                                  children: [
                                                    Icon(Icons.info),
                                                    SizedBox(width: 8),
                                                    Text(userBio),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(Icons.person),
                                                    SizedBox(width: 8),
                                                    Text(userLink),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
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
                                            onPressed: () async{
                                              if (userData != null) {
                                                Navigator.pushNamed(context, '/my_account_profile_edit', arguments: userData);
                                              } else {
                                                // emailがnullの場合の処理 (例: エラーメッセージを表示)
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('ユーザー情報がありません'),
                                                    )
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),

                                  ///自分の投稿をグリッドビューする
                                  /*Container(
                                    child: PostsGridviewPart(snapshot: snapshot),
                                  ),*/
                                ],
                              ),
                            )
                        );
                      } else {
                        return Text('データがありません');
                      }
                    },
                  ),
          bottomNavigationBar: BottomBar(),
              );
        },
    );
  }
}



