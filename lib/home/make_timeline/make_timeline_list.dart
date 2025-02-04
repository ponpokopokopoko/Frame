import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frame/home/make_timeline/make_timeline_list_contents.dart';

//タイムラインの「リストタイルを並べる」担当

class MakeTimelineList extends StatefulWidget{
  final Stream<QuerySnapshot<Object?>> querySnapshot;
  //final Widget onSuccess;

  const MakeTimelineList({super.key,required this.querySnapshot});
  @override
  State<MakeTimelineList> createState() => _MakeTimelineListState();
}

class _MakeTimelineListState extends State<MakeTimelineList> {


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //投稿情報の存在確認
        stream: widget.querySnapshot, //受け取る
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            //検索データが見つからなかった場合
            debugPrint('データ拾えてない');
            return Center(
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
            //ロード中
            return Center(
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
          if (snapshot.data != null && snapshot.data!.docs.length > 0) {
            //データがある場合の処理
            //投稿者情報がない場合もリストタイルが生まれてしまうので画面が変になる→SizeBoxで躱す
            return SizedBox.shrink(child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot document = snapshot.data!
                      .docs[index];
                  Map<String, dynamic> postData = document.data()! as Map<String, dynamic>;

                  //投稿者のユーザー情報を取得する
                  return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(postData['userUid'])
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          //取得失敗
                          debugPrint('投稿者情報の取得に失敗しました');
                          return SizedBox();
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          //ロード中
                          return Center(
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
                          return SizedBox();
                        }
                      });
                }),);
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
