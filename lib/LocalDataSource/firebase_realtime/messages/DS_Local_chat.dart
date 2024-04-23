import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../RemoteDataSource/firebase_messaging.dart';

class LocalDSChat {

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> updateIsMeInRoom(String currentUserProfileUid, String chatRoomId, int messagesListLength) async {
    DatabaseReference metadataRef =
    FirebaseDatabase.instance.ref('messages/${chatRoomId}/metadata');

    // var metadataRefOnce = await metadataRef.once();

    // final int messagesListLength = messagesList.length ?? 0;

    await metadataRef.update({
      currentUserProfileUid: {
        'lastSeen': messagesListLength, //currentLastSeen + 1
        'isInRoom': false,
      }
    });

    print('updateMyIsInRoom 완료');

  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("messages/$chatRoomId");

    await ref.remove()
        .then((_) {
      print("deleteChatRoom 데이터 삭제 완료");
    })
        .catchError((error) {
      print("deleteChatRoom 데이터 삭제 중 에러 발생: $error");
    });
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


  // Future<void> adjustOpponentBadgeCount(String uid) async { // 회원탈퇴 시,
  //
  //   DatabaseReference ref =
  //   FirebaseDatabase.instance.ref('messages');
  //   final once = await ref.once();
  //
  //   final map = once.snapshot.value as Map<Object?, Object?>;
  //
  //   print('map: ${map}');
  //
  //   map.forEach((key, value) async {
  //     print('key: $key');
  //     //print('Key: $key, Value: $value');
  //     if (key.toString().contains('${uid}')) {
  //       print('Key containing "uid": $key');
  //
  //       final DatabaseReference badgeRef = FirebaseDatabase.instance.ref('messages/$key/metadata'); // 채팅방 내 유저의 badge 개수
  //       final badgesOnce = await badgeRef.once();
  //
  //       final badge = badgesOnce.snapshot.value;
  //
  //       if (badge != null){
  //         final badgeMap = badgesOnce.snapshot.value as Map<Object?, Object?>;
  //         print('badgeMap: ${badgeMap}');
  //
  //         badgeMap.forEach((metadataKey, metadataValue) async {
  //           if (metadataKey != uid.toString()) {
  //             final DatabaseReference metadataRef = FirebaseDatabase.instance.ref('messages/$key/metadata/$metadataKey');
  //             final metadataOnce = await metadataRef.once();
  //
  //             final lastSeenKey = metadataOnce.snapshot.key; // 상대방의 lastSeen
  //             print('lastSeenKey: $lastSeenKey');
  //
  //             final lastSeenValue = metadataOnce.snapshot.value as Map<Object?, Object?>; // 상대방의 lastSeen
  //             final lastSeen = lastSeenValue['lastSeen'] as int ?? 0;
  //             print('lastSeen: $lastSeen');
  //
  //             await RepositoryBadge().adjustOpponentBadge(lastSeenKey.toString(), lastSeen);
  //
  //           }
  //
  //         });
  //       }
  //
  //     }
  //   });
  // }

}
