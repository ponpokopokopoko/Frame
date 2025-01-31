import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frame/home/tag_search/tag_search_top_page.dart';
import 'package:frame/ui_widgets/buttons/follow_button.dart';
import 'package:universal_html/html.dart';


//人気タグのカード
class PopularTagCard extends StatelessWidget{

  final Map<String,dynamic> map;//人気タグのMap

  const PopularTagCard({super.key,required this.map});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TagSerchTopPage(tagName:map['tagName'],),
          ),
        );},
      child: SizedBox(
          height: 200,
          width:200,
          child:  Card(//全体をポストカードぽく枠線、角丸く、正方形
            //背景灰黒
              //color: Colors.black,
              child: Column(
                children: [
                  //背景そのタグの人気写真

                  //中央タグ名でかめに
                  Text('#${map['tagName']}'),

                  //タグ件数
                  Text('${map['count']}',style: TextStyle(color: CupertinoColors.systemGrey3),),

                  //カードの背景をそのタグの人気投稿の写真にする
                  FutureBuilder(
                      future:  FirebaseFirestore.instance.collection('posts')
                          .where('tags', arrayContains: map['tagName']) // 特定のタグを持つ投稿を絞り込む
                          .orderBy('like', descending: true) // いいね数で降順に並び替える
                          .limit(1) // 最初のドキュメントを取得する
                          .get() ,
                      builder: (context, snapshot){
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }else if (snapshot.hasError) {
                          print('Error: ${snapshot.error}'); // エラー内容をログに出力
                          return Text('Error: ${snapshot.error}'); // エラーメッセージを表示
                        }else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          DocumentSnapshot topPostDoc = snapshot.data!.docs[0];
                          final tagPost = topPostDoc.data() as Map<String, dynamic>;
                          return SizedBox(
                            height: 100,
                            width: 150,
                            child: CachedNetworkImage(
                              imageUrl: tagPost['imageUrl'][0],
                              fit: BoxFit.cover,),
                          );
                        } else{
                          return Text('a');
                        }
                      }
                  ),

                ],

              )
          )),
    );
  }
}