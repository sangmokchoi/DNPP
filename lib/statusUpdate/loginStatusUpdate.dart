//import 'dart:js_interop';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:dnpp/repository/repository_auth.dart' as viewModel;


class LoginStatusUpdate with ChangeNotifier {

  bool isLoading = false;

  Future<void> updateIsLoaging(bool value) async {
    isLoading = value;
    notifyListeners();
  }

  late User currentUser;

  String providerId = '';
  bool isAgreementChecked = false;
  bool isLoggedIn = false;
  bool isLogInButtonClicked = false;
  bool isUserDataExists = false;

  Future<void> updateIsAgreementChecked(bool value) async {
    isAgreementChecked = value;
    print('isAgreementChecked: $isAgreementChecked');
    notifyListeners();
  }

  Future<void> toggleIsAgreementChecked() async {
    isAgreementChecked = !isAgreementChecked;
    print('isAgreementChecked: $isAgreementChecked');
    notifyListeners();
  }

  Future<void> updateIsUserDataExists(bool value) async {
    isUserDataExists = value;
    print('isUserDataExists: $isUserDataExists');
    notifyListeners();
  }

  Future<void> updateIsLogInButtonClicked(bool value) async {
    isLogInButtonClicked = value;
    print('isLogInButtonClicked: $isLogInButtonClicked');
    notifyListeners();
  }

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
