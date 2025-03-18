import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Stream<DocumentSnapshot<Map<String, dynamic>>> postStream (dynamic postId){
  return FirebaseFirestore
      .instance
      .collection('posts')
      .doc(postId)
      .snapshots();
}


//いいねのカウント
class RealtimeLikeCount extends StatefulWidget{

  final postId;
  const RealtimeLikeCount({super.key, required this.postId});

  @override
  State<RealtimeLikeCount> createState() => _RealtimeLikeCountState();
}

class _RealtimeLikeCountState extends State<RealtimeLikeCount>{

  @override
  Widget build (BuildContext context){
    return StreamBuilder(
        stream: postStream(widget.postId),
        builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting ){
            return const CircularProgressIndicator();
          }
          if(snapshot.hasData && snapshot.data!.data() != null ){
            final data = snapshot.data!.data() as Map<String,dynamic>;
            return Text(data['like'].toString());
          }
          else{
            return const Text('0');
          }
        });
  }
}



///ブックマークのカウント

class RealtimeBookmarkCount extends StatefulWidget{

  final postId;
  const RealtimeBookmarkCount({super.key, required this.postId});

  @override
  State<RealtimeBookmarkCount> createState() => _RealtimeBookmarkCountState();
}

class _RealtimeBookmarkCountState extends State<RealtimeBookmarkCount>{

  @override
  Widget build (BuildContext context){
    return StreamBuilder(
        stream: postStream(widget.postId),
        builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting ){
            return const CircularProgressIndicator();
          }
          if(snapshot.hasData && snapshot.data!.data() != null){
            final data = snapshot.data!.data() as Map<String,dynamic>;
            return Text(data['bookmark'].toString());
          }
          else{
            return const Text('0');
          }
        });
  }
}