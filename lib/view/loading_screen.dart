import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/view/profile_screen.dart';
import 'package:dnpp/viewModel/loadingUpdate.dart';
import 'package:dnpp/viewModel/loginStatusUpdate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../repository/launchUrl.dart';
import '../viewModel/profileUpdate.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  static String id = '/';

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {

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
        print('SignupScreen user: $user');

        //Provider.of<LoginStatusUpdate>(context, listen: false).currentUser = user;
        //Provider.of<LoginStatusUpdate>(context, listen: false).trueIsLoggedIn();
        Provider.of<LoginStatusUpdate>(context, listen: false)
            .updateCurrentUser(user);

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
        } else {
          // 문서가 존재하지 않으면 이전에 저장한 유저 정보가 없다고 판단
          print(
              '문서가 존재하지 않으면 이전에 저장한 유저 정보가 없다고 판단 No UserData for ${user.uid}');
          await Provider.of<LoginStatusUpdate>(context, listen: false)
              .updateIsUserDataExists(false);
          await prefs.setBool('isUserTried', true);
          // 프로필 사진 가져올지 문의
          //await Provider.of<LoginStatusUpdate>(context, listen: false).falseIsLoggedIn();
          //print('이때, 유저에게 이용약관 동의 요청 필요');
          // if (Provider.of<LoginStatusUpdate>(context, listen: false).isLogInButtonClicked) { // 유저가 로그인 버튼을 눌렀을 떄를 인
          //   _showAgreementDialog(context);
          // }
          if (Provider.of<ProfileUpdate>(context, listen: false)
              .userProfileUpdated ==
              false) {
            // userprofile이 업데이트 되지 않았다면, 회원가입을 시도하는 것으로 간주
            await _showAgreementDialog(context);
          } else {
            Navigator.pop(context);
            print('Navigator.pop(context); 끝');
          }
        }

        // 로그인 버튼 클릭 여부 초기화
        await Provider.of<LoginStatusUpdate>(context, listen: false)
            .updateIsLogInButtonClicked(false);
      }

      // setState(() {
      //   print('main screen 로그인 버튼 클릭 여부 초기화 이후의 setstate');
      // });
    });

    super.initState();
  }

  Future<void> _showAgreementDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LoginStatusUpdate>(
            builder: (context, loginStatus, child) {
              return AlertDialog(
                insetPadding: EdgeInsets.only(left: 15.0, right: 15.0),
                shape: kRoundedRectangleBorder,
                title: Text('이용약관 및 개인정보 처리방침 동의'),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: Provider.of<LoginStatusUpdate>(context, listen: false)
                          .isAgreementChecked,
                      onChanged: (value) async {
                        await Provider.of<LoginStatusUpdate>(context, listen: false)
                            .toggleIsAgreementChecked();
                        // You can add any additional logic here if needed
                      },
                    ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black // 다크 모드일 때 텍스트 색상
                              : Colors.white,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: '(필수) '),
                          TextSpan(
                            text: '이용약관',
                            style: TextStyle(
                              color: kMainColor,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await LaunchUrl()
                                    .myLaunchUrl('https://www.naver.com/');
                              },
                          ),
                          TextSpan(text: ' 및 '),
                          TextSpan(
                            text: '개인정보 처리방침',
                            style: TextStyle(
                              color: kMainColor,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await LaunchUrl()
                                    .myLaunchUrl('https://www.naver.com/');
                              },
                          ),
                          TextSpan(text: '에\n동의합니다')
                        ],
                      ),
                    )
                  ],
                ),
                actions: [
                  Provider.of<LoginStatusUpdate>(context, listen: false)
                      .isAgreementChecked ==
                      true
                      ? TextButton(
                      style: kConfirmButtonStyle,
                      onPressed: () {
                        Navigator.pop(context);
                        _showProfilePictureAskDialog(context);
                      },
                      child: ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              '확인',
                              textAlign: TextAlign.center,
                              style: kTextButtonTextStyle,
                            ),
                          ),
                        ],
                      ))
                      : SizedBox.shrink()
                ],
              );
            });
      },
    );
  }

  Future<void> _showProfilePictureAskDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          shape: kRoundedRectangleBorder,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "알림",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
          content: Text(
            "소셜 로그인 계정에서 프로필 사진을 가져올까요?",
            textAlign: TextAlign.start,
          ),
          actions: [
            ButtonBar(
              alignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: kAlertDialogTextButtonWidth,
                  child: TextButton(
                    style: kCancelButtonStyle,
                    child: Text(
                      "아니오",
                      textAlign: TextAlign.center,
                      style: kTextButtonTextStyle,
                    ),
                    onPressed: () async {
                      await Provider.of<ProfileUpdate>(context, listen: false)
                          .updateIsGetImageUrl(false);
                      Navigator.pop(context);

                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: ProfileScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                        PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                ),
                Container(
                  width: kAlertDialogTextButtonWidth,
                  child: TextButton(
                    style: kConfirmButtonStyle,
                    child: Text(
                      "예",
                      textAlign: TextAlign.center,
                      style: kTextButtonTextStyle,
                    ),
                    onPressed: () async {
                      await Provider.of<ProfileUpdate>(context, listen: false)
                          .updateIsGetImageUrl(true);
                      Navigator.pop(context);

                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: ProfileScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                        PageTransitionAnimation.cupertino,
                      ).then((value) {
                        // This code will be executed when SignupScreen is popped.
                        setState(() {
                          print('로그인 완료 후 복귀 setState');
                        });
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<LoadingUpdate>(context, listen: false)
            .loadData(context, true, '', '')
            .timeout(
          Duration(seconds: 7),
          onTimeout: () {
            // 타임아웃이 발생한 경우에는 알림창 필요
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('오류'),
                  content:
                      Text('데이터를 불러오는 데 시간이 걸리고 있습니다.\n네트워크 등에 오류가 있을 수 있습니다'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        exit(0);
                      },
                      child: Text('확인'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kMainColor),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => HomeScreen()),
            // );
            print("지금 종료됨");
            return HomeScreen();
          } else {
            return Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            );
          }
        });
  }
}
