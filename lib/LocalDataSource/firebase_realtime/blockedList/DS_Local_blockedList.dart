import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class LocalDSBlockedList {

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> addToBlockList(String currentUserProfileUid, dynamic element) async {

    DatabaseReference blockRef =
    FirebaseDatabase.instance.ref(
        "blockedList/${currentUserProfileUid}");

    if (element?['id'] != null) {
      // 하위 노드로 element?['id']를 추가합니다.
      blockRef =
          blockRef.child(element?['id']);

      await blockRef.set(element);
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

}