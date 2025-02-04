import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



Future<void> _toggleFollow(String followingId, String followedId) async {
  try {
    // フォローしているか確認
    DocumentSnapshot followingSnapshot = await FirebaseFirestore.instance
        .collection('follows')
        .doc(followingId)
        .get();

    // フォローリストを取得
    Map<String, dynamic>? followingData = followingSnapshot.data() as Map<String, dynamic>?;
    // フォロー/フォロー解除
    bool followCheck = followingData?['myFollowingList'].contains(followedId);
    //フォローする側のドキュメント
    await FirebaseFirestore.instance
        .collection('follows')
        .doc(followingId)
        .update({
      'myFollowingList': followCheck
          ? FieldValue.arrayRemove([followedId])//trueすでに登録されてた場合はmyFollowingListから相手を削除
          : FieldValue.arrayUnion([followedId]),//false
      'myFollowingCount': followCheck
          ? FieldValue.increment(-1)
          : FieldValue.increment(1),
    });
    //される側のドキュメント
    await FirebaseFirestore.instance
        .collection('follows')
        .doc(followedId)
        .update({
      'myFollowerList': followCheck
          ? FieldValue.arrayRemove([followingId])//trueすでに登録されてた場合はmyFollowerListから削除
          : FieldValue.arrayUnion([followingId]),
      'myFollowerCount': followCheck
          ? FieldValue.increment(-1)
          : FieldValue.increment(1),
    });
  } catch (e) {
    print('Error: $e');
  }
}

class FollowButton extends StatefulWidget{

  final String followedId;

  const FollowButton ({super.key,required this.followedId});
  @override
  State<FollowButton> createState() => _FollowButtonState()  ;
}

class _FollowButtonState extends State<FollowButton>{
  late bool _isFollowed;
  String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '未登録';

  @override
  Widget build (BuildContext context){
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance//ボタン実行者のフォローリスト取得
            .collection('follows')
            .doc(currentUid)
            .snapshots(),
        builder: (context, snapshot) {

          //followsにドキュメントがある場合はフォローしてるかチェック
          if(snapshot.data!.data() != null){
            Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
            //List<String> followList = userData['myFollowingList']as List<String> ;
            //なんでこのコードがダメなのかを考えろ
            if ( userData['myFollowingList'].contains(widget.followedId)) {
              _isFollowed = true;
            } else {
              _isFollowed = false;
            }
          }else{
            //followsにドキュメントがない場合はフォローしてない判定
            _isFollowed = false;
          }

          return ElevatedButton(
                child: Text(
                  _isFollowed
                      ? 'フォロー中' //　?trueのとき
                      : 'フォロー',// :falseのとき
                ),
                onPressed: () async{
                  if (currentUid == '未登録') {
                    print('ログインしてください');
                  } else {
                    //フォロー関係のFirestore処理// 状態を更新
                    await _toggleFollow(currentUid, widget.followedId);
                    setState(() {
                      _isFollowed = !_isFollowed;
                    });
                  }
                }
          );
        }
    );
  }
}











/*
// 1. フォロー中のユーザーリストの　Stream の提供
final followsStreamProvider = StreamProvider.family<DocumentSnapshot?, String>((ref, targetUserId) {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid; // ログインユーザーID
  return FirebaseFirestore.instance
      .collection('follows')
      .doc(currentUserId)
      .snapshots();
});

// 2. StateNotifierProviderによる状態管理
class IsFollowingNotifier extends StateNotifier<bool?> {
  final String currentUserId;
  final String targetUserId;
  IsFollowingNotifier(this.currentUserId, this.targetUserId): super(null);

  Future<bool> fetchFollowingStatus() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('follows')
        .doc(currentUserId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      final following = data['following'] as List<dynamic> ?? [];
      return state = following.contains(targetUserId);
    } else {
      return state = false;
    }
  }

  Future<void> toggle(String followingId, String followedId ) async {
    await _toggleFollow(followingId, followedId);
    state = !state!;
  }
}

final isFollowingProvider = StateNotifierProvider.family<IsFollowingNotifier, bool, String>(
      (ref, targetUserId) => IsFollowingNotifier(
          FirebaseAuth.instance.currentUser!.uid, targetUserId
      )..fetchFollowingStatus(),
);

//フォローボタン
class FollowButtom extends ConsumerWidget{
  final String followedId; //相手側（フォローされるユーザー）
  FollowButtom({super.key, required this.followedId});
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '未登録';

  @override
  Widget build(BuildContext context,WidgetRef ref){
    ref.read(isFollowingProvider(followedId).notifier).fetchFollowingStatus()//Providerのbool値を参照

    return ElevatedButton(
               child: Text(
                 ref.read(isFollowingProvider(followedId).notifier).fetchFollowingStatus()//Providerのbool値を参照
                     ? 'フォロー中' //　?trueのとき
                     : 'フォロー',// :falseのとき
               ),
               onPressed: () async{
                 if (currentUid == '未登録') {
                   print('ログインしてください');
                 } else {
                   //フォロー関係のFirestore処理// 状態を更新
                   await ref.read(isFollowingProvider(followedId).notifier).toggle(currentUid, followedId);

                 }
               });

        }
}*/

