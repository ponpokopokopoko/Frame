import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frame/home/timeline_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//エラーメッセージをRiverpodで管理する
final errorMessageNotifierProvider = StateNotifierProvider<ErrorMessageNotifier, String?>((ref) => ErrorMessageNotifier());

// 状態を管理する StateNotifierProvider
class ErrorMessageNotifier extends StateNotifier<String?> {
  ErrorMessageNotifier() : super(null);

  void updateState(String? newValue) {
    state = newValue;
  }
}

//consumerstatefulwidgetで離れたらエラー消し
class AuthPageForm extends ConsumerStatefulWidget {
  final String which; //SignUpかLoginか
  const AuthPageForm({super.key, required this.which});

  @override
  ConsumerState<AuthPageForm> createState() => _AuthPageFormState();
}
class _AuthPageFormState extends ConsumerState<AuthPageForm>{

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build (BuildContext context){
    final errorMessage = ref.watch(errorMessageNotifierProvider);
    final _passwordController = TextEditingController();
    final _emailController = TextEditingController();

    return Container(
      height: 200,
      width: 400,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'メールアドレス'),
            controller:  _emailController,
            focusNode: _emailFocusNode,
            //keyboardType: TextInputType.emailAddress, // TextInputType (必要に応じて)
            onEditingComplete: () {
               ref.read(errorMessageNotifierProvider.notifier).updateState(null);
            },
            validator: (value) { // バリデーション (必要に応じて)
              if (value == null || value.isEmpty) {
                return 'メールアドレスを入力してください';
              }
              return null;
            },
          ),

          SizedBox(height: 8),

          TextFormField(
            decoration: InputDecoration(labelText: 'パスワード'),
            controller: _passwordController,
            //フォームに入力されたらエラーメッセージの表示を消す
           // onChanged: ref.read(errorMessageProvider.notifier).state = null,
            focusNode: _passwordFocusNode,
            obscureText: true, // パスワードを隠す
            onEditingComplete: () {
              ref.read(errorMessageNotifierProvider.notifier).updateState(null);
            },
            validator: (value) { // バリデーション (必要に応じて)
              if (value == null || value.isEmpty) {
                return 'パスワードを入力してください';
              }
              return null;
            },
          ),

          // エラーメッセージを表示する部分
          //visivilityだとエラーなる
          if (errorMessage != null)
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red), // エラーメッセージの色を変更
            ),
          SizedBox(width: 8),

          ElevatedButton(
              child: Text('実行'),
              //登録かログインの処理
              //keyを受け取って条件分岐
              onPressed: ()async{
                if(widget.which == 'Login'){
                  //ログイン
                  final value = await LoginFunc(_emailController.text, _passwordController.text, context);
                  if(value is String){
                    ref.read(errorMessageNotifierProvider.notifier).updateState(value);
                }else{
                  //登録処理
                  //成功したら遷移、失敗したらエラーメッセージ
                  final value = await SignUpFunc(_emailController.text, _passwordController.text, context);
                  if(value is String){
                    ref.read(errorMessageNotifierProvider.notifier).updateState(value);
                  }
                  }
                }
              }
          ),
        ],
      ),
    );
  }
}

//登録処理をする関数
Future<String?> SignUpFunc (String email,String password,BuildContext context)async{
  try {
    // メール/パスワードで登録
    final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    //認証成功してログイン状態変わったらFireStoreにユーザー情報を登録する
    await FirebaseAuth.instance.authStateChanges().listen((User? user) async{
      if (user != null) {
        // 認証成功した場合:Firestoreに登録
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDoc.set({
          'email': user.email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(), // サーバー時刻で作成日時を記録
          'backgroundImage': '', //準備できたら初期画像？
          'iconImage': '', //初期画像
          'userName': 'unknown',//もしくはnoname
          'userId': user.uid.substring(0, 9),//初期ID(uidの頭８文字)
        });
        await FirebaseFirestore.instance.collection('follows').doc(user.uid)
            .set({
          'myFollowingList':[],//空のリスト、ここにフォロー関係のUidが入る
          'myFollowerList':[],
          'myFollowingCount':0,
          'myFollowerCount':0
        });
        // 登録に成功した場合
        // ユーザー設定画面に遷移＋登録画面を破棄
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return TimelinePage();
          }),
        );
      }
    });
  } catch (e) {// 登録に失敗した場合エラーメッセージを返す
    final String message = 'エラーが発生しました: $e';
    //ref.read(errorMessageProvider.notifier).state = '$e';
    return message;
  }
  return null;
}

//ログイン処理をする関数
Future<String?> LoginFunc (String email,String password,BuildContext context)async{
  try {
    // メール/パスワードでログイン
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // ログインに成功した場合
    // チャット画面に遷移＋ログイン画面を破棄
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) {
        return TimelinePage();
      }),
    );
  } catch (e) {
    // ログインに失敗した場合
    // エラーメッセージを設定
    String message = 'エラーどす$e';
    return message;
  }
  return null;
}