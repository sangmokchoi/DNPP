//import 'dart:js_interop';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:dnpp/repository/repository_firebase.dart' as viewModel;


class LoginStatusUpdate with ChangeNotifier {

  String providerId = '';
  bool isLoggedIn = false;
  late User currentUser;

  Future<void> updateProviderId(String newProviderId) async {

    providerId = newProviderId;
    print('updateProviderId 완료');
    notifyListeners();
  }

  Future<void> updateCurrentUser(User newUser) async {

    currentUser = newUser;
    print('updatecurrentUser 완료');
    print('currentUser: $currentUser');
    notifyListeners();
  }

  Future logout() async {
    //await _socialLogin.logout();
    isLoggedIn = false;
    //user = null;

    await viewModel.FirebaseRepository().signOut();

    // switch (providerId) {
    //   case 'google.com':
    //     print('구글 로그아웃');
    //     break;
    // }

    print('로그아웃 완료');
    notifyListeners();
  }

}
