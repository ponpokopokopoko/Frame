import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frame/ui_widgets/buttons/follow_button.dart';


//人気ユーザーのカード
class PopularUserCard extends StatelessWidget{

 final Map<String,dynamic> map;//人気ユーザーのMap

  const PopularUserCard({super.key,required this.map});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(
          context, '/other_user_profile_page',
          arguments: map['uid']
        );},
      child: SizedBox(
          height: 200,
          width:200,
          child:  Card(//全体をポストカードぽく枠線、角丸く、正方形
            //背景灰黒
              color: Colors.black,
              child: Column(
                children: [
                  //中央アイコンでかめに
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(map['iconImage']),
                    radius: 60,
                  ),

                  Text(map['userId'],style: TextStyle(color: CupertinoColors.systemGrey3),),

                  //フォローボタン
                  FollowButton(followedId: map['uid']),

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