import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frame/home/other_user_profile_page.dart';
import 'package:frame/navigation_rail.dart';
import 'package:frame/ui_widgets/buttons/follow_button.dart';


//人気ユーザーのカード
class PopularUserCard extends StatelessWidget{

 final Map<String,dynamic> map;//人気ユーザーのMap

  const PopularUserCard({super.key,required this.map});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context, MaterialPageRoute(
            builder: (context) =>
                NavigationRailPart(widgetUI:OtherUserProfilePage(postUid: map['uid']))
          )
        );},
      child: Container(
          height: 200,
          width:200,
          child:  Card(//全体をポストカードぽく枠線、角丸く、正方形
            //背景灰黒
              color: Colors.black,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey, width: 1), // 枠線の色と太さ
                borderRadius: BorderRadius.circular(10), // 角の丸み
              ),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  //中央アイコンでかめに
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(map['iconImage']),
                    radius: 60,
                  ),
                  const SizedBox(height: 5),

                  Text(map['userId'],style: TextStyle(color: CupertinoColors.systemGrey3),),

                  const SizedBox(height: 5),
                  //フォローボタン
                  (map['uid'] != FirebaseAuth.instance.currentUser?.uid )
                      ?FollowButton(followedId: map['uid'])
                      :SizedBox.shrink(),

                  //下にセット投稿３枚添える
                  /* Row(
                children: [
                  CachedNetworkImage(imageUrl: imageUrl)
                ],
              )*/
                ],

              )
          )),
    );
  }
}