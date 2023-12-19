import 'dart:convert';
//import 'dart:js_interop';

import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dnpp/repository/repository_firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:dnpp/dataSource/firebase_auth_remote_data_source.dart';
import 'package:dnpp/repository/repository_firebase.dart' as viewModel;
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../viewModel/loginStatusUpdate.dart';

class SignupScreen extends StatefulWidget {
  static String id = '/SignupScreenID';

  final String title = '';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _textFormFieldController = TextEditingController();

  bool isChecked = false;

  void toggleDone() {
    isChecked = !isChecked;
    print(isChecked);
  }

  Future<void> _launchUrl(String _url) async {
    print('_launchURL 진입');
    final Uri _newUrl = Uri.parse(_url);
    if (!await launchUrl(_newUrl)) {
      throw Exception('Could not launch $_newUrl');
    }
  }

  @override
  void initState() {
    // FirebaseAuth.instance.authStateChanges().listen((user) {
    //   if (user == null) {
    //     // user == null
    //     print('SignupScreen user isNotLoggedIn');
    //     print('SignupScreen user: $user');
    //     print('신규유저 이므로 프로필 생성 필요');
    //     print('user: $user');
    //
    //   } else {
    //     // user != null
    //     print('SignupScreen user isLoggedIn');
    //     print('SignupScreen user: $user');
    //
    //     Provider.of<LoginStatusUpdate>(context, listen: false)
    //         .updateCurrentUser(user);
    //
    //     if (user.providerData.isNotEmpty) {
    //       print('user.providerData.isNotEmpty');
    //       print(
    //           'SignupScreen user.providerData: ${user.providerData.first.providerId.toString()}');
    //
    //       String providerId = user.providerData.first.providerId.toString();
    //       switch (providerId) {
    //         case 'google.com':
    //           return print('구글로 로그인');
    //         case 'apple.com':
    //           return print('애플로 로그인');
    //       }
    //       //Provider.of<LoginStatusUpdate>(context, listen: false).updateProviderId(user.providerData.first.providerId.toString());
    //     } else if (user.providerData.isEmpty) {
    //       print('카카오로 로그인한 상태');
    //       print('user.providerData.isEmpty');
    //     }
    //   }
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.blue, // 원하는 색상으로 변경
            size: 24.0, // 아이콘 크기 설정
          ),
          titleTextStyle: kAppbarTextStyle,
          title: Text('회원가입'),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/empty_profile_160.png'),
              Divider(
                thickness: 2.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          toggleDone();
                        });
                      },
                    ),
                    //Text('(필수) 이용약관 및 개인정보 처리방침에 동의합니다.'),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: '이용약관',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                // 여기에 링크를 클릭했을 때 수행할 동작을 추가하세요.
                                await _launchUrl('https://www.naver.com/');
                              },
                          ),
                          TextSpan(text: ' 및 '),
                          TextSpan(
                            text: '개인정보 처리방침',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                // 여기에 링크를 클릭했을 때 수행할 동작을 추가하세요.
                                await _launchUrl('https://www.naver.com/');
                              },
                          ),
                          TextSpan(text: '에 동의합니다')
                        ],
                      ),
                    )
                  ],
                ),
              ),
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

class LoginButton extends StatefulWidget {
  LoginButton(this._buttonTitle);

  final String _buttonTitle;

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool isLoading = true;
  late BuildContext dialogContext;

  Future<void> CircularProgressWorking(BuildContext context0) async {
    try {
      print('${widget._buttonTitle}');
      switch (widget._buttonTitle) {
        case 'images/Google Button.png':
          await viewModel.FirebaseRepository().signInWithGoogle();
          print('images/Google Button.png');
          break;
        case 'images/btnG_아이콘원형.png':
          await viewModel.FirebaseRepository().signInWithNaver();
          print('images/btnG_아이콘원형.png');
          break;
        case 'images/Kakao Button.png':
          //await FirebaseRepository().kakaoSelectFriends(context);
          await viewModel.FirebaseRepository().kakaoLogin();
          print('images/Kakao Button.완료');
          break;
        case 'images/Apple ID Login Black.png':
          await viewModel.FirebaseRepository().signInWithApple();
          print('images/Apple ID Login Black.png');
          break;
      }
    } finally {
      // 비동기 작업이 끝나면 다이얼로그를 닫습니다.
      //Navigator.of(context).pop();
      setState(() {
        print('loading true');
        Navigator.of(dialogContext).pop();
      });
    }
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
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                child: Image.asset('${widget._buttonTitle}')),
          );
        });
  }
}
