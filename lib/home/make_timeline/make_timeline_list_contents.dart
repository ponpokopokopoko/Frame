import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frame/home/tag_search/tag_search_top_page.dart';
import 'package:frame/ui_widgets/buttons/bookmark_button_widget.dart';
import 'package:frame/ui_widgets/buttons/like_button_widget.dart';
import 'package:frame/ui_widgets/post_parts/image_swiper.dart';
import 'package:frame/ui_widgets/post_parts/post_date_widget.dart';
import 'package:frame/ui_widgets/post_parts/post_icon_image_widget.dart';

class MakeTimelineListContents extends StatefulWidget{
  final Map<String, dynamic> postUserData;
  final Map<String, dynamic> postData;


  const MakeTimelineListContents({super.key, required this.postUserData, required this.postData});
  @override
  State<MakeTimelineListContents> createState() => _MakeTimelineListContentsState();
}
class _MakeTimelineListContentsState extends State<MakeTimelineListContents>{

  @override
  Widget build(BuildContext conext){
    return LayoutBuilder(
        builder: (context, constraints) {
          // 画面の幅に応じて画像の幅を調整 (例)
          final imageWidth = constraints.maxWidth * 0.7; // 画面幅の50%
          //以下にUI
          return Card(
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
                                iconImage: widget.postUserData['iconImage'],
                                iconSize: 10,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/other_user_profile_page',
                                      arguments: widget.postUserData['uid']
                                  );
                                }
                            ),

                            SizedBox(width: 5,),
                            //名前（ｉｄ）
                            Text(widget.postUserData['userId'] ?? 'null'),

                            SizedBox(width: 5,),
                            //日付
                            PostDate(timestamp: widget.postData['createdAt'],
                              fontSize: 12,)
                          ],
                        ),
                        SizedBox(height: 5,),

                        Container(
                          width: imageWidth,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            //画像表示
                            child: ImageSwiper(
                              imageUrls: widget.postData['imageUrl'],
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
                                LikeButton(postId: widget.postData['postId']),
                                BookmarkButton(
                                    postId: widget.postData['postId'],),
                              ],),

                            Visibility(
                              visible: widget.postData['caption'] != '',
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(widget.postData['caption']),
                              ),
                            ),

                            Visibility(//型エラーが出る→childrenにText()を返していたのが型エラーになってた
                              visible:widget.postData['tags'] != null,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 8,
                                  children: (widget.postData['tags'] != null)
                                      ? (widget.postData['tags'] as List<dynamic>).map((tag) =>
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
                                ),
                              ),
                            )
                          ],
                        ),
                      ]
                  ))
          );
        });
  }

}