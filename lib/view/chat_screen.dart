import 'dart:async';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/repository/firebase_realtime_blockedList.dart';
import 'package:dnpp/repository/firebase_realtime_users.dart';
import 'package:dnpp/statusUpdate/profileUpdate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';
import '../models/userProfile.dart';
import 'package:uuid/uuid.dart';
import '../repository/firebase_realtime_messages.dart';
import '../statusUpdate/googleAnalytics.dart';
import '../statusUpdate/CurrentPageProvider.dart';

class ChatScreen extends StatefulWidget {
  Map<String, dynamic> receivedData;

  ChatScreen({required this.receivedData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {

  late Stream<void> myFuture;

  @override
  void initState() {
    //ChatBackgroundListen().setIsCurrentUserInChat();

    debugPrint('widget.receivedData: ${widget.receivedData}');
    debugPrint('widget.receivedData.values: ${widget.receivedData.values}');
    if (!widget.receivedData.values.contains(null)){
      String opponentUid = '';

    final fromChatList = widget.receivedData['id']; // 유저가 채팅 리스트에서 건너오는 경우
    final fromDirect = widget.receivedData['uid']; // 유저가 다이렉트로 채팅 보내는 경우
    debugPrint('fromChatList: $fromChatList');
    debugPrint('fromDirect: $fromDirect');

    if (fromChatList == null) {
      opponentUid = fromDirect;
    } else {
      opponentUid = fromChatList;
    }

    final _chatRoodID = generateChatRoomId(
        FirebaseAuth.instance.currentUser?.uid ?? '',
        widget.receivedData);
    chatRoomId = _chatRoodID;

    myFuture = RepositoryRealtimeUsers().getCheckUserNotification(opponentUid);

    } else {

      final _chatRoodID = widget.receivedData.keys.first;
      chatRoomId = _chatRoodID;

      myFuture = Stream.empty();
    }

    loadMessages();
    //ChatBackgroundListen().checkIsOpponentUserInChat(opponentUser().id.toString());

    // WidgetsBinding.instance!.addPostFrameCallback((_) async {
    //   Provider.of<CurrentPageProvider>(context, listen: false)
    //       .setInitialCurrentPage();
    //   Provider.of<GoogleAnalyticsNotifier>(context, listen: false).startTimer(
    //       'ChatListScreen');
    // });

    Future.microtask(() {
        Provider.of<CurrentPageProvider>(context, listen: false)
            .setInitialCurrentPage();
        Provider.of<GoogleAnalyticsNotifier>(context, listen: false).startTimer(
            'ChatListScreen');
    });

    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void deactivate() {
    super.deactivate();

    // Future.microtask(() {
    //   ChatBackgroundListen().updateMyIsInRoom(
    //       FirebaseAuth.instance.currentUser?.uid.toString() ?? '', chatRoomId,
    //       messagesList.length ?? 0); // 채팅방에서 나감을 선언
    //   if (mounted) {
    //     Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
    //         .startTimer('ChatScreen');
    //   }
    // });
    // if (mounted) {
    //   Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
    //       .startTimer('ChatScreen');
    // }
  }

  @override
  void dispose() {
    debugPrint('dispose!!!');
    _lastMessagesSubscription.cancel(); // 리스너 취소
    // ChatBackgroundListen().disconnectIsCurrentUserInChat();
    //ChatBackgroundListen().setIsCurrentUserInChat(false);
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint('챗 뷰 didChangeAppLifecycleState');
    if (state == AppLifecycleState.paused) {
      debugPrint('챗 뷰에서 백그라운드로 들어감');
      _lastMessagesSubscription.cancel();

      await RepositoryRealtimeMessages().getUpdateIsMeInRoom(
          FirebaseAuth.instance.currentUser?.uid.toString() ?? '', chatRoomId,
          messagesList.length ?? 0); // 채팅방에서 나감을 선언
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('챗 뷰에서 포그라운드로 들어서');
      debugPrint('_lastMessagesSubscription.isPaused: ${_lastMessagesSubscription.isPaused}');
      debugPrint('_lastMessagesSubscription == null : ${_lastMessagesSubscription == null}');
      //if (_lastMessagesSubscription == null) {
        loadMessages();
      //}
    }

  }

  String imageUrlFromStorage = '';
  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final gsReference = FirebaseStorage.instance.refFromURL(
          "gs://dnpp-402403.appspot.com/profile_photos/empty_profile_6.png");
      imageUrlFromStorage = await gsReference.getDownloadURL();
      //await ChatBackgroundListen().setIsCurrentUserInChat(true);
      if (mounted) {
        debugPrint('채팅 스크린 마운트됨');
        await Provider.of<CurrentPageProvider>(context, listen: false)
            .setCurrentPage('ChatScreen');
        await GoogleAnalytics().trackScreen(context, 'ChatScreen');
      }
    });

    return PopScope(
        onPopInvoked: (_) {

          Future.microtask(() async {
            FocusScope.of(context).unfocus();
            RepositoryRealtimeMessages().getUpdateIsMeInRoom(
                FirebaseAuth.instance.currentUser?.uid.toString() ?? '', chatRoomId,
                messagesList.length ?? 0); // 채팅방에서 나감을 선언

            await Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
                .startTimer('ChatScreen');

          });

        },
      child: GestureDetector(
        onTap: (){
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          key: const ValueKey("ChatScreen"),
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                FocusScope.of(context).unfocus();

                Future.microtask(() async {
                  RepositoryRealtimeMessages().getUpdateIsMeInRoom(
                      FirebaseAuth.instance.currentUser?.uid.toString() ?? '', chatRoomId,
                      messagesList.length ?? 0); // 채팅방에서 나감을 선언

                  await Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
                      .startTimer('ChatScreen');

                }).then((value) {
                  Navigator.pop(context);
                });


              },
            ),
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              opponentUser().firstName!,
            ),
          ),
          body: StreamBuilder(
            stream: myFuture,
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
                  l10n: const ChatL10nEn(
                    attachmentButtonAccessibilityLabel: '미디어 전송',
                    emptyChatPlaceholder: '아직 받은 메시지가 없습니다',
                    fileButtonAccessibilityLabel: '파일',
                    inputPlaceholder: '채팅 입력',
                    sendButtonAccessibilityLabel: '보내기',
                    unreadMessagesLabel: '안 읽은 메시지',
                  ),
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
        ),
      ),
    );
  }



  late StreamSubscription<DatabaseEvent> _lastMessagesSubscription;

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;

  List<types.Message> messages = [];

  String chatRoomId = '';

  late bool IsOpponentUserInChat; //
  late bool isOpponentBlockedMe;
  late bool isOpponentInRoom;

  String generateChatRoomId(
      String currentUid, Map<String, dynamic> opponent) {

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
      // id: room().metadata.uid,
      // imageUrl: currentUserProfile.photoUrl,
      // firstName: currentUserProfile.nickName,
      // lastSeen: 0,

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

      debugPrint('uid opponent: $opponent');
      id = opponent['uid'];
      imageUrl = opponent['photoUrl'];
      firstName = opponent['nickName'];
      lastSeen = opponent['lastSeen'] ?? 0;

    } else if (opponent['id'] != null) {

      debugPrint('id opponent: $opponent');

      //if (opponent['id'] != currentUserProfile.uid) {
      id = opponent['id'];
      imageUrl = opponent['imageUrl'];
      firstName = opponent['firstName'];
      lastSeen = opponent['lastSeen'] ?? 0;
      //}

    } else {

      debugPrint('null opponent: $opponent');

      id = opponent.keys.first;
      imageUrl = imageUrlFromStorage;
      firstName = '(알 수 없는 사용자)';
      lastSeen = opponent['lastSeen'] ?? 0;

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
          user().id.toString(): {'lastSeen': user().lastSeen, 'isInRoom': false},
          opponentUser().id.toString(): {'lastSeen': opponentUser().lastSeen, 'isInRoom': false},
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

    //debugPrint('IsOpponentUserInChat: $IsOpponentUserInChat');
    final currentUserProfileUid = FirebaseAuth.instance.currentUser?.uid.toString() ?? '';

    isOpponentBlockedMe = await RepositoryRealtimeBlockedList().getCheckIsOpponentBlockedMe(opponentUser().id.toString()); // true 이면 현재 유저가 상대방으로부터 차단 당한 상태
    isOpponentInRoom = await loadOpponentMetadata(currentUserProfileUid);

    debugPrint('handleSendPressed isOpponentInRoom: $isOpponentInRoom');
    debugPrint('isOpponentBlockedMe: $isOpponentBlockedMe');

    if (isOpponentInRoom == false && isOpponentBlockedMe == false) { //isOpponentInRoom

      await Future.delayed(Duration(milliseconds: 10)).then((value) async {
        final newBadge = await RepositoryRealtimeUsers().getAddOpponentUserBadge(
            opponentUser().id);
        debugPrint('newBadge in chat view: $newBadge');

        //FlutterLocalNotification.showNotification();
        final token = await RepositoryRealtimeUsers().getCheckFcmToken(
            opponentUser().id);
        //await FirebaseMessaging.instance.deleteToken();
        //var token = await FirebaseMessaging.instance.getToken();
        // await ChatBackgroundListen().postMessage(token!);
        //final token = 'cVRSMCX9XUvpixCoWL0O9j:APA91bElB0fTgYCyIN3sfAiQYmVGSAyJEvLjeqiy9iL7h8AZgwocBkdWaz61cIP7Jd-uUN7QtSsomuKX8KeX6ynI00K5WThwz6c5knlxobHw47WMnt5oQMtvvvRAgYYkbZYDRTwURZAA';
        //final token = 'cBtWUHp5gE3eslHpNCGiI5:APA91bFWZF3sJD_LoynH5faMTYhd5ewltaZ6XDaCJCrNh7tUjrcV2NpJZO8LeYymgRuBKacowfa8sun_FvszskbgZ4npwEDfbSy82uBdiwayQ1-IOiyl7S4J6J1_uVq9UguwhOB4EzMD';
        await RepositoryRealtimeMessages().getSendMessageData(
            user().firstName!, message.text, token!, newBadge);
      });
    }
  }

  void handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );
    debugPrint('handlePreviewDataFetched 진입');

    messages[index] = updatedMessage;
  }

  void handleMessageTap(BuildContext _, types.Message message) async {
    var createdAt = message.createdAt;
    //debugPrint("createdAt: $createdAt");
  }


  Future<void> createChatRoom() async {
    debugPrint('  Future<void> createChatRoom() async ');
    DatabaseReference ref =
    FirebaseDatabase.instance.ref("messages/${chatRoomId}");
    await ref.set(room().toJson());
  }
  //int badge = 0;

  List<types.Message> messagesList = [];

  void loadMessages() async {

    //UserProfile currentUserProfile = Provider.of<ProfileUpdate>(context, listen: false).userProfile;

    final currentUserProfileUid = FirebaseAuth.instance.currentUser?.uid.toString() ?? '';

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

        debugPrint('messagesList: $messagesList');
      }

      await updateMyMetadata(currentUserProfileUid).then((badge) async {

        debugPrint('final badge = await updateMetadata(currentUserProfile);: $badge');
        await clearMyBadge(currentUserProfileUid, badge);

        try {

          if (Provider.of<ProfileUpdate>(context, listen: false).userProfile != UserProfile.emptyUserProfile) {
            await updateMyProfile(Provider
                .of<ProfileUpdate>(context, listen: false)
                .userProfile);
          }
        } catch (e) {
          debugPrint('updateMyProfile e: $e');
        }

      }).then((value) {

        if (mounted) {
          setState(() {
            messages = messagesList;
          });
        }
      });

    });

  }

  Future<void> updateMyProfile(UserProfile currentUserProfile) async {
    DatabaseReference usersRef =
    FirebaseDatabase.instance.ref('messages/${chatRoomId}/users');

    final onceResult = await usersRef.once();

    var refResult = onceResult.snapshot.value as List<Object?>;
    // final result = (refResult)?.map<String, dynamic>(
    //       (key, value) => MapEntry(key.toString(), value),
    // );

    List<Object?> newResult= [];

    refResult.forEach((element) {
      // 각 요소가 Map<String, dynamic>인지 확인합니다.
      debugPrint('element.runtimeType ${element.runtimeType}');
      var finalElement =
      (element as Map<Object?, Object?>?)?.map<String, dynamic>(
            (key, value) => MapEntry(key.toString(), value),
      );
      //if (element is Map<String, dynamic>) {
      //debugPrint('id가 currentUserProfileUid와 일치하는 경우에만 firstName과 imageUrl을 업데이트합니다.');

      if (finalElement?["id"] == currentUserProfile.uid) {
        debugPrint('업데이트할 값으로 firstName과 imageUrl을 변경합니다.');
        finalElement?["firstName"] = currentUserProfile.nickName;
        finalElement?["imageUrl"] = currentUserProfile.photoUrl;

        newResult.add(finalElement);

      } else {
        newResult.add(finalElement);
      }
      //}
    });

// 업데이트된 refResult를 출력합니다.
    debugPrint('Updated newResult: $newResult');

    await usersRef.set(newResult);

    debugPrint('updateMyProfile 완료');

  }



  Future<int> updateMyMetadata(String currentUserProfileUid) async {
    DatabaseReference metadataRef =
    FirebaseDatabase.instance.ref('messages/${chatRoomId}/metadata');

    var metadataRefOnce = await metadataRef.once();

    final metadataRefResult = metadataRefOnce.snapshot.value as Map<Object?, Object?>?;
    final metadata = (metadataRefResult)?.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
    );

    final currentLastSeen = metadata?[currentUserProfileUid]['lastSeen'] as int; // 2 int 출력, 이전의 lastSeen
    final currentIsInRoom = metadata?[currentUserProfileUid]['isInRoom'] as bool;

    if (currentLastSeen != null) {
      // metadata의 현재 사용자 항목을 업데이트합니다.
      //metadata?[currentUserProfile.uid]?['lastSeen'] = currentLastSeen;

      final int messagesListLength = messagesList.length ?? 0;

      await metadataRef.child(currentUserProfileUid).update({
        //currentUserProfileUid: {
          'lastSeen': messagesListLength, //currentLastSeen + 1
          'isInRoom': true,
        //}
      });

      debugPrint('messagesListLength: $messagesListLength');
      debugPrint('currentLastSeen: $currentLastSeen');

      return messagesListLength - currentLastSeen;

    } else {
      return 0;
    }
  }

  Future<bool> loadOpponentMetadata(String currentUserProfileUid) async {

    //await Future.delayed(Duration(milliseconds: 1000));

    DatabaseReference metadataRef =
    FirebaseDatabase.instance.ref('messages/${chatRoomId}/metadata');

    var metadataRefOnce = await metadataRef.once();

    final metadataRefResult = metadataRefOnce.snapshot.value as Map<Object?, Object?>?;
    final metadata = (metadataRefResult)?.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
    );

    // int myLastSeen = 0;
    // int opponentLastSeen = 0;

    bool opponentIsInRoom = false;

    metadata?.forEach((key, value) {
      // 현재 사용자의 UID를 키로 가지지 않는 경우에만 필터링
      if (key != currentUserProfileUid) {
        //filteredMetadata[key] = value;
        debugPrint('value: $value');
        // opponentLastSeen = value['lastSeen'] as int;
        // debugPrint('opponentLastSeen: $opponentLastSeen');

        opponentIsInRoom = value['isInRoom'] as bool;
        debugPrint('opponentIsInRoom: $opponentIsInRoom');

      } else {
        // myLastSeen = value['lastSeen'] as int;
        // debugPrint('myLastSeen: $myLastSeen');
      }

    });

    // if (opponentLastSeen > (myLastSeen - 1)){ // 원래는 opponentLastSeen == myLastSeen 라는 뜻
    //   if (opponentLastSeen == myLastSeen) {
    //      debugPrint('1111');
    //      return true; //false 면 badge를 보냄
    //   } else {
    //     debugPrint('2222');
    //     return false; //false 면 badge를 보냄
    //   }
    //
    // } else { // opponentLastSeen < (myLastSeen - 1)
    //   debugPrint('3333');
    //   return false;
    // }

    return opponentIsInRoom;

  }

  Future<void> clearMyBadge(String currentUserProfileUid, int badge) async {

    debugPrint('clearMyBadge 진입');

    DatabaseReference badgeRef =
    FirebaseDatabase.instance.ref("users/${currentUserProfileUid}/badge");
    debugPrint('updateBadge currentUserProfile: ${currentUserProfileUid}');

    var badgeRefOnce = await badgeRef.once();

    final badgeRefResult = badgeRefOnce.snapshot.value; // int
    debugPrint('badgeRefResult: $badgeRefResult');

    if (badgeRefResult == null) {

      await badgeRef.set(0);

    } else {
      debugPrint('badgeRefResult as int: ${(badgeRefResult as int)}');
      int newBadge = (badgeRefResult as int) - badge; // 현재 유저가 가지고 있는 배치를 가져오고, 이번에 읽은 lastSeen을 뺌
      debugPrint('badge: $badge');
      debugPrint('newBadge: $newBadge');

      newBadge = newBadge < 0 ? 0 : newBadge;

      DatabaseReference usersRef =
      FirebaseDatabase.instance.ref("users/${currentUserProfileUid}");

      await RepositoryRealtimeUsers().getUpdateMyBadge(newBadge).then((value) async {
        await usersRef.update({
          "badge": newBadge
        });
      });

    }
  }

}
