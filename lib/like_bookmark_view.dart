import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:frame/ui_widgets/main_page.dart';
import 'package:frame/ui_widgets/posts_gridview_part.dart';

//いいね,ブクマの振り返り(グリッドビューで表示)をするページのコード
class LikeBookmarkView extends StatelessWidget{
  final String? uid ;
  final String select;
  const LikeBookmarkView({super.key, required this.uid, required this.select});

  @override
  Widget build (BuildContext context){
    return  Column(
        children: [


          Container(
            child: (select == 'like')
                ?Text ('いいねした投稿',
              style:TextStyle(
                color: Colors.white,
                fontSize:  22,
              ) ,)
                :Text('保存した投稿',
                style:TextStyle(
                  color: Colors.white,
                  fontSize:  22,
                ) ),),
          Divider(
            color: Colors.grey,
            thickness: 4,
          ),

          Container(
            child: (uid != null && uid != '未登録')//Uidがちゃんとあるかどうか
                ?FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              //Likes(Bookmarks)コレクションからUidのあるdocumentを取得する
                future: (select == 'like')
                //いいね
                    ?FirebaseFirestore
                    .instance
                    .collection('likes')
                    .where('UserId' ,isEqualTo: uid)
                    .get()
                //ブックマーク
                    :FirebaseFirestore
                    .instance
                    .collection('bookmarks')
                    .where('UserId' ,isEqualTo: uid)
                    .get(),
                builder: (BuildContext context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return CircularProgressIndicator();
                  }
                  if(snapshot.hasData && snapshot.data!.docs.isNotEmpty){

                    return FutureBuilder(
                        future: DataList(snapshot),
                        builder: (BuildContext context,snapshot){
                          if(snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return PostsGridviewPartByList(
                                DataList: snapshot.data!);
                          }
                          else{
                            return Center();
                          }
                        }) ;
                  }else{
                    return Center(
                      child: (select == 'like')
                          ? const Text('いいねした投稿はありません',style: TextStyle(color: Colors.white),)
                          :const Text('保存した投稿はありません',style: TextStyle(color: Colors.white)),
                    );
                  }
                })
                :const Center(child: Text('ユーザー情報を取得できませんでした'
                ,style: TextStyle(color: Colors.white))),)
        ]);
  }
}

//投稿IDのリストを引数に投稿ドキュメント情報を取得する関数 (修正版 - async, Future.wait を使用)
Future<List<Map<String,dynamic>>> DataList(AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) async { // async に変更、引数の型も明示的に
  debugPrint('DataList function called'); // デバッグログを追加
  if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
    debugPrint('DataList: snapshot has no data or docs are empty, returning empty list'); // デバッグログを追加
    return []; // snapshot にデータがない場合は空のリストを返す
  }
  return await Future.wait(
    snapshot.data!.docs.map((doc) async {
      try {
        DocumentSnapshot<Map<String, dynamic>> document = await FirebaseFirestore
            .instance
            .collection('posts')
            .doc(doc['postId'])
            .get();
        if (document.exists && document.data() != null && document.data()!.isNotEmpty) { // null チェックを追加
          return document.data()!;
        } else {
          return <String, dynamic>{}; // データがない場合は空の Map を返す (フォールバック)
        }
      } catch (e) {
        return <String, dynamic>{}; // エラー発生時も空の Map を返す (エラーハンドリング)
      }
    }).toList(),
  );
}
