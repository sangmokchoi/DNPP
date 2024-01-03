import 'dart:convert';
//import 'dart:js_interop';

import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dnpp/repository/repository_firebase.dart';
import 'package:dnpp/view/home_screen.dart';
import 'package:dnpp/view/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:dnpp/dataSource/firebase_auth_remote_data_source.dart';
import 'package:dnpp/repository/repository_firebase.dart' as viewModel;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../repository/repository_loadData.dart';
import '../viewModel/profileUpdate.dart';
import '../viewModel/sharedPreference.dart';
import '../viewModel/loginStatusUpdate.dart';

class SignupScreen extends StatefulWidget {
  static String id = '/SignupScreenID';

  final String title = '';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _textFormFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: kMainColor, // 원하는 색상으로 변경
            size: 24.0, // 아이콘 크기 설정
          ),
          titleTextStyle: kAppbarTextStyle,
          title: Text('로그인'),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Padding(
          padding:
              EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('images/핑퐁플러스 로고.png')
                            as ImageProvider<Object>,
                      ) //가져온 이미지를 화면에 띄워주는 코드
                      ),
                ),
              ),
              Text('핑퐁플러스'),
              Divider(
                thickness: 1.0,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LoginButton('images/Google Button.png'),
                    LoginButton('images/Kakao Button.png'),
                    Theme.of(context).brightness == Brightness.light ?
                    LoginButton('images/Apple Button_black.png') :
                    LoginButton('images/Apple Button_white.png')
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  LoginButton(this._buttonTitle);

  final String _buttonTitle;

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool isLoading = true;

  late BuildContext dialogContext;

  Future<void> CircularProgressWorking(BuildContext context) async {
    final SharedPreferences prefs = await _prefs;

    // 로그인 버튼이 클릭됨을 알려줌
    await Provider.of<LoginStatusUpdate>(context, listen: false).updateIsLogInButtonClicked(true);

    try {
      print('${widget._buttonTitle}');
      switch (widget._buttonTitle) {
        case 'images/Google Button.png':
          await viewModel.FirebaseRepository().signInWithGoogle(context);
          print('images/Google Button.png');

          // setState(() {
          //   print('CircularProgressWorking setState');
          // });
          break;
        // case 'images/btnG_아이콘원형.png':
        //   await viewModel.FirebaseRepository().signInWithNaver();
        //   print('images/btnG_아이콘원형.png');
        //
        //   // setState(() {
        //   //   print('CircularProgressWorking setState');
        //   // });
        //   break;
        case 'images/Kakao Button.png':
          //await FirebaseRepository().kakaoSelectFriends(context);
          await viewModel.FirebaseRepository().kakaoLogin(context);
          print('images/Kakao Button.완료');

          // setState(() {
          //   print('CircularProgressWorking setState');
          // });
          break;
        case 'images/Apple Button_white.png':
          await viewModel.FirebaseRepository().signInWithApple(context);
          print('images/Apple Button_white.png');

          // setState(() {
          //   print('CircularProgressWorking setState');
          // });
          break;
        case 'images/Apple Button_black.png':
          await viewModel.FirebaseRepository().signInWithApple(context);
          print('images/Apple Button_black.png');

          // setState(() {
          //   print('CircularProgressWorking setState');
          // });
          break;
      }
    } finally {
      // 비동기 작업이 끝나면 다이얼로그를 닫습니다.
      print('Provider.of<ProfileUpdate>(context, listen: false).userProfile.uid: ${Provider.of<ProfileUpdate>(context, listen: false).userProfile.uid}');

      //if (Provider.of<ProfileUpdate>(context, listen: false).userProfile.uid != 'uid') {
        print('if (Provider.of<LoginStatusUpdate>(context, listen: false).isLoggedIn) {');
        await LoadData().fetchUserData(context);
      //}

      //setState(() {
        Navigator.of(dialogContext).pop();
        print('Navigator.of(dialogContext).pop(); 끝');
        print('Provider.of<ProfileUpdate>(context, listen: false).userProfileUpdated: ${Provider.of<ProfileUpdate>(context, listen: false).userProfileUpdated}');

        if (Provider.of<ProfileUpdate>(context, listen: false).userProfileUpdated == false) { // userprofile이 업데이트 되지 않았다면, 회원가입을 시도하는 것으로 간주
          await _showAgreementDialog(context);
        } else {
          Navigator.pop(context);
          print('Navigator.pop(context); 끝');
        }
      //});

      // if (Provider.of<LoginStatusUpdate>(context, listen: false)
      //     .isUserDataExists) {
      //
      //   print('유저정보가 서버에 존재하는 경우');
      //   await Provider.of<LoginStatusUpdate>(context, listen: false)
      //       .updateIsAgreementChecked(true);
      //   await Provider.of<LoginStatusUpdate>(context, listen: false).trueIsLoggedIn();
      //
      //   Navigator.pop(context);
      //
      // } else {
      //   print('유저정보가 서버에 존재하지 않는 경우');
      //
      //   await prefs.setBool('isUserTried', true);
      //   // 프로필 사진 가져올지 문의
      //   await Provider.of<LoginStatusUpdate>(context, listen: false).falseIsLoggedIn();
      //
      //   _showAgreementDialog(context);
      // }


    }
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
                                await _launchUrl('https://www.naver.com/');
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
                                await _launchUrl('https://www.naver.com/');
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
  Future<void> _launchUrl(String _url) async {
    print('_launchURL 진입');
    final Uri _newUrl = Uri.parse(_url);
    if (!await launchUrl(_newUrl)) {
      throw Exception('Could not launch $_newUrl');
    }
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
          content:
          Text(
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return InkWell(
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) {
                dialogContext = context;
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
            await CircularProgressWorking(context);
          },
          child: Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Image.asset('${widget._buttonTitle}')),
        );
      },
    );
  }
}
