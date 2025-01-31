
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

///いいね機能のクラス
class LikeButton extends StatefulWidget {
  final String postId; // いいね対象の投稿ID
  const LikeButton({super.key, required this.postId});
  @override
  _LikeButtonState createState() => _LikeButtonState();
}
class _LikeButtonState extends State<LikeButton> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '未登録';

  late bool _isLiked;//

  //いいね押した時の処理
  void onLikePressed(String postId, String userId) async {
    if (_isLiked == false) {
      await likePost(postId, userId);
    } else {
      await unlikePost(postId, userId);
    }
    setState(() {});
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



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('likes')
            .doc('${widget.postId}_$uid')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data!.data() != null ) {
            _isLiked = true;
          } else {
            _isLiked = false;
          }
          return IconButton(
              icon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.pinkAccent,
              ),
              onPressed: () {
                if (uid == '未登録') {
                  print('ログインしてください');
                } else {
                  onLikePressed(widget.postId, uid);
                }
              }
          );
        }
    );
  }
}