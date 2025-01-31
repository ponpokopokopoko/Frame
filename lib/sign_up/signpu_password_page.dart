import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frame/auth_page.dart';
import 'package:frame/sign_up/signup_code_page.dart';




class SignupPasswordPage extends StatefulWidget {
  const SignupPasswordPage({super.key});

  @override
  State<SignupPasswordPage> createState() => _SignupPasswordPageState();
}

class _SignupPasswordPageState extends State<SignupPasswordPage> {

  final _passwordController = TextEditingController();
  String errorMessage = '';

  /*//Firestoreにユーザー情報を登録する関数
  Future<void> saveUserDataToFirestore(User user) async {
    debugPrint('5');
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    String uid = result.user!.uid;
    debugPrint('6');
    await userDoc.set({
      'name': '山田太郎', // ユーザー名
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(), // サーバー時刻で作成日時を記録
    });
  }*/

  @override
  Widget build(BuildContext context) {

    //final email = ModalRoute.of(context)?.settings.arguments as String;
    final email = ModalRoute.of(context)?.settings.arguments;



    if (email is String) {
      return Scaffold(
        body: Center(
          child: Container(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                TextFormField(
                  enabled: false,
                  decoration: InputDecoration(labelText: email),
                ),
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
                  visible: errorMessage != null,
                  child: SelectableText(errorMessage),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                ),
                ElevatedButton(
                  child: Text('次へ'),
                  onPressed: () async {
                    try {
                      // メール/パスワードで登録
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: _passwordController.text,
                      );

                      //FireStoreにユーザー情報を登録する
                      await auth.authStateChanges().listen((User? user) async{

                        if (user != null) {
                          // 認証成功した場合:Firestoreに登録
                          final userDoc = FirebaseFirestore.instance.collection('users').doc(result.user!.uid);
                          await userDoc.set({
                            'email': result.user!.email,
                            'uid': result.user!.uid,
                            'createdAt': FieldValue.serverTimestamp(), // サーバー時刻で作成日時を記録
                          });
                        }else{
                          debugPrint('5');
                        }
                      });

                      // 認証メールを送信
                      //await result.user!.sendEmailVerification();

                      // 登録に成功した場合
                      ///エラー表示をclearする（出来てるかわからない）
                      //ErrorMessageNotifier.clearValue();
                      // ユーザー設定画面に遷移＋登録画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return SignupCodePage();
                        }),
                      );
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