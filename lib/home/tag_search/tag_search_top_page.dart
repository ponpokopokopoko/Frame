import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frame/home/post_detail_page.dart';
import 'package:frame/ui_widgets/posts_gridview_part.dart';

class TagSerchTopPage extends StatefulWidget{
  final String tagName;
  const TagSerchTopPage({super.key,required this.tagName});
  @override
  State<TagSerchTopPage> createState() => _TagSerchTopPageState();
}

class _TagSerchTopPageState extends State<TagSerchTopPage>{

  final _tagController = TextEditingController();
  late String tag;

  @override
  void initState() {
    tag = widget.tagName;
    super.initState();
  }

  @override
  Widget build (BuildContext context){
    return  Scaffold(
      appBar: AppBar(
        title: Text('タグ検索'),
      ),
      body: Column(
        children: [
          Container(
            child: Row(
              children: [
                Text('タグ検索'),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    decoration: InputDecoration(
                        labelText: '#'
                    ),
                    controller: _tagController,
                  ),
                ),
                IconButton(
                    onPressed: (){
                      setState(() {
                        tag =_tagController.text;
                      });
                    },
                    icon: Icon(Icons.search_outlined)
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text('#${tag}の検索結果',
              style: TextStyle(
                fontSize:20,
                fontWeight: FontWeight.bold,
              ) ,),
          ),
          Container(
            child: FutureBuilder(
                future: FirebaseFirestore.instance.collection('posts')
                    .where('tags', arrayContains: tag )
                    .orderBy('like', descending: true)
                    .limit(10)
                    .get(),
                builder: (BuildContext context , AsyncSnapshot<QuerySnapshot> snapshot) {
                  //ローディング中
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  //エラー起きたら
                  else if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  //成功した場合
                  else if(snapshot.hasData && snapshot.data!.docs.isNotEmpty){
                    return Flexible(
                        child:PostsGridviewPart(snapshot: snapshot)
                    );
                  }
                  else {
                    return Text('投稿の取得に失敗しました');
                  }
                }
            ),
          ),
        ],
      ),
    );
  }
}