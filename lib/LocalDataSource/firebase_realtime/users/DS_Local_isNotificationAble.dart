import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LocalDSIsNotificationAble {

  final currentUser = FirebaseAuth.instance.currentUser;

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

}