//import 'dart:js_interop';

import 'package:dnpp/models/userProfile.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../widgets/map/map_pingpongList_element.dart';

class ProfileUpdate with ChangeNotifier {
  List<bool> genderIsSelected = <bool>[false, false, true];
  List<bool> playStyleIsSelected = <bool>[true, false];
  List<bool> rubberIsSelected = <bool>[false, false, false, true];
  List<bool> racketIsSelected = <bool>[false, false, false, true];

  late UserProfile userProfile;

  Future<void> updatUserProfile(UserProfile newProfile) async {
    userProfile = newProfile;
    print('userProfile.nickName: ${userProfile.nickName}');
    print('userProfile.gender: ${userProfile.gender}');
    print('userProfile.ageRange: ${userProfile.ageRange}');
    print('userProfile.playStyle: ${userProfile.playStyle}');
    print('userProfile.rubber: ${userProfile.rubber}');
    print('userProfile.racket: ${userProfile.racket}');
    notifyListeners();
  }

  void updateGenderIsSelected(int index) {
    if (index == 0) {
      genderIsSelected[0] = true;
      genderIsSelected[1] = false;
      genderIsSelected[2] = false;

    } else if (index == 1) {
      genderIsSelected[0] = false;
      genderIsSelected[1] = true;
      genderIsSelected[2] = false;
    } else if (index == 2) {
      genderIsSelected[0] = false;
      genderIsSelected[1] = false;
      genderIsSelected[2] = true;
    }
    notifyListeners();
  }

  void updatePlayStyleIsSelected(int index) {
    if (index == 0) {
      playStyleIsSelected[0] = true;
      playStyleIsSelected[1] = false;
    } else if (index == 1) {
      playStyleIsSelected[0] = false;
      playStyleIsSelected[1] = true;
    }
    notifyListeners();
  }

  void updateRubberIsSelected(int index) {
    if (index == 0) {
      rubberIsSelected[0] = true;
      rubberIsSelected[1] = false;
      rubberIsSelected[2] = false;
      rubberIsSelected[3] = false;
    } else if (index == 1) {
      rubberIsSelected[0] = false;
      rubberIsSelected[1] = true;
      rubberIsSelected[2] = false;
      rubberIsSelected[3] = false;
    } else if (index == 2) {
      rubberIsSelected[0] = false;
      rubberIsSelected[1] = false;
      rubberIsSelected[2] = true;
      rubberIsSelected[3] = false;
    } else if (index == 3) {
      rubberIsSelected[0] = false;
      rubberIsSelected[1] = false;
      rubberIsSelected[2] = false;
      rubberIsSelected[3] = true;
    }
    notifyListeners();
  }

  void updateRacketIsSelected(int index) {
    if (index == 0) {
      racketIsSelected[0] = true;
      racketIsSelected[1] = false;
      racketIsSelected[2] = false;
      racketIsSelected[3] = false;
    } else if (index == 1) {
      racketIsSelected[0] = false;
      racketIsSelected[1] = true;
      racketIsSelected[2] = false;
      racketIsSelected[3] = false;
    } else if (index == 2) {
      racketIsSelected[0] = false;
      racketIsSelected[1] = false;
      racketIsSelected[2] = true;
      racketIsSelected[3] = false;
    } else if (index == 3) {
      racketIsSelected[0] = false;
      racketIsSelected[1] = false;
      racketIsSelected[2] = false;
      racketIsSelected[3] = true;
    }
    notifyListeners();
  }
}
