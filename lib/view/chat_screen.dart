import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/statusUpdate/profileUpdate.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';

import '../models/userProfile.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  Map<String, dynamic> receivedData;

  ChatScreen({required this.receivedData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  void loadMessages() async {

    DatabaseReference messageRef =
        FirebaseDatabase.instance.ref('messages/${chatRoomId}');

    var result = await messageRef.once();

    // 데이터가 없는 경우에만 새로운 채팅방 생성
    if (!result.snapshot.exists) {
      await messageRef.set(room().toJson());
    }

    messageRef.onValue.listen((DatabaseEvent event) {
      List<types.Message> messagesList = [];

      final dataSnapshot = event.snapshot;

      final DataSnapshot lastMessagesSnapshot =
          dataSnapshot.child('lastMessages');

      final List<dynamic>? lastMessagesData =
          lastMessagesSnapshot.value as List<dynamic>?;

      if (lastMessagesData != null) {
        messagesList = lastMessagesData.map((messageData) {
          // 각 메시지 데이터를 types.Message 유형으로 변환
          final authorData = messageData['author'] as Map<Object?, Object?>;
          final author = types.User(
            id: authorData['id'] as String, // 문자열로 캐스팅
            imageUrl: authorData['imageUrl'] as String?,
            firstName: authorData['firstName'] as String?,
            // 추가적인 필드가 있다면 여기에 추가
          );

          return types.TextMessage(
              id: messageData['id'],
              createdAt: messageData['createdAt'],
              text: messageData['text'],
              author: author);
        }).toList();
      }

      setState(() {
        messages = messagesList;
      });
    });
  }

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

    if (opponent['uid'] != null) {
      id = opponent['uid'];
      imageUrl = opponent['photoUrl'];
      firstName = opponent['nickName'];
    } else {

      //if (opponent['id'] != currentUserProfile.uid) {
        id = opponent['id'];
        imageUrl = opponent['imageUrl'];
        firstName = opponent['firstName'];
      //}

    }

    final _user = types.User(
      id: id,
      imageUrl: imageUrl,
      firstName: firstName,
    );

    return _user;
  }

  types.Room room() {
    final room = types.Room(
        id: chatRoomId,
        type: types.RoomType.direct, // direct, channel, group
        users: [user(), opponentUser()],
        lastMessages: []);

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

    DatabaseReference ref =
        FirebaseDatabase.instance.ref("messages/${chatRoomId}/lastMessages");

    final List<Map<String, dynamic>> messagesJson =
        messages.map((message) => message.toJson()).toList();

    // 업데이트된 Room 객체를 Firebase에 저장
    await ref.set(messagesJson);
  }

  void handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    messages[index] = updatedMessage;
  }

  void handleMessageTap(BuildContext _, types.Message message) async {
    var createdAt = message.createdAt;
    //print("createdAt: $createdAt");
  }

  Future<void> createChatRoom() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("messages/${chatRoomId}");
    await ref.set(room().toJson());
  }

  @override
  void initState() {
    print('widget.receivedData: ${widget.receivedData}');

    final _chatRoodID = generateChatRoomId(
        Provider.of<ProfileUpdate>(context, listen: false).userProfile,
        widget.receivedData);
    chatRoomId = _chatRoodID;

    loadMessages();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          opponentUser().firstName!,
        ),
      ),
      body: Chat(
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
          seenIcon: Text(
            'read',
            style: TextStyle(
              fontSize: 19.0,
            ),
          ),
        ),
      ),
    );
  }
}
