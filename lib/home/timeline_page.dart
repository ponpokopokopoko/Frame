import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frame/ui_widgets/bottom_bar.dart';
import 'package:frame/home/make_timeline/make_timeline_list.dart';
import 'package:frame/home/make_timeline/post_repository.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});
  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage>{
  late String uid;
  String express = '最新';
  final postRepository = PostRepository();//()はクラスを表すっぽい
  //final StreamController<QuerySnapshot<Map<String, dynamic>>> _streamController =
  //StreamController();

  final StreamConsumer<QuerySnapshot> _dataController = StreamController();

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
  }



  Future<Stream<QuerySnapshot<Object?>>>? _fetchData() async {
    if(express == '最新'){
      Stream<QuerySnapshot> data = postRepository.fetchLatestPosts();
      //_dataController.addStream(data); // Streamにデータを追加
      return data;
    }else{
      //フォローリストを取得
      List<Object> follow = await postRepository.getFollowingUserIds(uid);

      if( follow != null) {
        //１人でもフォローしていた場合
        //フォロー中の人の投稿を時系列に取得して返す
        Stream<QuerySnapshot> data = postRepository.fetchFollowingPosts(follow); // Streamにデータを追加
        return data;
      }else{
        //誰もフォローしてない場合　一旦最新を表示・本当はフォローしてくださいを出す必要がある、ページ別で作らなきゃいかんかも
        Stream<QuerySnapshot> data = postRepository.fetchLatestPosts();
        //_dataController.addStream(data); // Streamにデータを追加
        return data;
      }
    }
  }

  @override
  void dispose() {
    _dataController.close();
    super.dispose();
  }

  //課題の言語化：検索するデータを選びたいけどifが出来ない＆データを持ってくるのにawaitが必要
  //ページ変えるか、値を入れて判定する関数を作り、それ次第で表示するwidgetを根本から変える、bodyだけを変えたい
  //まずは最新を表示すればいいんじゃない？

  @override
  Widget build(BuildContext context){
    return LayoutBuilder(
        builder: (context, constraints) {
          // 画面の幅に応じて画像の幅を調整 (例)
          final imageWidth = constraints.maxWidth * 0.7; // 画面幅の50%
          //以下にUI

          return Scaffold(
              appBar: AppBar(
                  title: Row(
                    children: [
                      ElevatedButton(
                          onPressed:(){
                            setState(() {
                              express = '最新';
                            });
                            //_fetchData();
                          },
                          child: Text('最新')),
                      ElevatedButton(
                          onPressed:(){
                            setState(() {
                              express = 'フォロー';
                            });
                            //_fetchData();
                          },
                          child: Text('フォロー')),
                      Text(express),
                    ],)
              ),

              //StreamBuilder（リアルタイムなデータ更新）使います！
              body:  Container(
                child:  FutureBuilder<Stream<QuerySnapshot<Object?>>>(
                    future: _fetchData(),
                    builder: (context, snapshot) {
                      return MakeTimelineList(
                        querySnapshot: snapshot.data!, //型合わせが鬼大変
                      );
                    }),
              ),

              bottomNavigationBar: BottomBar()
          );
        }
    );
  }
}