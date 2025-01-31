import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      return Scaffold(
        appBar: AppBar(title: Text('ユーザープロフィール')),
        body: FutureBuilder<QuerySnapshot>(
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

              return LayoutBuilder(
                  builder: (context, constraints) {
                    // 画面の幅に応じて画像の幅を調整 (例)
                    //final imageWidth = constraints.maxWidth * 0.7; // 画面幅の50%
                    return Column(
                      children: [
                        ///ユーザーのプロフィール
                        Container(
                          child:Column(
                            children: [
                              //背景画像
                              Container(
                                height: constraints.maxHeight * 0.2,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Image.network(userData['backgroundImage'] ?? '' ),
                                ),
                              ),

                              SizedBox(height: 5),

                              //アイコン
                              PostIconImage(
                                  iconImage: userData['iconImage'],
                                  iconSize: 30,
                                  onTap: () {
                                    Text('a');
                                  }
                                  ),
                              SizedBox(height: 5),
                              //名前
                              Text(userData['userName'] ?? 'a'),
                              SizedBox(height: 5),
                              //Bio
                              Visibility(
                                  visible: userData['userBio'] != '',
                                  child: Column(children: [
                                    Text(userData['userBio']),
                                    SizedBox(height: 5),
                                  ],)
                              ),
                              //link
                              Visibility(
                                visible: userData['userLink'] != '',
                                  child: Column(children: [
                                    Text(userData['userLink']??'a'),
                                    SizedBox(height: 5),
                                  ],)
                              ),
                             FollowButtom(followedId: userData['uid'] as String),
                            ]
                          )
                        ),

                        ///ここで分ける
                        // 投稿一覧
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .where('userUid', isEqualTo: postUid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                debugPrint('1');
                                return Text('エラーが発生しました');

                              }

                              if (snapshot.data!.docs.isEmpty || snapshot.data!.docs == null) {
                                return Text('投稿がありません');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                debugPrint('3');
                                return CircularProgressIndicator();
                              }
                              if(snapshot.data!.docs.isNotEmpty && snapshot.data!.docs != null){
                                debugPrint('46');
                                return PostsGridviewPart(snapshot: snapshot);
                              }
                              else{
                                debugPrint('6');
                                return Text('Error');
                              }

                            },
                          ),
                        ),
                      ],
                    );
                  });



            } else {
              return Text('ユーザーが見つかりません');
            }
          },
        ),
        bottomNavigationBar: BottomBar(),
      );
    } else {
      return Text('投稿者の情報が取得できませんでした');
    }
  }
}
