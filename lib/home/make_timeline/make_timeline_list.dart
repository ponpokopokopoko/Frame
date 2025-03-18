import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frame/home/make_timeline/make_timeline_list_contents.dart';
/*
//取得した投稿リストに対して、投稿者ユーザーのドキュメントをリスト化する
Future<List<Map<String, dynamic>>> getUserInfoFromPostList(
  List<Map<String,dynamic>> postList) async {

  final uids = postList.map((doc) => doc['userUid'] as String).toList();

  final userFutures = uids.map((uid) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get());

  final List userSnapshots = await Future.wait(userFutures);

  return userSnapshots
      .where((snapshot) => snapshot.exists)
      .map((snapshot) => snapshot.data() as Map<String, dynamic>)
      .toList();
}


//タイムラインの「リストタイルを並べる」担当

class MakeTimelineList extends StatelessWidget{
  final Future<List<Map<String,dynamic>>> querySnapshot;

  const MakeTimelineList({super.key,required this.querySnapshot});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String,dynamic>>>(
      //投稿情報の存在確認
        future: querySnapshot, //受け取る
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String,dynamic>>> snapshot) {
          if (snapshot.hasError) {
            //検索データが見つからなかった場合
            debugPrint('データ拾えてない');
            return const Center(
              child: Text(
                '投稿がありません',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('投稿検索中');
            //ロード中
            return const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    Text(
                      '投稿検索中',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey
                      ),
                    ),
                  ],)
            );
          }
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            debugPrint('データがある場合の処理');
            //データがある場合の処理
            //投稿者情報がない場合もリストタイルが生まれてしまうので画面が変になる→SizeBoxで躱す
            final postList = snapshot.data! ;//as List<Map<String, dynamic>>;
            //final postUserData = getUserInfoFromPostList(postList);

            return FutureBuilder(
                future: getUserInfoFromPostList(postList),
                builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot){
                  //ユーザーのリストデータ取得中
                  if(snapshot is ConnectionState){
                    return const CircularProgressIndicator();
                  }
                  //リストデータ取得成功
                  if(snapshot.hasData && snapshot.data != null){
                    return MakeTimelineListContents(postUserList: snapshot.data!, postList: postList);
                  }
                  //ここには基本来ない
                  else{
                    return const SizedBox.shrink();
                  }
                });
            /*return   ListView.builder(
                addAutomaticKeepAlives: true,
                cacheExtent: 30,
                //ScrollPhysics
              //physics: const BouncingScrollPhysics(),
                physics: const ClampingScrollPhysics(),//AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 4,//snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot document = snapshot.data!
                      .docs[index];
                  Map<String, dynamic> postData = document.data()! as Map<String, dynamic>;

                  //投稿者のユーザー情報を取得する
                  //ここ別関数で済ます？ buiderしなくていい
                  return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(postData['userUid'])
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          //取得失敗
                          debugPrint('投稿者情報の取得に失敗しました');
                          return SizedBox();
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          //ロード中
                          return const Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  Text(
                                    '投稿者情報検索中',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey
                                    ),
                                  ),
                                ],)
                          );
                        }
                        if (snapshot.data!.exists) {
                          debugPrint('データがあるngo');
                          //リストタイルの中身部分
                          //別ページのクラスに外注
                          Map<String, dynamic> postUserData = snapshot.data!
                              .data() as Map<String, dynamic>;

                          return MakeTimelineListContents(
                            postUserData: postUserData,
                            postData: postData,
                          );
                        }
                        else {
                          debugPrint('投稿者情報の取得に失敗しました');
                          return const SizedBox();
                        }
                      });
                });*/
          }
          else {
            //普通にエラーで検索することすらダメだった場合
            return Center(
              child: Text(
                '投稿の検索に失敗しました',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
        });
  }
}
*/
class timelinePost {
  final  postId;
  final  caption;
  final  userUid;
  final  userId;
  final  iconUrl;
  final  createdAt;
  final List<dynamic> imageUrl;
  final List<dynamic> tags;
  final bookmark;
  final like;

  timelinePost({
    required this.postId,
    required this.caption,
    required this.userUid,
    required this.userId,
    required this.iconUrl,
    required this.createdAt,
    required this.imageUrl,
    required this.tags,
    required this.bookmark,
    required this.like,
  });

  //ここはユーザーとポストの２つから情報を取得する必要がある（）１hくらい、改善
  factory timelinePost.fromJson(
      Map<String, dynamic> post,
      dynamic postId,
      Map<String, dynamic> user){

    return timelinePost(
      postId: postId,
      imageUrl:post['imageUrl'],
      tags:post['tags'],
      caption: post['caption'] ,
      userUid: post['userUid'] ,
      createdAt: post['createdAt'] ,
      like:post['like'],
      bookmark:post['bookmark'],
      userId: user['userId'] ,
      iconUrl: user['iconImage'],
    );
  }
}