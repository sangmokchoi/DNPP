
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
    //debugPrint('isLoggedInStream isLoggedIn: $isLoggedIn');

    //yield isLoggedIn;
    yield* RepositoryRealtimeUsers().getCheckIsCurrentUserInApp(currentUser.uid);
  }

  Future<void> updateIsAgreementChecked(bool value) async {
    isAgreementChecked = value;
    debugPrint('isAgreementChecked: $isAgreementChecked');
    notifyListeners();
  }

  Future<void> toggleIsAgreementChecked() async {
    isAgreementChecked = !isAgreementChecked;
    debugPrint('isAgreementChecked: $isAgreementChecked');
    notifyListeners();
  }

  Future<void> toggleIsUnderstood() async {
    isUnderstood = !isUnderstood;
    debugPrint('isUnderstood: $isUnderstood');
    notifyListeners();
  }

  Future<void> updateIsUserDataExists(bool value) async {
    isUserDataExists = value;
    debugPrint('isUserDataExists: $isUserDataExists');
    notifyListeners();
  }

  Future<void> updateIsLogInButtonClicked(bool value) async {
    isLogInButtonClicked = value;
    debugPrint('isLogInButtonClicked: $isLogInButtonClicked');
    notifyListeners();
  }

  Future<void> trueIsLoggedIn() async {
    isLoggedIn = true;
    notifyListeners();
    debugPrint('trueIsLoggedIn isLoggedIn: $isLoggedIn');
  }

  Future<void> falseIsLoggedIn() async {
    isLoggedIn = false;
    notifyListeners();
    debugPrint('falseIsLoggedIn isLoggedIn: $isLoggedIn');
  }

  Future<void> updateProviderId(String newProviderId) async {
    providerId = newProviderId;
    debugPrint('updateProviderId 완료');
    notifyListeners();
  }

  Future<void> updateCurrentUser(User newUser) async {
    currentUser = newUser;
    debugPrint('updatecurrentUser 완료');
    debugPrint('currentUser: $currentUser');
    notifyListeners();
  }

  Future<void> updateCurrentVisit(DateTime value) async {
    currentVisit = value;
    debugPrint('updateCurrentVisit 완료');
    debugPrint('currentVisit: $currentVisit');
    notifyListeners();
  }

}
