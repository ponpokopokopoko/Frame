import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frame/home/other_user_profile_page.dart';
import 'package:frame/ui_widgets/buttons/follow_button.dart';
import 'package:frame/ui_widgets/post_parts/post_icon_image_widget.dart';

class FollowsListview extends StatefulWidget{
  final Map<String ,dynamic> data ;
  const FollowsListview({super.key,required this.data});
  @override
  State<FollowsListview> createState() => _FollowsListviewState();
}

class _FollowsListviewState extends State<FollowsListview>{
  String follows = 'フォロー';


  @override

  Widget build(BuildContext context){
    final followers = widget.data['myFollowerList'] as List<dynamic> ;
    final following = widget.data['myFollowingList'] as List<dynamic>;

    return Scaffold(
      //backgroundColor: Colors.black87,
      body: Column(
        children: [
         SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child:Padding(
                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        child:  Text('フォロー',
                          style: TextStyle(
                            fontSize: 30,
                              color: (follows == 'フォロー')
                                  ? Colors.black
                                  :Colors.black45
                          )
                        )
                      ),
                      onTap: (){setState(() {follows = 'フォロー';});},
                    ),
                    GestureDetector(
                      child:Padding(
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        child: Text('フォロワー',
                          style: TextStyle(
                              fontSize: 30,
                              //fontWeight: FontWeight.w100,
                              color: (follows == 'フォロワー')
                                  ? Colors.black
                                  :Colors.black45
                          ),
                        ),
                      ) ,
                      onTap: (){setState(() {follows = 'フォロワー';});},
                    ),
                  ],
                ),
          ),
          SizedBox(height: 15,),
          Container(
            width: 500,
            alignment: Alignment.center,
            child: (follows == 'フォロー')
                ?_buildUserList(follows, following)//フォロー
                :_buildUserList(follows, followers),//フォロワー
            )
          ],
        ),
    );
  }
  Widget _buildUserList(String title, List<dynamic> userIds) {
    return Wrap(
      children: [
        Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            (userIds.length == 0 )
                ?Text('情報がありません')
                :ListView.builder(
              shrinkWrap: true,
              itemCount: userIds.length,
              itemBuilder: (context, index) {
                final userId = userIds[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    final userData = snapshot.data!.data() as Map<String, dynamic>;
                    return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 3),
                        leading:PostIconImage(
                          iconImage: userData['iconImage'],
                          iconSize: 40,
                          onTap: (){
                            Navigator.pushNamed(
                                context, '/other_user_profile_page',
                                arguments: userData['uid']);
                          },
                        ),
                        title: Row(
                          children: [
                            SizedBox(
                                width:120,
                                child: Text(userData['userName']??'')
                            ),
                            SizedBox(width: 5,),
                            FollowButton(followedId: userData['uid'])
                          ],
                        )
                    );
                  },
                );
              },
            ),
          ],
        )
      ],
    );
  }
}
