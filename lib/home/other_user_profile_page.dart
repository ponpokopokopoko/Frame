import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frame/follower_view_part.dart';
import 'package:frame/home/my_account/my_account_top.dart';
import 'package:frame/like_bookmark_view.dart';
import 'package:frame/navigation_rail.dart';
//import 'package:frame/ui_widgets/main_page.dart';
import 'package:frame/ui_widgets/buttons/follow_button.dart';
import 'package:frame/ui_widgets/post_parts/post_icon_image_widget.dart';
import 'package:frame/ui_widgets/posts_gridview_part.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String postUid;
  const OtherUserProfilePage({super.key, required this.postUid});
  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}
class _OtherUserProfilePageState extends State<OtherUserProfilePage>{
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';


  @override
  Widget build(BuildContext context) {

      if(widget.postUid == currentUid){
        return MyAccountTopPage();
      }else{
        return Column(
            children: [
              Text('ユーザープロフィール',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22
                ),),
              Divider(
                color: Colors.grey,
                thickness: 4,
              ),
              Expanded(
                child: SingleChildScrollView(
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('uid', isEqualTo: widget.postUid)
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
                                                  FollowerViewPart(uid:widget.postUid),
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
                                              Icon(Icons.person,color: Colors.grey,),
                                              SizedBox(width: 8),
                                              Text('userId：',
                                                  style:TextStyle(color: Colors.grey) ),
                                              Text(userData['userId']),
                                            ],
                                          ),
                                          ///名前（フォント、サイズ、色の調整が必要）
                                          Row(
                                            children: [
                                              Icon(Icons.person,color: Colors.grey,),
                                              SizedBox(width: 8),
                                              Text('Name：',
                                                  style:TextStyle(color: Colors.grey) ),
                                              Text(userData['userName']),
                                            ],
                                          ),

                                          ///bio　（フォント、サイズ、色の調整,複数行にできる必要）
                                          Row(
                                            children: [
                                              Icon(Icons.info,color: Colors.grey,),
                                              SizedBox(width: 8),
                                              Text('Bio：',
                                                  style:TextStyle(color: Colors.grey) ),
                                              Text(userData['userBio']),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.link,color: Colors.grey,),
                                              SizedBox(width: 8),
                                              Text('link：',
                                                  style:TextStyle(color: Colors.grey) ),
                                              Text(userData['userLink']),
                                            ],
                                          ),
                                          //いいね
                                          GestureDetector(
                                              child: Row(
                                                children: [
                                                  Icon(Icons.favorite_border_outlined,color: Colors.grey,),
                                                  SizedBox(width: 10,),
                                                  Text('いいねした投稿',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17
                                                    ),),
                                                ],
                                              ),
                                              onTap: (){
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (context){
                                                      return NavigationRailPart(
                                                          widgetUI:LikeBookmarkView(
                                                            uid: userData['uid'],
                                                            select: 'like',
                                                          ));
                                                    })
                                                );}
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
                                .where('userUid', isEqualTo: widget.postUid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('エラーが発生しました');
                              }

                              if (snapshot.data!.docs.isEmpty || snapshot.data?.docs == null) {
                                return Text('投稿がありません');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if(snapshot.data!.docs.isNotEmpty && snapshot.data?.docs != null){
                                return PostsGridviewPart(snapshot: snapshot);
                              }
                              else{
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
              )]
        );
      }
  }
}
