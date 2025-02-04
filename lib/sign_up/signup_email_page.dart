import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frame/sign_up/signup_setting_page.dart';

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

  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context){
    return  Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'メールアドレス'),
                controller:  _emailController,
              ),

              SizedBox(height: 8),

              TextFormField(
                decoration: InputDecoration(labelText: 'パスワード'),
                controller: _passwordController,
                obscureText: true,
                onChanged: (value){
                  setState(() {
                    errorMessage = '';
                  });
                },
              ),

              Visibility(
                visible: errorMessage != '',
                child: SelectableText(errorMessage),
              ),
              SizedBox(width: 8),

              ElevatedButton(
                child: Text('登録'),
                onPressed: () async {
                  try {
                    // メール/パスワードで登録
                    final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    //認証成功してログイン状態変わったらFireStoreにユーザー情報を登録する
                    await FirebaseAuth.instance.authStateChanges().listen((User? user) async{
                      if (user != null) {
                        // 認証成功した場合:Firestoreに登録
                        final userDoc = FirebaseFirestore.instance.collection('users').doc(result.user!.uid);
                        await userDoc.set({
                          'email': result.user!.email,
                          'uid': result.user!.uid,
                          'createdAt': FieldValue.serverTimestamp(), // サーバー時刻で作成日時を記録
                        });
                        // 登録に成功した場合
                        // ユーザー設定画面に遷移＋登録画面を破棄
                        await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                            return SignupSettingPage();
                          }),
                        );
                      }
                    });
                  } catch (e) {
                    // 登録に失敗した場合
                    // エラーメッセージを設定
                    setState(() {
                      errorMessage = 'エラーが発生しました: $e';
                    });
                  }
                },
              ),
            ],
          ),
        );
  }
}