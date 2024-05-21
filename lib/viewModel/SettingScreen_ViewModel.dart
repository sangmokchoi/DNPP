import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/LocalDataSource/DS_Local_Auth.dart';
import 'package:dnpp/LocalDataSource/firebase_fireStore/DS_Local_appointments.dart';
import 'package:dnpp/repository/firebase_auth.dart';
import 'package:dnpp/repository/firebase_firestore_appointments.dart';
import 'package:dnpp/repository/firebase_realtime_messages.dart';
import 'package:dnpp/repository/firebase_realtime_users.dart';
import 'package:dnpp/statusUpdate/othersPersonalAppointmentUpdate.dart';
import 'package:dnpp/viewModel/CalendarScreen_ViewModel.dart';
import 'package:dnpp/viewModel/MatchingScreen_ViewModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../LocalDataSource/firebase_realtime/messages/DS_Local_chat.dart';
import '../constants.dart';
import '../models/launchUrl.dart';

import '../models/moveToOtherScreen.dart';
import '../LocalDataSource/DS_Local_auth.dart';
import '../LocalDataSource/firebase_fireStore/DS_Local_userData.dart';

import '../repository/firebase_firestore_userData.dart';
import '../statusUpdate/ShowToast.dart';
import '../statusUpdate/courtAppointmentUpdate.dart';
import '../statusUpdate/personalAppointmentUpdate.dart';
import '../statusUpdate/profileUpdate.dart';
import '../view/ossLicense_screen.dart';
import '../view/profile_screen.dart';
import '../view/signup_screen.dart';

class SettingScreenViewModel extends ChangeNotifier {

  FirebaseFirestore db = FirebaseFirestore.instance;
  final _fireAuth = FirebaseAuth.instance;

  List<String> LoggedInsettingMenuList = [
    '프로필 수정',
    '오픈소스 라이센스',
    '이용약관',
    '개인정보 처리방침',
    '운영정책',
    '스토어 평점 남기기',
    '문의',
    '로그아웃',
    '회원 탈퇴'
  ];

  List<String> LoggedOutsettingMenuList = [
    '로그인',
    '오픈소스 라이센스',
    '이용약관',
    '개인정보 처리방침',
    '운영정책',
    '문의',
  ];

