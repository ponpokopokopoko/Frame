import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frame/auth/auth_page.dart';
import 'package:frame/home/my_account/my_account_top.dart';
import 'package:frame/home/post_detail_page.dart';
import 'package:frame/home/timeline_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frame/main_page.dart';
import 'firebase_options.dart';
import 'package:frame/login_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(//初期化しないといけない
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseUserのログイン状態が確定するまで待つ
  //これを使うとかじゃなくて、状態の確定を待つために使ってる？
  final firebaseUser = await FirebaseAuth.instance.userChanges().first;

  await dotenv.load(fileName: ".env"); // .envファイルを読み込む

  runApp(
      ProviderScope(//ProviderScopeでアプリをラップする
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
        // テーマカラー、これ意味ある？、薄紫にしかならないけど
        primarySwatch: Colors.blueGrey,
      ),

      routes: {
        '/timeline_page':(context) => TimelinePage(),
        '/main_page':(context) => const MainPage(),
        '/post_detail_page':(context) => const PostDetailPage(),
        '/my_account_top':(context) => const MyAccountTopPage(),
      },

      // ログイン画面を表示
      //現在のログイン状況を確認し、ログインしている→MainPage：ログインしてない→AuthPage
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {

          return loginCheck(snapshot, const AuthPage());

        }
      ),
    );
  }
}
