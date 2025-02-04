import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AboutPostButton extends StatelessWidget {
  final String posterUid;
  final String postId;

  const AboutPostButton({super.key, required this.posterUid, required this.postId});


  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      return PopupMenuButton<String>(
        icon: Icon(Icons.more_horiz),
        //削除、ブロック、通報、フォロー、気に入らない他
        onSelected: (String value) {
          // 選択されたメニュー項目に応じて処理を分岐
          if (value == 'block') {
            // ユーザーをブロックする処理
            _blockUser(posterUid);
          } else if (value == 'delete') {
            // 投稿を削除する処理
            _deletePost(postId);
          } else if (value == 'follow') {
            // 投稿者をフォローする処理
            _followUser(posterUid);
          }
        },
        itemBuilder: (BuildContext context) {
          String currentUid = FirebaseAuth.instance.currentUser!.uid;


          if (posterUid == currentUid) {
            //自分の投稿の場合（投稿削除）
            return [
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('投稿を削除'),
              ),
            ];
          } else{
            //自分以外の投稿の場合（ブロック、フォロー）
            return [
              PopupMenuItem<String>(
                value: 'block',
                child: Text('ブロック'),
              ),
              PopupMenuItem<String>(
                value: 'follow',
                child: Text('投稿者をフォロー'),
              )
            ];
          }
        },
      );
    } else {
      //閲覧者がログインしてない状態ならボタン自体を表示しない
      return SizedBox.shrink();
    }
  }

  // ユーザーをブロックする処理
  void _blockUser(String userId) {
    // FirebaseやProviderなどを使ってブロック処理を実装
    print('ユーザー $userId をブロック');
  }

// 投稿を削除する処理
  void _deletePost(String postId) async{
    // FirebaseやProviderなどを使って削除処理を実装
    //投稿削除（いいね、ブクマ情報の削除は本当はcloudfunctionsでやる）
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    deleteDocumentsByValue('likes', 'postId', postId);
    deleteDocumentsByValue('bookmarks','postId', postId);
  }

  //指定したドキュメントを消す関数(コレクション)
  //本当はcloudfunctionsで処理する
  Future<void> deleteDocumentsByValue(String collectionName,String fieldValue, String value) async {
    Query query = FirebaseFirestore.instance
        .collection(collectionName)
        .where(fieldValue, isEqualTo: value );

    try {
      QuerySnapshot snapshot = await query.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        //print('Document deleted: ${doc.id}');
      }
    } catch (error) {
      print('Error deleting documents: $error');
    }
  }

// ユーザーをフォローする処理
  void _followUser(String userId) {
    // FirebaseやProviderなどを使ってフォロー処理を実装
    print('ユーザー $userId をフォロー');
  }
}