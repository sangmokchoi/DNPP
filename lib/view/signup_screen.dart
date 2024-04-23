import 'dart:io';

import 'package:dnpp/models/userProfile.dart';
import 'package:dnpp/repository/moveToOtherScreen.dart';

import 'package:dnpp/view/profile_screen.dart';
import 'package:dnpp/viewModel/MatchingScreen_ViewModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:dnpp/repository/repository_auth.dart' as viewModel;

import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../repository/launchUrl.dart';
import '../repository/repository_userData.dart';
import '../statusUpdate/courtAppointmentUpdate.dart';
import '../statusUpdate/personalAppointmentUpdate.dart';
import '../statusUpdate/profileUpdate.dart';
import '../statusUpdate/loginStatusUpdate.dart';

import 'package:flutter_svg/flutter_svg.dart';

class SignupScreen extends StatelessWidget {
  static String id = '/SignupScreenID';

  final String title = '';

  TextEditingController _textFormFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Container(
                    width: 100,
                    height: 100,
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
                Text(
                  'Pingpong Plus',
                  style: kProfileTextStyle.copyWith(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  '탁구에 새로움을 더하다',
                  style: kProfileTextStyle,
                ),
                Divider(
                  thickness: 1.0,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LoginButton('images/Google Login.svg'),
                      LoginButton('images/Kakao ID Login.svg'),
                      if (!Platform.isAndroid)
                        Theme.of(context).brightness == Brightness.light
                            ? LoginButton('images/Apple ID Login_black.svg')
                            : LoginButton('images/Apple ID Login.svg')
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  LoginButton(this._buttonTitle);

  final String _buttonTitle;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late BuildContext dialogContext;

  Future<void> CircularProgressWorking(BuildContext context) async {
    final SharedPreferences prefs = await _prefs;

    //await Future.delayed(Duration(seconds: 10));

    // 10초 후 실행될 코드
    // 여기서는 사용자에게 화면을 새로 고칠지 묻는 대화상자를 표시합니다.
    if (Navigator.canPop(context)) {
      // 현재 보이는 다이얼로그나 화면을 닫습니다.
      print('여기서는 사용자에게 화면을 새로 고칠지 묻는 대화상자를 표시합니다.');
      //Navigator.pop(context);
    }

    // 로그인 버튼이 클릭됨을 알려줌
    await Provider.of<LoginStatusUpdate>(context, listen: false)
        .updateIsLogInButtonClicked(true);

    try {
      print('$_buttonTitle');

      bool loginSuccess = false;

      switch (_buttonTitle) {
        case 'images/Google Login.svg':
          loginSuccess =
              await viewModel.RepositoryAuth().signInWithGoogle(context);
          print('images/Google Login.svg');

        // case 'images/btnG_아이콘원형.png':
        //   await viewModel.FirebaseRepository().signInWithNaver();
        //   print('images/btnG_아이콘원형.png');

        case 'images/Kakao ID Login.svg':
          //await FirebaseRepository().kakaoSelectFriends(context);
          loginSuccess = await viewModel.RepositoryAuth().kakaoLogin(context);
          print('images/Kakao ID Login.svg 완료');

        case 'images/Apple ID Login.svg':
          loginSuccess =
              await viewModel.RepositoryAuth().signInWithApple(context);
          print('images/Apple Login.svg 완료');

        case 'images/Apple ID Login_black.svg':
          loginSuccess =
              await viewModel.RepositoryAuth().signInWithApple(context);
          print('images/Apple Login_black.svg 완료');
      }
      print('loginSuccess: $loginSuccess');

      if (loginSuccess == true) {
        print('await RepositoryUserData().fetchUserData(context); 직전');
        await RepositoryUserData().fetchUserData(context).then((value) async {
          Future.delayed(Duration(seconds: 1));
          print('await RepositoryUserData().fetchUserData(context); 직후');

          await Provider.of<
              PersonalAppointmentUpdate>(context,
              listen: false)
              .updateChart(0); // 최근 일자 중 최근 7일 클릭한 상태로 변환

          await Provider.of<CourtAppointmentUpdate>(
              context,
              listen: false)
              .updateChart(0); // 최근 일자 중 최근 7일 클릭한 상태로 변환

          Navigator.of(dialogContext).pop();
          print('Navigator.of(dialogContext).pop(); 끝');

          //Navigator.pop(context);

          if (Provider.of<ProfileUpdate>(context, listen: false)
                      .userProfileUpdated ==
                  false &&
              Provider.of<LoginStatusUpdate>(context, listen: false)
                      .isLoggedIn ==
                  false) {
            // userprofile이 업데이트 되지 않았다면, 회원가입을 시도하는 것으로 간주
            await _showAgreementDialog(context);
          }
        });

        if (Provider.of<ProfileUpdate>(context, listen: false).userProfile != UserProfile.emptyUserProfile) {
          LaunchUrl().alertFunc(context, '알림', '로그인이 완료되었습니다', '확인', () {

            Navigator.pop(context);
            Navigator.pop(context);

          });
        }

      } else {
        print('유저가 취소함');
        Navigator.pop(context);
      }
    } catch (error) {
      print("CircularProgressWorking error: $error");

      if (error is PlatformException && error.code == 'CANCELED') {
        // 유저가 취소
        print(
            'CircularProgressWorking error is PlatformException && error.code == "CANCELED"');
        //return;
      } else if (error.toString() ==
          'error is PlatformException && error.code == "CANCELED"') {
        print(
            'CircularProgressWorking error is PlatformException && error.code == "CANCELED"');
        //return;
      } else {
        LaunchUrl().alertFunc(context, '오류', '로그인 중 에러가 발생했습니다', '확인', () {
          Navigator.of(context).pop();
        });
      }
    }
  }

  Future<void> _showAgreementDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LoginStatusUpdate>(
            builder: (context, loginStatus, child) {
          print('이용약관 및 개인정보 처리방침 동의 나타남');
          return AlertDialog(
            insetPadding: EdgeInsets.only(left: 15.0, right: 15.0),
            shape: kRoundedRectangleBorder,
            title: Text('이용약관 및 개인정보 처리방침 동의'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '핑퐁플러스 이용을 위해서는 이용약관 및 개인정보 처리방침 동의가 필요합니다.\n\n아래 설명에서 파란 부분을 클릭하면 이용약관과 개인정보 처리방침을 살펴볼 수 있습니다',
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value:
                          Provider.of<LoginStatusUpdate>(context, listen: false)
                              .isAgreementChecked,
                      onChanged: (value) async {
                        await Provider.of<LoginStatusUpdate>(context,
                                listen: false)
                            .toggleIsAgreementChecked();
                        // You can add any additional logic here if needed
                      },
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '(필수) ',
                        style: TextStyle(
                          fontSize: 14.0,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black // 다크 모드일 때 텍스트 색상
                                  : Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'NanumSquare',
                            fontSize: 14.0,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black // 다크 모드일 때 텍스트 색상
                                    : Colors.white,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '이용약관',
                              style: TextStyle(
                                color: kMainColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: ' 및 '),
                            TextSpan(
                              text: '개인정보 처리방침',
                              style: TextStyle(
                                color: kMainColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: '에 동의합니다')
                          ],
                        ),
                        maxLines: 2,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value:
                          Provider.of<LoginStatusUpdate>(context, listen: false)
                              .isUnderstood,
                      onChanged: (value) async {
                        await Provider.of<LoginStatusUpdate>(context,
                                listen: false)
                            .toggleIsUnderstood();
                      },
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '(필수) ',
                        style: TextStyle(
                          fontSize: 14.0,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black // 다크 모드일 때 텍스트 색상
                                  : Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Expanded(
                      child: Text(
                        '핑퐁플러스에 등록되는 탁구장 방문 일정이 다른 이용자에게 보여질 수 있음을 확인하였고 이에 동의합니다',
                        maxLines: 3,
                        style: TextStyle(
                            fontSize: 14.0,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black // 다크 모드일 때 텍스트 색상
                                    : Colors.white,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                  style: kCancelButtonStyle,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          '취소',
                          textAlign: TextAlign.center,
                          style: kTextButtonTextStyle,
                        ),
                      ),
                    ],
                  ),
              ),
              SizedBox(
                height: 5.0,
              ),

              (Provider.of<LoginStatusUpdate>(context,
                  listen: false)
                  .isAgreementChecked ==
                  true &&
                  Provider.of<LoginStatusUpdate>(context, listen: false)
                      .isUnderstood ==
                      true)
                  ?
              TextButton( // 필수 항목을 모두 클릭한 경우
                  style: kConfirmButtonStyle,
                  onPressed: () async {
                          Navigator.pop(context);
                          final providerData = FirebaseAuth.instance.currentUser?.providerData;
                          print(
                              'providerData: ${providerData}');
                          if (providerData!.isEmpty) { // 카카오로 로그인
                            _showProfilePictureAskDialog(context);
                          }

                          if (AppleAuthProvider().providerId != providerData?.first.providerId) { // 애플이 아닌 경우
                            _showProfilePictureAskDialog(context);

                          } else { // 애플인 경우
                            await Provider.of<ProfileUpdate>(context, listen: false)
                                .updateIsGetImageUrl(false);
                            //Navigator.pop(context);

                            MoveToOtherScreen()
                                .persistentNavPushNewScreen(
                                context,
                                ProfileScreen(
                                  isSignup: true,
                                ),
                                false,
                                PageTransitionAnimation.cupertino)
                                .then((value) {});

                          }
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
              : TextButton( // 아직 필수 항목을 모두 클릭 안 한 경우
                  style: kNotConfirmButtonStyle,
                  onPressed: () {

                  },
                  child: ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          '(필수) 항목 동의가 필요합니다',
                          textAlign: TextAlign.center,
                          style: kTextButtonTextStyle,
                        ),
                      ),
                    ],
                  ))
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
                  child: ElevatedButton(
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

                      MoveToOtherScreen()
                          .persistentNavPushNewScreen(
                              context,
                              ProfileScreen(
                                isSignup: true,
                              ),
                              false,
                              PageTransitionAnimation.cupertino)
                          .then((value) {});
                    },
                  ),
                ),
                Container(
                  width: kAlertDialogTextButtonWidth,
                  child: ElevatedButton(
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

                      MoveToOtherScreen()
                          .persistentNavPushNewScreen(
                              context,
                              ProfileScreen(
                                isSignup: true,
                              ),
                              false,
                              PageTransitionAnimation.cupertino)
                          .then((value) {});
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
    return GestureDetector(
      onTap: () async {
        showDialog(
          barrierDismissible: false, // 유저가 화면 뒤를 클릭해도 아무일도 일어나지 않음
          context: context,
          builder: (context) {
            dialogContext = context;
            return IgnorePointer(
              ignoring: true,
              child: Center(
                child: kCustomCircularProgressIndicator,
              ),
            );
          },
        );
        await CircularProgressWorking(context);
      },
      child: Container(
        width: 240.0,
        height: 48.0,
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: SvgPicture.asset(
          '$_buttonTitle',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
