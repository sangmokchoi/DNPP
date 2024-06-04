import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class LocalDSIsNotificationAble {

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> toggleNotification(bool value) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/isNotificationAble");

      await ref.set(value);
      return;

    } catch (e) {
      debugPrint('toggleNotification e: $e');
      return;

    }
  }

  Stream<bool> checkUserNotification(String value) async* {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${value}/isNotificationAble");

      final refOnce = await ref.once();
      final userNotification = refOnce.snapshot.value; //bool
      debugPrint('userNotification: ${userNotification}');

      if (userNotification == null) {
        ref.set(true);
        userNotification == true;
      }

      yield userNotification as bool;

    } catch (e) {
      debugPrint('checkUserNotification e: $e');
      yield false;

    }
  }

  Future<bool> checkUserNotificationFunction(String value) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${value}/isNotificationAble");

      final refOnce = await ref.once();
      final userNotification = refOnce.snapshot.value; //bool
      debugPrint('userNotification: ${userNotification}');

      if (userNotification == null) {
        ref.set(true);
        userNotification == true;
      }

      return userNotification as bool;

    } catch (e) {
      debugPrint('checkUserNotificationFunction e: $e');
      return false;

    }
  }

}