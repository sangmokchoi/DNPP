import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/repository/moveToOtherScreen.dart';
import 'package:dnpp/view/chat_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import '../models/userProfile.dart';
import '../statusUpdate/profileUpdate.dart';

class ChatListView extends StatefulWidget {
  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  ScrollController _viewScrollController = ScrollController();
  ScrollController _courtScrollController = ScrollController();

  late Stream _stream;
  late UserProfile currentUserProfile;

  // void _loadMessages() {
  //   DatabaseReference messageRef = FirebaseDatabase.instance.ref('messages');
  //
  //   messageRef.onValue.listen((DatabaseEvent event) {
  //     List<types.Room> _roomsList = [];
  //
  //     final dataSnapshot = event.snapshot;
  //
  //     final List<DataSnapshot> snapshot = dataSnapshot.children.toList();
  //     print('snapshot: $snapshot');
  //
  //     // 데이터 스냅샷에서 Room 객체를 생성하는 함수
  //     types.Room roomFromSnapshot(DataSnapshot snapshot) {
  //       final _map = snapshot.value as Map<Object?, Object?>?;
  //       final data = _map?.cast<String, dynamic>() ?? {};
  //
  //       // Room 객체 생성 및 반환
  //       return types.Room(
  //           id: data['id'],
  //           type: types.RoomType.direct,
  //           users: (data['users'] != null
  //               ? (data['users'] as List<dynamic>).map((userData) {
  //
  //               // User 객체를 생성하고 반환
  //               return types.User(
  //                 id: userData['id'],
  //                 imageUrl: userData['imageUrl'],
  //                 firstName: userData['firstName'],
  //               );
  //
  //           }).toList()
  //               : []),
  //
  //           lastMessages:
  //               (data['lastMessages'] as List<dynamic>?)?.map((userData) {
  //             final authorData = userData['author'] as Map<Object?, Object?>;
  //             final author = types.User(
  //               id: authorData['id'] as String, // 문자열로 캐스팅
  //               imageUrl: authorData['imageUrl'] as String?,
  //               firstName: authorData['firstName'] as String?,
  //               // 추가적인 필드가 있다면 여기에 추가
  //             );
  //
  //             return types.TextMessage(
  //                 id: userData['id'],
  //                 createdAt: userData['createdAt'],
  //                 text: userData['text'],
  //                 author: author);
  //           }).toList() // List<Object?>
  //       );
  //     }
  //
  //     // 모든 데이터 스냅샷을 기반으로 Room 객체들을 생성
  //     final List<types.Room> allRooms =
  //         snapshot.map((snapshot) => roomFromSnapshot(snapshot)).toList();
  //
  //     // 모든 채팅방을 반복하여 사용자가 속한 채팅방을 식별
  //     for (final room in allRooms) {
  //       // 사용자 목록에서 user() 또는 opponentUser()가 포함되어 있는지 확인
  //       final bool containsCurrentUser = room.users.any((element) => element.id == currentUserProfile.uid);
  //       if (containsCurrentUser) {
  //         _roomsList.add(room); // 사용자가 속한 채팅방을 추가
  //       }
  //
  //     }
  //
  //     setState(() {
  //       _rooms = _roomsList;
  //     });
  //   });
  // }

  Stream<List<types.User>> getBlockedUsers() async* {
    DatabaseReference blockedRef = FirebaseDatabase.instance.ref('blockedList/${currentUserProfile.uid}');
    final result = await blockedRef.once();

    List<types.User> _blockedList = [];

    if (result.snapshot.value != null) {

      print('result.snapshot.valuexs: ${result.snapshot.value}');
      final _user = result.snapshot.value as Map<Object?, Object?>;

      final user = types.User(
          id: _user['id'] as String,
          imageUrl: _user['imageUrl'] as String,
        firstName: _user['firstName'] as String,
      );

      _blockedList.add(user);

    }
    print('_blockedList: $_blockedList');

    yield _blockedList;
  }

  Stream<List<types.Room>> getRoomsStream() async* {
    DatabaseReference messageRef = FirebaseDatabase.instance.ref('messages');

    yield* messageRef.onValue.map((event) {
      List<types.Room> _roomsList = [];

      final dataSnapshot = event.snapshot;

      final List<DataSnapshot> snapshot = dataSnapshot.children.toList();
      print('snapshot: $snapshot');

      // 데이터 스냅샷에서 Room 객체를 생성하는 함수
      types.Room roomFromSnapshot(DataSnapshot snapshot) {
        final _map = snapshot.value as Map<Object?, Object?>?;
        final data = _map?.cast<String, dynamic>() ?? {};

        // Room 객체 생성 및 반환
        return types.Room(
          id: data['id'],
          type: types.RoomType.direct,
          users: (data['users'] != null
              ? (data['users'] as List<dynamic>).map((userData) {
                  // User 객체를 생성하고 반환
                  return types.User(
                    id: userData['id'],
                    imageUrl: userData['imageUrl'],
                    firstName: userData['firstName'],
                  );
                }).toList()
              : []),
          lastMessages:
              (data['lastMessages'] as List<dynamic>?)?.map((userData) {
            final authorData = userData['author'] as Map<Object?, Object?>;
            final author = types.User(
              id: authorData['id'] as String, // 문자열로 캐스팅
              imageUrl: authorData['imageUrl'] as String?,
              firstName: authorData['firstName'] as String?,
              // 추가적인 필드가 있다면 여기에 추가
            );

            return types.TextMessage(
              id: userData['id'],
              createdAt: userData['createdAt'],
              text: userData['text'],
              author: author,
            );
          }).toList(), // List<Object?>
        );
      }

      // 모든 데이터 스냅샷을 기반으로 Room 객체들을 생성
      final List<types.Room> allRooms =
          snapshot.map((snapshot) => roomFromSnapshot(snapshot)).toList();

      // 모든 채팅방을 반복하여 사용자가 속한 채팅방을 식별
      for (final room in allRooms) {
        // 사용자 목록에서 user() 또는 opponentUser()가 포함되어 있는지 확인
        final bool containsCurrentUser =
            room.users.any((element) => element.id == currentUserProfile.uid);
        if (containsCurrentUser) {
          _roomsList.add(room); // 사용자가 속한 채팅방을 추가
        }
      }

      return _roomsList;
    });
  }

