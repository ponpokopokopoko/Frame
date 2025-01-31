import 'package:flutter/material.dart';
import 'sign_up/signup_email_page.dart';
import 'login/login_email.dart';

/// ログイン画面用Widget
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // メールアドレス入力
              Container(
                width: double.infinity,
                // ユーザー登録ボタン
                child: ElevatedButton(
                    child: Text('ログイン'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return LoginEmailPage();
                        }),
                      );
                    }
                ),
              ),

              Container(
                padding: EdgeInsets.all(8),
              ),

              Container(
                width: double.infinity,
                // ユーザー登録ボタン
                child: ElevatedButton(
                  child: Text('アカウントを作成'),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return SignupEmailPage();
                        }),
                      );
                    }
                ),
              ),

              const SizedBox(height: 8),

            ],
          ),
        ),
      ),
    );
  }
}
