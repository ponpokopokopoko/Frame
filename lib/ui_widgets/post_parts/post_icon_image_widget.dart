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
      child: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(iconImage),
        radius: iconSize, // アイコンの半径
      ),
    );
  }
}