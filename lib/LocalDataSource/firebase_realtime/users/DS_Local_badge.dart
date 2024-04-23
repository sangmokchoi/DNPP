
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class LocalDSBadge {


  final currentUser = FirebaseAuth.instance.currentUser;

  Stream<int> myBadgeListen() async* {

    int myBadgeCount = 0;

    DatabaseReference ref =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}/badge");

    StreamController<int> controller = StreamController<int>();

    ref.onValue.listen((event) {
      final eventSnapshot = event.snapshot;
      //print('myBadgeListen eventSnapshot: $eventSnapshot');
      //print('myBadgeListen eventSnapshot: ${eventSnapshot.key}'); // badge
      //print('myBadgeListen eventSnapshot: ${eventSnapshot.value}'); // badge 의 개수

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
      print('appbadger currentBadge: $currentBadge');

      await FlutterAppBadger.updateBadgeCount(currentBadge);
      return;

    } catch (e) {
      print('updateMyBadge e: $e');
      return;

    }
  }

  Future<void> initializeMyBadge() async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/badge");

      await ref.set(0);
      print('initializeMyBadge updateBadgeCount');
      await FlutterAppBadger.updateBadgeCount(0);
      return;

    } catch (e) {
      print('initializeMyBadge e: $e');
      return;

    }
  }

  Future<int> addOpponentUserBadge(String opponentUid) async {

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

  Future<int> adjustOpponentBadge(String opponentUid, int lastSeen) async {

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
}