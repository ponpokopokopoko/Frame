
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FollowButtom extends StatefulWidget{

  final String followedId; //相手側（フォローされるユーザー）
  //final String followingId; //ボタン実行側（フォローするユーザー）

  FollowButtom({super.key, required this.followedId});
  @override
  State<FollowButtom> createState() => _FollowButtomState();
}


class _FollowButtomState extends State<FollowButtom>{

  late bool _isFollowed;
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '未登録';



 /* // フォロー,フォロー解除をする関数
  Future<void> Follow (bool isFollow) async {
    try{
      //トランザクション開始
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        //参照をゲット
        DocumentReference followingDoc = FirebaseFirestore.instance.collection('follows').doc(widget.followingId);
        DocumentReference followedDoc= FirebaseFirestore.instance.collection('follows').doc(widget.followedId);
        //ボタン実行側ドキュメントのフォローフィールドに相手側のUIDを追加
        DocumentSnapshot followingSnapshot = await transaction.get(followingDoc);//ドキュメント取得
        List<String> myFollowList = followingSnapshot.get('myFollowingList') as List<String>;//リスト取得

        if (isFollow) {
          myFollowList.add(widget.followedId);//リストに追加
        } else {
          myFollowList.remove(widget.followedId);//リストから削除
        }
        await transaction.update(followingDoc, {'myFollowingList': myFollowList});


        //相手側ドキュメントのフォロワーフィールドにボタン実行側のUIDを追加
        DocumentSnapshot followedSnapshot = await transaction.get(followedDoc);//ドキュメント取得
        List<String> myFollowerList = followedSnapshot.get('myFollowerList') as List<String>;//リスト取得

        if(isFollow){
          myFollowerList.add(widget.followingId);//リストに追加
        }else{
          myFollowerList.remove(widget.followingId);//リストから削除
        }
        await transaction.update(followedDoc, {'myFollowerList': myFollowerList});

      });
      } catch (e) {
      // エラー処理
      print('Error: $e');
    }
  }*/

  Future<void> _toggleFollow() async {
    try {
      // フォローしているか確認
      DocumentSnapshot followingSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .doc(uid)
          .get();

      // フォローリストを取得
      Map<String, dynamic>? followingData = followingSnapshot.data() as Map<String, dynamic>?;
      //List<String> myFollowList = followingData?['myFollowingList'] as List<String>; // null安全な取得
      //上のコードワンちゃんダメかもしれない
      //List<String> myFollowList = followingSnapshot.get('myFollowingList') ?? [];

      // フォロー/フォロー解除
      bool isFollowing = followingData?['myFollowingList'].contains(widget.followedId);
      await FirebaseFirestore.instance
          .collection('follows')
          .doc(uid)
          .update({
        'myFollowingList': isFollowing
            ? FieldValue.arrayRemove([widget.followedId])//true
            : FieldValue.arrayUnion([widget.followedId]),//false
        'myFollowingCount': isFollowing
            ? FieldValue.increment(-1)
            : FieldValue.increment(1),
      });

      // 相手のフォローリストも更新 (同様の処理を繰り返す)
      // フォローしているか確認
      DocumentSnapshot followedSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .doc(widget.followedId)
          .get();

      // フォローリストを取得

      Map<String, dynamic>? followedData = followedSnapshot.data() as Map<String, dynamic>?;
      //List<String> myFollowedList = followedData?['myFollowerList'] ?? [];
      //上のコードワンちゃんダメかもしれない
      //List<String> myFollowedList = followedSnapshot.get('myFollowedList') ?? [];

      // フォロー/フォロー解除
      bool isFollowed = followedData?['myFollowerList'].contains(uid);
      await FirebaseFirestore.instance
          .collection('follows')
          .doc(widget.followedId)
          .update({
        'myFollowerList': isFollowed
            ? {FieldValue.arrayRemove([uid])}
            : {FieldValue.arrayUnion([uid])},
        'myFollowerCount': isFollowed
            ? FieldValue.increment(-1)
            : FieldValue.increment(1),
      });


    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isFollowed = !_isFollowed;
      });
    }
  }

  @override
  Widget build(BuildContext context){
     return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance//ボタン実行者のフォローリスト取得
            .collection('follows')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {

          //followsにドキュメントがある場合はフォローしてるかチェック
          if(snapshot.data!.data() != null){
            Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
            //List<String> followList = userData['myFollowingList']as List<String> ;
            //なんでこのコードがダメなのかを考えろ
            if ( userData['myFollowingList'].contains(widget.followedId)) {
              _isFollowed = true;
            } else {
              _isFollowed = false;
            }
          }else{
            //followsにドキュメントがない場合はフォローしてない判定
            _isFollowed = false;
          }

          return ElevatedButton(
              child: Text(
                _isFollowed ? 'フォロー解除' : 'フォロー',//　?trueのとき :falseのとき
              ),
              onPressed: () {
                 debugPrint('a');
                if (uid == '未登録') {
                  print('ログインしてください');
                } else {
                  print('mazukoko');
                  //await Follow(_isFollowed);
                  _toggleFollow();
                }
              }
          );
        }
    );
  }
}
