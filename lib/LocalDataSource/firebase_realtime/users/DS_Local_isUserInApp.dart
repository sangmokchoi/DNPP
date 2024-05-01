
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class LocalDSIsUserInApp {

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> setIsCurrentUserInApp() async { // 앱에 현재 유저가 들어와 있음을 알려주는 bool 함수

    // try {//

    debugPrint('setIsCurrentUserInApp 진입');
    DatabaseReference ref =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}/isUserInApp");

    final connectedRef = FirebaseDatabase.instance.ref(".info/connected");

    connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value as bool? ?? false;
      if (connected) {
        await ref.set(true);
      } else {
        await ref.set(false);
      }
    });

    // } catch (e) {
    //   debugPrint('setIsCurrentUserInChat e: $e');
    //
    //
    // }
  }

  Future<void> disconnectIsCurrentUserInApp() async { // 앱에서 현재 유저가 나갔음을 표시하는 함수

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid}/isUserInApp");

      ref.onDisconnect().set(false);

      await ref.set(false);


    } catch (e) {
      debugPrint('setIsCurrentUserInChat e: $e');
      return;

    }
  }

  Stream<bool> checkIsCurrentUserInApp(String uid) async* { // 채팅리스트에 현재 유저가 들어와 있음을 알려주는 bool 함수

    DatabaseReference ref =
    FirebaseDatabase.instance.ref("users/${uid}/isUserInApp");

    try {

      final once = await ref.once();

      final isOpponentUserInChat = (once.snapshot.value) as bool? ?? false;
      //debugPrint('checkIsOpponentUserInChat isOpponentUserInChat: $isOpponentUserInChat');
      yield isOpponentUserInChat;

    } catch (e) {
      debugPrint('checkIsOpponentUserInChat e: $e');
      yield false;

    }
    //
    // try {
    //
    //   bool returnBool = false;
    //   //final once = await ref.once();
    //
    //   ref.onValue.listen((event) async {
    //
    //     final connected = event.snapshot.value as bool? ?? false;
    //
    //     debugPrint('connected: $connected');
    //     returnBool = connected;
    //     return returnBool;
    //   });
    //
    //   //debugPrint('returnBool: $returnBool');
    //
    //
    // } catch (e) {
    //   debugPrint('setIsCurrentUserInChat e: $e');
    //
    //   return false;
    // }


  }

}