import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frame/about_post_button.dart';
import 'package:frame/ui_widgets/buttons/bookmark_button_widget.dart';
import 'package:frame/ui_widgets/buttons/like_button_widget.dart';
import 'package:frame/ui_widgets/post_parts/post_date_widget.dart';
import 'package:frame/ui_widgets/post_parts/post_icon_image_widget.dart';

class MakeTimelineListContents extends StatelessWidget{
  final Map<String, dynamic> postUserData;
  final Map<String, dynamic> postData;

  const MakeTimelineListContents({super.key, required this.postUserData, required this.postData,});

  @override
  Widget build(BuildContext conext){
    return LayoutBuilder(
          builder: (context, constraints) {
            // 画面の幅に応じて画像の幅を調整 (例)
            final imageWidth = constraints.maxWidth * 0.5; // 画面幅の50%
            //以下にUI
            return Card(
                //key: UniqueKey(),
                child: Container(
                  width: imageWidth,//このwidth効いてない？
                    height: 700,
                    color: Colors.black26,
                    child: Column(
                        //mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //アイコン
                              //初期アイコン準備
                              PostIconImage(
                                  iconImage:postUserData['iconImage'],
                                  iconSize: 15,
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/other_user_profile_page',
                                        arguments: postUserData['uid']
                                    );
                                  }
                              ),

                              const SizedBox(width: 5,),
                              //名前（ｉｄ）
                              Text(postUserData['userId'] ?? 'null'),

                              const SizedBox(width: 5,),
                              //日付
                              PostDate(timestamp: postData['createdAt'],
                                fontSize: 12,)
                            ],
                          ),
                          const SizedBox(height: 5,),

                         SizedBox(
                            width: 500,
                            height: 500,
                              //本当はイメージスワイパーにする
                              child: CachedNetworkImage(
                                imageUrl: postData['imageUrl'][0],
                                fit: BoxFit.cover, // コンテナを覆うように拡大・縮小
                                alignment: Alignment.center,  // 画像の中心を基準にトリミング
                              ),
                            ),

                         Column(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              //いいね
                              SizedBox(
                                height: 55,
                                child:RepaintBoundary(

                                  child:  Row(
                                  children: [
                                    RepaintBoundary(
                                      child: LikeButton(postId: postData['postId']),
                                    ),

                                    //リアルタイムの数値を反映するようにする
                                    Text(postData['like'].toString(),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),),
                                    BookmarkButton(postId: postData['postId'],),
                                    Text(postData['bookmark'].toString(),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),),
                                    AboutPostButton(
                                        posterUid: postUserData['uid'],
                                        postId: postData['postId']
                                    )
                                  ],),
                                )
                              ),

                              /*(postData['caption'] != '')
                                  ?Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(postData['caption']),
                                  )
                                  :SizedBox.shrink(),

                              (postData['tags'] != null)
                                ? Wrap(
                                spacing: 8,
                                children: (postData['tags'] != null)
                                    ? (postData['tags'] as List<dynamic>).map((tag) =>
                                    InkWell( // タップ可能にする
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => TagSerchTopPage(tagName: tag)),
                                        );
                                      },
                                      child: Chip(label: Text('#$tag')),
                                    ))
                                    .toList()
                                    : <Widget>[], // 空のリストを渡す,
                              )
                              :const SizedBox.shrink()*/

                            ],
                          ),
                        ]
                    ))
            );
          }
        );
  }

}