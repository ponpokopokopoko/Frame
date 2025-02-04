import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frame/auth_page_form.dart';
import 'package:frame/home/timeline_page.dart';
import 'package:frame/sign_up/signup_setting_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// ログイン画面用Widget
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  bool _loginIsVisible = false; // ログイン入力欄の表示/非表示を管理する変数
  String loginErrorMessage = '';

  bool _signUpIsVisible = false; // 登録入力欄の表示/非表示を管理する変数
  String signUpErrorMessage = '';


  Future<void> _signInWithGoogle() async {
    try {
      // GoogleAuthProvider のインスタンスを作成
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Firebase Auth で Google ログインを実行
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser
          ?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // ログイン成功
      final User? user = userCredential.user;
      print('ログイン成功: ${user?.displayName}');
    } catch (e) {
      // ログイン失敗
      print('ログイン失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          //Google認証に成功した場合
          //カスタムクレーム付与→Firestoreにフラグ立てる→それ取得して新規か既存を判定する
          else if (snapshot.hasData) {
            final user = snapshot.data;
            //firestoreのフラグ取得
            return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('user_status')
                    .doc(user?.uid)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // 待機
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // エラー
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    if (data['customClaimsSet'] == true) {
                      //Firestoreに書き込みがあった場合→カスタムクレームを確認
                      return FutureBuilder(
                        future: _isNewUser(user!),//カスタムクレームチェック
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> isNewUserSnapshot) {
                          if (isNewUserSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (isNewUserSnapshot.hasData) {
                            if (isNewUserSnapshot.data!) {
                              return SignupSettingPage(); //カスタムクレームがtrue:新規ユーザーの場合
                            } else {
                              return TimelinePage(); //false:既存ユーザーの場合
                            }
                          } else {
                            return Text('Error: Could not determine user status');
                          }
                        },
                      );
                    } else {
                      return Text('Error:data[customClaimsSet] が存在しない');
                    }
                  } else {
                    return Text('Error: Could not determine user status');
                  }
                });
          }
          // 未ログイン
          else {
            return Container(
              height: 600,
              child: Column(
                children: [
                  // メールアドレス入力
                  // ユーザー登録ボタン
                  ElevatedButton(
                      child: Text('ログイン'),
                      // ボタンが押されたらログインフォームの表示/非表示を切り替える
                      onPressed: () {
                        setState(() {
                          _loginIsVisible != _loginIsVisible;
                          _signUpIsVisible == false;//反対のフォームしまう
                        });
                      }
                  ),

                  Visibility(
                      visible: _loginIsVisible,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: AuthPageForm(which: 'Login'),
                      )
                  ),

                  SizedBox(height: 10),

                  //ユーザー登録ボタン
                  ElevatedButton(
                      child: Text('アカウントを作成'),
                      onPressed: () {
                        setState(() {
                          _signUpIsVisible != _signUpIsVisible;//ボタンを押したらフォームを出したり消したり
                          _loginIsVisible == false;//反対のフォームしまう
                        });
                      }),

                  Visibility(
                    visible: _signUpIsVisible,
                    child: Container(
                      padding:EdgeInsets.symmetric(vertical: 8),
                      child:AuthPageForm(which: 'SignUp'),
                    ),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _signInWithGoogle,
                    child: Text('Google でログイン'),
                  )
                ],
              ),

            );
          }
        }
    );
  }

  Future<bool> _isNewUser(User user) async {
    // ユーザーのカスタムクレームを取得
    final idTokenResult = await user.getIdTokenResult(true);
    final claims = idTokenResult.claims;

    // 新規ユーザーかどうかを判定するカスタムクレームが存在するか確認
    final isNewUser = claims!.containsKey('isNewUser');
    debugPrint('関数動いてます');//関数動いてる
    return isNewUser;
  }
}