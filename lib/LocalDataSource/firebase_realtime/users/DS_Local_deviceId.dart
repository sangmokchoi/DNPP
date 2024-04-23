
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LocalDSDeviceId {

  final currentUser = FirebaseAuth.instance.currentUser;


  Future<String> checkMyDeviceId(String uid) async {
    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/deviceId");

      final result = await ref.once();

      if (result.snapshot.value != null) {
        print('result.snapshot.value: ${result.snapshot.value}');
        final deviceId = result.snapshot.value as String;
        return deviceId;

      } else {
        print('등록된 deviceId 없음');

        return "deviceId";
      }

    } catch (e) {
      print('checkMyDeviceId e: $e');
      return e.toString();
    }
  }

  Future<void> uploadMyDeviceId(String deviceId) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/deviceId");

      await ref.set(deviceId);
      print('deviceId: $deviceId');
      print('deviceId 업로드 완료');
      return;

    } catch (e) {
      print('uploadMyDeviceId e: $e');
      return;
    }

  }

}