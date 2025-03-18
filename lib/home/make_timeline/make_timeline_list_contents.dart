import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frame/about_post_button.dart';
import 'package:frame/home/make_timeline/make_timeline_list.dart';
import 'package:frame/home/other_user_profile_page.dart';
import 'package:frame/home/tag_search/tag_search_top_page.dart';
import 'package:frame/navigation_rail.dart';
import 'package:frame/realtime_count.dart';
import 'package:frame/ui_widgets/buttons/bookmark_button_widget.dart';
import 'package:frame/ui_widgets/buttons/like_button_widget.dart';
import 'package:frame/ui_widgets/post_parts/post_date_widget.dart';
import 'package:frame/ui_widgets/post_parts/post_icon_image_widget.dart';

//タイムラインの投稿のリスト部分の表示を担当
class MakeTimelineListContents extends StatelessWidget{
  //final Map<String, dynamic> postUserData;//投稿者のユーザーデータ
  //final Map<String, dynamic> postData;//投稿のデータ
  /*final List<Map<String, dynamic>> postList; // 投稿リストのデータを受け取る
  final List<Map<String, dynamic>> postUserList; */

  final timelinePost post;//投稿情報が入ったtimelinePost型の引数を受け取る

  const MakeTimelineListContents({super.key,required this.post/* required this.postUserList, required this.postList*/});

  @override
  Widget build(BuildContext context){

    final imageWidth = MediaQuery.of(context).size.width * 0.7; // 例として画面幅の70%を画像幅とする

    return  Card(
      //color: Colors.white,
        child: Container(
           padding: const EdgeInsets.all(5),
            width: imageWidth,//このwidth効いてない？,
            color: Colors.black54,
            child: Column(
                children: [
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //アイコン
                      //初期アイコン準備
                      PostIconImage(
                          iconImage: post.iconUrl,
                          iconSize: 20,
                          onTap: () {
                            Navigator.push(
                                context,MaterialPageRoute(
                                builder:(context) => NavigationRailPart(widgetUI:
                                  OtherUserProfilePage(postUid: post.userUid)))
                            );
                          }
                      ),

                      const SizedBox(width: 5,),
                      //名前（ｉｄ）
                      Text(post.userId,style: const TextStyle(fontSize: 16),),

                      const SizedBox(width: 5,),
                      //日付
                      PostDate(timestamp: post.createdAt,
                        fontSize: 12,)
                    ],
                  ),

                  const SizedBox(height: 5),

                  SizedBox(
                    width: 400,
                    //本当はイメージスワイパーにする
                    child: Column(
                      children: [
                        //投稿画像
                        ClipRRect(//角丸くする奴
                          borderRadius: BorderRadius.circular(10.0), // 角の丸みを調整
                          child:CachedNetworkImage(
                            imageUrl: post.imageUrl[0],
                            fit: BoxFit.fitWidth, // コンテナを覆うように拡大・縮小
                            alignment: Alignment.center, // 画像の中心を基準にトリミング
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          children: [
                            const Spacer(),
                            //いいね
                            RepaintBoundary(
                              child: LikeButton(postId: post.postId),),
                            RealtimeLikeCount(postId: post.postId),

                            //ブクマ
                            const SizedBox(width: 5,),
                            BookmarkButton(postId: post.postId,),
                            RealtimeBookmarkCount(postId: post.postId),

                            const SizedBox(width: 5),
                            //・・・ボタン
                            AboutPostButton(
                                posterUid: post.userUid,
                                postId: post.postId
                            )
                          ],
                        ),

                      ],)
                  ),

                  const SizedBox(height: 8),

                  Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //いいね,ブクマ


                      //キャプション
                      (post.caption != '')
                          ?Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(post.caption))
                          :const SizedBox.shrink(),

                      //タグ
                      (post.tags != [])
                          ? Wrap(
                          spacing: 8,
                          children: (post.tags).map((tag) =>
                              InkWell( // タップ可能にする
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>
                                        NavigationRailPart(widgetUI: TagSerchTopPage(tagName: tag))
                                    )
                                  );
                                },
                                child: Chip(
                                  backgroundColor: Colors.white,
                                    label: Text('#$tag')),
                              )).toList())
                          :const SizedBox.shrink()
                    ],
                  ),
                ]
            )
        )
    );
  }
}