import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frame/follower_view_part.dart';
import 'package:frame/home/my_account/my_account_top.dart';
import 'package:frame/ui_widgets/bottom_bar.dart';
import 'package:frame/ui_widgets/buttons/follow_button.dart';
import 'package:frame/ui_widgets/post_parts/post_icon_image_widget.dart';
import 'package:frame/ui_widgets/posts_gridview_part.dart';

class OtherUserProfilePage extends StatefulWidget {
  const OtherUserProfilePage({super.key});
  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}
class _OtherUserProfilePageState extends State<OtherUserProfilePage>{
  late String currentUid;

  @override
  void initState() {
    super.initState();
    // ログイン状態の監視
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        setState(() { currentUid = '未登録';});
      } else {
        setState(() { currentUid = user.uid;});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final postUid = ModalRoute
        .of(context)
        ?.settings
        .arguments;

    if (postUid is String) {
      if(postUid == currentUid){
        return MyAccountTopPage();
      }else{
      return Scaffold(
        appBar: AppBar(title: Text('ユーザープロフィール')),
        body: SingleChildScrollView(
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .where('uid', isEqualTo: postUid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('エラーが発生しました');
              }

              if (snapshot.data!.docs.isNotEmpty) {
                final DocumentSnapshot document = snapshot.data!
                    .docs[0];
                Map<String, dynamic> userData = document.data()! as Map<String, dynamic>;

                return Column(
                  children: [
                    ///ユーザーのプロフィール
                    Container(
                        child:Column(
                            children: [
                              //背景画像
                              //背景画像
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: (userData['backgroundImage'] != '')//三項演算子を使う
                                      //背景画像を設定してる場合
                                          ?NetworkImage(userData['backgroundImage'])
                                      //設定してない場合
                                          :AssetImage('assets/images/S__207101993.jpg'), // 初期画像
                                      fit: BoxFit.cover
                                  ),
                                ),
                              ),
                              /*Container(
                                height: 150,//constraints.maxHeight * 0.2,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Image.network(userData['backgroundImage'] ?? '' ),
                                ),
                              ),*/

                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child:Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, //  これを追加
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            (userData['iconImage'] != '')
                                            //アイコン画像を設定済の場合
                                                ? CircleAvatar(
                                              radius: 50,
                                              backgroundImage: NetworkImage(userData['iconImage']),
                                            )
                                            //設定してない場合→初期アイコン
                                                :CircleAvatar(
                                              radius: 50,
                                              child: Icon(Icons.person), // 初期アイコン,
                                            ),
                                            FollowerViewPart(uid:postUid),
                                          ],
                                        ),

                                        Spacer(), // 空きスペースを埋める
                                        FollowButton(followedId: userData['uid'] as String),
                                        // 右端に配置したいウィジェット
                                      ],
                                    ),

                                    SizedBox(height: 16),

                                    /// アイコンと情報
                                    ///id（フォント、サイズ、色の調整が必要）
                                    Row(
                                      children: [
                                        Icon(Icons.person),
                                        SizedBox(width: 8),
                                        Text(userData['userId']),
                                      ],
                                    ),
                                    ///名前（フォント、サイズ、色の調整が必要）
                                    Row(
                                      children: [
                                        Icon(Icons.person),
                                        SizedBox(width: 8),
                                        Text(userData['userName']),
                                      ],
                                    ),

                                    ///bio　（フォント、サイズ、色の調整,複数行にできる必要）
                                    Row(
                                      children: [
                                        Icon(Icons.info),
                                        SizedBox(width: 8),
                                        Text(userData['userBio']),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.person),
                                        SizedBox(width: 8),
                                        Text(userData['userLink']),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        )
                    ),

                    ///ここで分ける
                    // 投稿一覧
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('userUid', isEqualTo: postUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          debugPrint('1');
                          return Text('エラーが発生しました');

                        }

                        if (snapshot.data!.docs.isEmpty || snapshot.data?.docs == null) {
                          return Text('投稿がありません');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          debugPrint('3');
                          return CircularProgressIndicator();
                        }
                        if(snapshot.data!.docs.isNotEmpty && snapshot.data?.docs != null){
                          debugPrint('46');
                          return PostsGridviewPart(snapshot: snapshot);
                        }
                        else{
                          debugPrint('6');
                          return Text('Error');
                        }

                      },
                    ),
                  ],
                );
              } else {
                return Text('ユーザーが見つかりません');
              }
            },
          ),
        ),
        bottomNavigationBar: BottomBar(),
      );
      }
    } else {
      return Text('投稿者の情報が取得できませんでした');
    }
  }
}
