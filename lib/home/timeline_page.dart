import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frame/ui_widgets/bottom_bar.dart';
import 'package:frame/home/make_timeline/make_timeline_list.dart';
import 'package:frame/home/make_timeline/post_repository.dart';

// providerの定義
final expressProvider = StateProvider<String>((ref) => '最新');

class TimelinePage extends StatelessWidget {
  
   TimelinePage({super.key});

  /*@override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage>{
   */

  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '未登録';
  //String express = '最新';
  final postRepository = PostRepository();//()はクラスを表すっぽい?そんなことはない　返り値を表す
  //final StreamController<QuerySnapshot<Map<String, dynamic>>> _streamController =
  //StreamController();

  final StreamConsumer<QuerySnapshot> _dataController = StreamController();

  /*
  @override
  void initState() {
    super.initState();
    // ログイン状態の監視
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        setState(() { uid = '未登録';});
      } else {
        setState(() { uid = user.uid;});
      }
    });
    _fetchData();
  }*/



  Future<QuerySnapshot<Object?>> _fetchData(String express) async {
    if(express == '最新'){
      Future<QuerySnapshot> data = postRepository.fetchLatestPosts();
      //_dataController.addStream(data); // Streamにデータを追加
      return data;
    }else{
      //フォローリストを取得
      List<Object> follow = await postRepository.getFollowingUserIds(uid);

      if( follow != []) {
        //１人でもフォローしていた場合
        //フォロー中の人の投稿を時系列に取得して返す
        Future<QuerySnapshot> data = postRepository.fetchFollowingPosts(follow); // Streamにデータを追加
        return data;
      }else{
        //誰もフォローしてない場合　一旦最新を表示・本当はフォローしてくださいを出す必要がある、ページ別で作らなきゃいかんかも
        Future<QuerySnapshot> data = postRepository.fetchLatestPosts();
        //_dataController.addStream(data); // Streamにデータを追加
        return data;
      }
    }
  }

  //課題の言語化：検索するデータを選びたいけどifが出来ない＆データを持ってくるのにawaitが必要
  //ページ変えるか、値を入れて判定する関数を作り、それ次第で表示するwidgetを根本から変える、bodyだけを変えたい
  //まずは最新を表示すればいいんじゃない？

  @override
  Widget build(BuildContext context){
    final user = FirebaseAuth.instance.currentUser;

    debugPrint(user?.uid);
    return Consumer(builder: (BuildContext context,WidgetRef ref, child){
      /*return  LayoutBuilder(
          builder: (context, constraints) {
            // 画面の幅に応じて画像の幅を調整 (例)
            final imageWidth = constraints.maxWidth * 0.7; // 画面幅の50%
            //以下にUI
*/
            return Scaffold(
                appBar: AppBar(
                    title: Row(
                      children: [
                        ElevatedButton(
                            onPressed:(){
                              ref.read(expressProvider.notifier).state = '最新';
                              //_fetchData();
                            },
                            child: Text('最新')),
                        ElevatedButton(
                            onPressed:(){
                              ref.read(expressProvider.notifier).state = 'フォロー';
                              //_fetchData();
                            },
                            child: Text('フォロー')),
                        Text(ref.watch(expressProvider)),
                      ],)
                ),


                //StreamBuilder（リアルタイムなデータ更新）使います！
                body: /* FutureBuilder<Future<QuerySnapshot<Object?>>>(
                    future: _fetchData(ref.watch(expressProvider)),
                    builder: (context, snapshot) {
                      if(snapshot.hasData && snapshot.data != null){
                        debugPrint('a');
                        return*/ MakeTimelineList(
                          querySnapshot: _fetchData(ref.watch(expressProvider)), //型合わせが鬼大変
                        ),  /*;
                      }else if (!snapshot.hasData) {
                        debugPrint('b');
                        return const CircularProgressIndicator();
                      }else{
                        debugPrint('c');
                        return const Text('エラーが発生しました');
                      }
                    }),*/

                bottomNavigationBar: BottomBar()
            );
          }
      );
    //});
  }
}