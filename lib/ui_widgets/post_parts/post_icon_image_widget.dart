//投稿に付属するアイコンのクラス()指定：画像URL、半径
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostIconImage extends StatelessWidget {
  final String iconImage;
  final double iconSize;
  final VoidCallback onTap; // アイコンがタップされた時のコールバック関数

  const PostIconImage({
    Key? key,
    required this.iconImage,
    required this.iconSize,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:  onTap,
        child: iconImage != ''
        //アイコン画像を設定済の場合
          ? CircleAvatar(
             radius: iconSize, // アイコンの半径
             backgroundImage: CachedNetworkImageProvider(iconImage),
           )
          //設定してない場合→初期アイコン
          :CircleAvatar(
             radius: iconSize, // アイコンの半径
              child: Icon(Icons.person), // 初期アイコン,
           )
    );
  }
}