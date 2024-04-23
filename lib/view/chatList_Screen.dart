import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/repository/launchUrl.dart';
import 'package:dnpp/repository/moveToOtherScreen.dart';
import 'package:dnpp/view/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import '../models/userProfile.dart';
import '../norification.dart';
import '../repository/chatBackgroundListen.dart';
import '../statusUpdate/loginStatusUpdate.dart';
import '../statusUpdate/profileUpdate.dart';

class ChatListView extends StatefulWidget {
  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  ScrollController _BlockedListScrollController = ScrollController();
  ScrollController _chatListScrollController = ScrollController();

  late Stream _stream;
  late UserProfile currentUserProfile;

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

    currentUserProfile =
        Provider.of<ProfileUpdate>(context, listen: false).userProfile;

    myFuture = ChatBackgroundListen()
        .checkUserNotification(currentUserProfile.uid.toString());

    _stream = getRoomsStream();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final status = await FlutterLocalNotification.requestNotificationPermission();
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
    super.initState();
  }

  @override
  void dispose() {
    _stream = Stream.empty(); // 스트림 리스너 취소
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMainColor,
        title: isBlockList ? Text('차단 목록') : Text('채팅'),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: (Provider.of<LoginStatusUpdate>(context, listen: false)
                .isLoggedIn)
            ? [
                IconButton(
                  onPressed: () async {
                    // LaunchUrl()
                    //     .alertFunc(context, '알림', '친구 관리 기능은 준비중입니다', '확인', () {
                    //   Navigator.pop(context);
                    // });
                    await ChatBackgroundListen().adjustOpponentBadgeCount(FirebaseAuth.instance.currentUser!.uid.toString());
                  },
                  icon: Icon(CupertinoIcons.person_add_solid),
                ),
                IconButton(
                  onPressed: () {

                    if (isBlockList == true) {

                      isBlockList = false;
                      print('isBlockList = false');
                      setState(() {
                        _stream = getRoomsStream();
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
                          //     .checkUserNotification(currentUserProfile.uid.toString());
                          // print('bool: ${bool}');

                          if (notiBool == true) {
                            LaunchUrl()
                                .alertFunc(context, '알림', '채팅 알림을 비활성화합니다\n(채팅이 도착해도 알리지 않습니다)', '확인', () async {
                              //notiBool 가 true 이면 수신되는 상태이고 수신 불가로 아이콘이 바뀌어야 함, false 이면, 알림수신이 안되는 상태

                              await ChatBackgroundListen()
                                  .toggleNotification(false);

                              myFuture = ChatBackgroundListen()
                                  .checkUserNotification(
                                  currentUserProfile.uid.toString());
                              setState(() {
                                Navigator.pop(context);
                              });
                            });
                          } else {
                            LaunchUrl()
                                .alertFunc(context, '알림', '채팅 알림을 활성화합니다\n(채팅이 도착하면 알림을 받습니다)', '확인', () async {
                              //notiBool 가 true 이면 수신되는 상태이고 수신 불가로 아이콘이 바뀌어야 함, false 이면, 알림수신이 안되는 상태

                              await ChatBackgroundListen()
                                  .toggleNotification(true);

                              myFuture = ChatBackgroundListen()
                                  .checkUserNotification(
                                  currentUserProfile.uid.toString());

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
                          //         currentUserProfile.uid.toString());
                        },
                        icon: notiBool
                            ? Icon(Icons.notifications_none)
                            : Icon(Icons.notifications_off_outlined),
                      );
                    }),
              ]
            : [],
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 150,
            width: MediaQuery.of(context).size.width,
            child: StreamBuilder(
              stream: _stream,
              builder: (context, snapshot) {
                print('chatlist snapshot: $snapshot');
                final data = snapshot.data; //List<Room>?
                print('data : ${data}');

                if (snapshot.hasData && data?.length != 0) {
                  // 데이터가 있을 때
                  // 데이터를 사용하여 화면을 구성하는 위젯 반환
                  if (data.runtimeType == List<types.Room>) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _chatListScrollController,
                      //shrinkWrap: true,
                      itemCount: data?.length,
                      //snapshot.data?.docs.length,
                      padding: const EdgeInsets.all(8.0),
                      itemBuilder: ((context, index) {
                        //print('data[index].users: ${data?[index].users}');

                        if (data?.length == 0) {
                          return Center(
                            child: Text(
                              '데이터 없음',
                              style: TextStyle(),
                            ),
                          );
                        } else if (data?.length == 1 && data?[index].lastMessages == null){
                          return Center(
                            child: Text(
                              '데이터 없음',
                              style: TextStyle(),
                            ),
                          );
                        }
                        else {
                          print('dataRoom metadata: ${data?[index].metadata}');

                          if (data?[index].lastMessages != null) {
                            final users = data?[index].users;

                            final metaData = data?[index].metadata;
                            print('metaData: $metaData');

                            final lastSeenList = metaData.entries.map((entry) {
                              print('entry.key: ${entry.key}');
                              print('entry.value: ${entry.value['lastSeen']}');
                              return {
                                'userId': entry.key,
                                // 사용자 ID
                                'lastSeen': entry.value['lastSeen'],
                                // 마지막으로 본 시간
                              };
                            }).toList();

                            print('lastSeenList: $lastSeenList');

                            final lastMessages = data?[index].lastMessages;
                            final lastMessage =
                                lastMessages?.first as types.TextMessage?;

                            final latestChat = lastMessage?.text ?? '';
                            print('latestChat: $latestChat');

                            final noCurrentUser = users
                                ?.where((element) =>
                                    element.id != currentUserProfile.uid)
                                .toList();
                            //print('noCurrentUser: $noCurrentUser');

                            final element =
                                noCurrentUser?.first.toJson(); //User
                            print('noCurrentUser element: $element');
                            //print('data.length: ${data?.length}');
                            // lastSeenList 를 여기서 선언해야 할듯
                            print('lastSeenList: ${lastSeenList}');
                            print(
                                'lastSeenList[index]: ${lastSeenList[index]}');

                            print(
                                'lastSeenList.runtimeType: ${lastSeenList.runtimeType}');
                            print(
                                'lastSeenList[index].runtimeType: ${lastSeenList[index].runtimeType}');

                            print(
                                'lastSeenList[index][lastSeen]: ${lastSeenList[index]['lastSeen']}');

                            //Map<String, dynamic> filteredMyItem = lastSeenList.where((item) => item['userId'] == currentUserProfile.uid.toString());
                            //Map<String, dynamic> filteredOpponentItem = lastSeenList.where((item) => item['userId'] != currentUserProfile.uid.toString());

                            // List<Map<String, dynamic>> filteredMyItems = lastSeenList.where((item) => item['userId'] == currentUserProfile.uid.toString()).toList();
                            // List<Map<String, dynamic>> filteredOpponentItems = lastSeenList.where((item) => item['userId'] != currentUserProfile.uid.toString()).toList();

                            List<Map<String, dynamic>> filteredMyItems =
                                lastSeenList
                                    .whereType<Map<String, dynamic>>()
                                    .where((item) =>
                                        item['userId'] ==
                                        currentUserProfile.uid.toString())
                                    .toList();
                            List<Map<String, dynamic>> filteredOpponentItems =
                                lastSeenList
                                    .whereType<Map<String, dynamic>>()
                                    .where((item) =>
                                        item['userId'] !=
                                        currentUserProfile.uid.toString())
                                    .toList();

                             return Dismissible(
                              direction: DismissDirection.endToStart,
                              // 왼쪽에서 오른쪽으로 슬라이드할 때만 작동
                              onDismissed: (direction) async {
                                //DatabaseReference usersRef = FirebaseDatabase.instance.ref("messages/${generateChatRoomId(currentUserProfile, element!)}/users");

                                // //await usersRef.child(currentUserProfile.uid).remove();
                                // await usersRef.remove();

                                setState(() {
                                  data.removeAt(index);
                                });

                                // currentUser에다가 상대방을 차단 목록에 추가
                                DatabaseReference blockRef =
                                    FirebaseDatabase.instance.ref(
                                        "blockedList/${currentUserProfile.uid}");
                                //await blockRef.set(element?['id']);
                                await blockRef.set(element);
                                //print('차단 목록에 추가');
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
                                  child:
                                      Icon(Icons.block, color: Colors.white),
                                ),
                              ),
                              key: ValueKey<String>('list_item_$index'),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: GestureDetector(
                                      onTap: () {
                                        print('filteredOpponentItems: ${filteredOpponentItems}');
                                        print('lastMessage: ${lastMessage}');
                                        print('lastMessage: ${lastMessage?.author}');
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

                                      final badge = await ChatBackgroundListen()
                                          .downloadMyBadge();
                                      print(
                                          'lastSeenList[index]: ${lastSeenList[index]}');
                                      final lastSeenListIndex =
                                          lastSeenList[index]['lastSeen']
                                              as int;
                                      final currentBadge =
                                          badge - lastSeenListIndex;

                                      print(
                                          'lastSeenList[index]: ${lastSeenList[index]}');
                                      print('currentBadge: $currentBadge');

                                      await ChatBackgroundListen()
                                          .updateMyBadge(currentBadge);

                                      setState(() {
                                        lastSeenList[index] = 0;

                                        MoveToOtherScreen()
                                            .persistentNavPushNewScreen(
                                          context,
                                          ChatScreen(receivedData: element!),
                                          false,
                                          PageTransitionAnimation.cupertino,
                                        );
                                      });
                                    },
                                  ),
                                  //Divider(),
                                ],
                              ),
                            );
                          }
                          // else {
                          //   return Center(
                          //     child: Text(
                          //       '데이터 없음2',
                          //       style: TextStyle(),
                          //     ),
                          //   );
                          // }
                        }
                      }),
                    );
                  } else if (data.runtimeType == List<types.User>) {
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
                            if (_blockedUser.id != currentUserProfile.uid) {
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
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  child: Text('해제'),
                                  onPressed: () async {
                                    LaunchUrl().alertFunc(context, '알림',
                                        '해당 유저를 차단 해제하시겠습니까?', '확인', () async {
                                      DatabaseReference blockRef =
                                          FirebaseDatabase.instance.ref(
                                              "blockedList/${currentUserProfile.uid}");

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

                  // } else if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return kCustomCircularProgressIndicator;
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
                  return Center(child: kCustomCircularProgressIndicator); // 데이터 로딩 중일 때 보여줄 위젯
                } else {
                  // 데이터가 없는 경우
                  // 로딩 인디케이터 등을 표시하는 위젯 반환
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
    );
  }

  Stream<List<types.User>> getBlockedUsers() async* {
    DatabaseReference blockedRef =
        FirebaseDatabase.instance.ref('blockedList/${currentUserProfile.uid}');
    final result = await blockedRef.once();

    List<types.User> _blockedList = [];

    if (result.snapshot.value != null) {
      //print('result.snapshot.valuexs: ${result.snapshot.value}');
      final _user = result.snapshot.value as Map<Object?, Object?>;

      final user = types.User(
        id: _user['id'] as String,
        imageUrl: _user['imageUrl'] as String,
        firstName: _user['firstName'] as String,
      );

      _blockedList.add(user);
    }
    //print('_blockedList: $_blockedList');

    yield _blockedList;
  }

  Stream<List<types.Room>> getRoomsStream() async* {
    DatabaseReference blockedRef =
        FirebaseDatabase.instance.ref('blockedList/${currentUserProfile.uid}');
    final result = await blockedRef.once();

    List<String> _blockedList = [];

    if (result.snapshot.value != null) {
      //print('result.snapshot.valuexs: ${result.snapshot.value}');
      final _user = result.snapshot.value as Map<Object?, Object?>;

      final user = types.User(
        id: _user['id'] as String,
        imageUrl: _user['imageUrl'] as String,
        firstName: _user['firstName'] as String,
      );

      _blockedList.add(user.id);
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

        print('types.Room _map:  ${_map?['users']}');
        print('types.Room data: ${data['users']}');

        // print('roomFromSnapshot data: ${data}');
        // print('roomFromSnapshot data: ${data.runtimeType}');
        // print('roomFromSnapshot id data: ${data['id']}');
        // print('roomFromSnapshot data: ${data['metadata']}');
        // print('roomFromSnapshot lastMessages data: ${data['lastMessages'].runtimeType}');
        // print('roomFromSnapshot data: ${data['metadata'].runtimeType}');
        // print('roomFromSnapshot metadata data: ${data['metadata'].runtimeType}');
        //
        // print('data[metadata]: ${data['metadata']}');
        // print('data[metadata]: ${data['metadata'].runtimeType}');

        //final metadata = data['metadata'] as Map<Object?, Object?>?;
        final metadata =
            (data['metadata'] as Map<Object?, Object?>?)?.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );
        // print('metadata: $metadata');
        // print('metadata: ${metadata.runtimeType}');
        // Room 객체 생성 및 반환
        print('data[users]: ${data['users']}');
        return types.Room(
          id: data['id'].toString(),
          type: types.RoomType.direct,
          users: ((data['users'] as List<dynamic>).map((userData) {
            // User 객체를 생성하고 반환
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
                id: authorData['id'] as String, // 문자열로 캐스팅
                imageUrl: authorData['imageUrl'] as String?,
                firstName: authorData['firstName'] as String?,
                lastSeen: userData['lastSeen'] as int?
                // 추가적인 필드가 있다면 여기에 추가
                );

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

      // 모든 데이터 스냅샷을 기반으로 Room 객체들을 생성
      // final List<types.Room> allRooms =
      //     snapshot.map((snapshot) => roomFromSnapshot(snapshot)).toList();
      // 모든 데이터 스냅샷을 기반으로 Room 객체들을 생성
      final List<types.Room> allRooms = snapshot
          .map((snapshot) => roomFromSnapshot(snapshot)) // 각 스냅샷을 Room 객체로 변환
          .where((room) =>
              room.metadata?[currentUserProfile.uid] !=
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
        //
        // final lastSeen =  room.metadata?[currentUserProfile.uid]['lastSeen'] as int;
        // print('roomMetadata lastSeen: $lastSeen');
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
      }

      return _roomsList;
    });
  }
}
