import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frame/ui_widgets/buttons/like_button_widget.dart';

//人気投稿のポストカード
class PopularPostCard extends StatelessWidget{

  final Map<String,dynamic> map;
  const PopularPostCard({super.key, required this.map});

  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(
            context, '/post_detail_page',
            arguments: map['postId']
        );},
      child: Container(
          padding: EdgeInsets.all(3),
          height: 200,
          width: 200,
          child:Card(
            color: Colors.black,
            child: Column(
              children: [
                //上に黒いバーをつける（アイコン、ユーザID）
                SizedBox(
                  height: 40,
                  child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc('${map['userUid']}')
                          .get() ,
                      builder: (context, snapshot){
                        if(snapshot.hasData){
                          final user = snapshot.data!.data() as Map<String, dynamic>;
                          return Row(
                            children: [
                              //アイコン追加
                              CircleAvatar(
                                radius: 15,
                                backgroundImage: CachedNetworkImageProvider(user['iconImage']),
                              ),
                              SizedBox(width: 10),
                              Text(user['userId'],style: TextStyle(color: CupertinoColors.systemGrey3),),
                            ],
                          );
                        }else{
                          return const Text('Unknown');
                        }
                      }),
                ),
                //投稿写真の1枚目
                //いいねボタン
                //全体をポストカードぽく枠線、角丸く正方形
                Expanded(
                  child: Stack(
                    children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: map['imageUrl'][0],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                        left: 5,
                        bottom: 5,
                        child: LikeButton(
                          postId: map['postId'],
                        )
                    )
                  ],),
                ),

              ],
            ),
          )
      ),
    );
  }
}