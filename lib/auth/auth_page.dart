import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frame/auth/auth_page_screan.dart';
import 'package:frame/login_check.dart';
import 'package:google_sign_in/google_sign_in.dart';

//「カスタムクレームで新規ユーザーを見分けて処理分岐」について
// 今は使っていないが後から使う可能性があるので一応残しておく


/// ログイン画面用Widget
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin{ //mixin

  //Google認証をする関数　これココにある必要は？　フォームの方に置けばいいんじゃない？
  Future<void> _signInWithGoogle() async {
    try {
      // GoogleAuthProvider のインスタンスを作成
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Firebase Auth で Google ログインを実行

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      //↑ googleのサインイン画面を表示し、Googleサインインプロセスを開始。
      // ユーザーがGoogleアカウントを選択し、認証を完了すると
      // 選択したGoogleアカウントの情報がgoogleUserに格納され返される。


      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      //↑サインインしたユーザーの認証情報を取得。これには、アクセストークンとIDトークンが含まれる

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      //↑Googleサインインから取得したアクセストークンとIDトークンを
      // Firebase認証で使用できる認証情報（credential）に変換

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      //↑Firebase Authenticationを使用してユーザーをサインインさせる

      // ログイン成功
      final User? user = userCredential.user;
      debugPrint('ログイン成功: ${user?.displayName}');
    } catch (e) {
      // ログイン失敗
      debugPrint('ログイン失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    //ログインの有無→有：カスタムクレームの有無、無→ログインフォームを表示
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {

          return loginCheck(snapshot, AuthPageScrean(func: _signInWithGoogle));
        }
    );
  }
}