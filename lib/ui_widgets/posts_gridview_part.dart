import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frame/about_post_button.dart';
import 'package:frame/home/post_detail_page.dart';
import 'package:frame/navigation_rail.dart';

///クエリによって取得した投稿のSnapshotを受け取り、
///グリッドビュー表示＆タップで詳細表示に遷移するパーツ


class PostsGridviewPart extends StatelessWidget{
  const PostsGridviewPart({Key? key, required this.snapshot}) : super(key: key);
  final AsyncSnapshot<QuerySnapshot<Object?>> snapshot;

  @override
  Widget build(BuildContext context){

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, //１行に表示する数
            childAspectRatio: 1.0, // 正方形にする
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final DocumentSnapshot document = snapshot.data!.docs[index];
            
            List<dynamic> images = document.get('imageUrl') ?? [];
            if (images[0] != null) {
              return GestureDetector(
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder:
                          (context) => NavigationRailPart(widgetUI: PostDetailPage(postId: document.get('postId'),)))
                      );},
                    child: Stack(
                      children: [
                        Container(
                          constraints: BoxConstraints.expand(), // Container を最大限に広げる
                          child: Image.network(
                            images[0],
                            fit: BoxFit.cover,
                          ),
                        ),
                       // Image.network(images[0], fit: BoxFit.cover,),

                        Positioned(//いいねとその数字（インスタ参照）
                            child: AboutPostButton(
                                posterUid: document.get('userUid'),
                                postId: document.get('postId')
                            )
                        )

                ],),

              );
            } else {
              // imageUrlが文字列でない場合の処理 (エラー表示など)
              print('imageUrl is not a string:');
              return SizedBox.shrink();
            }
          },
        )
      ],
    );
  }
}

///Listで受ける用(いいねを表示するときに使う)
class PostsGridviewPartByList extends StatelessWidget{
  final List<Map<String,dynamic>> DataList;
  const PostsGridviewPartByList({Key? key, required this.DataList}) : super(key: key);

  @override
  Widget build(BuildContext context){

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, //１行に表示する数
            childAspectRatio: 1.0, // 正方形にする
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: DataList.length,
          itemBuilder: (context, index) {
            final Map<String,dynamic> data = DataList[index];

            List<dynamic> images = data['imageUrl'] ?? [];
            if (images[0] != null) {
              return GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder:
                          (context) => NavigationRailPart(widgetUI:PostDetailPage(postId: data['postId'],)))
                  );},
                child: Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints.expand(), // Container を最大限に広げる
                      child: Image.network(
                        images[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Image.network(images[0], fit: BoxFit.cover,),

                    Positioned(//いいねとその数字（インスタ参照）
                        child: AboutPostButton(
                            posterUid: data['userUid'],
                            postId: data['postId']
                        )
                    )

                  ],),

              );
            } else {
              // imageUrlが文字列でない場合の処理 (エラー表示など)
              print('imageUrl is not a string:');
              return SizedBox.shrink();
            }
          },
        )
      ],
    );
  }
}