
import 'package:flutter/material.dart';
import 'package:frame/sign_up/signup_setting_page.dart';


class SignupCodePage extends StatefulWidget{
  const SignupCodePage({super.key});

  @override
  State<SignupCodePage> createState()  => _SignupCodePageState();
}
class _SignupCodePageState extends  State<SignupCodePage>{


  final _verificationController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              TextFormField(
                enabled: false,
                decoration: InputDecoration(labelText: ''),
              ),

              TextFormField(
                decoration: InputDecoration(labelText: '認証コード'),
                controller: _verificationController,
              ),
              ElevatedButton(
                child: Text('次へ'),
                onPressed: (){
                    Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) {
                      return SignupSettingPage();}),
                    );
                    //return SignupSettingPage();
                },
              ),


                /*onPressed: () async {
                  try {
                    // 認証コードを使ってユーザーを認証
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final result = await FirebaseAuth.instance.signInWithCredential(
                      EmailAuthProvider.credential(
                        email: '{$Email?.email}',
                        password:  _verificationController.text,
                      ),
                    );
                    // 認証成功時の処理
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return SignupSettingPage();
                        })
                    );
                  } catch (e) {
                    // 認証失敗時の処理
                  }
                },*/
            ],
          ),
        ),
      ),
    );
  }
}