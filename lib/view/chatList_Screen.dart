import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:dnpp/LocalDataSource/firebase_realtime/blockedList/DS_Local_blockedList.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/repository/firebase_realtime_blockedList.dart';
import 'package:dnpp/repository/firebase_realtime_messages.dart';
import 'package:dnpp/view/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import '../LocalDataSource/firebase_realtime/messages/DS_Local_chat.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_badge.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_isNotificationAble.dart';
import '../models/launchUrl.dart';
import '../models/moveToOtherScreen.dart';
import '../models/userProfile.dart';
import '../norification.dart';
import '../repository/firebase_realtime_users.dart';
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

  bool notiBool = false;

  late Future<bool> myFuture;

  Future<void> myNotificationStatus() async {
    PermissionStatus status = await Permission.notification.request();
    print('PermissionStatus status: $status');
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

    myFuture =
        RepositoryRealtimeUsers().getCheckUserNotification(currentUserProfileUid);

    // myFuture = ChatBackgroundListen()
    //     .checkUserNotification(currentUserProfileUid);

    _stream = getRoomsStream(false);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final status =
          await FlutterLocalNotification.requestNotificationPermission();
      print('PermissionStatus status: ${status}');

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

    print('chatlist 이닛스테이츠!!!');

    Future.microtask(() {
      Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
          .startTimer('MatchingScreen');
    });
    //
    // WidgetsBinding.instance!.addPostFrameCallback((_) async {
    //   Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
    //       .startTimer('MatchingScreen');
    // });

    super.initState();
  }

  @override
  void deactivate() {
    print('채팅 리스트 deactivate!!!');
    super.deactivate();

      //Future.microtask(() {
        //if (mounted) {

  }

  @override
  void dispose() {
    _stream = Stream.empty(); // 스트림 리스너 취소
    print('chatlist 디스포스!!!');

    super.dispose();
  }

  //int removeUserCount = 0;
  List<String> popUpMenuList = ["모두 읽음 처리", "친구 관리", "운영정책", "유저 차단"];

  //String initialPopUpMenu = "모두 읽음 처리";

  int badgeCount = 0;

  bool absorbPointing = false;

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance!.addPostFrameCallback((_) async {

      await Provider.of<CurrentPageProvider>(context, listen: false).setCurrentPage('ChatListView');

      //Provider.of<LoadingScreenViewModel>(context, listen: false).initialize(context);

      await GoogleAnalytics().trackScreen(context, 'ChatListScreen');
    });

    badgeCount = 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMainColor,
        title: isBlockList ? Text('차단 목록') : Text('채팅'),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            //WidgetsBinding.instance!.addPostFrameCallback((_) async {
            Future.microtask(() async {
              Provider.of<CurrentPageProvider>(context, listen: false)
                  .setInitialCurrentPage();
              await Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
                  .startTimer('ChatListScreen');
              //}
            }).then((value) {
              Navigator.pop(context);
            });

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
                      print('isBlockList = false');
                      setState(() {
                        _stream = getRoomsStream(false);
                      });
                    } else {
                      isBlockList = true;
                      print('isBlockList = true');

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
                FutureBuilder(
                    future: myFuture,
                    builder: (context, snapshot) {
                      print('myFuture snapshot data: ${snapshot.data}');
                      final data = snapshot.data;
                      if (data == true) {
                        notiBool = true;
                      } else {
                        notiBool = false;
                      }
                      return IconButton(
                        onPressed: () async {
                          print('notiBool: $notiBool');
                          //final status = await FlutterLocalNotification.requestNotificationPermission();
                          //print('PermissionStatus status: ${status}');
                          // final bool = await ChatBackgroundListen()
                          //     .checkUserNotification(currentUserProfileUid);
                          // print('bool: ${bool}');

                          if (notiBool == true) {
                            LaunchUrl().alertFunc(
                                context,
                                '알림',
                                '채팅 알림을 비활성화합니다\n(채팅이 도착해도 알리지 않습니다)',
                                '확인', () async {
                              //notiBool 가 true 이면 수신되는 상태이고 수신 불가로 아이콘이 바뀌어야 함, false 이면, 알림수신이 안되는 상태

                              await RepositoryRealtimeUsers()
                                  .getToggleNotification(false);

                              myFuture = RepositoryRealtimeUsers()
                                  .getCheckUserNotification(currentUserProfileUid);
                              setState(() {
                                Navigator.pop(context);
                              });
                            });
                          } else {
                            LaunchUrl().alertFunc(
                                context,
                                '알림',
                                '채팅 알림을 활성화합니다\n(채팅이 도착하면 알림을 받습니다)',
                                '확인', () async {
                              //notiBool 가 true 이면 수신되는 상태이고 수신 불가로 아이콘이 바뀌어야 함, false 이면, 알림수신이 안되는 상태

                              await RepositoryRealtimeUsers()
                                  .getToggleNotification(true);

                              myFuture = RepositoryRealtimeUsers()
                                  .getCheckUserNotification(currentUserProfileUid);

                              setState(() {
                                Navigator.pop(context);
                              });
                            });
                          }

                          // if (status == PermissionStatus.granted) {
                          //   LaunchUrl()
                          //       .alertFunc(context, '알림', '채팅 알림을 비활성화합니다\n(채팅이 도착해도 알리지 않습니다)', '확인', () async {
                          //     //notiBool 가 true 이면 수신되는 상태이고 수신 불가로 아이콘이 바뀌어야 함, false 이면, 알림수신이 안되는 상태
                          //     // setState(() {
                          //     //   notiBool = false;
                          //     // });
                          //     await ChatBackgroundListen()
                          //         .toggleNotification(false);
                          //     Navigator.pop(context);
                          //   });
                          //   // //notiBool 가 true 이면 수신되는 상태이고 수신 불가로 아이콘이 바뀌어야 함, false 이면, 알림수신이 안되는 상태
                          //
                          // } else { // status == PermissionStatus.denied
                          //   LaunchUrl()
                          //       .alertFunc(context, '알림', '채팅 알림을 활성화합니다\n(채팅이 도착하면 알림을 받습니다)', '확인', () async {
                          //     //notiBool 가 true 이면 수신되는 상태이고 수신 불가로 아이콘이 바뀌어야 함, false 이면, 알림수신이 안되는 상태
                          //     // setState(() {
                          //     //   notiBool = true;
                          //     // });
                          //     await ChatBackgroundListen()
                          //         .toggleNotification(true);
                          //     Navigator.pop(context);
                          //   });
                          //
                          // }

                          // myFuture = ChatBackgroundListen()
                          //     .checkUserNotification(
                          //         currentUserProfileUid);
                        },
                        icon: notiBool
                            ? Icon(Icons.notifications_none)
                            : Icon(Icons.notifications_off_outlined),
                      );
                    }),
                PopupMenuButton<String>(
                  //initialValue: initialPopUpMenu,
                  onSelected: (item) async {
                    if (item == popUpMenuList[0]) {
                      // 모두 읽음 처리
                      // currentUser의 badge를 0으로 초기화

                      await RepositoryRealtimeUsers().getUpdateMyBadge(0);
                      setState(() {
                        _stream = getRoomsStream(true);
                      });

                    } else if (item == popUpMenuList[1]) {
                      // 친구 관리
                      LaunchUrl().alertFunc(
                          context, '알림', '친구 관리 기능은 준비중입니다', '확인', () {
                        Navigator.pop(context);
                      });
                    } else if (item == popUpMenuList[2]) {
                      // 운영정책
                      await LaunchUrl().myLaunchUrl(
                          'https://sites.google.com/view/pingponplus-operationpolicy/%ED%99%88');
                    } else if (item == popUpMenuList[3]) {
                      // 운영정책
                      LaunchUrl().alertFunc(context, '알림',
                          '유저를 차단하려면 차단하려는 유저의 채팅방을 왼쪽으로 슬리이드해주세요', '확인', () {
                        Navigator.pop(context);
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    ...popUpMenuList.map((String item) => PopupMenuItem<String>(
                          value: item,
                          child: Text(item),
                        )),
                  ],
                ),
              ]
            : [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 150,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                stream: _stream,
                builder: (context, snapshot) {
                  //print('chatlist snapshot: $snapshot');
                  var data = snapshot.data; //List<Room>?
                  //print('chatlist data : ${data}');
                  //print('chatlist data.length : ${data.length}');
                  //print('chatlist data.runtimeType : ${data.runtimeType}');
                  if (snapshot.connectionState ==
                    ConnectionState.done || snapshot.connectionState ==
                      ConnectionState.active) {
                    if (snapshot.hasData && data?.length != 0) {
                      // 데이터가 있을 때
                      // 데이터를 사용하여 화면을 구성하는 위젯 반환

                      /////////////////////////////////////////

                      if (data.runtimeType == List<types.Room>) {
                        // 채팅 목록

                        Map<Room, int> badgeCounts = {};

                        int itemCount = data
                            ?.where((item) => item?.lastMessages != null)
                            ?.length ??
                            0;
                        print('itemCount : ${itemCount}');

                        // if (itemCount == 0) {
                        //   return Center(
                        //     child: Text('데이터 없음'),
                        //   );
                        // } else {
                        // data?[index] 하나하나가 모두 현재 유저가 속한 채팅방

                        // badgeCount 계산 로직 (이미 위에 작성하신 로직을 활용)
                        for (var chat in data) {
                          print('chat: ${chat}');
                          print('chat: ${chat.metadata}');

                          Map<String, dynamic> chatMetadata = chat.metadata;

                          List<Map<String, dynamic>> lastSeenList = chatMetadata.entries.map((entry) {
                            return {'userId': entry.key, 'isInRoom': entry.value['isInRoom'], 'lastSeen': entry.value['lastSeen']};
                          }).toList();

                          List<Map<String, dynamic>> filteredMyItems = lastSeenList
                              .where((item) => item['userId'] == currentUserProfileUid)
                              .toList();

                          List<Map<String, dynamic>> filteredOpponentItems = lastSeenList
                              .where((item) => item['userId'] != currentUserProfileUid)
                              .toList();

                          int badgeCount = 0;
                          if (filteredOpponentItems.isNotEmpty && filteredMyItems.isNotEmpty) {
                            badgeCount += (filteredOpponentItems.first['lastSeen'] as int) -
                                (filteredMyItems.first['lastSeen'] as int);
                            if (badgeCount < 0) {
                              badgeCount = 0;
                            }
                          }

                          //chatMetadata['badgeCount'] = badgeCount;  // 대화 데이터에 badgeCount 추가
                          //print('chatMetadata[badgeCount]: ${chatMetadata['badgeCount']}');
                          print('chat.metadata: ${chat.metadata}');
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
                            //print('index: $index');
                            //print('data?[index]: ${data?[index]}');
                            //var chat = data[index];

                            if (data?[index].lastMessages != null) {
                              print('data?[index].lastMessages != null');
                              final users = data?[index].users;
                              print('users: $users');

                              final metaData = data?[index].metadata;
                              //print('metaData: $metaData');

                              final lastSeenList = metaData.entries.map((entry) {
                                print('entry.key: ${entry.key}');
                                print('entry.value: ${entry.value}');
                                //print('entry.value: ${entry.value['lastSeen']}');
                                return {
                                  'userId': entry.key,
                                  // 사용자 ID
                                  'lastSeen': entry.value['lastSeen'],
                                  // 마지막으로 본 시간
                                };
                              }).toList();

                              print('lastSeenList: $lastSeenList');

                              final lastMessages = data?[index].lastMessages;
                              final lastMessage = lastMessages?.first as types.TextMessage?;
                              final latestChat = lastMessage?.text ?? '';

                              print('latestChat: $latestChat');
                              print('currentUserProfileUid: $currentUserProfileUid');

                              // 상대방이 회원 탈퇴한 경우는 users 에서 나가버리기 때문에 noCurrentUser가 []로 나타날 수 밖에 없음

                              final noCurrentUser = users
                                  ?.where((element) =>
                              element.id != currentUserProfileUid)
                                  .toList();
                              print('noCurrentUser: $noCurrentUser');

                              final element = noCurrentUser.isEmpty
                                  ? null
                                  : noCurrentUser.first.toJson();

                              // final element =
                              //     noCurrentUser?.first.toJson(); //User
                              print('noCurrentUser element: $element');
                              //print('data.length: ${data?.length}');
                              // lastSeenList 를 여기서 선언해야 할듯
                              print('lastSeenList: ${lastSeenList}');
                              // print(
                              //     'lastSeenList[index]: ${lastSeenList[index]}');
                              //
                              // print(
                              //     'lastSeenList.runtimeType: ${lastSeenList.runtimeType}');
                              // print(
                              //     'lastSeenList[index].runtimeType: ${lastSeenList[index].runtimeType}');
                              //
                              // print(
                              //     'lastSeenList[index][lastSeen]: ${lastSeenList[index]['lastSeen']}');

                              //Map<String, dynamic> filteredMyItem = lastSeenList.where((item) => item['userId'] == currentUserProfileUid);
                              //Map<String, dynamic> filteredOpponentItem = lastSeenList.where((item) => item['userId'] != currentUserProfileUid);

                              // List<Map<String, dynamic>> filteredMyItems = lastSeenList.where((item) => item['userId'] == currentUserProfileUid).toList();
                              // List<Map<String, dynamic>> filteredOpponentItems = lastSeenList.where((item) => item['userId'] != currentUserProfileUid).toList();

                              List<Map<String, dynamic>> filteredMyItems =
                              lastSeenList
                                  .whereType<Map<String, dynamic>>()
                                  .where((item) =>
                              item['userId'] == currentUserProfileUid)
                                  .toList();
                              print(
                                  'filteredMyItems: $filteredMyItems'); // [{userId: XRxDio7Cxec67Nbl3Q4mBy0Ahkh2, lastSeen: 2}]

                              List<Map<String, dynamic>> filteredOpponentItems =
                              lastSeenList
                                  .whereType<Map<String, dynamic>>()
                                  .where((item) =>
                              item['userId'] != currentUserProfileUid)
                                  .toList();
                              print(
                                  'filteredOpponentItems: $filteredOpponentItems'); // [{userId: XRxDio7Cxec67Nbl3Q4mBy0Ahkh2, lastSeen: 2}]


                              print('배지 1: ${filteredOpponentItems.first['lastSeen']
                              as int}');
                              print('배지 2: ${filteredMyItems.first['lastSeen']
                              as int}');
                              print('배지 3: ${(filteredOpponentItems.first['lastSeen']
                              as int) -
                                  (filteredMyItems.first['lastSeen']
                                  as int)}');

                              if ((filteredOpponentItems.first['lastSeen'] as int) - (filteredMyItems.first['lastSeen'] as int) >= 0) {

                                badgeCount = badgeCount +
                                    (filteredOpponentItems.first['lastSeen']
                                    as int) -
                                    (filteredMyItems.first['lastSeen'] as int);

                                //print('badgeCount: $badgeCount');
                              }

                              if (badgeCount < 0) {
                                badgeCount = 0;
                              }
                              print('chatlist listview builder badgeCount: $badgeCount');
                              RepositoryRealtimeUsers().getUpdateMyBadge(badgeCount);

                              badgeCount = 0; // 업로드 이후 badgeCount 초기화

                              if (element != null) {
                                return Dismissible(
                                  direction: DismissDirection.endToStart,
                                  // 왼쪽에서 오른쪽으로 슬라이드할 때만 작동
                                  confirmDismiss: (direction) {
                                    Completer<bool> completer = Completer<bool>();
                                    //if (direction == DismissDirection.endToStart) {
                                    LaunchUrl().alertOkAndCancelFunc(
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
                                      });
                                    }, () async {
                                      // currentUser에다가 상대방을 차단 목록에 추가

                                      await RepositoryRealtimeBlockedList()
                                          .getAddToBlockList(
                                          currentUserProfileUid, element)
                                          .then((value) async {
                                        // final List<Map<String, dynamic>> messagesJson =
                                        // messages.map((message) => message.toJson()).toList();
                                        //
                                        // // 업데이트된 Room 객체를 Firebase에 저장
                                        // await messagesRef.set(messagesJson);

                                        //await blockRef.set(element);
                                        //print('차단 목록에 추가');

                                        await RepositoryRealtimeUsers()
                                            .getAdjustOpponentBadge(
                                            element['id'],
                                            filteredOpponentItems
                                                .first['lastSeen'] -
                                                filteredMyItems
                                                    .first['lastSeen'])
                                            .then((value) {
                                          completer.complete(true);

                                          //removeUserCount++;

                                          setState(() {
                                            data.removeAt(index);
                                            //data = List.from(data)..removeAt(index);
                                            print('data.length : ${data.length}');
                                          });
                                        });
                                      });
                                    });
                                    //}

                                    return completer.future;
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    decoration: BoxDecoration(
                                      color: Colors.red, // 슬라이드 할 때 보여지는 배경 색상
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 20.0),
                                      // 왼쪽 패딩 추가
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(Icons.block, color: Colors.white),
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
                                              print(
                                                  'filteredOpponentItems: ${filteredOpponentItems}');
                                              print('lastMessage: ${lastMessage}');
                                              print(
                                                  'lastMessage: ${lastMessage?.author}');
                                              //element.id가 해당 유저의 uid
                                              MoveToOtherScreen().bottomProfileUp(
                                                  context, element['id']);
                                            },
                                            child: CircleAvatar(
                                              backgroundImage:
                                              NetworkImage(element?["imageUrl"])
                                              as ImageProvider<Object>,
                                            ),
                                          ),
                                          title: Text(
                                            element?["firstName"],
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                          subtitle: Text(
                                            latestChat ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                                                filteredOpponentItems != null &&
                                                (filteredOpponentItems
                                                    .first['lastSeen'] -
                                                    filteredMyItems
                                                        .first['lastSeen'] >
                                                    0))
                                                ? Text(
                                                '${filteredOpponentItems.first['lastSeen'] - filteredMyItems.first['lastSeen']}')
                                                : null,
                                            // 여기서 lastseen 을 그대로 내보내는게 아니라, (메시지 개수 - lastSeen)으로 표현되어야 함
                                            backgroundColor: (filteredMyItems !=
                                                null &&
                                                filteredOpponentItems != null &&
                                                (filteredOpponentItems
                                                    .first['lastSeen'] -
                                                    filteredMyItems
                                                        .first['lastSeen'] >
                                                    0))
                                                ? Colors.red
                                                : Colors.transparent,
                                            smallSize: 10.0,
                                            //largeSize: 20.0,
                                            child: Icon(Icons.chat_bubble_outline),
                                          ),
                                          onTap: () async {

                                            print('index: $index');
                                            setState(() {
                                              absorbPointing = true;
                                            });
                                            await RepositoryRealtimeUsers()
                                                .getDownloadMyBadge()
                                                .then((badge) async {

                                              // final lastSeenListIndex =
                                              //     filteredMyItems.first['lastSeen']
                                              //         as int;
                                              // final currentBadge =
                                              //     badge - lastSeenListIndex;
                                              //
                                              // print('currentBadge: $currentBadge');

                                              // await ChatBackgroundListen()
                                              //     .updateMyBadge(currentBadge)
                                              //     .then((value) {
                                              setState(() {
                                                //lastSeenList[index] = 0;
                                                filteredMyItems
                                                    .first['lastSeen'] = 0;

                                                absorbPointing = false;

                                                MoveToOtherScreen()
                                                    .persistentNavPushNewScreen(
                                                  context,
                                                  ChatScreen(
                                                      receivedData: element!),
                                                  false,
                                                  PageTransitionAnimation
                                                      .cupertino,
                                                );
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
                                final String chatRoomId = data?[index].id;
                                return Dismissible(
                                  direction: DismissDirection.endToStart,
                                  // 왼쪽에서 오른쪽으로 슬라이드할 때만 작동
                                  confirmDismiss: (direction) {
                                    Completer<bool> completer = Completer<bool>();
                                    //if (direction == DismissDirection.endToStart) {
                                    LaunchUrl().alertOkAndCancelFunc(
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
                                      });
                                    }, () async {
                                      await RepositoryRealtimeMessages()
                                          .getDeleteChatRoom(chatRoomId)
                                          .then((value) {
                                        completer.complete(true);

                                        setState(() {
                                          data.removeAt(index);
                                          //data = List.from(data)..removeAt(index);
                                          print('data.length : ${data.length}');
                                        });
                                      });
                                    });
                                    //}

                                    return completer.future;
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    decoration: BoxDecoration(
                                      color: Colors.red, // 슬라이드 할 때 보여지는 배경 색상
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 20.0),
                                      // 왼쪽 패딩 추가
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(Icons.block, color: Colors.white),
                                          Text(
                                            '차단',
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
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                        subtitle: Text(
                                          latestChat ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: Badge(
                                          label: (filteredMyItems != [] &&
                                              filteredOpponentItems != [] &&
                                              (filteredOpponentItems
                                                  .first['lastSeen'] -
                                                  filteredMyItems
                                                      .first['lastSeen'] >
                                                  0))
                                              ? Text(
                                              '${filteredOpponentItems.first['lastSeen'] - filteredMyItems.first['lastSeen']}')
                                              : null,
                                          // 여기서 lastseen 을 그대로 내보내는게 아니라, (메시지 개수 - lastSeen)으로 표현되어야 함
                                          backgroundColor: (filteredMyItems !=
                                              [] &&
                                              filteredOpponentItems != [] &&
                                              (filteredOpponentItems
                                                  .first['lastSeen'] -
                                                  filteredMyItems
                                                      .first['lastSeen'] >
                                                  0))
                                              ? Colors.red
                                              : Colors.transparent,
                                          smallSize: 10.0,
                                          //largeSize: 20.0,
                                          child: Icon(Icons.chat_bubble_outline),
                                        ),
                                        onTap: () async {
                                          LaunchUrl().alertOkAndCancelFunc(
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
                                            print(
                                                'lastMessages.length: ${lastMessages.length}');
                                            print(
                                                'lastMessages: ${lastMessages}');

                                            for (final types.TextMessage message
                                            in lastMessages) {
                                              //final author = message.author as types.User;
                                              final author = types.User(
                                                id: message.author.id,
                                                imageUrl: message.author.imageUrl,
                                                firstName:
                                                message.author.firstName,
                                                lastSeen: 0,
                                              );
                                              print('author: ${author}');

                                              if (author.id !=
                                                  currentUserProfileUid) {
                                                DatabaseReference ref =
                                                FirebaseDatabase.instance.ref(
                                                    "messages/$chatRoomId/users");

                                                await ref
                                                    .once()
                                                    .then((dataSnapshot) async {
                                                  print(
                                                      'dataSnapshot: $dataSnapshot');
                                                  print(
                                                      'dataSnapshot.snapshot.value: ${dataSnapshot.snapshot.value}');

                                                  final authorList = dataSnapshot
                                                      .snapshot
                                                      .value as List<Object?>;
                                                  final authorListMe = authorList
                                                      ?.first
                                                  as Map<Object?, Object?>;

                                                  final authorMe = types.User(
                                                    id: authorListMe['id']
                                                    as String,
                                                    imageUrl:
                                                    authorListMe['imageUrl']
                                                    as String,
                                                    firstName:
                                                    authorListMe['firstName']
                                                    as String,
                                                    lastSeen: 0,
                                                  );

                                                  print('authorMe: $authorMe');

                                                  final _list = [
                                                    author,
                                                    authorMe
                                                  ];

                                                  final List<Map<String, dynamic>>
                                                  _listJson = _list
                                                      .map((message) =>
                                                      message.toJson())
                                                      .toList();

                                                  await ref.set(_listJson);

                                                  return;
                                                });
                                              }
                                            }

                                            await RepositoryRealtimeUsers()
                                                .getDownloadMyBadge()
                                                .then((badge) async {
                                              //final lastSeenListIndex = lastSeenList[index]['lastSeen'] as int;
                                              final lastSeenListIndex =
                                              filteredMyItems
                                                  .first['lastSeen'] as int;
                                              final currentBadge =
                                                  badge - lastSeenListIndex;

                                              print('downloadMyBadge 이후 updateMyBadge');
                                              await RepositoryRealtimeUsers()
                                                  .getUpdateMyBadge(currentBadge)
                                                  .then((value) {
                                                setState(() {
                                                  //lastSeenList[index] = 0;
                                                  filteredMyItems
                                                      .first['lastSeen'] = 0;

                                                  MoveToOtherScreen()
                                                      .persistentNavPushNewScreen(
                                                    context,
                                                    ChatScreen(receivedData: {
                                                      chatRoomId: null
                                                    }),
                                                    false,
                                                    PageTransitionAnimation
                                                        .cupertino,
                                                  );
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
                      } else if (data.runtimeType == List<types.User>) {
                        // 차단 목록
                        // data == List<types.User>
                        return ListView.builder(
                            scrollDirection: Axis.vertical,
                            controller: _BlockedListScrollController,
                            //shrinkWrap: true,
                            itemCount: data?.length,
                            //snapshot.data?.docs.length,
                            padding: const EdgeInsets.all(8.0),
                            itemBuilder: ((context, index) {
                              final _blockedUser = data?[index] as types.User;
                              //print('_blockedUser: $_blockedUser');
                              if (data?.length == 0) {
                                return Center(
                                    child: Text(
                                      '데이터 없음',
                                      style: TextStyle(),
                                    ));
                              } else {
                                if (_blockedUser.id != currentUserProfileUid) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                      NetworkImage(_blockedUser.imageUrl!)
                                      as ImageProvider<Object>,
                                    ),
                                    title: Text(
                                      _blockedUser.firstName!,
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    trailing: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            width: 0.7, color: Colors.grey),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                        ),
                                      ),
                                      child: Text('해제'),
                                      onPressed: () async {
                                        LaunchUrl().alertFunc(
                                            context,
                                            '알림',
                                            '해당 유저를 차단 해제하시겠습니까?',
                                            '확인', () async {
                                          DatabaseReference blockRef =
                                          FirebaseDatabase.instance.ref(
                                              "blockedList/${currentUserProfileUid}");

                                          await blockRef.remove();

                                          setState(() {
                                            // 아이템을 목록에서 제거
                                            //print('차단 목록에서 삭제');
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
                    return Center(
                      child: Column(
                        children: [
                          kCustomCircularProgressIndicator,
                          Text('Error: ${snapshot.error}'),
                        ],
                      ),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                        child:
                            kCustomCircularProgressIndicator); // 데이터 로딩 중일 때 보여줄 위젯
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

          final user = types.User(
            id: finalValue['id'] as String,
            imageUrl: finalValue['imageUrl'] as String,
            firstName: finalValue['firstName'] as String,
            lastSeen: finalValue['lastSeen'] as int,
          );

          _blockedList.add(user);
        });

        //_blockedList.add(user);
      }
      //print('_blockedList: $_blockedList');

      yield _blockedList;
    } catch (e) {
      print('getBlockedUsers e: $e');
      yield [];
    }
  }

  Stream<List<types.Room>> getRoomsStream(bool makeAllRead) async* {
    DatabaseReference blockedRef =
        FirebaseDatabase.instance.ref('blockedList/${currentUserProfileUid}');
    final result = await blockedRef.once();

    List<String> _blockedList = [];

    if (result.snapshot.value != null) {
      //print('result.snapshot.valuexs: ${result.snapshot.value}');
      final _user = result.snapshot.value as Map<Object?, Object?>;
      print('_user: $_user');

      final _userMap = result.snapshot.value as Map<Object?, Object?>;

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
    } // 차단 유저 찾기

    ///////

    DatabaseReference messageRef = FirebaseDatabase.instance.ref('messages');

    yield* messageRef.onValue.map((event) {
      List<types.Room> _roomsList = [];

      final dataSnapshot = event.snapshot;
      final List<DataSnapshot> snapshot = dataSnapshot.children.toList();

      // 데이터 스냅샷에서 Room 객체를 생성하는 함수
      types.Room roomFromSnapshot(DataSnapshot snapshot) {
        final _map = snapshot.value as Map<Object?, Object?>?;
        final data = _map?.cast<String, dynamic>() ?? {};

        //final metadata = data['metadata'] as Map<Object?, Object?>?;
        final metadata =
            (data['metadata'] as Map<Object?, Object?>?)?.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );
        // print('metadata: $metadata');
        // print('metadata: ${metadata.runtimeType}');
        // Room 객체 생성 및 반환
        //print('data[users]: ${data['users']}');
        return types.Room(
          id: data['id'].toString(),
          type: types.RoomType.direct,
          users: ((data['users'] as List<dynamic>).map((userData) {
            //print('userData: $userData');
            // if (userData == null){
            //   return types.User(
            //       id: 'id',
            //       imageUrl: 'imageUrl',
            //       firstName: '(알 수 없는 사용자)',
            //       lastSeen: 0);
            // } else {
            //   // User 객체를 생성하고 반환
            return types.User(
                id: userData['id'],
                imageUrl: userData['imageUrl'],
                firstName: userData['firstName'],
                lastSeen: userData['lastSeen']);
            //}
          }).toList()),
          lastMessages:
              (data['lastMessages'] as List<dynamic>?)?.map((userData) {
            final authorData = userData['author'] as Map<Object?, Object?>;
            final author = types.User(
                id: authorData['id'] as String, // 문자열로 캐스팅
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
          .map((snapshot) => roomFromSnapshot(snapshot)) // 각 스냅샷을 Room 객체로 변환
          .where((room) =>
              room.metadata?[currentUserProfileUid] !=
              null) // 조건을 만족하는 Room만 필터링
          .toList(); // 필터링된 Room 객체들을 리스트로 변환
      // 기존의 채팅방은 리스트에 안 보일 수 있음. 메타데이터 필드가 없기 때문

      // 모든 채팅방을 반복하여 사용자가 속한 채팅방을 식별
      // ( 채팅방의 채팅 개수 - 현재 유저의 lastSeen )을 이용해 읽지 않은 편지 개수를 표현해야 함

      for (final room in allRooms) {
        //print('Room Length: ${room.lastMessages?.length}');
        //final lastMessagesLength = room.lastMessages?.length ?? 0;

        bool containsBlockedUser = false;

        // int lastSeenInt;

        //final myLastSeen =  room.metadata?[currentUserProfileUid]['lastSeen'] as int;

        //print('roomMetadata mylastSeen: $mylastSeen');
        //
        // //setState(() {
        // lastSeenInt = (lastMessagesLength - lastSeen);
        // print('lastSeenInt: $lastSeenInt');
        //lastSeenList.add(lastSeenInt);
        //});

        for (final user in room.users) {
          // 차단된 사용자 포함 여부 확인
          if (_blockedList.contains(user.id)) {
            containsBlockedUser = true;
          }
        }

        if (!containsBlockedUser) {
          _roomsList.add(room);
        }

        /////////// 모두 읽음 처리 하는 경우에만

        if (makeAllRead == true) {
          int myLastSeen = 0;
          String myKey = '';
          int opponentLastSeen = 0;
          String opponentKey = '';

          room.metadata?.forEach((key, value) {
            print('room.metadata key: $key');
            print('room.metadata value: $value');

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
            print('if (myLastSeen < opponentLastSeen) { 진입');

            if (_roomsList.contains(room)) {
              print('if (_roomsList.contains(room)) { 진입');

              DatabaseReference ref = FirebaseDatabase.instance
                  .ref("messages/${room.id}/metadata/${myKey}/lastSeen");

              // await ref.set(currentBadge);
              ref.set(opponentLastSeen);

              //room.metadata?[myKey]['lastSeen'] == opponentLastSeen;
            }
          }

          RepositoryRealtimeUsers()
              .getInitializeMyBadge();
        }

        /////////// 모두 읽음 처리 하는 경우에만
      }

      return _roomsList;
    });
  }
}