  Future<void> settingScreenProfile(BuildContext context) async {
    await MoveToOtherScreen()
        .persistentNavPushNewScreen(
            context,
            ProfileScreen(
              isSignup: false,
            ),
            false,
            PageTransitionAnimation.cupertino)
        .then((value) async {
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> settingScreenOss(BuildContext context) async {
    await MoveToOtherScreen().persistentNavPushNewScreen(
        context, OssLicenseScreen(), false, PageTransitionAnimation.fade);
    notifyListeners();
  }

  Future<void> settingScreenLogin(BuildContext context) async {
    await MoveToOtherScreen()
        .persistentNavPushNewScreen(
            context, SignupScreen(3), false, PageTransitionAnimation.fade)
        .then((value) async {
      debugPrint('로그인 완료 후 복귀 setState');

      notifyListeners();
    });
  }

  Future<void> settingTermsOfUse(BuildContext context) async {
    await LaunchUrl().myLaunchUrl(
        'https://sites.google.com/view/pingponplus-intermsofuse/%ED%99%88');
  }

  Future<void> settingPrivacy(BuildContext context) async {
    await LaunchUrl().myLaunchUrl(
        'https://sites.google.com/view/pingponplus-privacy/%ED%99%88');
  }

  Future<void> settingOperationPolicy(BuildContext context) async {
    await LaunchUrl().myLaunchUrl(
        'https://sites.google.com/view/pingponplus-operationpolicy/%ED%99%88');
  }

  Future<void> settingEnquire(BuildContext context) async {
    LaunchUrl().alertFunc(
        context, '문의', '아래 이메일 주소를 복사합니다\nsimonwork177@simonwork.net', '복사',
        () {
      Clipboard.setData(ClipboardData(text: 'simonwork177@simonwork.net'));
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  Future<void> settingMoveToStore(BuildContext context) async {

    if (Platform.isAndroid || Platform.isIOS) {
      final appId = Platform.isAndroid ? 'com.simonwork.dnpp.dnpp' : '6478840964';
      //final appId = Platform.isAndroid ? 'com.instagram.android' : '389801252';
      // final String url = Platform.isAndroid ?
      // "market://details?id=$appId" :
      // "https://apps.apple.com/app/id$appId";

      final url = Uri.parse(
        Platform.isAndroid
            //? "market://details?id=$appId"
        ? "https://play.google.com/store/apps/details?id=$appId"
        //com.instagram.android
            : "https://apps.apple.com/app/id$appId",
        //: "https://apps.apple.com/app/id389801252", // 핑퐁플러스 app id : id6478840964
        //itms-apps://apps.apple.com/app/
        //id389801252
      );

      //LaunchUrl().myLaunchUrl(url);
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }


  }

  Future<void> settingScreenLogout(BuildContext context) async {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
            shape: kRoundedRectangleBorder,
            title: Text(
              '알림',
              style: kAppointmentDateTextStyle,
              textAlign: TextAlign.center,
            ),
            content: Text(
              '로그아웃을 진행합니다',
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
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: Center(
                        child: Text(
                      '취소',
                      style: kAppointmentTextButtonStyle.copyWith(
                          color: kMainColor),
                    )),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: Center(
                        child: Text('로그아웃',
                            style: kAppointmentTextButtonStyle.copyWith(
                                color: kMainColor))),
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return IgnorePointer(
                            ignoring: true,
                            child: Center(
                              child:
                                  kCustomCircularProgressIndicator, // 로딩 바 표시
                            ),
                          );
                        },
                      );

                      await signOut(context).then((value) {
                        Navigator.of(context, rootNavigator: true).pop();
                        ShowToast().showToast("로그아웃이 완료되었습니다");

                        // LaunchUrl().alertFunc(
                        //     context, '알림', '로그아웃이 완료되었습니다', '확인', () {
                        //   Navigator.of(context, rootNavigator: true).pop();
                        //   Navigator.of(context, rootNavigator: true).pop();
                        //   //Navigator.pop(context);
                        // });
                      });
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future<void> signOut(BuildContext context) async {

    await Future.delayed(Duration(seconds: 1));

    try {
      await Provider.of<ProfileUpdate>(context, listen: false)
          .updateUserProfileUpdated(false);

      await RepositoryFirebaseAuth().getSignOut();

      await Provider.of<ProfileUpdate>(context, listen: false)
          .resetUserProfile();

      try {
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .resetMeetings();
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .resetHourlyCounts();
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .resetDaywiseDurations();
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .resetSelectedList();

        try {
          await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
              .resetMeetings();
          await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
              .resetHourlyCounts();
          await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
              .resetDaywiseDurations();
          await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
              .resetSelectedList();

          try {
            await Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .resetMeetings();
            await Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .resetHourlyCounts();
            await Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .resetDaywiseDurations();
            await Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .resetSelectedList();

            await Provider.of<CalendarScreenViewModel>(context, listen: false)
                .resetAppointments(); // 캘린더에 있는 appointment 리스트 초기화


            try {
              await Provider.of<MatchingScreenViewModel>(context, listen: false)
                  .initializeListeners()
                  .then((value) {
                //Navigator.of(context, rootNavigator: true).pop();
                //Navigator.pop(context);

                notifyListeners();
              });
            } catch (e) {
              debugPrint('initializeListeners 에러: $e');
            }

          } catch (e) {
            debugPrint('CourtAppointmentUpdate signOut e: $e');
          }
        } catch (e) {
          debugPrint('OthersPersonalAppointmentUpdate signOut e: $e');
        }
      } catch (e) {
        debugPrint('PersonalAppointmentUpdate signOut e: $e');
      }
    } catch (e) {
      debugPrint('ProfileUpdate signOut e: $e');
      LaunchUrl().alertFunc(
          context, '오류', '로그아웃 중 에러가 발생했습니다\n이용에 불편을 드려 죄송합니다', '확인', () {
        Navigator.pop(context);
      });
    }
  }

  Future<void> settingScreenRemoveData(BuildContext context) async {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
            shape: kRoundedRectangleBorder,
            title: Text(
              '알림',
              style: kAppointmentDateTextStyle,
              textAlign: TextAlign.center,
            ),
            content: Text(
              '정말 회원탈퇴 하시겠습니까?\n(최근 로그인한 이력이 없는 경우,\n재로그인 절차가 요구될 수 있습니다)',
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
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: Center(
                        child: Text(
                      '취소',
                      style: kAppointmentTextButtonStyle.copyWith(
                          color: kMainColor),
                    )),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: Center(
                        child: Text('회원탈퇴',
                            style: kAppointmentTextButtonStyle.copyWith(
                                color: Colors.red))),
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        useRootNavigator: false,
                        builder: (context) {
                          return IgnorePointer(
                            ignoring: true,
                            child: Center(
                              child:
                                  kCustomCircularProgressIndicator, // 로딩 바 표시
                            ),
                          );
                        },
                      );

                      await removeData(context).then((value) {
                        LaunchUrl().alertFunc(
                            context, '알림', '회원탈퇴가 완료되었습니다', '확인', () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.pop(context);
                          //Navigator.of(context, rootNavigator: true).pop();
                        });
                      });
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future<void> removeData(BuildContext context) async {

    await Future.delayed(Duration(seconds: 1));

    try {
      await RepositoryFirebaseAuth().deleteUserAccount().then((value) async {

        await RepositoryFirestoreUserData()
            .getDeleteUser(_fireAuth.currentUser!.uid.toString());
        await RepositoryFirestoreAppointments()
            .getDeleteUserAppointment(_fireAuth.currentUser!.uid.toString());
        await RepositoryRealtimeMessages()
            .getDeleteUsersData(_fireAuth.currentUser!.uid.toString());
        await RepositoryRealtimeMessages()
            .getDeleteChatData(_fireAuth.currentUser!.uid.toString());

        try {
          await Provider.of<ProfileUpdate>(context, listen: false)
              .updateUserProfileUpdated(false);

          await Provider.of<ProfileUpdate>(context, listen: false)
              .resetUserProfile();

          try {
            await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                .resetMeetings();
            await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                .resetHourlyCounts();
            await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                .resetDaywiseDurations();
            await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                .resetSelectedList();

            try {
              await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
                  .resetMeetings();
              await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
                  .resetHourlyCounts();
              await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
                  .resetDaywiseDurations();
              await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
                  .resetSelectedList();

              try {
                await Provider.of<CourtAppointmentUpdate>(context, listen: false)
                    .resetMeetings();
                await Provider.of<CourtAppointmentUpdate>(context, listen: false)
                    .resetHourlyCounts();
                await Provider.of<CourtAppointmentUpdate>(context, listen: false)
                    .resetDaywiseDurations();
                await Provider.of<CourtAppointmentUpdate>(context, listen: false)
                    .resetSelectedList();

                await Provider.of<CalendarScreenViewModel>(context,
                    listen: false)
                    .resetAppointments(); // 캘린더에 있는 appointment 리스트 초기화

                try {

                  await Provider.of<MatchingScreenViewModel>(context,
                          listen: false)
                      .initializeListeners()
                      .then((value) {
                    notifyListeners();
                  });
                } catch (e) {
                  debugPrint(
                      'CalendarScreenViewModel, MatchingScreenViewModel removeData e: $e');
                }
              } catch (e) {
                debugPrint('CourtAppointmentUpdate removeData e: $e');
              }
            } catch (e) {
              debugPrint('OthersPersonalAppointmentUpdate removeData e: $e');
            }

          } catch (e) {
            debugPrint('PersonalAppointmentUpdate removeData e: $e');
          }
        } catch (e) {
          debugPrint('ProfileUpdate removeData e: $e');
        }
      });
    } catch (e) {
      debugPrint('removeData e: $e');
      LaunchUrl().alertFunc(
          context, '오류', '회원탈퇴 중 에러가 발생했습니다\n이용에 불편을 드려 죄송합니다', '확인', () {
        Navigator.pop(context);
      });
    }
  }
}
