import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

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

    debugPrint('updateMyIsInRoom 완료');

  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("messages/$chatRoomId");

    await ref.remove()
        .then((_) {
      debugPrint("deleteChatRoom 데이터 삭제 완료");
    })
        .catchError((error) {
      debugPrint("deleteChatRoom 데이터 삭제 중 에러 발생: $error");
    });
  }

  Future<void> deleteUsersData(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");

    await ref.remove()
        .then((_) {
      debugPrint("deleteUsersData 데이터와 모든 하위 데이터 삭제 완료");
    })
        .catchError((error) {
      debugPrint("deleteUsersData 데이터 삭제 중 에러 발생: $error");
    });
  }

  // Future<void> deleteChatData(String uid) async { // 채팅방에서 해당 유저 관련 정보 삭제
  //   DatabaseReference ref =
  //   FirebaseDatabase.instance.ref('messages');
  //   final once = await ref.once();
  //
  //   final map = once.snapshot.value as Map<Object?, Object?>;
  //
  //   debugPrint('map: ${map}');
  //
  //   await for (final event in ref.onValue) {
  //
  //     final dataSnapshot = event.snapshot;
  //     final List<DataSnapshot> snapshot = dataSnapshot.children.toList();
  //
  //     debugPrint('deleteChatData snapshot: ${snapshot}');
  //     // 모든 채팅방
  //     // [Instance of 'DataSnapshot', Instance of 'DataSnapshot', Instance of 'DataSnapshot', Instance of 'DataSnapshot', Instance of 'DataSnapshot', Instance of 'DataSnapshot', Instance of 'DataSnapshot']
  //
  //     snapshot.forEach((element) async {
  //       debugPrint('deleteChatData element.key: ${element.key}');
  //       debugPrint('deleteChatData element.value: ${element.value}');
  //       final chatRoomId = element.key;
  //       final DatabaseReference keyRef = FirebaseDatabase.instance.ref('messages/$chatRoomId'); // 채팅방
  //
  //       final value = element.value as Map<Object?, Object?>;
  //
  //       if (value != null) {
  //         final metadata = value['metadata'] as Map<Object?, Object?>;
  //
  //
  //         debugPrint('deleteChatData metadata: ${metadata}');
  //
  //         final List<Object?> keysList = metadata.keys.toList();
  //         debugPrint('keysList: ${keysList}');
  //
  //         if (keysList.contains(uid)){
  //
  //           debugPrint('keysList.contains(uid))');
  //
  //           if (keysList.length == 1) { // 이미 채팅방 유저가 1명인 경우에는 채팅방을 삭제해버림
  //
  //            await keyRef.remove();
  //
  //           } else {
  //
  //             keysList.remove(uid);
  //             final opponent = keysList.first;
  //             final newMetadata = metadata['$opponent'];
  //
  //             debugPrint('$opponent opponent: ${newMetadata}');
  //
  //             try {
  //               keyRef.child('metadata').set({
  //                 "$opponent": newMetadata
  //               });
  //
  //             } catch (e) {
  //               debugPrint('newMetadata set e: $e');
  //
  //             }
  //
  //             try {
  //               final DatabaseReference usersRef = FirebaseDatabase.instance.ref('messages/$chatRoomId/users'); // 채팅방 내 유저
  //               final usersOnce = await usersRef.once();
  //
  //               final list = usersOnce.snapshot.value as List<Object?>;
  //               debugPrint('list: ${list}');
  //
  //               if (list.length == 1){ // 이미 채팅방 유저가 1명인 경우에는 채팅방을 삭제해버림
  //                 await keyRef.remove();
  //
  //               } else {
  //
  //                 final filteredList = list.where((element) {
  //                   final _ele = element as Map<Object?, Object?>;
  //                   return _ele['id'] == uid;
  //                 }).toList(); // 삭제 되어야 하는 유저 (현재 유저)
  //                 debugPrint('filteredList: $filteredList');
  //
  //                 final notFilteredList = list.where((element) {
  //                   final _ele = element as Map<Object?, Object?>;
  //                   return _ele['id'] != uid;
  //                 }).toList(); // 삭제 되지 않아야 하는 유저 (상대방)
  //                 debugPrint('notFilteredList: $notFilteredList');
  //
  //                 try {
  //                   Map<String, dynamic> updateData = {
  //                     'users': notFilteredList,
  //                   }; // 현재 유저를 채팅방에서 제거 후 업데이트
  //
  //                   await keyRef.update(updateData);
  //
  //                 } catch (e) {
  //                   debugPrint('keyRef.update e: $e');
  //                 }
  //               }
  //
  //             } catch (e) {
  //
  //             }
  //
  //           }
  //
  //         }
  //       } else {
  //         debugPrint('if (value != null) { element.value: ${element.value}');
  //       }
  //
  //
  //     });
  //
  //   }
  //
  // }
  //

  Future<void> deleteChatData(String uid) async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref('messages');
      final once = await ref.once();
      final map = once.snapshot.value as Map<Object?, Object?>;

      debugPrint('map: $map');

      // 'messages' 경로의 모든 채팅방 데이터 가져오기
      final snapshot = await ref.once();
      final List<DataSnapshot> chatRooms = snapshot.snapshot.children.toList();

      // 모든 채팅방 데이터에 대해 반복 처리
      await Future.forEach(chatRooms, (DataSnapshot chatRoom) async {
        final chatRoomId = chatRoom.key;
        final DatabaseReference chatRoomRef = FirebaseDatabase.instance.ref('messages/$chatRoomId');

        final value = chatRoom.value as Map<Object?, Object?>?;
        if (value == null) return;

        final metadata = value['metadata'] as Map<Object?, Object?>?;
        if (metadata == null) return;

        debugPrint('deleteChatData metadata: $metadata');

        if (metadata.containsKey(uid)) {
          debugPrint('metadata.containsKey(uid)');

          if (metadata.length == 1) {
            // 이미 채팅방 유저가 1명인 경우 채팅방 삭제
            await chatRoomRef.remove();
          } else {
            // 유저 ID 제거 및 상대방 정보 업데이트
            metadata.remove(uid);
            final opponentUid = metadata.keys.first;
            final newMetadata = metadata[opponentUid];

            debugPrint('$opponentUid opponent: $newMetadata');

            await chatRoomRef.child('metadata').set({opponentUid: newMetadata});

            // 채팅방 내 유저 목록 업데이트
            final usersRef = FirebaseDatabase.instance.ref('messages/$chatRoomId/users');
            final usersSnapshot = await usersRef.once();
            final List<dynamic> usersList = usersSnapshot.snapshot.value as List<dynamic>;

            final updatedUsersList = usersList.where((user) {
              final userMap = user as Map<Object?, Object?>;
              return userMap['id'] != uid;
            }).toList();

            if (updatedUsersList.isEmpty) {
              await chatRoomRef.remove();
            } else {
              await chatRoomRef.child('users').set(updatedUsersList);
            }
          }
        }
      });
    } catch (e) {
      debugPrint('deleteChatData e: $e');
    }
  }


