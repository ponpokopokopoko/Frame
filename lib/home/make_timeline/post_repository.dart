
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//タイムラインに流す「投稿の収集」担当
class PostRepository {

  //final String express;
  //final String uid;

  //const PostRepository({required this.express,required this.uid});

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchLatestPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchFollowingPosts(
      List<Object> following) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('userUid', whereIn: following)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<List<Object>> getFollowingUserIds(String uid) async {
    debugPrint(uid);
    final userDoc = await FirebaseFirestore.instance.collection('follows').doc(
        uid).get();
    debugPrint('２');
    // myFollowingListがリスト型であることを確認
    final followingList = userDoc.data()?['myFollowingList'] as List<dynamic>?;
    if (followingList != null && followingList.isNotEmpty) {
      debugPrint('Nullじゃないですわ');
      return followingList.cast<Object>();
    } else {
      debugPrint('Nullですわ');
      return [];
    }

  }

}