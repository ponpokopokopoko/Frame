import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frame/home/make_timeline/make_timeline_list_contents.dart';
import 'package:frame/home/make_timeline/make_timeline_list.dart';
import 'package:frame/home/make_timeline/post_repository.dart';

//タイムラインの表示を管理するファイルです

//ページ下にこれ関連のコードあり
// providerの定義 (StateProvider -> ChangeNotifierProviderに変更)
final expressProvider = StateProvider<String>((ref) => '最新');


class TimelinePage extends ConsumerStatefulWidget { // ConsumerStatefulWidgetに変更
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> { // ConsumerStateに変更

  //ページネーション
  final ScrollController _scrollController = ScrollController(); // ← これを追加

  @override
  //始めに表示する投稿を取得
  void initState() {
    super.initState();
    ref.read(timelineProvider.notifier).fetchFirstPagePosts(); // 初期データ取得
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //スクロール位置が変化したときに呼ばれる
  void _scrollListener() {
    //現在の自分のスクロール位置＝スクロール可能最大値　の場合次の投稿が非同期で読み込まれる
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      ref.read(timelineProvider.notifier).fetchNextPagePosts(); // 次のページを読み込む
    }
  }

  @override

  Widget build(BuildContext context) {
    return  Column(
        children: [
          Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [

             const SizedBox(width: 10,),
             Text(ref.watch(expressProvider),
                  style:const TextStyle(
                      fontSize: 24,
                      color: Colors.white) ,),

              const Spacer(),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                   backgroundColor: (ref.watch(expressProvider) != '最新')
                       ?Colors.white38
                       :Colors.white,
                    foregroundColor: Colors.black87,
                   ),
                  onPressed:(){
                    ref.read(expressProvider.notifier).state = '最新';
                    ref.read(timelineProvider.notifier).fetchFirstPagePosts(); // データ再取得
                  },
                  child: const Text('最新')),
              const SizedBox(width: 15),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (ref.watch(expressProvider) != 'フォロー')
                        ?Colors.white38
                        :Colors.white,
                    foregroundColor: Colors.black87,
                  ),
                  onPressed:(){
                    ref.read(expressProvider.notifier).state = 'フォロー';
                    ref.read(timelineProvider.notifier).fetchFirstPagePosts(); // データ再取得
                  },
                  child: const Text('フォロー')),


            ],),
          const Divider(
          color: Colors.grey, // 線の色
          thickness: 4.0, // 線の太さ
          //indent: 20.0, // 左側の余白
          //endIndent: 20.0, // 右側の余白
           ),
          const Expanded(child: MakeTimelineList()),
        ],
      );
  }
}


// TimelineProvider (ChangeNotifierProviderとして定義)
final timelineProvider = ChangeNotifierProvider<TimelineNotifier>((ref) => TimelineNotifier(ref));

//投稿を取得するクラス
class TimelineNotifier extends ChangeNotifier {
  final Ref ref; // Refを追加
  TimelineNotifier(this.ref); // コンストラクタでRefを受け取る

  List<timelinePost> _posts = [];
  List<timelinePost> get posts => _posts;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  DocumentSnapshot? _lastDocument;

  String get express => ref.read(expressProvider); // expressProviderの状態を読み取る

  Future<void> fetchFirstPagePosts() async {
    _posts = [];
    _isLoading = true;
    _hasMore = true;
    _lastDocument = null;
    notifyListeners();
    await _fetchPosts();
  }

  Future<void> fetchNextPagePosts() async {
    if (!_hasMore || _isLoading) return;
    _isLoading = true;
    notifyListeners();
    await _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    debugPrint('a');
    Query<Map<String, dynamic>> query;

    String uid = FirebaseAuth.instance.currentUser?.uid ?? '未登録';
    final postRepository = PostRepository(); // PostRepositoryをインスタンス化

    if (express == '最新') {
      query = postRepository.fetchLatestPostsQuery(); // クエリを関数として取得
    } else {
      List<dynamic> follow = await postRepository.getFollowingUserIds(uid);
      if (follow != [] && follow.isNotEmpty && follow.first != null) {
        debugPrint('follow.isNotEmpty');
        query = postRepository.fetchFollowingPostsQuery(follow); // クエリを関数として取得
      } else {
        debugPrint('follow.isEmpty');
        query = postRepository.fetchLatestPostsQuery(); // フォローしていない場合は最新投稿
      }
    }

    query = query.limit(15); // 1ページの件数制限

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      _hasMore = false;
    } else {
      _lastDocument = snapshot.docs.last;
      final List<timelinePost> newPosts = await Future.wait( snapshot.docs.map((doc) async{

        DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(doc.data()['userUid'])
            .get();

        if(snapshot.exists && snapshot.data()!.isNotEmpty){
          debugPrint('User取得成功');
          return timelinePost.fromJson(doc.data() , doc.id, snapshot.data()!);
        }
        else{//基本ここには来ない
          debugPrint('User取得失敗');
          return timelinePost(
            postId: doc.id,
            imageUrl:doc.data()['imageUrl'],
            tags:doc.data()['tags'],
            caption: doc.data()['caption'] ,
            userUid: doc.data()['userUid'] ,
            createdAt: doc.data()['createdAt'] ,
            like:doc.data()['like'],
            bookmark:doc.data()['bookmark'],
            userId: '' ,
            iconUrl: '',
          );
        }

      }).toList());
      _posts.addAll(newPosts);
    }

    _isLoading = false;
    notifyListeners();
  }
}

// MakeTimelineList (ConsumerWidgetに変更)
class MakeTimelineList extends ConsumerWidget {
  const MakeTimelineList({super.key});

  @override

  Widget build(BuildContext context, WidgetRef ref) { // WidgetRefを受け取る
    final timelineState = ref.watch(timelineProvider); // StateProviderではなくChangeNotifierProviderをwatch
    if (timelineState.isLoading /*&& timelineState.posts.isEmpty*/) {
      return const Center(child: CircularProgressIndicator());
    }

    if ((timelineState.posts.isEmpty && !timelineState.hasMore && !timelineState.isLoading)
        /*|| (timelineState.posts.length == 0)*/) {
      return const Center(child: Text('投稿データがありません'));
    }

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final post = timelineState.posts[index];
              return MakeTimelineListContents(post: post); // PostCardにPostオブジェクトを渡す
            },
            childCount: timelineState.posts.length,
          ),
        ),
        if (timelineState.isLoading && timelineState.posts.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        if (timelineState.hasMore && timelineState.posts.isNotEmpty && !timelineState.isLoading)
          SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
      ],
    );
  }
}
