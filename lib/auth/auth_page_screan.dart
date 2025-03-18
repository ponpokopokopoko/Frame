import 'package:flutter/material.dart';
import 'package:frame/auth/auth_page_form.dart';

//アニメーション理解する

// 表示/非表示の状態を管理するProvider
class AuthPageScrean extends StatefulWidget {
  final Future<void> Function()  func;//google認証の関数
  const AuthPageScrean({super.key,required this.func});

  @override
  _AuthPageScreanState createState() => _AuthPageScreanState();
}

class _AuthPageScreanState extends State<AuthPageScrean>
    with SingleTickerProviderStateMixin {
  //with キーワードを使ってミックスイン（mixin）

  bool _loginIsVisible = false; // ログイン入力欄の表示/非表示を管理する変数
  String loginErrorMessage = '';

  bool _signUpIsVisible = false; // 登録入力欄の表示/非表示を管理する変数
  String signUpErrorMessage = '';

  late AnimationController _controller;
  late Animation<Offset> _offset;//Animation<Offset>は多分2次元アニメの型です
  //Animation<Offset>は、アニメーションの進行に伴ってOffset型の値が変化するアニメーションオブジェクト
  // Offsetは、2次元の座標を表すクラスで、ここではスライドインアニメーションの位置変化を表現するために使用

  @override
  void initState() {
    super.initState();
    //コントローラにアニメコントローラを代入して初期化
    _controller = AnimationController(
      vsync: this,
      //アニメーションの同期に使用されるTickerProviderを指定
      // thisは、現在のStateオブジェクトがTickerProviderを実装していることを示す
      duration: const Duration(milliseconds: 300),//再生時間の指定
    );
    //オフセットに2次元アニメーションを代入
    _offset = Tween<Offset>(//Tween<Offset>( ... ): Offset型の値の変化を定義
      begin: const Offset(0, -1), // 初期位置（上方向に隠れている）
      end: const Offset(0, 0), // 最終位置（表示される）
    ).animate(CurvedAnimation(//CurvedAnimation( ... ): アニメーションの速度変化をいじる
      parent: _controller,//アニメーションの進行を制御するAnimationControllerを指定
      curve: Curves.easeInOut,//アニメーションの速度変化にeaseInOutカーブを使用
      // easeInOutカーブは、アニメーションの開始時と終了時に緩やかに速度が変化する効果を与える
    ));
  }

  @override
  void dispose() {//StatefulWidgetが破棄される際に呼ばれるメソッド
    // AnimationControllerを破棄し、リソースを解放します。
    _controller.dispose();
    super.dispose();// 親クラスのdispose()メソッドを呼び出します
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          color: Colors.black87,
          //width: MediaQuery.of(context).size.width*0.6,
          child: Card(
            color: Colors.white,
            child:Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12,),

                  //Frameの部分
                  const Text('Frame',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 40),),
                  const SizedBox(height: 8,),
                  // メールアドレス入力
                  // ユーザー登録ボタン
                  const Divider(//Divider：ただの線です
                    color: Colors.grey,
                    thickness: 1,
                    indent: 300,
                    endIndent: 300,
                  ),

                  //入力フォームの部分
                  Container(
                    height: 370,
                    width: 370,
                    padding:const EdgeInsets.all(20),
                      /*decoration: BoxDecoration(
                        border: Border.all(
                          strokeAlign: 12,
                          color: Colors.grey, // 枠線の色
                          width: 1.0, // 枠線の太さ
                        ), ),*/

                      child:  Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //ログイン
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                              child: const Text('ログイン',style: TextStyle(color: Colors.black),),
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
                              position: _offset,//Animation型（アニメーションの情報）を渡す
                              child: Offstage( // Offstageで表示/非表示を切り替え
                                offstage: !_loginIsVisible,
                                child: const AuthPageForm(which: 'Login'),
                              )
                          ),

                          const SizedBox(height: 15),

                          //ユーザー登録ボタン
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                              child: const Text('アカウントを作成',style: TextStyle(color: Colors.black)),
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

                          SlideTransition( // 子widgetをスライドアニメーションする機能を持つ
                              position: _offset,
                              child: Offstage( // Offstageで表示/非表示を切り替え
                                offstage: !_signUpIsVisible,
                                child: AuthPageForm(which: 'Login'),
                              )
                          ),

                          const SizedBox(height: 15),

                          //googelログイン
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white
                            ),
                            onPressed: widget.func,
                            child: const Text('Google でログイン',style: TextStyle(color: Colors.black)),
                          )
                        ],
                      )
                  )
                ],
              ),
            ) ,
          ),
        )
    );
  }
}