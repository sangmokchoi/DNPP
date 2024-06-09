import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/LocalDataSource/firebase_realtime/blockedList/DS_Local_blockedList.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/repository/firebase_realtime_blockedList.dart';
import 'package:dnpp/repository/firebase_realtime_messages.dart';
import 'package:dnpp/view/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import '../GoogleAdMob.dart';
import '../LocalDataSource/firebase_realtime/messages/DS_Local_chat.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_badge.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_isNotificationAble.dart';
import '../models/launchUrl.dart';
import '../models/moveToOtherScreen.dart';
import '../models/userProfile.dart';
import '../notification.dart';
import '../repository/firebase_realtime_users.dart';
import '../repository/firebase_remoteConfig.dart';
import '../statusUpdate/googleAnalytics.dart';
import '../statusUpdate/CurrentPageProvider.dart';
import '../statusUpdate/loginStatusUpdate.dart';

class ChatListView extends StatefulWidget {
  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  ScrollController _BlockedListScrollController = ScrollController();
  ScrollController _chatListScrollController = ScrollController();

  ScrollController _policyScrollController = ScrollController();

  late Stream _stream;

  //late UserProfile currentUserProfile;
  late String currentUserProfileUid;



  //List<int> lastSeenList = [];

  String generateChatRoomId(
      UserProfile current, Map<String, dynamic> opponent) {
    final currentUid = current.uid;
    var opponentUid;
    if (opponent['uid'] != null) {
      opponentUid = opponent['uid'];
    } else {
      if (opponent['id'] != currentUid) {
        opponentUid = opponent['id'];
      }
    }

    String _chatRoomId = '';

    // currentUid와 opponentUid를 정렬하여 더 앞에 있는 문자열을 먼저 가져옴
    final sortedUids = [currentUid, opponentUid]..sort();

    // 정렬된 uid들을 문자열로 이어붙여서 chatRoomId 생성
    _chatRoomId = sortedUids.join();

    return _chatRoomId;
  }

  bool isBlockList = false;

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  late Stream<bool> notiStream;

  Future<void> myNotificationStatus() async {
    PermissionStatus status = await Permission.notification.request();
    debugPrint('PermissionStatus status: $status');
  }

  @override
  void initState() {
    // WidgetsBinding.instance!.addPostFrameCallback((_) async {
    //   await Provider.of<LoadingScreenViewModel>(context, listen: false).initialize(context);
    // });

    // ChatBackgroundListen().setIsCurrentUserInChat();

    // currentUserProfile =
    //     Provider.of<ProfileUpdate>(context, listen: false).userProfile; // 앱이 꺼졌다가 들어오는 경우에는 emptyProfile이 사용되기 때문에 이 부분을 수정할 필요가 있음
    //
    // FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
    //   if (user == null) {
    //     // 로그인이 필요하다고 안내 필요
    //
    //     LaunchUrl().alertFunc(context, '알림', '로그인이 필요합니다\n(로그인 화면으로 이동합니다)', '확인', () async {
    //       await MoveToOtherScreen()
    //           .persistentNavPushNewScreen(
    //           context, SignupScreen(), false, PageTransitionAnimation.fade);
    //     });
    //   } else {
    //
    //   }
    // });
    currentUserProfileUid =
        FirebaseAuth.instance.currentUser?.uid.toString() ?? '';

    //currentUserProfileUid

    notiStream = RepositoryRealtimeUsers()
        .getCheckUserNotification(currentUserProfileUid);

    // myFuture = ChatBackgroundListen()
    //     .checkUserNotification(currentUserProfileUid);

    _stream = getRoomsStream(false);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {

      final PolicyInChatList = await RepositoryRemoteConfig().getDownloadPolicyInChatList();

      final status =
          await FlutterLocalNotification.requestNotificationPermission();
      debugPrint('PermissionStatus status: ${status}');

      if (status == PermissionStatus.denied) {
        LaunchUrl().alertFunc(
            context,
            '알림 권한',
            '현재 디바이스에서 핑퐁플러스 알림이 꺼진 상태입니다\n원활한 수신을 위해서는 "설정"에서 핑퐁플러스 알림을 켜주세요',
            '확인', () {
          Navigator.pop(context);
          AppSettings.openAppSettings(type: AppSettingsType.notification);
        });
      }
    });

    debugPrint('chatlist 이닛스테이츠!!!');

    // Future.microtask(() {
    //   Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
    //       .startTimer('MatchingScreen');
    // });

