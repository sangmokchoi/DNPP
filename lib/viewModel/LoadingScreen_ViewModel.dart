import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/repository/chatBackgroundListen.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../statusUpdate/loginStatusUpdate.dart';

class LoadingScreenViewModel extends ChangeNotifier {

  String loadingMessage = '데이터를 불러오는 중입니다\n잠시만 기다려주세요';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> initialize(BuildContext context) async {

    FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
      final SharedPreferences prefs = await _prefs;

      if (user == null) {
        // user == null
        print('SignupScreen user isNotLoggedIn');
        print('SignupScreen user: $user');
        print('신규유저 이므로 프로필 생성 필요 또는 로그아웃한 상태');
        await Provider.of<LoginStatusUpdate>(context, listen: false)
            .falseIsLoggedIn();
      } else {
        // user != null
        print('SignupScreen user isLoggedIn');
        print('SignupScreen user: ${user}');
        await FirebaseMessaging.instance.getToken().then((token) async {
          print('FirebaseAuth.instance.idTokenChanges().listen token: $token');
          await ChatBackgroundListen().uploadFcmToken(token!);
        });
        print('1111');

        await Provider.of<LoginStatusUpdate>(context, listen: false)
            .updateCurrentUser(user);

        FirebaseAnalytics.instance.setUserId(id: user.uid);
        print('2222');

        if (user.providerData.isNotEmpty) {
          //print('user.providerData.isNotEmpty');
          print(
              'SignupScreen user.providerData: ${user.providerData.first.providerId.toString()}');

          String providerId = user.providerData.first.providerId.toString();
          switch (providerId) {
            case 'google.com':
              print('구글로 로그인');
            case 'apple.com':
              print('애플로 로그인');
          }
          //Provider.of<LoginStatusUpdate>(context, listen: false).updateProviderId(user.providerData.first.providerId.toString());
        } else if (user.providerData.isEmpty) {
          print('카카오로 로그인한 상태');
          print('user.providerData.isEmpty');
        }

        // 이전에 유저 정보가 있으면, 로그아웃했다가 다시 들어온 유저로 인식하고, 프로필 설정 화면으로 보낼 필요가 없음
        final QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
            .collection("UserData")
            .where("uid", isEqualTo: user.uid)
            .get();
        // print('이전에 유저 정보가 있으면, 로그아웃했다가 다시 들어온 유저로 인식하고, 프로필 설정 화면으로 보낼 필요가 없음');
        print('querySnapshot: $querySnapshot');

        if (querySnapshot.docs.isNotEmpty) {
          // 문서가 존재하면 이전에 저장한 유저 정보가 있다고 판단
          print(
              '문서가 존재하면 이전에 저장한 유저 정보가 있다고 판단 UserData exists for ${user.uid}');
          await Provider.of<LoginStatusUpdate>(context, listen: false)
              .updateIsUserDataExists(true);
          //Provider.of<ProfileUpdate>(context, listen: false).updateUserProfile(docRef as UserProfile);
          await Provider.of<LoginStatusUpdate>(context, listen: false)
              .updateIsAgreementChecked(true);
          await Provider.of<LoginStatusUpdate>(context, listen: false)
              .trueIsLoggedIn();
          final recentVisit = await ChatBackgroundListen().updateMyRecentVisit();
          print('recentVisit: $recentVisit');
          await Provider.of<LoginStatusUpdate>(context, listen: false).updateCurrentVisit(recentVisit);

        } else {
          // 문서가 존재하지 않으면 이전에 저장한 유저 정보가 없다고 판단
          print(
              '문서가 존재하지 않으면 이전에 저장한 유저 정보가 없다고 판단 No UserData for ${user.uid}');
          await Provider.of<LoginStatusUpdate>(context, listen: false)
              .updateIsUserDataExists(false);
          await prefs.setBool('isUserTried', true);


        }

        // 로그인 버튼 클릭 여부 초기화
        await Provider.of<LoginStatusUpdate>(context, listen: false)
            .updateIsLogInButtonClicked(false);

      }
    }, onDone: () async {
      print('!!리스너 onDone!!');
    });
  }
  
}
