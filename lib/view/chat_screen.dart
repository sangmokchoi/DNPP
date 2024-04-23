import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/repository/chatBackgroundListen.dart';
import 'package:dnpp/statusUpdate/profileUpdate.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';

import '../models/userProfile.dart';
import 'package:uuid/uuid.dart';

import '../norification.dart';

import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  Map<String, dynamic> receivedData;

  ChatScreen({required this.receivedData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  late Future<void> myFuture;

  @override
  void initState() {
    print('widget.receivedData: ${widget.receivedData}');
    String opponentUid = '';

    final fromChatList = widget.receivedData['id']; // 유저가 채팅 리스트에서 건너오는 경우
    final fromDirect = widget.receivedData['uid']; // 유저가 다이렉트로 채팅 보내는 경우
    print('fromChatList: $fromChatList');
    print('fromDirect: $fromDirect');

    if (fromChatList == null) {
      opponentUid = fromDirect;
    } else {
      opponentUid = fromChatList;
    }

    final _chatRoodID = generateChatRoomId(
        Provider.of<ProfileUpdate>(context, listen: false).userProfile,
        widget.receivedData);
    chatRoomId = _chatRoodID;

    myFuture = ChatBackgroundListen().checkUserNotification(opponentUid);
    loadMessages();

    super.initState();
  }

  @override
  void dispose() {
    print('dispose!!!');
    _lastMessagesSubscription.cancel(); // 리스너 취소

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            FocusScope.of(context).unfocus();
            await Future.delayed(Duration(milliseconds: 250)); // 예: 300 밀리초(0.3초) 후에 이동
            Navigator.pop(context);

          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          opponentUser().firstName!,
        ),
      ),
      body: FutureBuilder(
        future: myFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.done) {
            return Chat(
              messages: messages,
              // onAttachmentPressed: _handleAttachmentPressed,
              // onMessageTap: _handleMessageTap,
              onMessageTap: handleMessageTap,
              onPreviewDataFetched: handlePreviewDataFetched,
              onSendPressed: handleSendPressed,
              showUserAvatars: true,
              showUserNames: true,
              user: user(),
              theme: const DefaultChatTheme(
                primaryColor: kMainColor,
                seenIcon: Text(
                  'read',
                  style: TextStyle(
                    fontSize: 19.0,
                  ),
                ),
              ),
            );
          } else {
            return Center(child: kCustomCircularProgressIndicator);
          }

        }
      ),
    );
  }

  late StreamSubscription<DatabaseEvent> _lastMessagesSubscription;

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;

  List<types.Message> messages = [];

  String chatRoomId = '';

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

  types.User user() {
    final currentUserProfile =
        Provider.of<ProfileUpdate>(context, listen: false).userProfile;
    final _user = types.User(
      id: currentUserProfile.uid,
      imageUrl: currentUserProfile.photoUrl,
      firstName: currentUserProfile.nickName,
      lastSeen: 0,
    );

    return _user;
  }
  types.User opponentUser() {
    final opponent = widget.receivedData;
    final currentUserProfile =
        Provider.of<ProfileUpdate>(context, listen: false).userProfile;

    String id;
    String imageUrl;
    String firstName;
    int lastSeen;

    if (opponent['uid'] != null) {
      id = opponent['uid'];
      imageUrl = opponent['photoUrl'];
      firstName = opponent['nickName'];
      lastSeen = opponent['lastSeen'] ?? 0;
    } else {

      //if (opponent['id'] != currentUserProfile.uid) {
      id = opponent['id'];
      imageUrl = opponent['imageUrl'];
      firstName = opponent['firstName'];
      lastSeen = opponent['lastSeen'] ?? 0;
      //}

    }

    final _user = types.User(
      id: id,
      imageUrl: imageUrl,
      firstName: firstName,
      lastSeen: 0,
    );

    return _user;
  }
  types.Room room() {

    final room = types.Room(
        id: chatRoomId,
        type: types.RoomType.direct, // direct, channel, group
        users: [user(), opponentUser()],
        lastMessages: [],
        metadata: {
          user().id.toString(): {'lastSeen': user().lastSeen},
          opponentUser().id.toString(): {'lastSeen': opponentUser().lastSeen},
        }
    );

    return room;
  }

  void addMessage(types.Message message) {
    setState(() {
      messages.insert(0, message);
    });
  }

  Future<void> handleSendPressed(types.PartialText message) async {
    final textMessageId = const Uuid().v4();
    final textMessage = types.TextMessage(
      author: user(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: textMessageId,
      text: message.text,
    );

    addMessage(textMessage);

    DatabaseReference messagesRef =
    FirebaseDatabase.instance.ref("messages/${chatRoomId}/lastMessages");
    // DatabaseReference messagesRef =
    // FirebaseDatabase.instance.ref("blockedList/${opponentUser().id}");

    final List<Map<String, dynamic>> messagesJson =
    messages.map((message) => message.toJson()).toList();

    // 업데이트된 Room 객체를 Firebase에 저장
    await messagesRef.set(messagesJson);

    final newBadge = await ChatBackgroundListen().addUserBadge(opponentUser().id);
    print('newBadge in chat view: $newBadge');

    //FlutterLocalNotification.showNotification();
    final token = await ChatBackgroundListen().checkFcmToken(opponentUser().id);
    //await FirebaseMessaging.instance.deleteToken();
    //var token = await FirebaseMessaging.instance.getToken();
    // await ChatBackgroundListen().postMessage(token!);
    //final token = 'cVRSMCX9XUvpixCoWL0O9j:APA91bElB0fTgYCyIN3sfAiQYmVGSAyJEvLjeqiy9iL7h8AZgwocBkdWaz61cIP7Jd-uUN7QtSsomuKX8KeX6ynI00K5WThwz6c5knlxobHw47WMnt5oQMtvvvRAgYYkbZYDRTwURZAA';
    //final token = 'cBtWUHp5gE3eslHpNCGiI5:APA91bFWZF3sJD_LoynH5faMTYhd5ewltaZ6XDaCJCrNh7tUjrcV2NpJZO8LeYymgRuBKacowfa8sun_FvszskbgZ4npwEDfbSy82uBdiwayQ1-IOiyl7S4J6J1_uVq9UguwhOB4EzMD';
    await ChatBackgroundListen().sendMessageData(user().firstName!, message.text, token!, newBadge);

  }

  void handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );
    print('handlePreviewDataFetched 진입');

    messages[index] = updatedMessage;
  }

  void handleMessageTap(BuildContext _, types.Message message) async {
    var createdAt = message.createdAt;
    //print("createdAt: $createdAt");
  }

  Future<void> createChatRoom() async {
    print('  Future<void> createChatRoom() async ');
    DatabaseReference ref =
    FirebaseDatabase.instance.ref("messages/${chatRoomId}");
    await ref.set(room().toJson());
  }
  //int badge = 0;

  List<types.Message> messagesList = [];

  void loadMessages() async {

    UserProfile currentUserProfile = Provider.of<ProfileUpdate>(context, listen: false).userProfile;

    DatabaseReference messagesRef =
    FirebaseDatabase.instance.ref('messages/${chatRoomId}');

    var messageRefResult = await messagesRef.once();

    DatabaseReference lastMessagesRef =
    FirebaseDatabase.instance.ref('messages/${chatRoomId}/lastMessages');

    var lastMessagesRefResult = await lastMessagesRef.once();

    // 데이터가 없는 경우에만 새로운 채팅방 생성
    if (!messageRefResult.snapshot.exists) {
      await messagesRef.set(room().toJson());
    }

    _lastMessagesSubscription = lastMessagesRef.onValue.listen((DatabaseEvent event) async {
      // List<types.Message> messagesList = [];

      final dataSnapshot = event.snapshot;
      //final DataSnapshot lastMessagesSnapshot = dataSnapshot.child('lastMessages');

      final List<dynamic>? lastMessagesData = dataSnapshot.value as List<dynamic>?;

      if (lastMessagesData != null) {
        messagesList = lastMessagesData.map((messageData) {
          // 각 메시지 데이터를 types.Message 유형으로 변환
          final authorData = messageData['author'] as Map<Object?, Object?>;
          final author = types.User(
            id: authorData['id'] as String, // 문자열로 캐스팅
            imageUrl: authorData['imageUrl'] as String?,
            firstName: authorData['firstName'] as String?,
            //lastSeen: authorData['lastSeen'] as int?
            // 추가적인 필드가 있다면 여기에 추가
          );

          final message = types.TextMessage(
            id: messageData['id'],
            createdAt: messageData['createdAt'],
            text: messageData['text'],
            author: author,
          );

          return message;

        }).toList();

        print('messagesList: $messagesList');
      }

      final badge = await updateMetadata(currentUserProfile);

      print('final badge = await updateMetadata(currentUserProfile);: $badge');
      await clearMyBadge(currentUserProfile, badge);


      if (mounted) {
        setState(() {
          messages = messagesList;
        });
      }
    });

  }

  Future<int> updateMetadata(UserProfile currentUserProfile) async {
    DatabaseReference metadataRef =
    FirebaseDatabase.instance.ref('messages/${chatRoomId}/metadata');

    var metadataRefOnce = await metadataRef.once();

    final metadataRefResult = metadataRefOnce.snapshot.value as Map<Object?, Object?>?;
    final metadata = (metadataRefResult)?.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
    );

    final currentLastSeen = metadata?[currentUserProfile.uid.toString()]['lastSeen'] as int; // 2 int 출력, 이전의 lastSeen

    if (currentLastSeen != null) {
      // metadata의 현재 사용자 항목을 업데이트합니다.
      //metadata?[currentUserProfile.uid]?['lastSeen'] = currentLastSeen;

      final int messagesListLength = messagesList.length ?? 0;

      await metadataRef.update({
        currentUserProfile.uid.toString(): {
          'lastSeen': messagesListLength //currentLastSeen + 1
        }
      });

      print('messagesListLength: $messagesListLength');
      print('currentLastSeen: $currentLastSeen');

      return messagesListLength - currentLastSeen;

    } else {
      return 0;
    }
  }

  Future<void> clearMyBadge(UserProfile currentUserProfile, int badge) async {

    print('clearMyBadge 진입');

    DatabaseReference badgeRef =
    FirebaseDatabase.instance.ref("users/${currentUserProfile.uid}/badge");
    print('updateBadge currentUserProfile: ${currentUserProfile.uid}');

    var badgeRefOnce = await badgeRef.once();

    final badgeRefResult = badgeRefOnce.snapshot.value; // int
    print('badgeRefResult: $badgeRefResult');

    if (badgeRefResult == null) {

      await badgeRef.set(0);

    } else {
      print('badgeRefResult as int: ${(badgeRefResult as int)}');
      int newBadge = (badgeRefResult as int) - badge; // 현재 유저가 가지고 있는 배치를 가져오고, 이번에 읽은 lastSeen을 뺌
      print('badge: $badge');
      print('newBadge: $newBadge');

      newBadge = newBadge < 0 ? 0 : newBadge;

      DatabaseReference usersRef =
      FirebaseDatabase.instance.ref("users/${currentUserProfile.uid}");

      await usersRef.update({
        "badge": newBadge
      });

    }
  }
}
