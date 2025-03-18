import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frame/auth/auth_page.dart';
import 'package:frame/home/my_account/my_account_top.dart';
import 'package:frame/home/new_post_page.dart';
import 'package:frame/home/search/search_top_page.dart';
import 'package:frame/home/timeline_page.dart';
import 'package:frame/like_bookmark_view.dart';

class NavigationRailPart extends StatefulWidget {

  final dynamic widgetUI;
  const NavigationRailPart({super.key, required this.widgetUI});

  @override
  State<NavigationRailPart> createState() => _MainPage();
}

class _MainPage extends State<NavigationRailPart> {
  int _selectedIndex = 5;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
            children: [

              NavigationRail(
                minWidth: 120,
                indicatorColor: Colors.black26,
                backgroundColor: Colors.white,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    debugPrint('set');
                    _selectedIndex = index; // 選択されたインデックスを更新
                  });
                },
                destinations: [
                  //ホーム
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('ホーム'),
                  ),
                  //発見
                  NavigationRailDestination(
                    icon: Icon(Icons.tag),
                    label: Text('発見'),
                  ),
                  //投稿
                  NavigationRailDestination(
                    icon: Icon(Icons.add_box_outlined),
                    label: Text('投稿'),
                  ),
                  //プロフィール
                  const NavigationRailDestination(
                    icon: Icon(Icons.person),
                    label: Text('プロフィール'),
                  ),
                  //ブックマーク
                  (FirebaseAuth.instance.currentUser?.uid != null)
                      ? const NavigationRailDestination(
                    icon: Icon(Icons.bookmark_border_outlined),
                    label: Text('ブックマーク'),
                  )
                      : const NavigationRailDestination(
                    icon: Icon(Icons.login_outlined),
                    label: Text('ログイン'),
                  ),
                  //空虚

                  const NavigationRailDestination(
                    icon: Icon(Icons.person,color: Colors.white10,),
                    label: Text('プロフィール'),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  color: Colors.black87,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
                  padding: const EdgeInsets.all(15),
                  child: _buildContentArea(_selectedIndex),

                ),)
            ])
    );
  }

// コンテンツ領域を切り替える Widget
  Widget _buildContentArea(int index) {
    switch (index) {
      case 0:
        return TimelinePage(); // ホーム画面 Widget を返す
      case 1:
        return const SearchTopPage(); // 発見画面 Widget を返す
      case 2:
        return const NewPostPage(); // 投稿画面 Widget を返す
      case 3:
        return const MyAccountTopPage(); // マイページ Widget を返す
      case 4:
        final uid = FirebaseAuth.instance.currentUser?.uid;
        return (uid != null)
            ? LikeBookmarkView(
            uid: uid, select: 'bookmark') // ブックマーク画面 Widget を返す
            : const AuthPage(); // 認証画面 Widget を返す
      case 5:
        return widget.widgetUI;
      default:
        return Container(); // デフォルトは空の Container
    }
  }
}