// Future<void> adjustOpponentBadgeCount(String uid) async { // 회원탈퇴 시,
  //
  //   DatabaseReference ref =
  //   FirebaseDatabase.instance.ref('messages');
  //   final once = await ref.once();
  //
  //   final map = once.snapshot.value as Map<Object?, Object?>;
  //
  //   debugPrint('map: ${map}');
  //
  //   map.forEach((key, value) async {
  //     debugPrint('key: $key');
  //     //debugPrint('Key: $key, Value: $value');
  //     if (key.toString().contains('${uid}')) {
  //       debugPrint('Key containing "uid": $key');
  //
  //       final DatabaseReference badgeRef = FirebaseDatabase.instance.ref('messages/$key/metadata'); // 채팅방 내 유저의 badge 개수
  //       final badgesOnce = await badgeRef.once();
  //
  //       final badge = badgesOnce.snapshot.value;
  //
  //       if (badge != null){
  //         final badgeMap = badgesOnce.snapshot.value as Map<Object?, Object?>;
  //         debugPrint('badgeMap: ${badgeMap}');
  //
  //         badgeMap.forEach((metadataKey, metadataValue) async {
  //           if (metadataKey != uid.toString()) {
  //             final DatabaseReference metadataRef = FirebaseDatabase.instance.ref('messages/$key/metadata/$metadataKey');
  //             final metadataOnce = await metadataRef.once();
  //
  //             final lastSeenKey = metadataOnce.snapshot.key; // 상대방의 lastSeen
  //             debugPrint('lastSeenKey: $lastSeenKey');
  //
  //             final lastSeenValue = metadataOnce.snapshot.value as Map<Object?, Object?>; // 상대방의 lastSeen
  //             final lastSeen = lastSeenValue['lastSeen'] as int ?? 0;
  //             debugPrint('lastSeen: $lastSeen');
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
