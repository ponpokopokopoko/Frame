import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frame/auth_page.dart';
import 'package:frame/home/my_account/my_account_profile_edit.dart';
import 'package:frame/home/other_user_profile_page.dart';
import 'package:frame/home/post_detail_page.dart';
import 'package:frame/home/search/search_top_page.dart';
import 'package:frame/home/tag_search/tag_search_top_page.dart';
import 'package:frame/home/timeline_page.dart';
import 'package:frame/login/login_password.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frame/sign_up/signpu_password_page.dart';
import 'firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      ProviderScope(
        child:FrameApp()
      ),
  );
}

class FrameApp extends StatelessWidget {

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
        '/signup_password_page': (context) => SignupPasswordPage(),
        '/login_password':(context) => LoginPasswordPage(),
        '/my_account_profile_edit':(context) => MyAccountProfileEdit(),
        '/other_user_profile_page':(context) => OtherUserProfilePage(),
        '/timeline_page':(context) => TimelinePage(),
        '/search_top_page':(context) => SearchTopPage(),
        '/post_detail_page':(context) => PostDetailPage(),
        //'/tag_search_top_page':(context) => TagSerchTopPage(),
      },
      // ログイン画面を表示
      home:   AuthPage(),
    );
  }
}

