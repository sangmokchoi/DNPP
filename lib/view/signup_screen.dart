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

  Future<void> _launchUrl(String _url) async {
    print('_launchURL 진입');
    final Uri _newUrl = Uri.parse(_url);
    if (!await launchUrl(_newUrl)) {
      throw Exception('Could not launch $_newUrl');
    }
  }

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
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back),
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          // ),
        ),
        body: Padding(
          padding:
              EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                  width: 250,
                  height: 250,
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
              Divider(
                thickness: 2.0,
              ),
              FutureBuilder(
                  future: Provider.of<SharedPreference>(context, listen: false)
                      .initializeSharedPreferences(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Visibility(
                        visible: !Provider.of<SharedPreference>(context,
                                listen: false)
                            .isUserTried,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: Provider.of<LoginStatusUpdate>(context,
                                        listen: false)
                                    .isAgreementChecked,
                                onChanged: (value) async {
                                  await Provider.of<LoginStatusUpdate>(context,
                                          listen: false)
                                      .toggleIsAgreementChecked();
                                  setState(() {});
                                },
                              ),
                              //Text('(필수) 이용약관 및 개인정보 처리방침에 동의합니다.'),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.black),
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
                                          // 여기에 링크를 클릭했을 때 수행할 동작을 추가하세요.
                                          await _launchUrl(
                                              'https://www.naver.com/');
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
                                          // 여기에 링크를 클릭했을 때 수행할 동작을 추가하세요.
                                          await _launchUrl(
                                              'https://www.naver.com/');
                                        },
                                    ),
                                    TextSpan(text: '에 동의합니다')
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LoginButton('images/Google Button.png'),
                    //LoginButton('images/btnG_아이콘원형.png'),
                    LoginButton('images/Kakao Button.png'),
                    LoginButton('images/Apple ID Login Black.png'),
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

class LoginButton extends StatelessWidget {
  LoginButton(this._buttonTitle);

  final String _buttonTitle;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool isLoading = true;
  late BuildContext dialogContext;

  Future<void> CircularProgressWorking(BuildContext context) async {
    final SharedPreferences prefs = await _prefs;

    try {
      print('${_buttonTitle}');
      switch (_buttonTitle) {
        case 'images/Google Button.png':
          await viewModel.FirebaseRepository().signInWithGoogle(context);
          print('images/Google Button.png');
          //Navigator.pop(context);
          break;
        case 'images/btnG_아이콘원형.png':
          await viewModel.FirebaseRepository().signInWithNaver();
          print('images/btnG_아이콘원형.png');
          //Navigator.pop(context);
          break;
        case 'images/Kakao Button.png':
          //await FirebaseRepository().kakaoSelectFriends(context);
          await viewModel.FirebaseRepository().kakaoLogin(context);
          print('images/Kakao Button.완료');
          //Navigator.pop(context);

          break;
        case 'images/Apple ID Login Black.png':
          await viewModel.FirebaseRepository().signInWithApple(context);
          print('images/Apple ID Login Black.png');
          //Navigator.pop(context);
          break;
      }
    } finally {
      // 비동기 작업이 끝나면 다이얼로그를 닫습니다.
      //Navigator.of(context).pop();

      print('loading true');
      Navigator.of(dialogContext).pop();
      //Navigator.pop(context);
      if (Provider.of<LoginStatusUpdate>(context, listen: false)
          .isUserDataExists) {
        // 유저정보가 서버에 존재하는 경우
        print('유저정보가 서버에 존재하는 경우');
        Provider.of<LoginStatusUpdate>(context, listen: false)
            .updateIsAgreementChecked(true);
        Navigator.pop(context);
      } else {
        print('유저정보가 서버에 존재하지 않는 경우');

        await prefs.setBool('isUserTried', true);

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
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
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("프로필 사진을 가져올까요?"),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: Text("취소"),
                      onPressed: () async {
                        Navigator.pop(context);

                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ProfileScreen(),
                          withNavBar: false,
                          // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: Text("확인"),
                      onPressed: () async {
                        await Provider.of<ProfileUpdate>(context, listen: false)
                            .updateIsGetImageUrl(true);
                        Navigator.pop(context);

                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ProfileScreen(),
                          withNavBar: false,
                          // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return InkWell(
          onTap: () async {
            print('1111');
            if (Provider.of<LoginStatusUpdate>(context, listen: false)
                .isAgreementChecked) {
              // isAgreementChecked == true이면, 로그인 진행
              print('2222');
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
            } else {
              if (Provider.of<SharedPreference>(context, listen: false)
                  .isUserTried) {
                // true 이면, 체크박스 체크하라는 안내문이 안 나타나야 함
                print('3333');
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
              } else {
                print('4444');
                showDialog(
                  context: context,
                  builder: (context) {
                    dialogContext = context;
                    return AlertDialog(
                      insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
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
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("이용약관 및 개인정보 처리방침 동의가 필요합니다"),
                        ],
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                              child: Text("확인"),
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              }
            }
          },
          child: Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Image.asset('${_buttonTitle}')),
        );
      },
    );
  }
}
