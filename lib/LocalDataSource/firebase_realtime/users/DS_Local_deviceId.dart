
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class LocalDSDeviceId {

  final currentUser = FirebaseAuth.instance.currentUser;


  Future<String> checkMyDeviceId(String uid) async {
    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/deviceId");

      final result = await ref.once();

      if (result.snapshot.value != null) {
        debugPrint('result.snapshot.value: ${result.snapshot.value}');
        final deviceId = result.snapshot.value as String;
        return deviceId;

      } else {
        debugPrint('등록된 deviceId 없음');

        return "deviceId";
      }

    } catch (e) {
      debugPrint('checkMyDeviceId e: $e');
      return "null";
    }
  }

  Future<void> uploadMyDeviceId(String deviceId) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/deviceId");

      await ref.set(deviceId);
      debugPrint('deviceId: $deviceId');
      debugPrint('deviceId 업로드 완료');
      return;

    } catch (e) {
      debugPrint('uploadMyDeviceId e: $e');
      return;
    }

  }

}