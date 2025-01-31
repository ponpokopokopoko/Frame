import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frame/sign_up/signpu_password_page.dart';
import 'signup_code_page.dart';
import 'package:frame/auth_page.dart';


class Email {
  final String email;
  Email(this.email);
}

class SignupEmailPage extends StatefulWidget{
  const SignupEmailPage({super.key});

  @override
  State<SignupEmailPage> createState() => _SignupEmailPageState();
}

class _SignupEmailPageState extends State<SignupEmailPage> {
  @override
  Widget build(BuildContext context){

    String? _email ;

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'メールアドレス'),
                onChanged: (value){
                  _email = value;

                },
              ),
              ElevatedButton(
                child: Text('次へ'),
                onPressed:(){

                  //次のページメールアドレスを共有

                  if (_email != null) {
                    Navigator.pushNamed(context, '/signup_password_page', arguments: _email);
                  } else {
                    // emailがnullの場合の処理 (例: エラーメッセージを表示)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('メールアドレスを入力してください'),
                      ),
                    );
                  }
                  /*Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) {
                        return SignupPasswordPage();})
                  );*/
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}