import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frame/home/other_user_profile_page.dart';
import 'package:frame/navigation_rail.dart';
import 'package:frame/ui_widgets/buttons/bookmark_button_widget.dart';
import 'package:frame/ui_widgets/buttons/like_button_widget.dart';
import 'package:frame/ui_widgets/post_parts/image_swiper.dart';
import 'package:frame/ui_widgets/post_parts/post_date_widget.dart';
import 'package:frame/ui_widgets/post_parts/post_icon_image_widget.dart';
//import 'package:frame/ui_widgets/main_page.dart';



class PostDetailPage extends StatefulWidget{
  final  postId;

  const PostDetailPage({super.key, this.postId});
  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage>{



//future入れ子を採用
Widget build (BuildContext context) {
  //エラー、if文の分岐を用意しないとロード中とかデータないとか
  return FutureBuilder(
    future: FirebaseFirestore.instance.collection('posts').where(
        'postId', isEqualTo: widget.postId).get(),
    builder: (context, snapshot) {
      final DocumentSnapshot docment = snapshot.data!.docs[0];
      final post = docment.data() as Map<String, dynamic>;

      return FutureBuilder(
          future: FirebaseFirestore.instance.collection('users').doc(
              post['userUid']).get(),
          builder: (context, snapshot) {
            final user = snapshot.data!.data() as Map<String, dynamic>;
            return Container(
              height: MediaQuery.of(context).size.height,
                color: Colors.white38,
              child: SingleChildScrollView(
                    child: Column(
                        children: [
                          const SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //アイコン
                              PostIconImage(
                                  iconImage: user['iconImage'],
                                  iconSize: 18,
                                  onTap: () {
                                    Navigator.push(
                                      context,MaterialPageRoute(
                                        builder:(context) => NavigationRailPart(widgetUI:
                                    OtherUserProfilePage(postUid: user['uid']) )) ,
                                    );
                                  }
                              ),

                              SizedBox(width: 5,),
                              //名前（ｉｄ）
                              Text(user['userId'] ?? 'null',
                                style:TextStyle(
                                  fontSize: 16,
                                  color: Colors.black
                                ) ,),

                              SizedBox(width: 5,),
                              //日付
                              PostDate(timestamp: post['createdAt'],
                                fontSize: 12,)
                            ],
                          ),
                          SizedBox(height: 5,),

                          Container(
                            width: 400,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: 1 / 1,
                                //画像表示
                                child: ImageSwiper(
                                  imageUrls: post['imageUrl'],
                                  //fit: BoxFit.contain, // 画像のアスペクト比を維持して、コンテナ内に収める
                                ),
                              ),
                              //いいね
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  LikeButton(postId: post['postId']),
                                  BookmarkButton(
                                    postId: post['postId'],),
                                ],),

                              Visibility(
                                visible: post['caption'] != '',
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(post['caption']),
                                ),
                              ),

                              ///Firestoreから取得したMap型のフィールドの値を無理やりStringにしない！
                              ///dynamicのまま使うと上手くい
                              Visibility( //型エラー持ち
                                visible: post['tags'] != null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Wrap(
                                    spacing: 8,
                                    children: post['tags'] != null
                                        ? (post['tags'] as List<dynamic>).map((
                                        tag) => Chip(label: Text('#$tag')))
                                        .toList()
                                        : <Widget>[],
                                  ),
                                ),
                              )
                            ]
                            )
                          )
                        ]
                    )
            ));
          });
    },
  );
}
}