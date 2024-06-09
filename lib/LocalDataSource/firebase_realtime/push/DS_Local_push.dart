import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class LocalDSPush {

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, String>>> loadAllPush() async {

    List<Map<String, String>> combinedList = [];

    try {

      try {
        final publicList = await loadPublicPush();
        combinedList.addAll(publicList);

      } catch (e) {
        debugPrint('loadAllPush loadPublicPush e: $e');
      }

      try {
        final privateList = await loadPrivatePush();
        combinedList.addAll(privateList);
      } catch (e) {
        debugPrint('loadAllPush loadPrivatePush e: $e');
      }

      return combinedList;

    } catch (e) {
      debugPrint('loadAllPush e: $e');

      return [];
    }


  }

  Future<List<Map<String, String>>> loadPublicPush() async {

    DatabaseReference publicPushRef =
    FirebaseDatabase.instance.ref(
        "push/public");

    try {
      final publicPushRefResult = await publicPushRef.once();
      final snapshot = publicPushRefResult.snapshot;

      //debugPrint('loadPublicPush snapshot.value: ${snapshot.value}');
      //debugPrint('loadPublicPush snapshot.value.runtimeType :${snapshot.value.runtimeType }'); //as List<Object?>
      // key 말고 value들을 이용함

      final result = snapshot.value as List<Object?>;

      List<Map<String, String>> resultList = [];

      for (var element in result) {
        if (element is Map<Object?, Object?>) {
          // Object?를 String, dynamic으로 캐스팅
          final _element = element.cast<String, dynamic>(); // 각 푸시별 구분
          //debugPrint('loadPublicPush _element: $_element');

          if (_element['users'] is Map<Object?, Object?>) {
            // users에 *가 포함되어 있음 (모든 유저 대상으로 보여짐)
            final usersResult = _element['users'] as Map<Object?, Object?>;
            final _result = {
              "title": _element['title'] as String,
              "body": _element['body'] as String,
              "timeline": _element['timeline'] as String,
              "imageUrl": _element['imageUrl'] as String,
              "landingUrl": _element['landingUrl'] as String,
              "users": "*",
            };
            resultList.add(_result);

          } else if (_element['users'] is List<Object?>) {
            // user가 list 형태로 저장되어 있음 (유저 그룹군을 묶어서 보여주고 있음)
            final usersResult = _element['users'] as List<Object?>;
            debugPrint('usersResult: $usersResult');
            List<Map<String, Object>> usersList = [];

            // 만약 users에서 키 값이 * 인 경우에는 모든 유저들에게 해당됨
            for (var userElement in usersResult) {
              if (userElement is Map<Object?, Object?>) {

                final _userElement = userElement.cast<String, Object>(); // 각 유저별 구분
                //debugPrint('_userElement: $_userElement');

                if (_userElement['uid'] == currentUser?.uid.toString()) {
                  final _usersResult = {
                    "uid": _userElement['uid'] as String,
                    "fcmToken": _userElement['fcmToken'] as String,
                  };

                  usersList.add(_usersResult);
                }
              }
            }

            if (usersList.isNotEmpty) {
              final _result = {
                "title": _element['title'] as String,
                "body": _element['body'] as String,
                "timeline": _element['timeline'] as String,
                "imageUrl": _element['imageUrl'] as String,
                "landingUrl": _element['landingUrl'] as String,
              };
              resultList.add(_result);
              //debugPrint('resultList: $resultList');
              usersList.clear();
            }
          }


        }
      }

      //debugPrint('public resultList: $resultList');
      return resultList;

    } catch (e) {
      debugPrint('loadPublicPush e: $e');
      return [];
    }

  }

  Future<List<Map<String, String>>> loadPrivatePush() async {

    DatabaseReference publicPushRef =
    FirebaseDatabase.instance.ref(
        "push/private");

    try {
      final publicPushRefResult = await publicPushRef.once();
      final snapshot = publicPushRefResult.snapshot;

      //debugPrint('loadPrivatePush snapshot.value: ${snapshot.value}');
      //debugPrint('loadPrivatePush snapshot.value.runtimeType :${snapshot.value.runtimeType }'); //as List<Object?>
      // key 말고 value들을 이용함

      final result = snapshot.value as List<Object?>;
      //debugPrint('loadPrivatePush result: ${result.length}');
      List<Map<String, String>> resultList = [];

      for (var element in result) {

        if (element is Map<Object?, Object?>) {
          // Object?를 String, dynamic으로 캐스팅
          final _element = element.cast<String, dynamic>(); // 각 푸시별 구분
          //debugPrint('loadPrivatePush _element: $_element');

          final usersResult = _element['users'] as List<Object?>;

          List<Map<String, Object>> usersList = [];

          for (var userElement in usersResult) {
            if (userElement is Map<Object?, Object?>) {

              final _userElement = userElement.cast<String, Object>(); // 각 유저별 구분
              //debugPrint('_userElement: $_userElement');

              if (_userElement['uid'] == currentUser?.uid.toString()) {
                final _usersResult = {
                  "uid": _userElement['uid'] as String,
                  "fcmToken": _userElement['fcmToken'] as String,
                };

                usersList.add(_usersResult);
              }
            }
          }

          if (usersList.isNotEmpty) {
            final _result = {
              "title": _element['title'] as String,
              "body": _element['body'] as String,
              "timeline": _element['timeline'] as String,
              "imageUrl": _element['imageUrl'] as String,
              "landingUrl": _element['landingUrl'] as String,
            };
            resultList.add(_result);
            usersList.clear();
          }

        }
      }

      //debugPrint('private resultList: $resultList');
      return resultList;

    } catch (e) {
      debugPrint('loadPrivatePush e: $e');
      return [];
    }

  }



}