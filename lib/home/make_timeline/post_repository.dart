
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//タイムラインに流す「投稿の収集」担当
class PostRepository {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // 最新投稿を取得するクエリを返す関数
  Query<Map<String, dynamic>> fetchLatestPostsQuery() {
    debugPrint('aa');
    return _firestore.collection('posts').orderBy('createdAt', descending: true);
  }

  Future<List<Map<String, dynamic>>> fetchLatestPosts() async {
    // ... (以前のコードと同様 - 必要に応じて残す、または削除) ...
    // クエリ関数を使うように変更することも可能
    QuerySnapshot<Map<String, dynamic>> snapshot = await fetchLatestPostsQuery().get();
    return snapshot.docs.map((doc) => doc.data()).toList(); // Map<String, dynamic> のリストを返すように修正
  }


// フォロー中のユーザーの投稿を取得するクエリを返す関数
  Query<Map<String, dynamic>> fetchFollowingPostsQuery(List<dynamic> follow) {
    return _firestore.collection('posts')
        .where('userUid', whereIn: follow) // キャスト
        .orderBy('createdAt', descending: true);
  }

  Future<List<Map<String, dynamic>>> fetchFollowingPosts(List<dynamic> follow) async {
    // ... (以前のコードと同様 - 必要に応じて残す、または削除) ...
    // クエリ関数を使うように変更することも可能
    QuerySnapshot<Map<String, dynamic>> snapshot = await fetchFollowingPostsQuery(follow).get();
    return snapshot.docs.map((doc) => doc.data()).toList(); // Map<String, dynamic> のリストを返すように修正
  }


  Future<List<dynamic>> getFollowingUserIds(String uid) async {
    // ... (以前のコードと同様 - 変更なし) ...
    DocumentSnapshot snapshot = await _firestore.collection('follows').doc(uid).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    if ( data.containsKey('myFollowingList')) {
      return data['myFollowingList'] as List<dynamic>;
    } else {
      return [];
    }
  }

  //final String express;
  //final String uid;

  //const PostRepository({required this.express,required this.uid});

  ///ストリームだと再描画がやばいからfutueを取得することにした(2/9
  //設定なんでこれストリームで返してんの？
  /*Future<List<Map<String, dynamic>>> fetchLatestPosts() async{
   QuerySnapshot<Map<String,dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

   //QuerySnapshotをListにする
    List<Map<String, dynamic>> postList = snapshot.docs.map((doc) => doc.data()).toList();

    return postList;
  }

  Future<List<Map<String, dynamic>>> fetchFollowingPosts(List<Object> following)async {
     QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userUid', whereIn: following)
        .orderBy('createdAt', descending: true)
        .get();
     //QuerySnapshotをListにする
     List<Map<String, dynamic>> postList = snapshot.docs.map((doc) => doc.data()).toList();

     return postList;
  }

  Future<List<Object>> getFollowingUserIds(String uid) async {
    debugPrint(uid);
    final userDoc = await FirebaseFirestore.instance.collection('follows').doc(
        uid).get();

    // myFollowingListがリスト型であることを確認
    final followingList = userDoc.data()?['myFollowingList'] as List<dynamic>?;
    if (followingList != null && followingList.isNotEmpty) {

      return followingList.cast<Object>();
    } else {

      return [];
    }

  }*/

}