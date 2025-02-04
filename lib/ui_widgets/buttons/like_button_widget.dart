
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Stream<bool> isLikeStream (String postId, String userId){
  return FirebaseFirestore.instance
      .collection('likes')
      .doc('${postId}_${userId}')
      .snapshots()
      .map((snapshot) => snapshot.exists);//帰ってきたsnapshot対してexistでbool値を出す
}

//いいね押した時の処理
void onLikePressed(String postId, String userId ,bool _isLiked) async {
  (_isLiked == false)
      ?await likePost(postId, userId)
      :await unlikePost(postId, userId);
}
// いいねする関数
Future<void> likePost(String postId, String userId) async {
  await FirebaseFirestore.instance
      .collection('likes')
      .doc('${postId}_$userId')
      .set({
    'createdAt': FieldValue.serverTimestamp(),
    'UserId': userId,
    'postId': postId,
  });
  await FirebaseFirestore.instance.collection('posts').doc(postId).update({'like': FieldValue.increment(1)});
}
// いいねを取り消す関数
Future<void> unlikePost(String postId, String userId) async {
  await FirebaseFirestore.instance
      .collection('likes')
      .doc('${postId}_$userId')
      .delete();

  await FirebaseFirestore.instance.collection('posts').doc(postId).update({'like': FieldValue.increment(-1)});
}

///いいね機能のクラス
class LikeButton extends StatefulWidget {
  final String postId; // いいね対象の投稿ID
  const LikeButton({super.key, required this.postId});
  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '未登録';
  late bool _isLiked;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: isLikeStream(widget.postId, uid),
        builder: (context, snapshot) {

          if(snapshot.connectionState == ConnectionState.waiting){
            return  const CircularProgressIndicator();
          }

          if(snapshot.hasData && snapshot.data is bool){
            _isLiked = snapshot.data!;

            return IconButton(
                icon: Icon(
                  (_isLiked)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.pinkAccent,
                ),
                onPressed: () {
                  if (uid == '未登録') {
                    print('ログインしてください');
                  } else {
                    onLikePressed(widget.postId, uid, _isLiked);
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                  }
                }
            );
          }
          else{   //ココには来ない
            return const SizedBox.shrink();
          }
        }
    );
  }
}