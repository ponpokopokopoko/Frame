import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frame/auth/auth_page.dart';
import 'package:frame/main_page.dart';

//ログイン、カスタムクレームの状態をチェックする部品です
//ログインしていればMainPageへ、してなければ引数のpageに飛びます

dynamic loginCheck (AsyncSnapshot<User?> snapshot,Widget page){
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const CircularProgressIndicator();
  }
  else if(snapshot.hasData) {//ログインしている場合（Google認証の場合リダイレクトでここに飛んできて、この条件に入っていく）
    final user = snapshot.data;
    debugPrint(user?.uid);//uidちゃんと機能してるか？これだめなら検索できない
    return StreamBuilder(//この工程は何か
      //新規ユーザーにはカスタムクレームを付与する、その処理終了のフラッグとしてFirestoreに書き込まれる。
      //ここは処理の終了を待つための工程
        stream: FirebaseFirestore.instance
            .collection('user_status')
            .doc(user?.uid)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
            snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('11');
            return const CircularProgressIndicator(); // 待機
          } else if (snapshot.hasError) {
            debugPrint('12');
            return page; // エラーの場合ちゃんとログインしてもらう
            //フィールドの読み込みを待つ方法
          } else if (snapshot.hasData && snapshot.data != null ) {
            debugPrint('13');
            final data = snapshot.data!.data() as Map<String, dynamic>;
            if (data['customClaimsSet'] == true) {
              debugPrint('131');
              //Firestoreに書き込みがあった場合→カスタムクレームを確認
              return FutureBuilder(
                future: _isNewUser(user!),//カスタムクレームチェック
                builder: (BuildContext context,
                    AsyncSnapshot<bool> isNewUserSnapshot) {
                  if (isNewUserSnapshot.connectionState == ConnectionState.waiting) {
                    debugPrint('1311');
                    return const CircularProgressIndicator();
                  } else if (isNewUserSnapshot.hasData) {
                    debugPrint('1312');//ここまで
                    if (isNewUserSnapshot.data!) {
                      debugPrint('13121');
                      return const MainPage(); //カスタムクレームがtrue:新規ユーザーの場合
                    } else {
                      debugPrint('13122');
                      return const MainPage(); //false:既存ユーザーの場合タイムラインへ
                    }
                  } else {//カスタムクレームチェックに失敗した場合
                    debugPrint('1313');
                    return page;//ログインし直してもらう
                  }
                },
              );
            } else {//アカウントがあるのにFirestoreに書き込みがない場合（そんな事態基本ありえないが）
              debugPrint('132');
              return page;//Text('Error:data[customClaimsSet] が存在しない');
            }
          } else {
            debugPrint('14');
            return page;//Text('Error: Could not determine user status');
          }
        });
  }
  else {
    debugPrint('2');
    //ログインしていない場合
    return page;
  }
}

Future<bool> _isNewUser(User user) async {
  // 遅延処理(functionsでカスタムクレームをつけるのを待つ)
  //await Future.delayed(Duration(seconds: 10)); // 1秒待つ
  // ユーザーのカスタムクレームを取得
  final idTokenResult = await user.getIdTokenResult(true);
  final claims = idTokenResult.claims;

  // 新規ユーザーかどうかを判定するカスタムクレームが存在するか確認
  final isNewUser = claims!.containsKey('isNewUser');

  // デバッグプリント
  debugPrint('関数動いてます');

  return isNewUser;
}