  @override
  void initState() {
    currentUserProfile =
        Provider.of<ProfileUpdate>(context, listen: false).userProfile;

    _stream = getRoomsStream();
    //_loadMessages();
    super.initState();
  }

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
          actions: [
            IconButton(
              onPressed: () {

                if (isBlockList == true) {
                  print('111');
                  isBlockList = false;

                  setState(() {
                    _stream = getRoomsStream();
                  });

                } else {
                  print('222');
                  isBlockList = true;

                  setState(() {
                    _stream = getBlockedUsers();
                  });
                }

              },
              icon: Icon(
                isBlockList ? Icons.chat : Icons.block,
                color: Colors.black,
                size: 30,
              ),
            )
          ]),
      body: SingleChildScrollView(
        controller: _viewScrollController,
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                  stream: _stream,
                  builder: (context, snapshot) {
                    print('chatlist snapshot: $snapshot');
                    final data = snapshot.data; //List<Room>?
                    print('data.runtimeType : ${data.runtimeType}');

                    if (snapshot.hasData && data?.length != 0) {
                      // 데이터가 있을 때
                      // 데이터를 사용하여 화면을 구성하는 위젯 반환
                      if (data.runtimeType == List<types.Room>) {
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          controller: _courtScrollController,
                          //shrinkWrap: true,
                          itemCount: data?.length,
                          //snapshot.data?.docs.length,
                          itemBuilder: ((context, index) {
                            print('data[index].users: ${data?[index].users}');

                            if (data?.length == 0) {
                              return Center(
                                  child: Text(
                                    '데이터 없음',
                                    style: TextStyle(color: Colors.black),
                                  ));
                            } else {

                              final users = data?[index].users;
                              final lastMessages = data?[index].lastMessages;
                              final lastMessage =
                              lastMessages?.first as types.TextMessage?;

                              final latestChat = lastMessage?.text;

                              final noCurrentUser = users
                                  ?.where((element) =>
                              element.id != currentUserProfile.uid)
                                  .toList();
                              print('noCurrentUser: $noCurrentUser');

                              final element = noCurrentUser?.first.toJson(); //User
                              print('element: $element');
                              print('data.length: ${data?.length}');

                              return Dismissible(
                                direction: DismissDirection.endToStart,
                                // 왼쪽에서 오른쪽으로 슬라이드할 때만 작동
                                onDismissed: (direction) async {
                                  //DatabaseReference usersRef = FirebaseDatabase.instance.ref("messages/${generateChatRoomId(currentUserProfile, element!)}/users");

                                  // //await usersRef.child(currentUserProfile.uid).remove();
                                  // await usersRef.remove();

                                  print('차단 목록에 추가');
                                  // currentUser에다가 상대방을 차단 목록에 추가
                                  DatabaseReference blockRef =
                                  FirebaseDatabase.instance.ref(
                                      "blockedList/${currentUserProfile.uid}");
                                  //await blockRef.set(element?['id']);
                                  await blockRef.set(element);

                                },
                                background: Container(
                                  color: Colors.red, // 슬라이드 할 때 보여지는 배경 색상
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    // 왼쪽 패딩 추가
                                    child: Icon(Icons.delete,
                                        color: Colors.white), // 삭제 아이콘 등
                                  ),
                                ),
                                key: ValueKey<String>('list_item_$index'),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                        NetworkImage(element?["imageUrl"])
                                        as ImageProvider<Object>,
                                      ),
                                      title: Text(
                                        element?["firstName"],
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      subtitle: Text(latestChat ?? ''),
                                      trailing:
                                      Icon(Icons.arrow_forward_ios_rounded),
                                      onTap: () {
                                        MoveToOtherScreen()
                                            .persistentNavPushNewScreen(
                                          context,
                                          ChatScreen(receivedData: element!),
                                          false,
                                          PageTransitionAnimation.cupertino,
                                        );
                                      },
                                    ),
                                    Divider(),
                                  ],
                                ),
                              );
                            }
                          }),
                        );
                      } else if (data.runtimeType == List<types.User>) { // data == List<types.User>
                        return Text('차단 목록');
                      } else {
                        return Center(
                          child: Text(
                            '데이터 없음',
                            style: TextStyle(color: Colors.black, fontSize: 18.0),
                          ),
                        );
                      }

                    } else if (snapshot.hasError) {
                      // 에러가 발생한 경우
                      // 에러를 표시하는 위젯 반환
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // 데이터가 없는 경우
                      // 로딩 인디케이터 등을 표시하는 위젯 반환
                      return Center(
                        child: Text(
                          '데이터 없음',
                          style: TextStyle(color: Colors.black, fontSize: 18.0),
                        ),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
