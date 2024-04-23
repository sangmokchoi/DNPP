
import 'package:dnpp/repository/firebase_realtime_users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:dnpp/LocalDataSource/DS_Local_auth.dart' as viewModel;

import '../LocalDataSource/firebase_realtime/users/DS_Local_isUserInApp.dart';


class LoginStatusUpdate with ChangeNotifier {

  bool isLoading = false;
  final auth = FirebaseAuth.instance;

  late User currentUser;

  String providerId = '';
  bool isAgreementChecked = false;
  bool isUnderstood = false;
  bool isLoggedIn = false;
  bool isLogInButtonClicked = false;
  bool isUserDataExists = false;
  DateTime currentVisit = DateTime.now();

  Stream<bool> isLoggedInStream() async* {
    //print('isLoggedInStream isLoggedIn: $isLoggedIn');

    //yield isLoggedIn;
    yield* RepositoryRealtimeUsers().getCheckIsCurrentUserInApp(currentUser.uid);
  }

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

  Future<void> toggleIsUnderstood() async {
    isUnderstood = !isUnderstood;
    print('isUnderstood: $isUnderstood');
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
    notifyListeners();
    print('trueIsLoggedIn isLoggedIn: $isLoggedIn');
  }

  Future<void> falseIsLoggedIn() async {
    isLoggedIn = false;
    notifyListeners();
    print('falseIsLoggedIn isLoggedIn: $isLoggedIn');
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

  Future<void> updateCurrentVisit(DateTime value) async {
    currentVisit = value;
    print('updateCurrentVisit 완료');
    print('currentVisit: $currentVisit');
    notifyListeners();
  }

}
