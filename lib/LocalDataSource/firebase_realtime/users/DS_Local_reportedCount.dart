
import 'package:html/parser.dart' as htmlParser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class LocalDSReportedCount {

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<int> checkMyReportedCount() async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid.toString()}/reportedCount");

      final once = await ref.once();
      final value = once.snapshot.value;

      int reportedCount;

      if (value == null) {
        // 현재 신고된 적 없으므로 추가
        reportedCount = 0;

      } else {
        reportedCount = value as int;
      }

      return reportedCount;

    } catch (e) {
      debugPrint('checkMyReportedCount e: $e');
      return 0;
    }

  }

  Future<int> checkMyReportLimitDays() async {
    // 신고 누적 횟수가 5회, 10회, 15회 달성되어 이용 제한을 받고 있는지 확인하는 함수

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${currentUser?.uid.toString()}/limitDays");

      final once = await ref.once();
      final value = once.snapshot.value;

      int limitDays; // limitDays를 기준으로 7일 뒤 또는 14일 뒤를 계산해아함

      if (value == null) {
        // 현재 신고된 적 없으므로 우선 0으로 기입
        limitDays = 0;

      } else {
        limitDays = value as int;
      }

      return limitDays;

    } catch (e) {
      debugPrint('checkMyReportLimitDays e: $e');
      return 0;
    }

  }

  Future<int> checkOpponentReportedCount(String opponentUid) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${opponentUid}/reportedCount");

      final once = await ref.once();
      final value = once.snapshot.value;

      int reportedCount;

      if (value == null) {
        // 현재 신고된 적 없으므로 추가
        reportedCount = 0;

      } else {
        reportedCount = value as int;
      }

      return reportedCount;

    } catch (e) {
      debugPrint('checkOpponentReportedCount e: $e');
      return 0;
    }

  }

  Future<int> addOpponentReportedCount(String opponentUid) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${opponentUid}/reportedCount");

      final once = await ref.once();
      int reportedCount;

      debugPrint("once: ${once.snapshot.key}");
      debugPrint("once: ${once.snapshot.value}");
      final value = once.snapshot.value;

      if (value == null) {
        // 현재 신고된 적 없으므로 추가
        debugPrint("현재 신고된 적 없으므로 추가");

        reportedCount = 1;
        await ref.set(reportedCount);

      } else {
        reportedCount = value as int;
        await ref.set(reportedCount + 1);
      }

      return reportedCount;

    } catch (e) {
      debugPrint('addOpponentReportedCount e: $e');
      return 0;
    }

  }

  Future<void> flagOpponentLimitDays(String opponentUid) async {

    try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/${opponentUid}/limitDays");

      final now = DateTime.now().millisecondsSinceEpoch;
      await ref.set(now);

    } catch (e) {
      debugPrint('addOpponentReportedCount e: $e');

    }

  }


  Future<int?> flagOpponentReportedCount(String opponentUid, String chatRoomId, String reportedReason) async {

    final reportedCount = await checkOpponentReportedCount(opponentUid); // 최소 0, null이 출력되지 않음

    //try {

      DatabaseReference ref =
      FirebaseDatabase.instance.ref("reportedList/${opponentUid}");

      DatabaseReference childRef = ref.child(chatRoomId);

      DataSnapshot snapshot = await childRef.get();
      if (snapshot.exists) {
        // 데이터가 이미 존재하면 return
        return null;
      }

    // <li></li> 태그 안의 텍스트를 추출하여 리스트로 변환하는 함수
    List<String> parseReportedReasons(String reportedReason) {
      final document = htmlParser.parse(reportedReason);
      final elements = document.querySelectorAll('li');
      return elements.map((e) => e.text).toList();
    }

    final parsedReasons = parseReportedReasons(reportedReason);
    debugPrint('parsedReasons: $parsedReasons');

      int dateTime = DateTime.now().millisecondsSinceEpoch;

      await childRef.set({
        "reporterUid": currentUser?.uid.toString(),
        "chatRoomId": chatRoomId,
        "when": {
          "reportedCount": reportedCount + 1,
          "dateTime": dateTime
        },
        "why": parsedReasons
      });

      try {

        await addOpponentReportedCount(opponentUid);
        return reportedCount + 1;

      } catch (e) {
        debugPrint('addOpponentReportedCount e: $e');
        return reportedCount;
      }


    // } catch (e) {
    //   debugPrint('flagOpponentReportedCount e: $e');
    //   return reportedCount;
    // }

  }

}