import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'package:http/http.dart' as http;

class ChatBackgroundListen {

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> updateAdBannerVisibleConfirmTime() async {

    DatabaseReference ref =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}");

    try {
      Map<String, dynamic> updateData = {
        'adBannerVisibleConfirmTime': DateTime.now().millisecondsSinceEpoch,
      };

      await ref.update(updateData);

    } catch (e) {
      print('updateAdBannerVisibleConfirmTime e: $e');

    }

  }

  Future<DateTime?> downloadAdBannerVisibleConfirmTime() async {

    DatabaseReference adBannerVisibleConfirmTimeRef =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}/adBannerVisibleConfirmTime");

    try {
      DatabaseEvent event = await adBannerVisibleConfirmTimeRef.once();
      final timeStamp = event.snapshot.value;
      print('downloadAdBannerVisibleConfirmTime timeStamp: $timeStamp');

      if (timeStamp != null) {
        print('if (timeStamp != null) {');
        if (timeStamp is int) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);
          print('if (timeStamp is int) {');
          print('dateTime: $dateTime');
          print('dateTime.runtimeType: ${dateTime.runtimeType}');
          return dateTime;
        } else {
          final dateTime =
          DateTime.parse((timeStamp as Timestamp).toDate().toString());
          print('} else {');
          return dateTime;
        }
      } else {
        print('return null;');
        return null;
      }

    } catch (e) {
      print('downloadAdBannerVisibleConfirmTime e: $e');
      return null;
    }

  }

  Future<DateTime> updateMyRecentVisit() async {

    DatabaseReference ref =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}");
    DatabaseReference recentVisitRef =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}/recentVisit");

    try {
      // 데이터베이스에서 기존 데이터를 가져옵니다.
      DatabaseEvent event = await recentVisitRef.once();
      final timeStamp = event.snapshot.value;
      print('updateMyRecentVisit timeStamp: $timeStamp');
      print('updateMyRecentVisit timeStamp: ${timeStamp.runtimeType}');

      if (timeStamp != null) {
        // 데이터가 이미 존재하는 경우, 업데이트를 수행합니다.
        Map<String, dynamic> updateData = {
          'recentVisit': DateTime.now().millisecondsSinceEpoch,
        };

        // 데이터베이스에 데이터를 업데이트합니다.
        await ref.update(updateData);

        // final dateTime = DateTime.parse((timeStamp as Timestamp).toDate().toString());
        //
        // print('dateTime: $dateTime');
        // 데이터베이스에 저장된 timeStamp를 밀리초로 가정하여 DateTime으로 변환합니다.
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp as int);
        print('dateTime: $dateTime');
        return dateTime;
      } else {

        // 데이터베이스에 데이터를 추가합니다.
        await recentVisitRef.set(DateTime.now().millisecondsSinceEpoch);

        return DateTime.now();
      }

    } catch (e) {
      print('updateMyRecentVisit e: $e');

      return DateTime.now();
    }
  }

  Stream<int> myBadgeListen() async* {

    int myBadgeCount = 0;

    DatabaseReference ref =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}/badge");

    StreamController<int> controller = StreamController<int>();

    ref.onValue.listen((event) {
      final eventSnapshot = event.snapshot;
      print('myBadgeListen eventSnapshot: $eventSnapshot');
      print('myBadgeListen eventSnapshot: ${eventSnapshot.key}'); // badge
      print('myBadgeListen eventSnapshot: ${eventSnapshot.value}'); // badge 의 개수

      if (eventSnapshot.value != null) {
        myBadgeCount = eventSnapshot.value as int;
      } else {
        myBadgeCount = 0;
      }

      controller.add(myBadgeCount);
    });

    //yield myBadgeCount;
    yield* controller.stream; // 생성된 스트림을 반환

  }

  Future<int> downloadMyBadge() async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/badge");

      final oldBadge = await ref.once();

      if (oldBadge.snapshot.value == null) {
        return 0;
      } else {
        final badge = oldBadge.snapshot.value as int;
        return badge;
      }

    } catch (e) {
      print('downloadMyBadge e: $e');
      return 0;
    }
  }

  Future<void> updateMyBadge(int currentBadge) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/badge");

      await ref.set(currentBadge);
      print('currentBadge: $currentBadge');

      await FlutterAppBadger.updateBadgeCount(currentBadge);
      return;

    } catch (e) {
      print('updateMyBadge e: $e');
      return;

    }
  }

  Future<int> addUserBadge(String opponentUid) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${opponentUid}/badge");

      final oldBadge = await ref.once();
      print('oldBadge..snapshot.value: ${oldBadge.snapshot.value}');

      int badge = 0;

      if (oldBadge.snapshot.value == null) {
        print('oldBadge.runtimeType: ${oldBadge.runtimeType}');

      } else {
        badge = oldBadge.snapshot.value as int;
      }
      print('badge: $badge');
      final newBadge = badge + 1;
      print('newBadge: $newBadge');
      await ref.set(newBadge);

      return newBadge;

    } catch (e) {
      print('updateUserBadge e: $e');
      return 0;
    }

  }

  Future<int> adjustUserBadge(String opponentUid, int lastSeen) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${opponentUid}/badge");

      final oldBadge = await ref.once();
      print('oldBadge..snapshot.value: ${oldBadge.snapshot.value}');

      int badge = 0;

      if (oldBadge.snapshot.value == null) {
        print('oldBadge.runtimeType: ${oldBadge.runtimeType}');

      } else {
        badge = oldBadge.snapshot.value as int;
      }
      print('badge: $badge');
      final newBadge = badge - lastSeen;
      print('newBadge: $newBadge');
      await ref.set(newBadge);

      return newBadge;

    } catch (e) {
      print('updateUserBadge e: $e');
      return 0;
    }

  }

  Future<void> toggleNotification(bool value) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/isNotificationAble");

      await ref.set(value);
      return;

    } catch (e) {
      print('toggleNotification e: $e');
      return;

    }
  }

  Future<bool> checkUserNotification(String value) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${value}/isNotificationAble");

      final refOnce = await ref.once();
      final userNotification = refOnce.snapshot.value; //bool
      print('userNotification: ${userNotification}');

      return userNotification as bool;

    } catch (e) {
      print('checkUserNotification e: $e');
      return false;

    }
  }

  Future<void> uploadFcmToken(String token) async {

      try {

        DatabaseReference ref =
        FirebaseDatabase.instance.ref("users/${currentUser?.uid}/fcmToken");

        await ref.set(token);
        print('토큰 token: $token');
        print('토큰 업로드 완료');
        return;

      } catch (e) {
        print('checkFcmToken e: $e');
        return;
      }

  }

  Future<String> checkFcmToken(String opponentId) async {
    try {

      // DatabaseReference ref =
      // FirebaseDatabase.instance.ref("users/${currentUser?.uid}/fcmToken");

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${opponentId}/fcmToken");

      final result = await ref.once();

      if (result.snapshot.value != null) {
        print('토큰이 이미 존재');
        print('result.snapshot.value: ${result.snapshot.value}');
        final token = result.snapshot.value as String;
        return token;

      } else {
      //await FirebaseMessaging.instance.deleteToken();
       // var token = await FirebaseMessaging.instance.getToken();
        //print('getToken: $token'); // 토큰 길이가 길어서 잘 안보이지만, 매번 다른 토큰 생성됨
        //await ref.set(token);
        print('등록된 토큰 없음');

        return "token";
      }

        //var token = await FirebaseMessaging.instance.getToken();
        //print('getToken: $token'); // 토큰 길이가 길어서 잘 안보이지만, 매번 다른 토큰 생성됨
        // await ref.set(token);
        // print('토큰 업로드 완');

      //return token!;

    } catch (e) {
      print('checkFcmToken e: $e');
      return e.toString();
    }
  }

  Future<void> sendMessageData(String senderNickName, String messageBody, String token, int newBadge) async {

    print('senderNickName: $senderNickName');
    print('messageBody: $messageBody');
    print('token: $token');

    print('sendMessageData 시작');
    String baseUrl = 'https://sendchatnotitoopponent-dto7nx7sua-uc.a.run.app';
    String cloudUrl = '$baseUrl?senderNickName=$senderNickName&messageBody=$messageBody&token=$token&newBadge=$newBadge';

    final response = await http.get(Uri.parse(cloudUrl));
    print('sendMessageData response: ${response.headers}');
    print('sendMessageData response: ${response.body}');
    print('sendMessageData response: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('정상 작동됨');
    } else {
      //await FirebaseMessaging.instance.deleteToken();
      //print('deleteToken됨');
    }

  }

  Future<void> deleteUsersData(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");

    await ref.remove()
        .then((_) {
      print("deleteUsersData 데이터와 모든 하위 데이터 삭제 완료");
    })
        .catchError((error) {
      print("deleteUsersData 데이터 삭제 중 에러 발생: $error");
    });
  }

  Future<void> deleteChatData(String uid) async {
    DatabaseReference ref =
    FirebaseDatabase.instance.ref('messages');
    final once = await ref.once();

    final map = once.snapshot.value as Map<Object?, Object?>;

    print('map: ${map}');
    print('map[users]: ${map['users']}');

    map.forEach((key, value) async {
      print('key: $key');
      //print('Key: $key, Value: $value');
      if (key.toString().contains('${uid}')) {
        print('Key containing "uid": $key');
        final DatabaseReference keyRef = FirebaseDatabase.instance.ref('messages/$key'); // 채팅방

        // final deleteOnce = await keyRef.once();
        // print('deleteOnce: ${deleteOnce.snapshot.key}');
        // print('deleteOnce: ${deleteOnce.snapshot.value}');

        final DatabaseReference usersRef = FirebaseDatabase.instance.ref('messages/$key/users'); // 채팅방 내 유저
        final usersOnce = await usersRef.once();

        final list = usersOnce.snapshot.value as List<Object?>;
        print('list: ${list}');

        if (list.length == 1){ // 이미 채팅방 유저가 1명인 경우에는 채팅방을 삭제해버림
          await keyRef.remove();

        } else {
          final filteredList = list.where((element) {
            final _ele = element as Map<Object?, Object?>;
            return _ele['id'] == uid;
          }).toList(); // 삭제 되어야 하는 유저 (현재 유저)
          print('filteredList: $filteredList');

          final notFilteredList = list.where((element) {
            final _ele = element as Map<Object?, Object?>;
            return _ele['id'] != uid;
          }).toList(); // 삭제 되지 않아야 하는 유저 (상대방)
          print('notFilteredList: $notFilteredList');

          try {
            Map<String, dynamic> updateData = {
              'users': notFilteredList,
            }; // 현재 유저를 채팅방에서 제거 후 업데이트

            await keyRef.update(updateData);

          } catch (e) {
            print('keyRef.update e: $e');

          }
        }


        //print('deleteOnce: ${usersOnce.snapshot.key}');
        //print('deleteOnce: ${usersOnce.snapshot.value as List<Object>?}');

        // users 에서 currentUser를 삭제한 후, users에 아무 유저도 남지 않으면, 해당 채팅방을 삭제할 것
        //await keyRef.remove();
      }
    });
  }

  Future<void> adjustOpponentBadgeCount(String uid) async {
    DatabaseReference ref =
    FirebaseDatabase.instance.ref('messages');
    final once = await ref.once();

    final map = once.snapshot.value as Map<Object?, Object?>;

    print('map: ${map}');

    map.forEach((key, value) async {
      print('key: $key');
      //print('Key: $key, Value: $value');
      if (key.toString().contains('${uid}')) {
        print('Key containing "uid": $key');

        final DatabaseReference badgeRef = FirebaseDatabase.instance.ref('messages/$key/metadata'); // 채팅방 내 유저의 badge 개수
        final badgesOnce = await badgeRef.once();

        final badge = badgesOnce.snapshot.value;

        if (badge != null){
          final badgeMap = badgesOnce.snapshot.value as Map<Object?, Object?>;
          print('badgeMap: ${badgeMap}');

          badgeMap.forEach((metadataKey, metadataValue) async {
            if (metadataKey != uid.toString()) {
              final DatabaseReference metadataRef = FirebaseDatabase.instance.ref('messages/$key/metadata/$metadataKey');
              final metadataOnce = await metadataRef.once();

              final lastSeenKey = metadataOnce.snapshot.key; // 상대방의 lastSeen
              print('lastSeenKey: $lastSeenKey');

              final lastSeenValue = metadataOnce.snapshot.value as Map<Object?, Object?>; // 상대방의 lastSeen
              final lastSeen = lastSeenValue['lastSeen'] as int ?? 0;
              print('lastSeen: $lastSeen');

              await adjustUserBadge(lastSeenKey.toString(), lastSeen);


            }

          });
        }



      }
    });
  }

}