import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frame/follower_view_part.dart';
import 'package:frame/home/my_account/my_account_profile_edit.dart';
import 'package:frame/like_bookmark_view.dart';
import 'package:frame/navigation_rail.dart';
//import 'package:frame/ui_widgets/main_page.dart';
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
  String backgroundImageUrl = '';
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

  @override
  Widget build(BuildContext build) {

    final user = FirebaseAuth.instance.currentUser;
    //debugPrint(user?.uid);

    return Column(
        children: [
          Text('マイページ',
            style: TextStyle(
                fontSize: 22,
                color: Colors.white
            ),
          ),
          const Divider(
            color: Colors.grey, // 線の色
            thickness: 4.0, // 線の太さ
          ),

          Expanded(
              child: FutureBuilder<DocumentSnapshot?>(
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
                    userId = userData['userId'] ?? '';
                    userName = userData['userName'] ?? '';
                    userBio = userData['userBio'] ?? '';
                    userLink = userData['userLink'] ?? '';


                    return SingleChildScrollView(
                        child:Container(
                          //color: Colors.white70,
                          //width:  constraints.maxWidth * 0.7 // 画面幅の50%
                            child:Column(

                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ///アセット内のローカルな写真を設定、トップ写真＆スワイプで固定写真表示
                                ///ここは写真投稿が出来たら作ろう！
                                /*Stack(
                                        children: [*/
                                //背景画像
                                Container(
                                  height: 150,
                                  //width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: (backgroundImageUrl != '')//三項演算子を使う
                                        //背景画像を設定してる場合
                                            ?NetworkImage(backgroundImageUrl)
                                        //設定してない場合
                                            :AssetImage('assets/images/S__207101993.jpg'), // 初期画像
                                        fit: BoxFit.cover
                                    ),
                                  ),
                                ) ,


                                ///グラデーション係
                                /*Positioned(
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
                                      ),*/

                                //プロフィール係(後でやる：サイズを画面に合わせる)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, //  これを追加
                                    children: [
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              (iconImageUrl != '')
                                              //アイコン画像を設定済の場合
                                                  ? CircleAvatar(
                                                radius: 50,
                                                backgroundImage: NetworkImage(iconImageUrl),
                                              )
                                              //設定してない場合→初期アイコン
                                                  :CircleAvatar(
                                                radius: 50,
                                                child: Icon(Icons.person), // 初期アイコン,
                                              ),
                                              FollowerViewPart(uid:user!.uid),
                                            ],
                                          ),
                                          Spacer(), // 空きスペースを埋める
                                          IconButton(
                                            icon: const Icon(Icons.mode_edit_outline_outlined,color: Colors.white,),
                                            onPressed: () {

                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>NavigationRailPart(widgetUI: MyAccountProfileEdit(
                                                          iconImageUrl: iconImageUrl,
                                                          backgroundImageUrl: backgroundImageUrl,
                                                          userId: userId,
                                                          userName: userName,
                                                          userBio: userBio,
                                                          userLink: userLink
                                                      )))
                                              );
                                            },
                                          ),
                                          // 右端に配置したいウィジェット
                                        ],
                                      ),

                                      SizedBox(height: 16),

                                      /// アイコンと情報
                                      ///id（フォント、サイズ、色の調整が必要）
                                      Row(
                                        children: [
                                          Icon(Icons.person, color:Colors.grey ,),
                                          SizedBox(width: 8),
                                          Text('userId：',
                                              style:TextStyle(color: Colors.grey) ),
                                          Text(userId,
                                              style:TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17
                                              ) ),
                                        ],
                                      ),
                                      ///名前（フォント、サイズ、色の調整が必要）
                                      Row(
                                        children: [
                                          Icon(Icons.camera, color:Colors.grey),
                                          SizedBox(width: 8),
                                          Text('Name：',
                                              style:TextStyle(color: Colors.grey) ),
                                          Text(userName,
                                              style:TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17
                                              ) ),

                                        ],
                                      ),

                                      ///bio　（フォント、サイズ、色の調整,複数行にできる必要）
                                      Row(
                                        children: [
                                          Icon(Icons.info, color:Colors.grey),
                                          SizedBox(width: 8),
                                          Text('Bio：',
                                              style:TextStyle(color: Colors.grey) ),
                                          Text(userBio,
                                              style:TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17
                                              ) ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.link, color:Colors.grey),
                                          SizedBox(width: 8),
                                          Text('Link：',
                                              style:TextStyle(color: Colors.grey) ),
                                          Text(userLink,
                                              style:TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17
                                              ) ),
                                        ],
                                      ),
                                      //いいね
                                      GestureDetector(
                                        child: Row(
                                          children: [
                                            Icon(Icons.favorite_border_outlined,color:Colors.grey),
                                            SizedBox(width: 10,),
                                            Text('いいねした投稿',
                                              style:TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17
                                              ) ,),
                                          ],                                  ),
                                          onTap: (){
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) =>
                                                    NavigationRailPart(widgetUI: LikeBookmarkView(uid: user.uid, select: 'like',)
                                                ))
                                            );
                                          })
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: 50,

                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, // 形状を円形に
                                    color: Colors.grey.shade100, // 背景色を好きな色に変更
                                  ),

                                ),
                                //),
                                ///自分の投稿をグリッドビューする
                                FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('posts')
                                      .where('userUid', isEqualTo: user.uid)
                                      .get(),
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
                            )
                        )
                    );
                  } else {
                    return Text('データがありません');
                  }
                },
              )),

        ]);
  }
}