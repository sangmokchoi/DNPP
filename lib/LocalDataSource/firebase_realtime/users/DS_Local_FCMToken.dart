import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class LocalDSFCMToken {

  Future<void> uploadFcmToken(String token) async {

    final currentUser = FirebaseAuth.instance.currentUser;

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/fcmToken");

      await ref.set(token);
      debugPrint('토큰 token: $token');
      debugPrint('토큰 업로드 완료');
      return;

    } catch (e) {
      debugPrint('checkFcmToken e: $e');
      return;
    }

  }

  Future<String> checkFcmToken(String uid) async {
    try {

      // DatabaseReference ref =
      // FirebaseDatabase.instance.ref("users/${currentUser?.uid}/fcmToken");

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${uid}/fcmToken");

      final result = await ref.once();

      if (result.snapshot.value != null) {
        debugPrint('토큰이 이미 존재');
        debugPrint('result.snapshot.value: ${result.snapshot.value}');
        final token = result.snapshot.value as String;
        return token;

      } else {
        //await FirebaseMessaging.instance.deleteToken();
        // var token = await FirebaseMessaging.instance.getToken();
        //debugPrint('getToken: $token'); // 토큰 길이가 길어서 잘 안보이지만, 매번 다른 토큰 생성됨
        //await ref.set(token);
        debugPrint('등록된 토큰 없음');

        return "token";
      }

      //var token = await FirebaseMessaging.instance.getToken();
      //debugPrint('getToken: $token'); // 토큰 길이가 길어서 잘 안보이지만, 매번 다른 토큰 생성됨
      // await ref.set(token);
      // debugPrint('토큰 업로드 완');

      //return token!;

    } catch (e) {
      debugPrint('checkFcmToken e: $e');
      return e.toString();
    }
  }

}