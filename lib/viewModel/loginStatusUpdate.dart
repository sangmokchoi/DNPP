//import 'dart:js_interop';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:dnpp/repository/repository_firebase.dart' as viewModel;


class LoginStatusUpdate with ChangeNotifier {

  late User currentUser;

  String providerId = '';
  bool isLoggedIn = false;

  Future<void> trueIsLoggedIn() async {
    isLoggedIn = true;
    print('isLoggedIn: $isLoggedIn');
    notifyListeners();
  }

  Future<void> falseIsLoggedIn() async {
    isLoggedIn = false;
    print('isLoggedIn: $isLoggedIn');
    notifyListeners();
  }

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

}
