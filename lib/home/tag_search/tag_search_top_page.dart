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
    return  Column(
      children: [
        const Text('タグ検索',
          style:TextStyle(
              fontSize: 22,
              color: Colors.white
          ) ,),
        const Divider(
          thickness: 4,
          color: Colors.grey,
        ),

        Row(
          children: [
            Text('タグ検索:#',style: TextStyle(color: Colors.white),),
            SizedBox(
              width: 100,
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  focusColor: Colors.white,
                  hoverColor: Colors.white,
                  //filled: true,
                  //fillColor: Colors.white,
                  //border: OutlineInputBorder(
                      //borderSide: BorderSide(color: Colors.grey)),
                    //labelText: '#',
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
                icon: Icon(Icons.search_outlined,color: Colors.white,)
            )
          ],
        ),

        Container(
          padding: EdgeInsets.all(10),
          child: Text('#${tag}の検索結果',
            style: const TextStyle(
              fontSize:20,
              color: Colors.white
            ) ,),
        ),
        Expanded(
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
                  return Text('Something went wrong',style: TextStyle(color: Colors.white),);
                }
                //成功した場合
                else if(snapshot.hasData && snapshot.data!.docs.isNotEmpty){
                  return Flexible(
                      child:PostsGridviewPart(snapshot: snapshot)
                  );
                }
                else {
                  return Text('投稿の取得に失敗しました',style: TextStyle(color: Colors.white));
                }
              }
          ),
        ),
      ],
    );
  }
}