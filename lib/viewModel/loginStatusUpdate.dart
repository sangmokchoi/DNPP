//import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


class LoginStatusUpdate with ChangeNotifier {

  String providerId = '';
  bool isLoggedIn = false;

  Future<void> updateProviderId(String newProviderId) async {

    providerId = newProviderId;
    print('updateProviderId 완료');
    notifyListeners();
  }

  Future logout() async {
    //await _socialLogin.logout();
    isLoggedIn = false;
    //user = null;

    switch (providerId) {
      case 'google.com':
        print('구글 로그아웃');
        break;
    }

    print('로그아웃 완료');
    notifyListeners();
  }

}
