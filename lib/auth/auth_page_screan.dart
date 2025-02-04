import 'package:flutter/material.dart';
import 'package:frame/auth/auth_page_form.dart';

// 表示/非表示の状態を管理するProvider
class AuthPageScrean extends StatefulWidget {
  final Future<void> Function()  func;

  const AuthPageScrean({super.key,required this.func});

  @override
  _AuthPageScreanState createState() => _AuthPageScreanState();
}

class _AuthPageScreanState extends State<AuthPageScrean>
    with SingleTickerProviderStateMixin {

  bool _loginIsVisible = false; // ログイン入力欄の表示/非表示を管理する変数
  String loginErrorMessage = '';

  bool _signUpIsVisible = false; // 登録入力欄の表示/非表示を管理する変数
  String signUpErrorMessage = '';

  late AnimationController _controller;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, -1), // 初期位置（上方向に隠れている）
      end: const Offset(0, 0), // 最終位置（表示される）
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: Center(
          child: Column(
            children: [
              // メールアドレス入力
              // ユーザー登録ボタン
              ElevatedButton(
                  child: Text('ログイン'),
                  // ボタンが押されたらログインフォームの表示/非表示を切り替える
                  onPressed: () {
                    setState(() {
                      debugPrint('trne');
                      _loginIsVisible = !_loginIsVisible;
                      _signUpIsVisible = false;//反対のフォームしまう
                      if (_loginIsVisible) {
                        _controller.forward(); // アニメーション開始
                      } else {
                        _controller.reverse(); // アニメーション逆再生
                      }
                    });

                  }
              ),

              SlideTransition( // スライドアニメーション
                  position: _offset,
                  child: Offstage( // Offstageで表示/非表示を切り替え
                    offstage: !_loginIsVisible,
                    child: AuthPageForm(which: 'Login'),
                  )
              ),

              SizedBox(height: 10),

              //ユーザー登録ボタン
              ElevatedButton(
                  child: Text('アカウントを作成'),
                  onPressed: () {
                    setState(() {
                      debugPrint(_signUpIsVisible.toString());
                      _signUpIsVisible = !_signUpIsVisible;//ボタンを押したらフォームを出したり消したり
                      _loginIsVisible = false;//反対のフォームしまう
                      if (_signUpIsVisible) {
                        _controller.forward(); // アニメーション開始
                      } else {
                        _controller.reverse(); // アニメーション逆再生
                      }});
                  }),

              SlideTransition( // スライドアニメーション
                  position: _offset,
                  child: Offstage( // Offstageで表示/非表示を切り替え
                    offstage: !_signUpIsVisible,
                    child: AuthPageForm(which: 'Login'),
                  )
              ),

              SizedBox(height: 8),

              ElevatedButton(
                onPressed: widget.func,
                child: Text('Google でログイン'),
              )
            ],
          ),
        )


    );
  }
}