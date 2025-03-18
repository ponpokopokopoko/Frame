
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frame/home/search/popular_post_card.dart';
import 'package:frame/home/search/popular_tag_card.dart';
import 'package:frame/home/search/popular_user_card.dart';

class PopularPart extends ConsumerWidget {

  final AsyncValue<List<Map<String, dynamic>>> asyncValue;
  final String attribute;

  const PopularPart({super.key,required this.asyncValue,required this.attribute});
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return SizedBox(
      height: 200,
      child: FutureBuilder(
        //Provider参照：人気ユーザーの情報の<List<Users>>を取得
          future: asyncValue.when(
            data: (data) => Future.value(data),
            loading: () => Future.value(null),
            error: (error, stackTrace) => Future.value(null),
          ),
          builder:(context, snapshot){
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              //ちゃんとデータの中身があるかチェック
              //表示する物を変更
              return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length ,
                  itemBuilder: (context, index) {
                    if(attribute == '人気ユーザー'){
                      return PopularUserCard(map: snapshot.data![index]);//人気ユーザーのポストカード
                    }else if(attribute == '人気投稿'){
                      return PopularPostCard(map: snapshot.data![index]);//人気投稿のポストカード
                    }else if(attribute == '人気タグ'){
                      return PopularTagCard(map: snapshot.data![index]);//人気タグのポストカード
                    }
                  });
            } else {
              return Text('投稿の取得に失敗しました');
            }
          }));
  }
}
