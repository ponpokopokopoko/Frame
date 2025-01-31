import 'package:flutter/material.dart';
import 'package:frame/home/timeline_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

//class _LoginPasswordPageState extends State<LoginPasswordPage> {
class LoginPasswordPage extends StatefulWidget {
  const LoginPasswordPage({super.key});
  @override
  State<LoginPasswordPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<LoginPasswordPage>{
  //パスワードコントローラー
  final _passwordController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {

    //前ページから引継ぎ
    final email = ModalRoute.of(context)?.settings.arguments;
    if (email is String) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // メールアドレス入力
              TextFormField(
                //入力できない灰色にする
                enabled: false,
                //前ページでの入力値を入れる
                decoration: InputDecoration(labelText: email),
              ),
              // パスワード入力

              TextFormField(
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                controller: _passwordController,
                onChanged: (value){
                  setState(() {
                    errorMessage = '';
                  });
                },

              ),

              Container(
                padding: EdgeInsets.all(8),
              ),

              ///Visibility :条件付きのwidget
              Visibility(
                visible: errorMessage != null,
                child: Text(errorMessage),
              ),

              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                // ログイン登録ボタン
                child: OutlinedButton(
                  child: Text('ログイン'),
                  onPressed: () async {
                    debugPrint('0');
                    try {
                      debugPrint('1');
                      // メール/パスワードでログイン
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      debugPrint('2');
                        final result = await auth.signInWithEmailAndPassword(
                          email: email,
                          password: _passwordController.text,
                        );
                      debugPrint('4');
                      // ログインに成功した場合
                      ///エラー表示をclearする（出来てるかわからない）
                      //ErrorMessageNotifier.clearValue();
                      // チャット画面に遷移＋ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return TimelinePage();
                        }),
                      );
                    } catch (e) {
                      // ログインに失敗した場合
                      // エラーメッセージを設定
                      setState(() {
                        errorMessage = 'エラーどす$e';
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    } else {
      // argsがnullの場合の処理 (例えば、デフォルト値を表示するなど)
      return Scaffold(
        appBar: AppBar(title: Text('パスワード設定')),
        body: Center(
          child: Text('メールアドレスを取得できませんでした'),
        ),
      );
    }
  }
}
