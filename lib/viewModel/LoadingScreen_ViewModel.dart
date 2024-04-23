import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/LocalDataSource/DS_Local_Auth.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/models/DeviceInfo.dart';
import 'package:dnpp/LocalDataSource/DS_Local_auth.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LocalDataSource/firebase_realtime/users/DS_Local_FCMToken.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_deviceId.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_recentVisit.dart';
import '../repository/firebase_auth.dart';
import '../repository/firebase_realtime_users.dart';
import '../statusUpdate/ShowToast.dart';
import '../statusUpdate/loginStatusUpdate.dart';

class LoadingScreenViewModel extends ChangeNotifier {

  String loadingMessage = '데이터를 불러오는 중입니다\n잠시만 기다려주세요';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  FirebaseFirestore db = FirebaseFirestore.instance;


  late OverlayEntry lateOverlayEntry;
  List<OverlayEntry> lateOverlayEntries = [];

  insertOverlay(BuildContext context, String token, String uniqueDeviceId) {

    OverlayEntry _overlay = OverlayEntry(builder: (_) => overlayBanner(token, uniqueDeviceId));

    print('insertOverlay 진입');

    if (lateOverlayEntries.isEmpty) {
      lateOverlayEntries.add(_overlay);
      print('lateOverlayEntries:${lateOverlayEntries.length}');

    Navigator
        .of(context)
        .overlay!
        .insert(_overlay);

      //lateOverlayEntries.clear();

    }

  }

  Widget overlayBanner(String token, String uniqueDeviceId) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.7),
      child: AlertDialog(
        insetPadding:
        EdgeInsets.only(left: 10.0, right: 10.0),
        shape: kRoundedRectangleBorder,
        title: Text(
          '알림',
          style: kAppointmentDateTextStyle,
          textAlign: TextAlign.center,
        ),
        content: Text(
          '다른 기기에서 로그인한 이력이 있습니다\n이 기기에서 핑퐁플러스를 이용하시겠습니까?',
          style: TextStyle(
            fontSize: 14.0,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                // style: TextButton.styleFrom(
                //   textStyle: Theme.of(context).textTheme.labelLarge,
                // ),
                child: Center(
                    child: Text(
                      '아니오',
                      style: kAppointmentTextButtonStyle.copyWith(color: Colors.red),
                    )),
                onPressed: () async {
                  await RepositoryFirebaseAuth().getSignOut().then((value) {
                    // 종료 말고 로그아웃만 해도 괜찮을지도?
                    return lateOverlayEntries.first.remove();
                   //return exit(0);
                  });

                },
              ),
              TextButton(
                // style: TextButton.styleFrom(
                //   textStyle: Theme.of(context).textTheme.labelLarge,
                // ),
                child: Center(
                    child: Text(
                        '확인',
                        style: kAppointmentTextButtonStyle.copyWith(color: kMainColor)
                    )),
                onPressed: () async {
                  await RepositoryRealtimeUsers().getUploadFcmToken(token).then((value) async {
                    ShowToast().showToast("로그인이 완료되었습니다");
                    await RepositoryRealtimeUsers().getUploadMyDeviceId(uniqueDeviceId).then((value) async {
                      await RepositoryRealtimeUsers().getUploadFcmToken(token!).then((value) {
                        lateOverlayEntries.first.remove();
                      });
                    });


                  });
                  //overlayRemove;
                  //Navigator.pop(context); // 다이얼로그 닫기는 여기서 호출
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  overlayRemove(OverlayEntry overlay) {
    overlay.remove();
  }

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
          await RepositoryRealtimeUsers().getCheckFcmToken(user.uid).then((loadedToken) async {
            print('loadedToken == token: ${loadedToken == token}');

            print('loadedToken: $loadedToken');
            print('token: $token');

            print('기존의 fcmtoken과 다른 경우에만 새로운 fcmtoken을 업로드');

            await RepositoryRealtimeUsers().getCheckMyDeviceId(user.uid).then((deviceId) async {

              final deviceInfo = await DeviceInfo().initPlatformState();
              print('deviceInfo: $deviceInfo'); //identifierForVendor

              String? uniqueDeviceId;

              if (Platform.isIOS) {
                uniqueDeviceId = deviceInfo['identifierForVendor'];
                print('deviceInfo[identifierForVendor]: $uniqueDeviceId');

              } else if (Platform.isAndroid) {
                uniqueDeviceId = deviceInfo['id'];
                print('deviceInfo[id]: $uniqueDeviceId');

              } else {
                uniqueDeviceId = 'null';
              }

              if (deviceId == 'deviceId') { // 디바이스 id가 기존에 없었던 상태
                await RepositoryRealtimeUsers().getUploadMyDeviceId(uniqueDeviceId!);

                if (loadedToken != token) { // 지금은 토큰을 이용했으나, 디바이스 id를 가져오는 것으로 변경 하기
                  // LaunchUrl().alertOkAndCancelFunc(context, '알림', '다른 기기에서 로그인한 이력이 있습니다\n이 기기에서 핑퐁플러스를 이용하시겠습니까?', '아니오 (앱 종료)', '확인', Colors.red, kMainColor, () async {
                  //   //Navigator.pop(context);
                  //   // 앱 종료 함수
                  //   await RepositoryAuth().signOut().then((value) => exit(0));
                  //
                  // }, () async {
                  //
                  //   await ChatBackgroundListen().uploadFcmToken(token!).then((value) {
                  //     Navigator.pop(context);
                  //
                  //     //Navigator.of(context, rootNavigator: true).pop();
                  //
                  //   });
                  //
                  // });

                  // insertOverlay(context, token!, uniqueDeviceId!);

                  //ShowToast().showToast(); // 잘 작동됨

                  await RepositoryRealtimeUsers().getUploadFcmToken(token!).then((value) {

                  });
                } else {

                }

              } else if (deviceId == uniqueDeviceId) { // 이미 동일한 디바이스 id가 db에 있으므로 굳이 업로드 안함
                print('Device ID already exists in the database.');

                if (loadedToken != token) { // 지금은 토큰을 이용했으나, 디바이스 id를 가져오는 것으로 변경 하기
                  // LaunchUrl().alertOkAndCancelFunc(context, '알림', '다른 기기에서 로그인한 이력이 있습니다\n이 기기에서 핑퐁플러스를 이용하시겠습니까?', '아니오 (앱 종료)', '확인', Colors.red, kMainColor, () async {
                  //   //Navigator.pop(context);
                  //   // 앱 종료 함수
                  //   await RepositoryAuth().signOut().then((value) => exit(0));
                  //
                  // }, () async {
                  //
                  //   await ChatBackgroundListen().uploadFcmToken(token!).then((value) {
                  //     Navigator.pop(context);
                  //
                  //     //Navigator.of(context, rootNavigator: true).pop();
                  //
                  //   });
                  //
                  // });

                  // insertOverlay(context, token!, uniqueDeviceId!);

                  //ShowToast().showToast(); // 잘 작동됨

                  await RepositoryRealtimeUsers().getUploadFcmToken(token!).then((value) {

                  });
                } else {

                }

              } else if (deviceId != uniqueDeviceId) { // 디바이스 id가 기존과 다른 경우
                insertOverlay(context, token!, uniqueDeviceId!);
              }


            });

          });


        });

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
          final recentVisit = await RepositoryRealtimeUsers().getUpdateMyRecentVisit();
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

    });
  }
  
}
