import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frame/auth_page.dart';
import 'login_password.dart';


class LoginEmailPage extends StatefulWidget{
  const LoginEmailPage({super.key});
  @override
  State<LoginEmailPage> createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage>{

  String? _email ='';

  @override
  Widget build(BuildContext context){

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: [
              TextFormField(
                //状態管理の箱に入れる
                onChanged: (value) {
                  _email = value;
                },
                decoration: InputDecoration(labelText: 'メールアドレス'),

              ),

              ElevatedButton(
                  child: Text('次へ'),
                  onPressed:(){
                    //次のページメールアドレスを共有

                    if (_email != null) {
                      Navigator.pushNamed(context, '/login_password', arguments: _email);
                    } else {
                      // emailがnullの場合の処理 (例: エラーメッセージを表示)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('メールアドレスを入力してください'),
                        ),
                      );
                    }
                  },
              ),
            ]
          ),
        )
      )
    );
  }

}