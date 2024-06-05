import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class LocalDSBlockedList {

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> addToBlockList(String currentUserProfileUid, dynamic element, bool reported) async {

    DatabaseReference blockRef =
    FirebaseDatabase.instance.ref(
        "blockedList/${currentUserProfileUid}");

    debugPrint('addToBlockList currentUserProfileUid: $currentUserProfileUid');
    debugPrint('addToBlockList element: $element');
    debugPrint('addToBlockList reported: $reported');

      if (element?['id'] != null) {
        debugPrint('else if (element?[id] != null)');
        debugPrint('element: $element');
        //debugPrint('element:  {firstName: 최상목, id: 3166941235, imageUrl: https://k.kakaocdn.net/dn/bI2KNx/btrBIhyGdyx/ytoskqJAknrQgn3Fac5vL0/img_640x640.jpg, lastSeen: 0}
        blockRef =
            blockRef.child(element?['id']);

        await blockRef.set(element);

        try {
          DatabaseReference reportedRef = blockRef.child('reported');

          if (reported == true) {
            await reportedRef.set({
              "isReported": reported,
              "reporter": currentUserProfileUid,
              "dateTime": DateTime
                  .now()
                  .millisecondsSinceEpoch
            });
          } else {
            await reportedRef.set({
              "isReported": reported,
            });
          }

        } catch (e) {
          debugPrint('reportedRef e: $e');
        }

      } else if (element?['uid'] != null) {
        debugPrint('else if (element?[uid] != null)');
        debugPrint('element: $element');

        final String uid = element['uid'].toString();
        final String photoUrl = element['photoUrl'].toString();
        final String nickName = element['nickName'].toString();

        debugPrint('uid: $uid');
        debugPrint('photoUrl: $photoUrl');
        debugPrint('nickName: $nickName');

        final user = types.User(
          id: uid,
          imageUrl: photoUrl,
          firstName: nickName,
          lastSeen: 0,
        );
        debugPrint('user: $user');

        try {
          // final uid = element['uid'].toString();

          // 하위 노드로 opponentUid를 추가합니다.
          blockRef =
              blockRef.child(uid);

          // final user = types.User(
          //   id: uid,
          //   imageUrl: photoUrl,
          //   firstName: nickName,
          //   lastSeen: 0,
          // );

          //await blockRef.set(user);

          await blockRef.set({
            "id": uid,
            "imageUrl": photoUrl,
            "firstName": nickName,
            "lastSeen": 0,
          });

        } catch (e) {
          debugPrint('blockRef.child(uid) e: $e');
        }


        try {
          DatabaseReference reportedRef = blockRef.child('reported');

          if (reported == true) {
            await reportedRef.set({
              "isReported": reported,
              "reporter": currentUserProfileUid,
              "dateTime": DateTime
                  .now()
                  .millisecondsSinceEpoch
            });
          } else {
            await reportedRef.set({
              "isReported": reported,
            });
          }

        } catch (e) {
          debugPrint('reportedRef e: $e');
        }

      } else {
        debugPrint('addToBlockList if (opponentUid == null)');
      }



  }

  Future<bool> checkIsOpponentBlockedMe(String opponentUid) async { // 채팅방에 현재 유저가 들어와 있음을 알려주는 bool 함수

    DatabaseReference ref =
    FirebaseDatabase.instance.ref("blockedList/${opponentUid}");

    try {
      final once = await ref.once();
      if (once.snapshot.value != null) {
        final finalData = once.snapshot.value as Map<Object?, Object?>;

        // forEach 대신 일반 for 루프를 사용하여 키 확인
        for (var key in finalData.keys) {
          debugPrint('key: $key');
          if (key.toString().contains('${currentUser?.uid}')) {
            debugPrint('상대방이 나를 차단해놨으므로, 알림을 보내선 안 됨');
            return true; // 여기서 함수 전체에서 바로 true를 반환
          }
        }
      }

      // 만약 for 루프를 벗어났다면 차단한 사실이 없는 것으로 간주
      return false;

    } catch (e) {
      debugPrint('checkIsOpponentBlockedMe e: $e');
      return false;
    }

  }

  Future<bool> checkIsOpponentBlocked(String opponentUid) async { // matching에서 곧장 채팅방으로 가기전, 이 유저가 차단된 유저인지 확인하는 함수

    DatabaseReference ref =
    FirebaseDatabase.instance.ref("blockedList/${currentUser?.uid.toString()}/${opponentUid}");

    try {

      final once = await ref.once();
      final value = once.snapshot.value;

      if (value != null) {
        // 데이터가 있으므로 차단된 유저임
        return true;
      } else {
        return false;
      }

    } catch (e) {
      debugPrint('checkIsOpponentBlockedMe e: $e');
      return false;
    }

  }

}