import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frame/auth/auth_page.dart';
import 'package:frame/home/my_account/my_account_top.dart';
import 'package:frame/home/new_post_page.dart';
import 'package:frame/home/search/search_top_page.dart';
import 'package:frame/home/timeline_page.dart';
import 'package:frame/like_bookmark_view.dart';

//NavigationRail(画面横に固定表示)
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  int _selectedIndex = 0;
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
            ?LikeBookmarkView(uid: uid, select: 'bookmark') // ブックマーク画面 Widget を返す
            :const AuthPage(); // 認証画面 Widget を返す
      default:
        return Container(); // デフォルトは空の Container
    }
  }

/*
class BottomBar extends StatelessWidget {
  BottomBar({super.key});

  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context){
    return BottomAppBar(
      child: Container(
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //ホーム(TL)
            IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return TimelinePage();
                    }),
                  );
                }
            ),

            //検索
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return SearchTopPage();
                  }),
                );
              },
            ),

            //投稿
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return NewPostPage();
                  }),
                );
              },
            ),
            //マイページ
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return MyAccountTopPage();
                  }),
                );
              },
            ),
            //ブックマーク
            (uid != null)
                ?IconButton(
                 //別画面飛ぶ
                    onPressed:  () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return LikeBookmarkView(uid: uid, select: 'bookmark');
                        }),
                      );
                    },
                    icon: const Icon(Icons.bookmark_border_outlined))
                :const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}*/

// 画面遷移などの処理
/*switch (index) {

                  //ホーム
                    case 0:Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return TimelinePage();}));
                    break;
                  //発見
                    case 1:Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return const SearchTopPage();}));
                    break;
                  //投稿
                    case 2:Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return const NewPostPage();}));
                    break;
                  //マイページ
                    case 3 :Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context){
                          return const MyAccountTopPage();
                        })
                    );
                    break;
                  //ブックマーク
                    case 4:Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return (uid != null)
                              ?LikeBookmarkView(uid: uid, select: 'bookmark')
                              :const AuthPage();
                        }));
                    break;
                  }
         */