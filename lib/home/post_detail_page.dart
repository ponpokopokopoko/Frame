import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frame/ui_widgets/buttons/bookmark_button_widget.dart';
import 'package:frame/ui_widgets/buttons/like_button_widget.dart';
import 'package:frame/ui_widgets/post_parts/image_swiper.dart';
import 'package:frame/ui_widgets/post_parts/post_date_widget.dart';
import 'package:frame/ui_widgets/post_parts/post_icon_image_widget.dart';



class PostDetailPage extends StatefulWidget{
  //final String postId;

  const PostDetailPage({super.key});
  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage>{


  @override
  Widget build(BuildContext context){
    final Object? postId = ModalRoute
        .of(context)
        ?.settings
        .arguments;


//future入れ子を採用

    //エラー、if文の分岐を用意しないとロード中とかデータないとか
  if(postId is String){
    return  FutureBuilder(
      future: FirebaseFirestore.instance.collection('posts').where('postId',isEqualTo: postId).get(),
      builder: (context,snapshot){
        final DocumentSnapshot docment = snapshot.data!.docs[0];
        final post = docment.data() as Map<String,dynamic>;

        return FutureBuilder(
            future: FirebaseFirestore.instance.collection('users').doc(post['userUid']).get(),
            builder: (context,snapshot){
              final user = snapshot.data!.data() as Map<String,dynamic>;
              return Scaffold(

                body: Card(
                    key: UniqueKey(),
                    child: Container(
                        child: Column(
                            children: [
                              const SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //アイコン
                                  PostIconImage(
                                      iconImage: user['iconImage'],
                                      iconSize: 10,
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/other_user_profile_page',
                                            arguments: user['uid']
                                        );
                                      }
                                  ),

                                  SizedBox(width: 5,),
                                  //名前（ｉｄ）
                                  Text(user['userId'] ?? 'null'),

                                  SizedBox(width: 5,),
                                  //日付
                                  PostDate(timestamp: post['createdAt'],
                                    fontSize: 12,)
                                ],
                              ),
                              SizedBox(height: 5,),

                              Container(
                                width: 500,
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  //画像表示
                                  child: ImageSwiper(
                                    imageUrls: post['imageUrl'],
                                    //fit: BoxFit.contain, // 画像のアスペクト比を維持して、コンテナ内に収める
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  //いいね
                                  Row(
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
                                            ? (post['tags'] as List<dynamic>).map((tag) => Chip(label: Text('#$tag')))
                                            .toList()
                                            : <Widget>[],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ]
                        ))
                ),
              );
            });

      },
    );

  }else{
    return Text('投稿者の情報が取得できませんでした');
  }
  }
}