    super.initState();
  }

  @override
  void deactivate() {
    debugPrint('채팅 리스트 deactivate!!!');
    super.deactivate();

    //Future.microtask(() {
    //if (mounted) {
  }

  @override
  void dispose() {
    _stream = Stream.empty(); // 스트림 리스너 취소
    debugPrint('chatlist 디스포스!!!');
    _bannerAd?.dispose();

    super.dispose();
  }

  //int removeUserCount = 0;
  // List<String> popUpMenuList = ["모두 읽음 처리", "친구 관리", "운영정책", "유저 차단"];
  List<String> _popUpMenuList = ["모두 읽음 처리", "운영정책", "유저 차단"];

  //String initialPopUpMenu = "모두 읽음 처리";

  int badgeCount = 0;
  int listTileCount = 0;

  bool absorbPointing = false;

  late Future<bool> policyCheckFuture;

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  Future<void> loadAd() async {
    debugPrint('채팅 리스트 loadAd 시작');

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdHelper.chatListBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    );
    return _bannerAd!.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadAd();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //Provider.of<LoadingScreenViewModel>(context, listen: false).initialize(context);

      await GoogleAnalytics().trackScreen(context, 'ChatListScreen');
    });

    badgeCount = 0;

    return PopScope(
      onPopInvoked: (_) {
        // Future.microtask(() async {
        //   Provider.of<CurrentPageProvider>(context, listen: false)
        //       .setInitialCurrentPage();
        // });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: const ValueKey("ChatListScreen"),
        appBar: AppBar(
          backgroundColor: kMainColor,
          title: isBlockList ? Text('차단 목록') : Text('채팅'),
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              //WidgetsBinding.instance!.addPostFrameCallback((_) async {
              // Future.microtask(() async {
              //   Provider.of<CurrentPageProvider>(context, listen: false)
              //       .setInitialCurrentPage();
              //
              // }).then((value) {
              setState(() {
                Navigator.pop(context);
              });

              // });
            },
          ),
          actions: (Provider.of<LoginStatusUpdate>(context, listen: false)
                  .isLoggedIn)
              ? [
                  // IconButton(
                  //   onPressed: () async {
                  //     LaunchUrl()
                  //         .alertFunc(context, '알림', '친구 관리 기능은 준비중입니다', '확인', () {
                  //       Navigator.pop(context);
                  //     });
                  //     //await ChatBackgroundListen().adjustOpponentBadgeCount(FirebaseAuth.instance.currentUser!.uid.toString());
                  //   },
                  //   icon: Icon(CupertinoIcons.person_add_solid),
                  // ),

                  IconButton(
                    onPressed: () {
                      if (isBlockList == true) {
                        isBlockList = false;
                        debugPrint('isBlockList = false');
                        setState(() {
                          _stream = getRoomsStream(false);
                        });
                      } else {
                        isBlockList = true;
                        debugPrint('isBlockList = true');

                        setState(() {
                          _stream = getBlockedUsers();
                        });
                      }
                    },
                    icon: Icon(
                      isBlockList ? Icons.chat : Icons.block,
                      //color: isBlockList ? Colors.black : Colors.red,
                      //size: 30,
                    ),
                  ),
                  StreamBuilder(
                      stream: notiStream,
                      builder: (context, snapshot) {
                        debugPrint('myFuture snapshot data: ${snapshot.data}');
                        final data = snapshot.data;
                        if (data == true) {
                          return IconButton(
                              onPressed: () async {
                                //data 가 true 이면 수신되는 상태이고 수신 불가로 아이콘이 바뀌어야 함, false 이면, 알림수신이 안되는 상태
                                LaunchUrl().alertOkAndCancelFunc(
                                    context,
                                    '현재 채팅 알림을 수신하고 있습니다',
                                    '채팅 알림을 비활성화하시겠습니까?\n(확인 버튼을 누르면 채팅이 도착해도 알림이 울리지 않습니다)',
                                    '뒤로',
                                    '확인',
                                    kMainColor,
                                    kMainColor, () {
                                  // 뒤로
                                  Navigator.pop(context);
                                }, () async {
                                  // 확인
                                  try {
                                    await RepositoryRealtimeUsers()
                                        .getToggleNotification(false);

                                    notiStream = RepositoryRealtimeUsers()
                                        .getCheckUserNotification(
                                            currentUserProfileUid);

                                    setState(() {});
                                  } catch (e) {
                                    debugPrint('채팅 알림을 비활성화 e: $e');
                                  }
                                });
                              },
                              icon: Icon(Icons.notifications_none));
                        } else {
                          return IconButton(
                            onPressed: () async {
                              //data 가 true 이면 수신되는 상태이고 수신 불가로 아이콘이 바뀌어야 함, false 이면, 알림수신이 안되는 상태
                              LaunchUrl().alertOkAndCancelFunc(
                                  context,
                                  '현재 채팅 알림을 수신하지 않고 있습니다',
                                  '채팅 알림을 활성화하시겠습니까?\n(확인 버튼을 누르면 채팅이 도착했을때 알림이 울립니다)',
                                  '뒤로',
                                  '확인',
                                  kMainColor,
                                  kMainColor, () {
                                // 뒤로

                                Navigator.pop(context);
                              }, () async {
                                // 확인

                                try {
                                  await RepositoryRealtimeUsers()
                                      .getToggleNotification(true);

                                  notiStream = RepositoryRealtimeUsers()
                                      .getCheckUserNotification(
                                          currentUserProfileUid);

                                  setState(() {});
                                } catch (e) {
                                  debugPrint('채팅 알림을 활성화 e: $e');
                                }
                              });
                            },
                            icon: Icon(Icons.notifications_off_outlined),
                          );
                        }
                      }),
                  PopupMenuButton<String>(
                    //initialValue: initialPopUpMenu,
                    onSelected: (item) async {
                      if (item == _popUpMenuList[0]) {
                        // 모두 읽음 처리
                        // currentUser의 badge를 0으로 초기화

                        await RepositoryRealtimeUsers().getUpdateMyBadge(0);
                        setState(() {
                          _stream = getRoomsStream(true);
                        });
                      }
                      // else if (item == popUpMenuList[1]) {
                      //   // 친구 관리
                      //   LaunchUrl().alertFunc(
                      //       context, '알림', '친구 관리 기능은 준비중입니다', '확인', () {
                      //     Navigator.pop(context);
                      //   });
                      // }
                      else if (item == _popUpMenuList[1]) {
                        // 운영정책
                        setState(() {
                          if (isPolicyCheckWidgetVisible != true) {
                            isPolicyCheckWidgetVisible = true;
                          }
                        });
                      } else if (item == _popUpMenuList[2]) {
                        // 운영정책
                        LaunchUrl().alertFunc(context, '알림',
                            '유저를 차단하려면 차단하려는 유저의 채팅방을 왼쪽으로 슬리이드해주세요', '확인', () {
                          Navigator.pop(context);
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      ..._popUpMenuList
                          .map((String item) => PopupMenuItem<String>(
                                value: item,
                                child: Text(item),
                              )),
                    ],
                  ),
                ]
              : [],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.sizeOf(context).height -
                              150 -
                              (_bannerAd != null ? _bannerAd!.size.height : 0),
                          //(_inlineAdaptiveAd != null ? 1 : 0)
                          //_bannerAd!.size.height
                          width: MediaQuery.sizeOf(context).width,
                          child: StreamBuilder(
                            stream: _stream,
                            builder: (context, snapshot) {
                              //debugPrint('chatlist snapshot: $snapshot');
                              debugPrint(
                                  '채팅 리스트 snapshot.connectionState ${snapshot.connectionState}');
                              var data = snapshot.data; //List<Room>?
                              debugPrint('chatlist data : ${data}');
                              //debugPrint('chatlist data.length : ${data.length}'); 1
                              debugPrint(
                                  'chatlist data.runtimeType : ${data.runtimeType}');
                              if (snapshot.connectionState ==
                                      ConnectionState.done ||
                                  snapshot.connectionState ==
                                      ConnectionState.active) {
                                if (snapshot.hasData && data?.length != 0) {
                                  // 데이터가 있을 때
                                  // 데이터를 사용하여 화면을 구성하는 위젯 반환

                                  /////////////////////////////////////////

                                  if (data.runtimeType == List<types.Room>) {
                                    // 채팅 목록

                                    Map<Room, int> badgeCounts = {};

                                    int itemCount = data
                                            ?.where((item) =>
                                                item?.lastMessages != null)
                                            ?.length ??
                                        0;
                                    debugPrint('itemCount : ${itemCount}');

                                    // if (itemCount == 0) {
                                    //   return Center(
                                    //     child: Text('데이터 없음'),
                                    //   );
                                    // } else {
                                    // data?[index] 하나하나가 모두 현재 유저가 속한 채팅방

                                    // badgeCount 계산 로직 (이미 위에 작성하신 로직을 활용)
                                    for (var chat in data) {
                                      debugPrint('chat: ${chat}');
                                      debugPrint('chat.id: ${chat.id}');
                                      //debugPrint('chat: ${chat.metadata}');

                                      Map<String, dynamic> chatMetadata =
                                          chat.metadata;

                                      List<Map<String, dynamic>> lastSeenList =
                                          chatMetadata.entries.map((entry) {
                                        return {
                                          'userId': entry.key,
                                          'isInRoom': entry.value['isInRoom'],
                                          'lastSeen': entry.value['lastSeen']
                                        };
                                      }).toList();

                                      List<Map<String, dynamic>>
                                          filteredMyItems = lastSeenList
                                              .where((item) =>
                                                  item['userId'] ==
                                                  currentUserProfileUid)
                                              .toList();

                                      List<Map<String, dynamic>>
                                          filteredOpponentItems = lastSeenList
                                              .where((item) =>
                                                  item['userId'] !=
                                                  currentUserProfileUid)
                                              .toList();

                                      int badgeCount = 0;
                                      if (filteredOpponentItems.isNotEmpty &&
                                          filteredMyItems.isNotEmpty) {
                                        badgeCount += (filteredOpponentItems
                                                .first['lastSeen'] as int) -
                                            (filteredMyItems.first['lastSeen']
                                                as int);
                                        if (badgeCount < 0) {
                                          badgeCount = 0;
                                        }
                                      }

                                      //chatMetadata['badgeCount'] = badgeCount;  // 대화 데이터에 badgeCount 추가
                                      //debugPrint('chatMetadata[badgeCount]: ${chatMetadata['badgeCount']}');
                                      debugPrint(
                                          'chat.metadata: ${chat.metadata}');
                                      badgeCounts[chat] = badgeCount;
                                    }

                                    //data.sort((a, b) => b['badgeCount'].compareTo(a['badgeCount']));
                                    data.sort((Room a, Room b) {
                                      // badgeCounts에서 값을 가져올 때, null 처리를 해주어야 합니다.
                                      int badgeCountA = badgeCounts[a] ?? 0;
                                      int badgeCountB = badgeCounts[b] ?? 0;

                                      // 내림차순 정렬
                                      return badgeCountB.compareTo(badgeCountA);
                                    });

                                    return ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      controller: _chatListScrollController,
                                      //shrinkWrap: true,
                                      itemCount: itemCount,
                                      //data?.length,
                                      //snapshot.data?.docs.length,
                                      padding: const EdgeInsets.all(8.0),
                                      itemBuilder: ((context, index) {
                                        //debugPrint('index: $index');

                                        var chat = data[index];

                                        debugPrint('chat: ${chat}');
                                        debugPrint('chat.id: ${chat.id}');

                                        if (data?[index].lastMessages != null) {
                                          debugPrint(
                                              'data?[index].lastMessages != null');
                                          final users = data?[index].users;
                                          debugPrint('users: $users');

                                          final metaData =
                                              data?[index].metadata;
                                          //debugPrint('metaData: $metaData');

                                          final lastSeenList =
                                              metaData.entries.map((entry) {
                                            debugPrint(
                                                'entry.key: ${entry.key}');
                                            debugPrint(
                                                'entry.value: ${entry.value}');
                                            //debugPrint('entry.value: ${entry.value['lastSeen']}');
                                            return {
                                              'userId': entry.key,
                                              // 사용자 ID
                                              'lastSeen':
                                                  entry.value['lastSeen'],
                                              // 마지막으로 본 시간
                                            };
                                          }).toList();

                                          debugPrint(
                                              'lastSeenList: $lastSeenList');

                                          final lastMessages =
                                              data?[index].lastMessages;
                                          final lastMessage = lastMessages
                                              ?.first as types.TextMessage?;
                                          final latestChat =
                                              lastMessage?.text ?? '';

                                          //debugPrint('latestChat: $latestChat');
                                          //debugPrint(
                                          //    'currentUserProfileUid: $currentUserProfileUid');

                                          // 상대방이 회원 탈퇴한 경우는 users 에서 나가버리기 때문에 noCurrentUser가 []로 나타날 수 밖에 없음

                                          final noCurrentUser = users
                                              ?.where((element) =>
                                                  element.id !=
                                                  currentUserProfileUid)
                                              .toList();
                                          debugPrint(
                                              'noCurrentUser: $noCurrentUser');

                                          final element = noCurrentUser.isEmpty
                                              ? null
                                              : noCurrentUser.first.toJson();

                                          // final element =
                                          //     noCurrentUser?.first.toJson(); //User
                                          debugPrint(
                                              'noCurrentUser element: $element');
                                          //debugPrint('data.length: ${data?.length}');
                                          // lastSeenList 를 여기서 선언해야 할듯
                                          debugPrint(
                                              'lastSeenList: ${lastSeenList}');
                                          // debugPrint(
                                          //     'lastSeenList[index]: ${lastSeenList[index]}');
                                          //
                                          // debugPrint(
                                          //     'lastSeenList.runtimeType: ${lastSeenList.runtimeType}');
                                          // debugPrint(
                                          //     'lastSeenList[index].runtimeType: ${lastSeenList[index].runtimeType}');
                                          //
                                          // debugPrint(
                                          //     'lastSeenList[index][lastSeen]: ${lastSeenList[index]['lastSeen']}');

                                          //Map<String, dynamic> filteredMyItem = lastSeenList.where((item) => item['userId'] == currentUserProfileUid);
                                          //Map<String, dynamic> filteredOpponentItem = lastSeenList.where((item) => item['userId'] != currentUserProfileUid);

                                          // List<Map<String, dynamic>> filteredMyItems = lastSeenList.where((item) => item['userId'] == currentUserProfileUid).toList();
                                          // List<Map<String, dynamic>> filteredOpponentItems = lastSeenList.where((item) => item['userId'] != currentUserProfileUid).toList();

                                          List<Map<String, dynamic>>
                                              filteredMyItems = lastSeenList
                                                  .whereType<
                                                      Map<String, dynamic>>()
                                                  .where((item) =>
                                                      item['userId'] ==
                                                      currentUserProfileUid)
                                                  .toList();
                                          debugPrint(
                                              'filteredMyItems: $filteredMyItems'); // [{userId: XRxDio7Cxec67Nbl3Q4mBy0Ahkh2, lastSeen: 2}]

                                          List<Map<String, dynamic>>
                                              filteredOpponentItems =
                                              lastSeenList
                                                  .whereType<
                                                      Map<String, dynamic>>()
                                                  .where((item) =>
                                                      item['userId'] !=
                                                      currentUserProfileUid)
                                                  .toList();
                                          debugPrint(
                                              'filteredOpponentItems: $filteredOpponentItems'); // [{userId: XRxDio7Cxec67Nbl3Q4mBy0Ahkh2, lastSeen: 2}]

                                          // debugPrint(
                                          //     '배지 1: ${filteredOpponentItems.first['lastSeen'] as int ?? 0}');
                                          // debugPrint(
                                          //     '배지 2: ${filteredMyItems.first['lastSeen'] as int}');
                                          // debugPrint(
                                          //     '배지 3: ${(filteredOpponentItems.first['lastSeen'] as int) - (filteredMyItems.first['lastSeen'] as int)}');

                                          int eachBadgeCount;
                                          if (filteredOpponentItems.isEmpty) {
                                            eachBadgeCount = 0;
                                          } else {
                                            eachBadgeCount =
                                                ((filteredOpponentItems
                                                            .first['lastSeen']
                                                        as int) -
                                                    (filteredMyItems
                                                            .first['lastSeen']
                                                        as int));
                                          }

                                          if (eachBadgeCount > 0) {
                                            debugPrint(
                                                '배지 3가 0보다 크거나 같음 badgeCount: $badgeCount');
                                            badgeCount =
                                                badgeCount + eachBadgeCount;

                                            //debugPrint('badgeCount: $badgeCount');
                                          } else {
                                            debugPrint(
                                                '배지 3가 0보다 작음 badgeCount: $badgeCount');
                                            //badgeCount = 0;
                                          }

                                          listTileCount = listTileCount + 1;

                                          debugPrint(
                                              'listTileCount: $listTileCount');
                                          debugPrint(
                                              'chatlist listview builder badgeCount: $badgeCount');
                                          if (listTileCount != 0 &&
                                              itemCount == listTileCount) {
                                            RepositoryRealtimeUsers()
                                                .getUpdateMyBadge(badgeCount);
                                            badgeCount =
                                                0; // 업로드 이후 badgeCount 초기화
                                            listTileCount = 0;
                                          }

                                          if (element != null) {
                                            return Dismissible(
                                              direction:
                                                  DismissDirection.endToStart,
                                              // 왼쪽에서 오른쪽으로 슬라이드할 때만 작동
                                              confirmDismiss: (direction) {
                                                Completer<bool> completer =
                                                    Completer<bool>();
                                                //if (direction == DismissDirection.endToStart) {
                                                LaunchUrl()
                                                    .alertOkAndCancelFunc(
                                                        context,
                                                        '알림',
                                                        '해당 유저를 차단하시겠습니까?',
                                                        '취소',
                                                        '확인',
                                                        Colors.red,
                                                        kMainColor, () {
                                                  setState(() {
                                                    Navigator.pop(context);
                                                    completer.complete(false);
                                                    _stream =
                                                        getRoomsStream(false);
                                                  });
                                                }, () async {
                                                  // currentUser에다가 상대방을 차단 목록에 추가

                                                  // 해당 유저가 보낸 메시지 개수만든 나의 badge에서 빼기

                                                  await RepositoryRealtimeBlockedList()
                                                      .getAddToBlockList(
                                                          currentUserProfileUid,
                                                          element,
                                                          false)
                                                      .then((value) async {
                                                    int lastBadgeCount =
                                                        badgeCount -
                                                            eachBadgeCount;

                                                    debugPrint(
                                                        "badgeCount: $badgeCount");
                                                    debugPrint(
                                                        "eachBadgeCount: $eachBadgeCount");
                                                    debugPrint(
                                                        "lastBadgeCount: $lastBadgeCount");

                                                    if (lastBadgeCount < 0) {
                                                      lastBadgeCount = 0;
                                                    }

                                                    await RepositoryRealtimeUsers()
                                                        .getUpdateMyBadge(
                                                            lastBadgeCount);

                                                    await RepositoryRealtimeUsers()
                                                        .getAdjustOpponentBadge(
                                                            element['id'],
                                                            filteredOpponentItems
                                                                        .first[
                                                                    'lastSeen'] -
                                                                filteredMyItems
                                                                        .first[
                                                                    'lastSeen'])
                                                        .then((value) {
                                                      completer.complete(true);

                                                      //removeUserCount++;

                                                      setState(() {
                                                        data.removeAt(index);
                                                        //data = List.from(data)..removeAt(index);
                                                        _stream =
                                                            getRoomsStream(
                                                                false);
                                                        debugPrint(
                                                            'data.length : ${data.length}');
                                                      });
                                                    });
                                                  });
                                                });
                                                //}

                                                return completer.future;
                                              },
                                              background: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  // 슬라이드 할 때 보여지는 배경 색상
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 20.0),
                                                  // 왼쪽 패딩 추가
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Icon(Icons.block,
                                                          color: Colors.white),
                                                      Text(
                                                        '차단',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10.0),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              //key: ValueKey<String>('list_item_$index'),
                                              key: UniqueKey(),
                                              child: Column(
                                                children: [
                                                  AbsorbPointer(
                                                    absorbing: absorbPointing,
                                                    child: ListTile(
                                                      leading: GestureDetector(
                                                        onTap: () {
                                                          debugPrint(
                                                              'filteredOpponentItems: ${filteredOpponentItems}');
                                                          debugPrint(
                                                              'lastMessage: ${lastMessage}');
                                                          debugPrint(
                                                              'lastMessage: ${lastMessage?.author}');
                                                          //element.id가 해당 유저의 uid
                                                          MoveToOtherScreen()
                                                              .bottomProfileUp(
                                                                  context,
                                                                  element[
                                                                      'id']);
                                                        },
                                                        child: CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                      element?[
                                                                          "imageUrl"])
                                                                  as ImageProvider<
                                                                      Object>,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        element?["firstName"],
                                                        style: TextStyle(
                                                            fontSize: 18.0),
                                                      ),
                                                      subtitle: Text(
                                                        latestChat ?? '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      trailing: Badge(
                                                        //label: (lastSeenList.isNotEmpty || lastSeenList[index] != 0 || lastSeenList[index] != null) ? Text('${lastSeenList[index]}') : null,
                                                        //backgroundColor: (lastSeenList.isNotEmpty || lastSeenList[index] != 0) ? Colors.red : Colors.transparent,
                                                        // label: (lastSeenList[index]['lastSeen'] !=
                                                        //             0 &&
                                                        //         lastSeenList[index] != null &&
                                                        //         (lastMessagesLength -
                                                        //                 lastSeenList[index]
                                                        //                     ['lastSeen']) !=
                                                        //             0)
                                                        //     ? Text(
                                                        //         '${lastMessagesLength - lastSeenList[index]['lastSeen']}')
                                                        //     : null,
                                                        label: (filteredMyItems != null &&
                                                                filteredOpponentItems !=
                                                                    null &&
                                                                (filteredOpponentItems.first[
                                                                            'lastSeen'] -
                                                                        filteredMyItems.first[
                                                                            'lastSeen'] >
                                                                    0))
                                                            ? Text(
                                                                '${filteredOpponentItems.first['lastSeen'] - filteredMyItems.first['lastSeen']}')
                                                            : null,
                                                        // 여기서 lastseen 을 그대로 내보내는게 아니라, (메시지 개수 - lastSeen)으로 표현되어야 함
                                                        backgroundColor: (filteredMyItems != null &&
                                                                filteredOpponentItems !=
                                                                    null &&
                                                                (filteredOpponentItems.first[
                                                                            'lastSeen'] -
                                                                        filteredMyItems.first[
                                                                            'lastSeen'] >
                                                                    0))
                                                            ? Colors.red
                                                            : Colors
                                                                .transparent,
                                                        smallSize: 10.0,
                                                        //largeSize: 20.0,
                                                        child: Icon(Icons
                                                            .chat_bubble_outline),
                                                      ),
                                                      onTap: () async {
                                                        debugPrint(
                                                            'index: $index');
                                                        setState(() {
                                                          absorbPointing = true;
                                                        });
                                                        await RepositoryRealtimeUsers()
                                                            .getDownloadMyBadge()
                                                            .then(
                                                                (badge) async {
                                                          // final lastSeenListIndex =
                                                          //     filteredMyItems.first['lastSeen']
                                                          //         as int;
                                                          // final currentBadge =
                                                          //     badge - lastSeenListIndex;
                                                          //
                                                          // debugPrint('currentBadge: $currentBadge');

                                                          // await ChatBackgroundListen()
                                                          //     .updateMyBadge(currentBadge)
                                                          //     .then((value) {
                                                          setState(() {
                                                            //lastSeenList[index] = 0;
                                                            filteredMyItems
                                                                    .first[
                                                                'lastSeen'] = 0;

                                                            absorbPointing =
                                                                false;
                                                          });

                                                          await MoveToOtherScreen()
                                                              .initializeGASetting(
                                                                  context,
                                                                  'ChatScreen')
                                                              .then(
                                                                  (value) async {
                                                            await MoveToOtherScreen()
                                                                .persistentNavPushNewScreen(
                                                              context,
                                                              ChatScreen(
                                                                  receivedData:
                                                                      element!),
                                                              false,
                                                              PageTransitionAnimation
                                                                  .cupertino,
                                                            )
                                                                .then(
                                                                    (value) async {
                                                              await MoveToOtherScreen()
                                                                  .initializeGASetting(
                                                                      context,
                                                                      'ChatListScreen');

                                                              setState(() {
                                                                _stream =
                                                                    getRoomsStream(
                                                                        false);
                                                              });
                                                            });
                                                          });

                                                          // });
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  //Divider(),
                                                ],
                                              ),
                                            );
                                          } else {
                                            final String chatRoomId =
                                                data?[index].id;
                                            return Dismissible(
                                              direction:
                                                  DismissDirection.endToStart,
                                              // 왼쪽에서 오른쪽으로 슬라이드할 때만 작동
                                              confirmDismiss: (direction) {
                                                Completer<bool> completer =
                                                    Completer<bool>();
                                                //if (direction == DismissDirection.endToStart) {
                                                LaunchUrl()
                                                    .alertOkAndCancelFunc(
                                                        context,
                                                        '알림',
                                                        '채팅방을 삭제하시겠습니까?',
                                                        '취소',
                                                        '확인',
                                                        Colors.red,
                                                        kMainColor, () {
                                                  setState(() {
                                                    Navigator.pop(context);
                                                    completer.complete(false);
                                                    _stream =
                                                        getRoomsStream(false);
                                                  });
                                                }, () async {
                                                  await RepositoryRealtimeMessages()
                                                      .getDeleteChatRoom(
                                                          chatRoomId)
                                                      .then((value) {
                                                    completer.complete(true);

                                                    setState(() {
                                                      data.removeAt(index);
                                                      //data = List.from(data)..removeAt(index);
                                                      _stream =
                                                          getRoomsStream(false);
                                                      debugPrint(
                                                          'data.length : ${data.length}');
                                                    });
                                                  });
                                                });
                                                //}

                                                return completer.future;
                                              },
                                              background: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  // 슬라이드 할 때 보여지는 배경 색상
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 20.0),
                                                  // 왼쪽 패딩 추가
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Icon(Icons.delete,
                                                          color: Colors.white),
                                                      Text(
                                                        '삭제',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10.0),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              //key: ValueKey<String>('list_item_$index'),
                                              key: UniqueKey(),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundImage: AssetImage(
                                                          'images/empty_profile_6.png'),
                                                    ),
                                                    title: Text(
                                                      '(알 수 없는 사용자)',
                                                      style: TextStyle(
                                                          fontSize: 18.0),
                                                    ),
                                                    subtitle: Text(
                                                      latestChat ?? '',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    trailing: Badge(
                                                      label: (filteredMyItems !=
                                                                  [] &&
                                                              filteredOpponentItems
                                                                  .isNotEmpty &&
                                                              (filteredOpponentItems
                                                                              .first[
                                                                          'lastSeen'] -
                                                                      filteredMyItems
                                                                              .first[
                                                                          'lastSeen'] >
                                                                  0))
                                                          ? Text(
                                                              '${filteredOpponentItems.first['lastSeen'] - filteredMyItems.first['lastSeen']}')
                                                          : null,
                                                      // 여기서 lastseen 을 그대로 내보내는게 아니라, (메시지 개수 - lastSeen)으로 표현되어야 함
                                                      backgroundColor: (filteredMyItems !=
                                                                  [] &&
                                                              filteredOpponentItems
                                                                  .isNotEmpty &&
                                                              (filteredOpponentItems
                                                                              .first[
                                                                          'lastSeen'] -
                                                                      filteredMyItems
                                                                              .first[
                                                                          'lastSeen'] >
                                                                  0))
                                                          ? Colors.red
                                                          : Colors.transparent,
                                                      smallSize: 10.0,
                                                      //largeSize: 20.0,
                                                      child: Icon(Icons
                                                          .chat_bubble_outline),
                                                    ),
                                                    onTap: () async {
                                                      LaunchUrl()
                                                          .alertOkAndCancelFunc(
                                                              context,
                                                              '주의',
                                                              '알 수 없는 사용자로부터의 채팅을 확인하시겠습니까?\n원하지 않는 경우에는 채팅방을 왼쪽으로 밀어서\n 알 수 없는 사용자를 차단해주세요',
                                                              '확인',
                                                              '채팅방으로 이동',
                                                              Colors.red,
                                                              kMainColor, () {
                                                        Navigator.pop(context);
                                                      }, () async {
                                                        //Navigator.pop(context);
                                                        //Navigator.of(context).pop(true)

                                                        // 알 수 없는 유저를 채팅방에 추가해야 함
                                                        // author 중에서 상대방을 그대로 users에 추가
                                                        debugPrint(
                                                            'lastMessages.length: ${lastMessages.length}');
                                                        debugPrint(
                                                            'lastMessages: ${lastMessages}');

                                                        for (final types
                                                            .TextMessage message
                                                            in lastMessages) {
                                                          //final author = message.author as types.User;
                                                          final author =
                                                              types.User(
                                                            id: message
                                                                .author.id,
                                                            imageUrl: message
                                                                .author
                                                                .imageUrl,
                                                            firstName: message
                                                                .author
                                                                .firstName,
                                                            lastSeen: 0,
                                                          );
                                                          debugPrint(
                                                              'author: ${author}');

                                                          if (author.id !=
                                                              currentUserProfileUid) {
                                                            DatabaseReference
                                                                ref =
                                                                FirebaseDatabase
                                                                    .instance
                                                                    .ref(
                                                                        "messages/$chatRoomId/users");

                                                            await ref.once().then(
                                                                (dataSnapshot) async {
                                                              debugPrint(
                                                                  'dataSnapshot: $dataSnapshot');
                                                              debugPrint(
                                                                  'dataSnapshot.snapshot.value: ${dataSnapshot.snapshot.value}');

                                                              final authorList =
                                                                  dataSnapshot
                                                                          .snapshot
                                                                          .value
                                                                      as List<
                                                                          Object?>;
                                                              final authorListMe =
                                                                  authorList
                                                                          ?.first
                                                                      as Map<
                                                                          Object?,
                                                                          Object?>;

                                                              final authorMe =
                                                                  types.User(
                                                                id: authorListMe[
                                                                        'id']
                                                                    as String,
                                                                imageUrl: authorListMe[
                                                                        'imageUrl']
                                                                    as String,
                                                                firstName:
                                                                    authorListMe[
                                                                            'firstName']
                                                                        as String,
                                                                lastSeen: 0,
                                                              );

                                                              debugPrint(
                                                                  'authorMe: $authorMe');

                                                              final _list = [
                                                                author,
                                                                authorMe
                                                              ];

                                                              final List<
                                                                      Map<String,
                                                                          dynamic>>
                                                                  _listJson =
                                                                  _list
                                                                      .map((message) =>
                                                                          message
                                                                              .toJson())
                                                                      .toList();

                                                              await ref.set(
                                                                  _listJson);

                                                              return;
                                                            });
                                                          }
                                                        }

                                                        await RepositoryRealtimeUsers()
                                                            .getDownloadMyBadge()
                                                            .then(
                                                                (badge) async {
                                                          //final lastSeenListIndex = lastSeenList[index]['lastSeen'] as int;
                                                          final lastSeenListIndex =
                                                              filteredMyItems
                                                                          .first[
                                                                      'lastSeen']
                                                                  as int;
                                                          final currentBadge =
                                                              badge -
                                                                  lastSeenListIndex;

                                                          debugPrint(
                                                              'downloadMyBadge 이후 updateMyBadge');
                                                          await RepositoryRealtimeUsers()
                                                              .getUpdateMyBadge(
                                                                  currentBadge)
                                                              .then(
                                                                  (value) async {
                                                            setState(() {
                                                              //lastSeenList[index] = 0;
                                                              filteredMyItems
                                                                      .first[
                                                                  'lastSeen'] = 0;
                                                            });

                                                            await MoveToOtherScreen()
                                                                .initializeGASetting(
                                                                    context,
                                                                    'ChatScreen')
                                                                .then(
                                                                    (value) async {
                                                              await MoveToOtherScreen()
                                                                  .persistentNavPushNewScreen(
                                                                context,
                                                                ChatScreen(
                                                                  receivedData: {
                                                                    chatRoomId:
                                                                        null
                                                                  },
                                                                ),
                                                                false,
                                                                PageTransitionAnimation
                                                                    .cupertino,
                                                              )
                                                                  .then(
                                                                      (value) async {
                                                                await MoveToOtherScreen()
                                                                    .initializeGASetting(
                                                                        context,
                                                                        'ChatListScreen');
                                                              });
                                                            });
                                                          });
                                                        });
                                                      });
                                                    },
                                                  ),
                                                  //Divider(),
                                                ],
                                              ),
                                            );
                                          }
                                        } else {
                                          return null;
                                        }
                                      }),
                                    );
                                    //}
                                  } else if (data.runtimeType ==
                                      List<types.User>) {
                                    // 차단 목록
                                    // data == List<types.User>
                                    return ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        controller:
                                            _BlockedListScrollController,
                                        //shrinkWrap: true,
                                        itemCount: data?.length,
                                        //snapshot.data?.docs.length,
                                        padding: const EdgeInsets.all(8.0),
                                        itemBuilder: ((context, index) {
                                          final _blockedUser =
                                              data?[index] as types.User;
                                          //debugPrint('_blockedUser: $_blockedUser');
                                          if (data?.length == 0) {
                                            return Center(
                                                child: Text(
                                              '데이터 없음',
                                              style: TextStyle(),
                                            ));
                                          } else {
                                            if (_blockedUser.id !=
                                                currentUserProfileUid) {
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                          _blockedUser
                                                              .imageUrl!)
                                                      as ImageProvider<Object>,
                                                ),
                                                title: Text(
                                                  _blockedUser.firstName!,
                                                  style:
                                                      TextStyle(fontSize: 18.0),
                                                ),
                                                trailing: OutlinedButton(
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    side: BorderSide(
                                                        width: 0.7,
                                                        color: Colors.grey),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                  ),
                                                  child: Text('해제'),
                                                  onPressed: () async {
                                                    String alertContentText;

                                                    if (_blockedUser.metadata?[
                                                            'isReported'] ==
                                                        true) {
                                                      alertContentText =
                                                          '이전에 신고했던 유저입니다\n그래도 해당 유저를 차단 해제하시겠습니까?';
                                                    } else {
                                                      alertContentText =
                                                          '해당 유저를 차단 해제하시겠습니까?';
                                                    }

                                                    LaunchUrl()
                                                        .alertOkAndCancelFuncNoPop(
                                                            context,
                                                            '알림',
                                                            alertContentText,
                                                            '취소',
                                                            '확인',
                                                            kMainColor,
                                                            kMainColor, () {
                                                      Navigator.pop(context);
                                                    }, () async {
                                                      DatabaseReference
                                                          blockRef =
                                                          FirebaseDatabase
                                                              .instance
                                                              .ref(
                                                                  "blockedList/${currentUserProfileUid}");

                                                      await blockRef.remove();

                                                      setState(() {
                                                        // 아이템을 목록에서 제거
                                                        //debugPrint('차단 목록에서 삭제');
                                                        data?.removeAt(index);
                                                        Navigator.pop(context);
                                                      });
                                                    });
                                                  },
                                                ),
                                              );
                                            }
                                          }
                                        }));
                                  } else {
                                    return Center(
                                      child: Text(
                                        '데이터 없음',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                    );
                                  }

                                  /////////////////////////////////////////

                                  // } else if (snapshot.connectionState == ConnectionState.waiting) {
                                  //   return kCustomCircularProgressIndicator;
                                } else {
                                  // 데이터가 없는 경우
                                  return Center(
                                    child: Text(
                                      '데이터 없음',
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                  );
                                }
                              } else if (snapshot.hasError) {
                                // 에러가 발생한 경우
                                // 에러를 표시하는 위젯 반환
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        kCustomCircularProgressIndicator,
                                        Text('Error: ${snapshot.error}'),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        kCustomCircularProgressIndicator,
                                      ],
                                    ),
                                  ),
                                ); // 데이터 로딩 중일 때 보여줄 위젯
                              } else {
                                // 데이터가 없는 경우
                                // 현재 앱이 아예 꺼진 상태에서 노티를 클릭해서 들어오는 경우, 아래 위젯이 반환되고 있음 '데이터 없음6: 반갑습니다!'
                                return Center(
                                  child: Text(
                                    '데이터 없음',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 운영정책 설정
                  FutureBuilder(
                      future: Future.wait([
                        RepositoryRealtimeUsers().getDownloadPolicyCheck(),
                        RepositoryRemoteConfig().getDownloadPolicyInChatList(),
                      ]),
                      builder: (context, snapshot) {
                        // 두 Future의 결과는 snapshot.data[0], snapshot.data[1]에 각각 저장
                        // debugPrint(
                        //     '운영정책 설정 snapshot.connectionState: ${snapshot.connectionState}');
                        debugPrint('운영정책 설정 snapshot.data: ${snapshot.data?[0]}');
                        debugPrint('채팅 운영 정책 snapshot.data: ${snapshot.data?[1]}');

                        final boolData = snapshot.data?[0] as bool?;
                        final policyInChatList = snapshot.data?[1] as String?;

                        debugPrint('policyInChatList: $policyInChatList');

                        if (boolData == null || policyInChatList == null) {
                          return kCustomCircularProgressIndicator;
                        } else {
                          return Visibility(
                              visible: isPolicyCheckWidgetVisible,
                              child: policyCheckWidget(policyInChatList));

                          // if (boolData != null) {
                          //   return Visibility(
                          //     visible: !boolData
                          //     child: policyCheckWidget(),
                          //   );
                          // } else {
                          //   return Container();
                          // }
                        }
                      }),
                ],
              ),
              if (_bannerAd != null && _isLoaded)
                Container(
                  color: Colors.green,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                )
            ],
          ),
        ),
      ),
    );
  }

  Stream<List<types.User>> getBlockedUsers() async* {
    DatabaseReference blockedRef =
        FirebaseDatabase.instance.ref('blockedList/${currentUserProfileUid}');
    final result = await blockedRef.once();

    List<types.User> _blockedList = [];

    try {
      if (result.snapshot.value != null) {
        final _userMap = result.snapshot.value as Map<Object?, Object?>;

        _userMap.forEach((key, value) {
          final finalValue = value as Map<Object?, Object?>;
          debugPrint('finalValue: ${finalValue}');
          final reported = finalValue['reported'] as Map<Object?, Object?>;
          debugPrint('reported: ${reported}');
          debugPrint('reported: ${reported.runtimeType}');

          String id;
          String imageUrl;
          String firstName;
          int lastSeen;

          if (finalValue['id'] != null) {
            id = finalValue['id'] as String;
            imageUrl = finalValue['imageUrl'] as String;
            firstName = finalValue['firstName'] as String;
            lastSeen = finalValue['lastSeen'] as int;
          } else {
            id = finalValue['uid'] as String;
            imageUrl = finalValue['photoUrl'] as String;
            firstName = finalValue['nickName'] as String;
            lastSeen = 0;
          }

          final isReported = reported['isReported'] as bool;
          final dateTime = reported['dateTime'] as int?;
          final reporter = reported['reporter'] as String?;

          debugPrint('isReported: ${isReported}');
          debugPrint('dateTime: ${dateTime}');
          debugPrint('reporter: ${reporter}');

          /// 여기에서 유저가 본인이 신고 먹인 상태인지 확인 필요
          if (isReported == true) {
            DateTime date = DateTime.fromMillisecondsSinceEpoch(dateTime!);
            debugPrint('date: ${date}');

            // formattedDate 은 String 임
            String formattedDate =
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
                "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

            final user = types.User(
                id: id,
                imageUrl: imageUrl,
                firstName: firstName,
                lastSeen: lastSeen,
                metadata: {
                  "isReported": isReported,
                  "dateTime": formattedDate,
                  "reporter": reporter,
                });

            debugPrint('user: ${user}');

            _blockedList.add(user);
          } else {
            final user = types.User(
                id: id,
                imageUrl: imageUrl,
                firstName: firstName,
                lastSeen: lastSeen,
                metadata: {
                  "isReported": isReported,
                });

            _blockedList.add(user);
          }
        });

        //_blockedList.add(user);
      }
      //debugPrint('_blockedList: $_blockedList');

      yield _blockedList;
    } catch (e) {
      debugPrint('getBlockedUsers e: $e');
      yield [];
    }
  }

  Stream<List<types.Room>> getRoomsStream(bool makeAllRead) async* {
    DatabaseReference messageRef = FirebaseDatabase.instance.ref('messages');

    DatabaseReference blockedRef =
        FirebaseDatabase.instance.ref('blockedList/${currentUserProfileUid}');

    final blockedRefResult = await blockedRef.once();
    List<String> _blockedList = [];

    // 블록된 유저의 값은 가져오지 않아야 함
    if (blockedRefResult.snapshot.value != null) {
      debugPrint('blockedRefResult.snapshot.value != null');
      final _userMap = blockedRefResult.snapshot.value as Map<Object?, Object?>;
      _userMap.forEach((key, value) {
        final finalValue = value as Map<Object?, Object?>;
        final user = types.User(
          id: finalValue['id'] as String,
          imageUrl: finalValue['imageUrl'] as String,
          firstName: finalValue['firstName'] as String,
          lastSeen: finalValue['lastSeen'] as int,
        );
        _blockedList.add(user.id);
      });
    } else {
      debugPrint('blockedRefResult.snapshot.value == null');
    }

    await for (final event in messageRef.onValue) {
      debugPrint('getroom 스트림 리스너 동작함');

      List<types.Room> _roomsList = [];

      final dataSnapshot = event.snapshot;
      final List<DataSnapshot> snapshot = dataSnapshot.children.toList();

      types.Room roomFromSnapshot(DataSnapshot snapshot) {
        final _map = snapshot.value as Map<Object?, Object?>?;
        final data = _map?.cast<String, dynamic>() ?? {};

        final metadata =
            (data['metadata'] as Map<Object?, Object?>?)?.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );

        return types.Room(
          id: data['id'].toString(),
          type: types.RoomType.direct,
          users: ((data['users'] as List<dynamic>).map((userData) {
            return types.User(
                id: userData['id'],
                imageUrl: userData['imageUrl'],
                firstName: userData['firstName'],
                lastSeen: userData['lastSeen']);
          }).toList()),
          lastMessages:
              (data['lastMessages'] as List<dynamic>?)?.map((userData) {
            final authorData = userData['author'] as Map<Object?, Object?>;
            final author = types.User(
                id: authorData['id'] as String,
                imageUrl: authorData['imageUrl'] as String?,
                firstName: authorData['firstName'] as String?,
                lastSeen: userData['lastSeen'] as int?);
            return types.TextMessage(
              id: userData['id'],
              createdAt: userData['createdAt'],
              text: userData['text'],
              author: author,
            );
          }).toList(),
          metadata: metadata,
        );
      }

      final List<types.Room> allRooms = snapshot
          .map((snapshot) => roomFromSnapshot(snapshot))
          .where((room) => room.metadata?[currentUserProfileUid] != null)
          .toList();

      for (final room in allRooms) {
        bool containsBlockedUser = false;

        for (final user in room.users) {
          if (_blockedList.contains(user.id)) {
            debugPrint('if (_blockedList.contains(user.id)) {');
            containsBlockedUser = true;
          }
        }

        if (containsBlockedUser == false) {
          _roomsList.add(room);
        }

        /////////// 모두 읽음 처리 하는 경우에만
        if (makeAllRead == true) {
          int myLastSeen = 0;
          String myKey = '';
          int opponentLastSeen = 0;
          String opponentKey = '';

          room.metadata?.forEach((key, value) {
            if (key.toString() == currentUserProfileUid) {
              myKey = key.toString();
              myLastSeen = room.metadata?[key.toString()]['lastSeen'] as int;
            } else {
              opponentKey = key.toString();
              opponentLastSeen =
                  room.metadata?[key.toString()]['lastSeen'] as int;
            }
          });

          if (myLastSeen < opponentLastSeen) {
            if (_roomsList.contains(room)) {
              DatabaseReference ref = FirebaseDatabase.instance
                  .ref("messages/${room.id}/metadata/${myKey}/lastSeen");
              ref.set(opponentLastSeen);
            }
          }

          RepositoryRealtimeUsers().getInitializeMyBadge();
        }
        /////////// 모두 읽음 처리 하는 경우에만
      }

      yield _roomsList;
    }
  }

  bool isPolicyCheckWidgetVisible = true;

  Widget policyCheckWidget(String policyInChatList) {
    double widgetHeight = MediaQuery.sizeOf(context).height * 0.7;

    return Stack(
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: widgetHeight,
          color: Colors.black.withOpacity(0.5), // 투명도 조절
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Center(
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width - 60,
                  height: widgetHeight,
                  padding: EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15.0, bottom: 15.0),
                  decoration: BoxDecoration(
                    color: kMainColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '운영정책 안내',
                        style: kMainScreen_AnnouncementTextStyle,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Scrollbar(
                        controller: _policyScrollController,
                        thumbVisibility: true,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2.0),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity, // 화면 너비에 맞게 설정
                                height: widgetHeight * 0.65,
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.transparent.withOpacity(0.1)
                                ),
                                child: SingleChildScrollView(
                                  controller: _policyScrollController,
                                  child: Text(
                                    policyInChatList,
                                    //'(1) Matching(매칭) 기능을 통해 다른 유저와 채팅을 하는 과정에서 운영정책 위반에 따른 신고를 수집하고 있습니다.\n유저의 신고가 접수된 후에는 신고 정보 확인 및 적절한 후속 조치를 위해 정보처리담당자가 신고가 발생한 채팅방을 열람할 수 있습니다. 채팅 이용 관련 신고에 따른 이용제한은 다음과 같이 적용됩니다.\n	- 누적 신고 5회 도달시, 7일 간 채팅 기능 제한 	- 누적 신고 10회 도달시, 14일 간 채팅 기능 제한 	- 누적 신고 15회 도달시, 영구 채팅 기능 제한\n그러나, 이러한 이용제한 수위는 신고 내용의 정도에 따라 즉시 영구 채팅 제한 등 운영자에 판단에 따라 다르게 적용될 수 있습니다. 이용 관련 신고에 따른 개인정보 열람 관련 정책은 개인정보처리방침을 참고바랍니다.\n\n(2) 또한, 운영정책에 반하지 않는 채팅 내용에 대한 무분별한 신고도 정상적인 핑퐁플러스 서비스 운영 방해로 간주되어 이용제한을 받을 수 있습니다. 이용제한 수위는 신고 내용 정도 및 빈도에 따라 한시적 채팅 제한 또는 영구적 채팅 제한 등 운영자에 판단에 따라 다르게 적용될 수 있습니다.\n\n(3) 신고 관련 소명을 위한 연락은 전자우편 simonwork177@simonwork.net으로 해주시기 바랍니다.',
                                    maxLines: null,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 15.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.transparent.withOpacity(0.1)
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'NanumSquare',
                                      fontSize: 14.0,
                                      color:
                                      Theme.of(context).brightness == Brightness.light
                                          ? Colors.black // 다크 모드일 때 텍스트 색상
                                          : Colors.white,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: '자세한 '),
                                      TextSpan(
                                        text: '운영정책',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            await LaunchUrl().myLaunchUrl(
                                                'https://sites.google.com/view/pingponplus-operationpolicy/%ED%99%88');
                                          },
                                        style: TextStyle(
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: ' 및 '),
                                      TextSpan(
                                        text: '개인정보처리방침',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            await LaunchUrl().myLaunchUrl(
                                                'https://sites.google.com/view/pingponplus-privacy/%ED%99%88');
                                          },
                                        style: TextStyle(
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: '은 링크에서 확인가능합니다'),
                                    ],
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: (MediaQuery.sizeOf(context).width - 60) / 2 -
                                  30, //140,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3), // 반투명한 흰색 배경
                                borderRadius:
                                    BorderRadius.circular(8.0), // 버튼의 모서리를 둥글게 만듦
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  //Navigator.pop(context);
                                  setState(() {
                                    isPolicyCheckWidgetVisible = false;
                                  });
                                },
                                child: Text(
                                  '닫기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: (MediaQuery.sizeOf(context).width - 60) / 2 -
                                  30, //140,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3), // 반투명한 흰색 배경
                                borderRadius:
                                    BorderRadius.circular(8.0), // 버튼의 모서리를 둥글게 만듦
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  await RepositoryRealtimeUsers()
                                      .getUpdatePolicyCheck()
                                      .then((value) {
                                    //Navigator.pop(context);
                                    setState(() {
                                      isPolicyCheckWidgetVisible = false;
                                    });
                                  });
                                },
                                child: Text(
                                  '다시 보지 않음',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ), // 닫기 버튼 2개
                    ],
                  ),
                ),
                Positioned(
                  top: 5.0,
                  right: 1.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () async {
                          setState(() {
                            isPolicyCheckWidgetVisible = false;
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }
}
