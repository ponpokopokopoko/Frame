import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frame/follows_listview.dart';

class FollowerViewPart extends StatefulWidget{
  final String uid;
  const FollowerViewPart({super.key,required this.uid});
  @override
  State<FollowerViewPart> createState() => _FollowerViewPartState();
}

class _FollowerViewPartState extends State<FollowerViewPart>{
  @override
  Widget build(BuildContext context){
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('follows')
            .doc(widget.uid)
            .snapshots(),
        builder: (context ,snapshot){
          if (snapshot.hasError) {
            return Text('エラー: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          // ドキュメントが存在する場合
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            // フォロー数、フォロワー数などを表示する
            return GestureDetector(
              onTap:(){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FollowsListview(data: data);
                  },
                );
                },
              child: Row(
                children: [
                  //押したらリストビュー表示
                  Text('フォロー ${data['myFollowingCount']}'),
                  Text('フォロワー ${data['myFollowerCount']}'),
                  // その他の情報を表示
                ],
              ),
            );
          } else {
            // ドキュメントが存在しない場合
            return Text('フォロー情報はありません');
          }
        }
        );
  }
}