import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///日付表示のクラス()指定：投稿日時、サイズ
class PostDate extends StatelessWidget{
  final Timestamp timestamp;
  final double fontSize;

  const PostDate({
    Key? key,
    required this.timestamp,
    required this.fontSize,
  }) : super(key: key);

  //日付を返す関数
  String formattedDate() {
    final DateTime dateTime = timestamp.toDate();//保存されたタイムスタンプを型変換
    final difference = DateTime.now().difference(dateTime);//今の時間との差を取得

    if (difference.inDays > 365) {
      return '${difference.inDays ~/ 365}年前';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}ヶ月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return '数秒前';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Text(
        formattedDate(),
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
            color: Colors.grey
        )
    );
  }
}