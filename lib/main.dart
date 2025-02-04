import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frame/auth/auth_page.dart';
import 'package:frame/auth/signup_setting_page.dart';
import 'package:frame/home/my_account/my_account_profile_edit.dart';
import 'package:frame/home/my_account/my_account_top.dart';
import 'package:frame/home/other_user_profile_page.dart';
import 'package:frame/home/post_detail_page.dart';
import 'package:frame/home/search/search_top_page.dart';
import 'package:frame/home/timeline_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseUserのログイン状態が確定するまで待つ
  final firebaseUser = await FirebaseAuth.instance.userChanges().first;

  runApp(
      ProviderScope(
        child:FrameApp()
      ),
  );
}

class FrameApp extends StatelessWidget {

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            // アプリ名
      title: 'FrameApp',
      theme: ThemeData(
        // テーマカラー
        primarySwatch: Colors.blueGrey,
      ),

      routes: {
        //'/my_account_profile_edit':(context) => MyAccountProfileEdit(),
        '/other_user_profile_page':(context) => OtherUserProfilePage(),
        '/timeline_page':(context) => TimelinePage(),
        '/search_top_page':(context) => SearchTopPage(),
        '/post_detail_page':(context) => PostDetailPage(),
        '/my_account_top':(context) => MyAccountTopPage(),
        //'/tag_search_top_page':(context) => TagSerchTopPage(),
      },
      // ログイン画面を表示
      //現在のログイン状況を確認し、状態に寄って表示ページを変える
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if(snapshot.hasData) {
            debugPrint('1');
            //ログインしている場合（Google認証の場合リダイレクトでここに飛んできて、この条件に入っていく）
              final user = snapshot.data;
            debugPrint(user?.uid);//uidちゃんと機能してるか？これだめなら検索できない
              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('user_status')
                      .doc(user?.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      debugPrint('11');
                      return CircularProgressIndicator(); // 待機
                    } else if (snapshot.hasError) {
                      debugPrint('12');
                      return AuthPage(); // エラーの場合ちゃんとログインしてもらう
                      //snapshot.data!.data() != null :
                      // この条件で弾かれるらしい。どうして？
                      //snapshot.data!.data() なぜNull →ドキュメントのフィールドが設定される前に読み込んでしまうため
                      //フィールドの読み込みを待つ方法
                    } else if (snapshot.hasData && snapshot.data != null /*&& snapshot.data!.data() != null */) {
                      debugPrint('13');
                      //final  DocumentSnapshot<Object?>? document = snapshot.data;
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      if (data['customClaimsSet'] == true) {
                        debugPrint('131');
                        //Firestoreに書き込みがあった場合→カスタムクレームを確認
                        return FutureBuilder(
                          future: _isNewUser(user!),//カスタムクレームチェック
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> isNewUserSnapshot) {
                            if (isNewUserSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              debugPrint('1311');
                              return CircularProgressIndicator();
                            } else if (isNewUserSnapshot.hasData) {
                              debugPrint('1312');//ここまで
                              if (isNewUserSnapshot.data!) {
                                debugPrint('13121');
                                return TimelinePage(); //カスタムクレームがtrue:新規ユーザーの場合
                              } else {
                                debugPrint('13122');
                                return TimelinePage(); //false:既存ユーザーの場合タイムラインへ
                              }
                            } else {//カスタムクレームチェックに失敗した場合
                              debugPrint('1313');
                              return AuthPage();//SignupSettingPage();//ログインし直してもらう
                            }
                          },
                        );
                      } else {//アカウントがあるのにFirestoreに書き込みがない場合（そんな事態基本ありえないが）
                        debugPrint('132');
                        return AuthPage();//SignupSettingPage();//Text('Error:data[customClaimsSet] が存在しない');
                      }
                    } else {
                      debugPrint('14');
                      return AuthPage();//Text('Error: Could not determine user status');
                    }
                  });
            } else {
            debugPrint('2');
            //ログインしていない場合
              return AuthPage();
            }
        }
      ),
    );
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
  //debugPrint('isNewUser: $isNewUser');
  debugPrint('関数動いてます');//関数動いてる

  return isNewUser;
}