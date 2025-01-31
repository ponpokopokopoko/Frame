import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frame/home/my_account/my_account_top.dart';
import 'package:frame/home/new_post_page.dart';
import 'package:frame/home/search/search_top_page.dart';
import 'package:frame/home/timeline_page.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

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
              icon: Icon(Icons.add_box_outlined),
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
          ],
        ),
      ),
    );
  }
}