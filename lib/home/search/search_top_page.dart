import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frame/home/search/popular_part.dart';
import 'package:frame/main_page.dart';

//人気ユーザー表示用のProvider
final popularUsersProvider = FutureProvider<List<Map<String,dynamic>>>((ref) async {
  //Userクラスのリストを用意
  List<Map<String,dynamic>> users = [];
  //followsコレクションでフォロワーの多いユーザーを取得
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('follows')
      .orderBy('myFollowerCount', descending: true)
      .limit(5)
      .get();
  //各人に対してuidからusersコレクションのドキュメンント取得
  for (var doc in querySnapshot.docs) {
    final userId = doc.id;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    //各人に対してUserクラスを作り、それをリストにする
    final userData = userDoc.data() as Map<String, dynamic>;
    users.add(userData);
  }
  return users;
});

//このコードがどうしてダメだったかだけはちゃんと調べる
/*//人気投稿の表示用のProvider
final popularPostsProvider = FutureProvider<List<Map<String,dynamic>>>((ref) async {
  List<Map<String,dynamic>> documents = [] ;
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('posts')
      .orderBy('like', descending: true)
      .limit(2) // 表示する投稿数
      .get();
  for (var doc in querySnapshot.docs){//特にこの辺りがどうしてダメなのか
    final document = doc as Map<String,dynamic>;
    documents.add(document);
  }
  return documents;
});*/

// 人気投稿の表示用のProvider
final popularPostsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('like', descending: true)
        .limit(5) // 表示する投稿数
        .get();

    // Map<String, dynamic> 型へのキャストとnullチェック
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    // エラーが発生した場合の処理
    print('エラーが発生しました: $e');
    return List.empty(); // 空のリストを返す
  }
});

// 人気タグの表示用のProvider
final popularTagsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tagCounts')
        .orderBy('count', descending: true)
        .limit(5) // 表示する投稿数
        .get();

    // Map<String, dynamic> 型へのキャストとnullチェック
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    // エラーが発生した場合の処理
    print('エラーが発生しました: $e');
    return List.empty(); // 空のリストを返す
  }
});

class SearchTopPage extends ConsumerWidget {
  const SearchTopPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Column(
          children: [
            Text('発見',
                 style:TextStyle(
                   fontSize: 24,
                     color: Colors.white)),
            Divider(
              color: Colors.grey, // 線の色
              thickness: 4.0, // 線の太さ
              //indent: 20.0, // 左側の余白
              //endIndent: 20.0, // 右側の余白
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //人気ユーザー
                    Container(
                      height: 35,
                      padding:const EdgeInsets.symmetric(vertical: 5),
                      child: const Row(
                        children: [
                          SizedBox(width: 30),
                          Text('人気のユーザー',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18,
                                  color: Colors.white
                              )
                          ),
                        ],
                      ),
                    ),

                    //SizedBox(height: 8,),
                    Container(
                        height: 200,
                        child: Column(children: [
                          PopularPart(
                              asyncValue: ref.watch(popularUsersProvider),
                              attribute: '人気ユーザー'
                          )
                        ],)
                    ),

                    SizedBox(height: 20),

                    Divider(
                      color: Colors.grey, // 線の色
                      thickness: 1.0, // 線の太さ
                      //indent: 20.0, // 左側の余白
                      endIndent: 20.0, // 右側の余白
                    ),

                    //人気投稿
                    Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: const Row(
                        children: [
                          SizedBox(width: 30),
                          Text('人気の投稿',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18,
                                  color: Colors.white
                              )
                          ),
                        ],
                      ),
                    ),

                    Container(
                        height: 200,
                        child: Column(
                            children: [
                              PopularPart(
                                  asyncValue: ref.watch(popularPostsProvider),
                                  attribute: '人気投稿'
                              )
                            ])
                    ),


                    SizedBox(height: 20),
                    Divider(
                      color: Colors.grey, // 線の色
                      thickness: 1.0, // 線の太さ
                      //indent: 20.0, // 左側の余白
                      endIndent: 20.0, // 右側の余白
                    ),

                    //人気タグ

                    Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: const Row(
                        children: [
                          SizedBox(width: 30),
                          Text('人気のタグ',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18,
                                  color: Colors.white
                              )
                          ),
                        ],
                      ),
                    ),

                    //SizedBox(height: 8,),

                    SizedBox(
                        height: 200,
                        child: Column(children: [
                          PopularPart(
                              asyncValue: ref.watch(popularTagsProvider),
                              attribute: '人気タグ'
                          )
                        ],)
                    ),

                  ],
                )
            ),
            )
          ],
        );
  }
}
