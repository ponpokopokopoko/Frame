import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//ブックマークを監視してbool値を返すストリーム関数
Stream<bool> isBookmarkStream(String postId, String userId) {
  return FirebaseFirestore.instance
      .collection('bookmarks')
      .doc('${postId}_$userId')
      .snapshots()
      .map((snapshot) => snapshot.exists);
}

///ブックマーク
///ブックマーク機能のクラス
class BookmarkButton extends StatefulWidget {
  final String postId; // いいね対象の投稿ID
  const BookmarkButton({super.key, required this.postId});
  @override
  _BookmarkButtonState createState() => _BookmarkButtonState();
}
class _BookmarkButtonState extends State<BookmarkButton> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '未登録';
  late bool _isBookmarked;//


  //ブックマーク押した時の処理
  void onBookmarkPressed(String postId, String userId) async {
    if (_isBookmarked == false) {
      await bookmarkPost(postId, userId);
    } else {
      await unBookmarkPost(postId, userId);
    }
    setState(() {});
  }
  // ブックマークする関数
  Future<void> bookmarkPost(String postId, String userId) async {
    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc('${postId}_$userId')
        .set({
      'createdAt': FieldValue.serverTimestamp(),
      'UserId': userId,
      'postId': postId,
    });
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({'bookmark': FieldValue.increment(1)});
  }
  // ブックマークを取り消す関数
  Future<void> unBookmarkPost(String postId, String userId) async {
    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc('${postId}_$userId')
        .delete();
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({'bookmark': FieldValue.increment(-1)});

  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: isBookmarkStream(widget.postId, uid),
        builder: (context, snapshot) {

          // データ読み込み中の場合
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasData && snapshot.data is bool ) {
            _isBookmarked = snapshot.data! ;

            return IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.black45,
                ),
                onPressed: () {
                  if (uid == '未登録') {
                    print('ログインしてください');
                  } else {
                    onBookmarkPressed(widget.postId, uid);
                  }
                }
            );
          }
          else{   //ここへは来ない
            return const SizedBox.shrink();
          }
        }
    );
  }
}


