import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/LocalDataSource/DS_Local_Auth.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/models/DeviceInfo.dart';
import 'package:dnpp/LocalDataSource/DS_Local_auth.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LocalDataSource/firebase_realtime/users/DS_Local_FCMToken.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_deviceId.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_recentVisit.dart';
import '../repository/firebase_auth.dart';
import '../repository/firebase_firestore_userData.dart';
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

    debugPrint('insertOverlay 진입');

    if (lateOverlayEntries.isEmpty) {
      lateOverlayEntries.add(_overlay);
      debugPrint('lateOverlayEntries:${lateOverlayEntries.length}');

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
                  //await RepositoryRealtimeUsers().getUploadFcmToken(token).then((value) async {
                    //ShowToast().showToast("로그인이 완료되었습니다");
                    await RepositoryRealtimeUsers().getUploadMyDeviceId(uniqueDeviceId).then((value) async {

                      ShowToast().showToast("로그인이 완료되었습니다");

                      await RepositoryRealtimeUsers().getUploadFcmToken(token!).then((value) {
                        lateOverlayEntries.first.remove();

                      });
                    });
                  //});
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
    debugPrint('로딩 initialize 실행');

    FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
      final SharedPreferences prefs = await _prefs;

      if (user == null) {
        // user == null
        debugPrint('SignupScreen user isNotLoggedIn');
        debugPrint('SignupScreen user: $user');
        debugPrint('신규유저 이므로 프로필 생성 필요 또는 로그아웃한 상태');
        await Provider.of<LoginStatusUpdate>(context, listen: false)
            .falseIsLoggedIn();

      } else {
        // user != null
        debugPrint('SignupScreen user isLoggedIn');
        debugPrint('SignupScreen user: ${user}');

        await FirebaseMessaging.instance.getToken().then((token) async {
          debugPrint('FirebaseAuth.instance.idTokenChanges().listen token: $token');
          await RepositoryRealtimeUsers().getCheckFcmToken(user.uid).then((loadedToken) async {
            debugPrint('loadedToken == token: ${loadedToken == token}');

            debugPrint('loadedToken: $loadedToken');
            debugPrint('token: $token');

            debugPrint('기존의 fcmtoken과 다른 경우에만 새로운 fcmtoken을 업로드');

            await RepositoryRealtimeUsers().getCheckMyDeviceId(user.uid).then((deviceId) async {

              final deviceInfo = await DeviceInfo().initPlatformState();
              debugPrint('deviceInfo: $deviceInfo'); //identifierForVendor

              String? uniqueDeviceId;

              if (Platform.isIOS) {
                uniqueDeviceId = deviceInfo['identifierForVendor'];
                debugPrint('deviceInfo[identifierForVendor]: $uniqueDeviceId');

              } else if (Platform.isAndroid) {
                uniqueDeviceId = deviceInfo['id'];
                debugPrint('deviceInfo[id]: $uniqueDeviceId');

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
                debugPrint('Device ID already exists in the database.');

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
        debugPrint('2222');

        if (user.providerData.isNotEmpty) {
          //debugPrint('user.providerData.isNotEmpty');
          debugPrint(
              'SignupScreen user.providerData: ${user.providerData.first.providerId.toString()}');

          String providerId = user.providerData.first.providerId.toString();
          switch (providerId) {
            case 'google.com':
              debugPrint('구글로 로그인');
            case 'apple.com':
              debugPrint('애플로 로그인');
          }
          //Provider.of<LoginStatusUpdate>(context, listen: false).updateProviderId(user.providerData.first.providerId.toString());
        } else if (user.providerData.isEmpty) {
          debugPrint('카카오로 로그인한 상태');
          debugPrint('user.providerData.isEmpty');
        }

        // 이전에 유저 정보가 있으면, 로그아웃했다가 다시 들어온 유저로 인식하고, 프로필 설정 화면으로 보낼 필요가 없음
        final QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
            .collection("UserData")
            .where("uid", isEqualTo: user.uid)
            .get();
        // debugPrint('이전에 유저 정보가 있으면, 로그아웃했다가 다시 들어온 유저로 인식하고, 프로필 설정 화면으로 보낼 필요가 없음');
        debugPrint('querySnapshot: $querySnapshot');

        if (querySnapshot.docs.isNotEmpty) {
          // 문서가 존재하면 이전에 저장한 유저 정보가 있다고 판단
          debugPrint(
              '문서가 존재하면 이전에 저장한 유저 정보가 있다고 판단 UserData exists for ${user.uid}');
          await Provider.of<LoginStatusUpdate>(context, listen: false)
              .updateIsUserDataExists(true);
          //Provider.of<ProfileUpdate>(context, listen: false).updateUserProfile(docRef as UserProfile);
          await Provider.of<LoginStatusUpdate>(context, listen: false)
              .updateIsAgreementChecked(true);
          await Provider.of<LoginStatusUpdate>(context, listen: false)
              .trueIsLoggedIn();
          final recentVisit = await RepositoryRealtimeUsers().getUpdateMyRecentVisit();
          debugPrint('recentVisit: $recentVisit');
          await Provider.of<LoginStatusUpdate>(context, listen: false).updateCurrentVisit(recentVisit);

        } else {
          // 문서가 존재하지 않으면 이전에 저장한 유저 정보가 없다고 판단
          debugPrint(
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

  ////////// 기존 LoadingUpdate //////////


  // mainScreen 광고 배너
  Map<String?, Uint8List?> imageMapMain = {};
  Map<String, String> refStringListMain = {};
  Map<String?, String?> urlMapMain = {};

  // 공지사항
  Map<String?, Uint8List?> announcementMapMain = {};
  Map<String, String> announcementString = {};
  Map<String?, String?> urlMapAnnouncement = {};
  Map<String?, String?> textMapAnnouncement = {};

  // 이용안내
  // 이용안내 관련 이미지나 텍스트가 불러와 지지 않았다면, 앱이 맨 처음 열리는 것으로 간주
  Map<String?, Uint8List?> howToUseMapMain = {};
  Map<String?, String?> textMapHowToUse = {};

  // matchingScreen 광고 배너
  Map<String?, Uint8List?> imageMapMatchingScreen = {};
  Map<String?, String?> urlMapMatchingScreen = {};
  Map<String, String> refStringListMatchingScreen = {};

  ///////////
  Future<void> downloadAllImagesInMainScreen() async {

    final gsReference =
    FirebaseStorage.instance.refFromURL("gs://dnpp-402403.appspot.com");

    Reference imageReference = gsReference.child("main_images");
    Reference urlReference = gsReference.child("main_urls");
    Reference announcementReference = gsReference.child("announcements");
    Reference announcementUrlReference = gsReference.child("announcement_url");
    Reference announcementTextReference = gsReference.child("announcement_text");
    Reference howToUseImageReference = gsReference.child("howToUse_images");
    Reference howToUseTextReference = gsReference.child("howToUse_text");

    // int mainBannerCount = 0;
    // int adBannerCount = 0;

    try {
      // ListResult의 items를 통해 해당 폴더에 있는 파일들을 가져옵니다.
      ListResult imageListResult = await imageReference.list(); // 광고배너 이미지
      ListResult urlListResult = await urlReference.list(); // 광고배너 링크
      ListResult announcementResult = await announcementReference.list(); // 공지사항 이미지
      ListResult announcementUrlResult = await announcementUrlReference.list(); // 공지사항 링크
      ListResult announcementTextResult = await announcementTextReference.list(); // 공지사항 텍스트

      ListResult howToUseImageResult = await howToUseImageReference.list(); // 이용안내 이미지
      ListResult howToUseTextResult = await howToUseTextReference.list(); // 이용안내 텍스트

      try {

        // 각 리스트를 위한 비동기 작업 시작
        await Future.wait([
          processMainImageListResult(imageListResult.items),
          processMainUrlListResult(urlListResult.items),
          processAnnouncementResult(announcementResult.items),
          processAnnouncementUrlResult(announcementUrlResult.items),
          processAnnouncementTextResult(announcementTextResult.items),
          processHowToUseImageResult(howToUseImageResult.items),
          processHowToUseTextResult(howToUseTextResult.items),
        ]).then((value) {
          notifyListeners();
        });

      } catch (e) {
        debugPrint("Error in downloadAllImages Future.wait: $e");
      }
    } catch (e) {
      debugPrint("Error in downloadAllImages: $e");
    }

  }

  Future<void> processMainImageListResult(List<Reference> items) async {

    int mainBannerCount = 0;

    for (Reference imageRef in items) {
      try {
        debugPrint('main_screen imageRef.fullPath: ${imageRef.fullPath}');
        List<String> parts = imageRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        debugPrint('imageListResult Result: $result');
        const oneMegabyte = 1024 * 1024;
        final Uint8List? imageData = await imageRef.getData(oneMegabyte);

        imageMapMain['$result'] = imageData; // 메인 스크린에서 인덱스 순으로 이미지가 들어감
        refStringListMain['$mainBannerCount'] = result;
        mainBannerCount++;

      } catch (e) {
        // Handle any errors.
        debugPrint("Error downloading image: $e");
      }
    }
  }
  Future<void> processMainUrlListResult(List<Reference> items) async {

    for (Reference urlRef in items) {
      try {
        debugPrint('Reference urlRef in urlListResult.items: ${urlRef.fullPath}');
        List<String> parts = urlRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        debugPrint('urlListResult Result: $result');

        final Uint8List? urlData = await urlRef.getData();
        // Assuming the content of the text file is UTF-8 encoded
        String? urlContent = utf8.decode(urlData!); // Convert bytes to string

        urlMapMain['$result'] = urlContent;
      } catch (e) {
        // Handle any errors.
        debugPrint("Error downloading image: $e");
      }
    }
  }
  Future<void> processAnnouncementResult(List<Reference> items) async {

    int adBannerCount = 0;

    for (Reference announcementRef in items) {
      try {
        debugPrint('announcementResult urlRef.fullPath: ${announcementRef.fullPath}');
        List<String> parts = announcementRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        debugPrint('announcementResult Result: $result');

        const oneMegabyte = 1024 * 1024;
        final Uint8List? imageData = await announcementRef.getData(oneMegabyte);
        //debugPrint('announcementResult imageData: $imageData');

        announcementMapMain['$result'] = imageData;
        announcementString['$adBannerCount'] = result;
        adBannerCount++;

      } catch (e) {
        // Handle any errors.
        debugPrint("Error downloading image: $e");
      }
    }
  }
  Future<void> processAnnouncementUrlResult(List<Reference> items) async {

    for (Reference urlRef in items) {
      try {
        debugPrint('Reference urlRef in announcementUrlResult.items: ${urlRef.fullPath}');
        List<String> parts = urlRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        debugPrint('announcementUrlResult Result: $result');

        final Uint8List? urlData = await urlRef.getData();
        // Assuming the content of the text file is UTF-8 encoded
        String? urlContent = utf8.decode(urlData!); // Convert bytes to string

        urlMapAnnouncement['$result'] = urlContent;
        debugPrint('urlMapAnnouncement[0]: ${urlMapAnnouncement['0']}');
      } catch (e) {
        // Handle any errors.
        debugPrint("Error downloading image: $e");
      }
    }
  }
  Future<void> processAnnouncementTextResult(List<Reference> items) async {

    for (Reference textRef in items) {
      try {
        debugPrint('Reference textRef in announcementTextResult.items: ${textRef.fullPath}');
        List<String> parts = textRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        debugPrint('announcementTextResult Result: $result');

        final Uint8List? urlData = await textRef.getData();
        // Assuming the content of the text file is UTF-8 encoded
        String? urlContent = utf8.decode(urlData!); // Convert bytes to string

        textMapAnnouncement['$result'] = urlContent;
        debugPrint('textMapAnnouncement[0]: ${textMapAnnouncement['0']}');
      } catch (e) {
        // Handle any errors.
        debugPrint("Error downloading image: $e");
      }
    }
  }
  Future<void> processHowToUseImageResult(List<Reference> items) async {


    for (Reference imageRef in items) {
      try {
        debugPrint('howToUseImageResult imageRef.fullPath: ${imageRef.fullPath}');
        List<String> parts = imageRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        debugPrint('howToUseImageResult Result: $result');
        const oneMegabyte = 1024 * 1024;
        final Uint8List? imageData = await imageRef.getData(oneMegabyte);

        howToUseMapMain['howToUse$result'] = imageData;
        //debugPrint('imageRef imageData: $imageData');

      } catch (e) {
        // Handle any errors.
        debugPrint("Error downloading image: $e");
      }
    }
  }
  Future<void> processHowToUseTextResult(List<Reference> items) async {

    for (Reference textRef in items) {
      try {
        debugPrint('howToUseTextResult textRef.fullPath: ${textRef.fullPath}');
        List<String> parts = textRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        debugPrint('howToUseTextResult Result: $result');

        final Uint8List? urlData = await textRef.getData();
        // Assuming the content of the text file is UTF-8 encoded
        String? urlContent = utf8.decode(urlData!); // Convert bytes to string

        textMapHowToUse['howToUse$result'] = urlContent;
        debugPrint('textMapHowToUse[result]: ${textMapHowToUse['howToUse$result']}');
      } catch (e) {
        // Handle any errors.
        debugPrint("Error downloading image: $e");
      }
    }
  }

  ///////////

  Future<void> downloadAllImagesInMatchingScreen() async {

    final gsReference =
    FirebaseStorage.instance.refFromURL("gs://dnpp-402403.appspot.com");

    Reference imageReference = gsReference.child("matchingScreen_images");
    Reference urlReference = gsReference.child("matchingScreen_urls");

    try {

      // ListResult의 items를 통해 해당 폴더에 있는 파일들을 가져옵니다.
      ListResult imageListResult = await imageReference.list();
      ListResult urlListResult = await urlReference.list();

      try {
        // 각 리스트를 위한 비동기 작업 시작
        await Future.wait([
          processMatchingImageListResult(imageListResult.items),
          processMatchingUrlListResult(urlListResult.items),
        ]).then((value) {
          notifyListeners();
        });
      } catch (e) {
        debugPrint("Error in downloadAllImagesInMatchingScreen Future.wait: $e");
      }

    } catch (e) {
      debugPrint("Error in downloadAllImagesInMatchingScreen: $e");
    }

  }

  Future<void> processMatchingImageListResult(List<Reference> items) async {

    int matchingBannerCount = 0;

    for (Reference imageRef in items) {
      try {
        debugPrint('matching_screen imageRef.fullPath: ${imageRef.fullPath}');
        List<String> parts = imageRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        debugPrint('matching_screen Result: $result');
        const oneMegabyte = 1024 * 1024;
        final Uint8List? imageData = await imageRef.getData(oneMegabyte);

        imageMapMatchingScreen['$result'] = imageData;

        refStringListMatchingScreen['$matchingBannerCount'] = result;
        matchingBannerCount++;
      } catch (e) {
        // Handle any errors.
        debugPrint("Error downloading image: $e");
      }
    }
  }
  Future<void> processMatchingUrlListResult(List<Reference> items) async {

    for (Reference urlRef in items) {
      try {
        debugPrint('matching_screen urlRef.fullPath: ${urlRef.fullPath}');
        List<String> parts = urlRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        debugPrint('matching_screen Result: $result');

        final Uint8List? urlData = await urlRef.getData();
        // Assuming the content of the text file is UTF-8 encoded
        String? urlContent = utf8.decode(urlData!); // Convert bytes to string

        urlMapMatchingScreen['$result'] = urlContent;
      } catch (e) {
        // Handle any errors.
        debugPrint("Error downloading image: $e");
      }
    }
  }

  //////////////////////////

  Future<void> loadData(
      BuildContext context, bool isPersonal, String courtTitle, String courtRoadAddress) async {

    try {

      await Future.wait([
        downloadAllImagesInMainScreen(),
        downloadAllImagesInMatchingScreen(),
      ]).then((value) async {

        try {
          //if (Provider.of<LoginStatusUpdate>(context, listen: false).isLoggedIn) {
          if (FirebaseAuth.instance.currentUser?.uid != '' || FirebaseAuth.instance.currentUser?.uid != null) {
            await RepositoryFirestoreUserData().getFetchUserData(context);

            // await Provider.of<CourtAppointmentUpdate>(context, listen: false)
            //     .daywiseDurationsCalculate(
            //     false, false, courtTitle, courtRoadAddress);
            // debugPrint(1);
            // await Provider.of<CourtAppointmentUpdate>(context, listen: false)
            //     .courtCountHours(false, false, courtTitle, courtRoadAddress);
            //
            // await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            //     .daywiseDurationsCalculate(
            //     false, isPersonal, courtTitle, courtRoadAddress);
            // await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            //     .personalCountHours(
            //     false, isPersonal, courtTitle, courtRoadAddress);

          } else {

          }

          debugPrint('await fetchUserData(); completed');

          notifyListeners();

        } catch (e) {
          debugPrint('loadData Future.wait after e: $e');
        }

        debugPrint('await downloadAllImagesInMainScreen(); completed');
        debugPrint('await downloadAllImagesInMatchingScreen(); completed');

      });

    } catch (e) {
      debugPrint('loadData e: $e');
    }

  }

}
