
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class LocalDSDeviceName {

  final currentUser = FirebaseAuth.instance.currentUser;


  Future<String> checkMyDeviceName() async {
    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/deviceName");

      final result = await ref.once();

      if (result.snapshot.value != null) {
        debugPrint('result.snapshot.value: ${result.snapshot.value}');
        final deviceId = result.snapshot.value as String;
        return deviceId;

      } else {
        debugPrint('등록된 deviceName 없음');

        return "deviceName";
      }

    } catch (e) {
      debugPrint('checkMyDeviceName e: $e');
      return "null";
    }
  }

  Future<void> uploadMyDeviceName(String deviceName) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/deviceName");

      await ref.set(deviceName);
      debugPrint('deviceName: $deviceName');
      debugPrint('deviceName 업로드 완료');
      return;

    } catch (e) {
      debugPrint('uploadMyDeviceName e: $e');
      return;
    }

  }

}