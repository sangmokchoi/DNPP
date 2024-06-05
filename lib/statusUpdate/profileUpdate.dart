//import 'dart:js_interop';

import 'package:dnpp/models/pingpongList.dart';
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

  //List<PingpongList> pingpongList = [];

  ScrollController horizontalScrollController = ScrollController();

  bool isGetImageUrl = false;
  bool userProfileUpdated = false;

  // String name = '';
  // String id = '';
  // String email = '';
  // String imageUrl = '';

  //late UserProfile userProfile;
  UserProfile userProfile = UserProfile.emptyUserProfile;

  Future updateIsGetImageUrl(bool value) async {

    isGetImageUrl = value;
    debugPrint('isGetImageUrl: $isGetImageUrl');
    notifyListeners();
  }

  Future updateName(String value) async {

    userProfile.nickName = value;
    //name = value;
    debugPrint('userProfile.nickName: ${userProfile.nickName}');
    notifyListeners();
  }

  Future updateId(String value) async {

    userProfile.uid = value;
    debugPrint('userProfile.uid: ${userProfile.uid}');
    notifyListeners();
  }

  Future updateEmail(String value) async {
    userProfile.email = value;
    //email = value;
    debugPrint('userProfile.email: ${userProfile.email}');
    notifyListeners();
  }

  Future updateImageUrl(String value) async {
    userProfile.photoUrl = value;
    //imageUrl = value;
    debugPrint('userProfile.photoUrl: ${userProfile.photoUrl}');
    notifyListeners();
  }

  void scrollListView() {
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   // Introduce a small delay to ensure everything is ready
    //   Future.delayed(Duration(milliseconds: 200), () {
    //     if (horizontalScrollController.hasClients) {
    //       horizontalScrollController.animateTo(
    //         horizontalScrollController.position.maxScrollExtent,
    //         duration: Duration(milliseconds: 500),
    //         curve: Curves.easeInOut,
    //       );
    //     }
    //   });
    // });

    Future.delayed(
      Duration(milliseconds: 200),
      () {
        horizontalScrollController.animateTo(
          horizontalScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
    //notifyListeners();
  }

  Future<void> addPingpongList(PingpongList element) async {
    userProfile.pingpongCourt?.add(element);
    debugPrint('userProfile.pingpongCourt: ${userProfile.pingpongCourt}');
    notifyListeners();
  }

  Future<void> removeByIndexPingpongList(int index) async {
    userProfile.pingpongCourt?.removeAt(index);
    notifyListeners();
  }

  Future<void> removeByElementPingpongList(PingpongList element) async {
    userProfile.pingpongCourt?.remove(element);
    notifyListeners();
  }

  Future<void> updateUserProfile(UserProfile newProfile) async {
    //await updateUserProfileUpdated(true);
    userProfile = newProfile;
    notifyListeners();
    debugPrint('updateUserProfile userProfile: ${userProfile.uid}');
    debugPrint('updateUserProfile done');
  }

  Future<void> updateUserProfileUpdated(bool value) async {
    userProfileUpdated = value;
    notifyListeners();
    debugPrint('updateUserProfileUpdated userProfileUpdated: ${userProfileUpdated}');
    debugPrint('updateUserProfileUpdated userProfileUpdated done');
  }

  Future<void> resetUserProfile() async {
    userProfile = UserProfile.emptyUserProfile;
    notifyListeners();
    debugPrint('resetUserProfile done');
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

  Future<List<bool>> initializeGenderIsSelected(String gender) async {
    if (gender == '남') {
      genderIsSelected = [true, false, false];
    } else if (gender == '여') {
      genderIsSelected = [false, true, false];
    } else if (gender == '밝히지 않음') {
      genderIsSelected = [false, false, true];
    }
    //notifyListeners();
    return genderIsSelected;
  }

  Future<double> initializeAgeRange(String ageRange) async {
    int extractedIndex = UserProfile.ageRangeList.indexOf(ageRange);
    debugPrint('initializeAgeRange extractedIndex: ${extractedIndex}');
    return extractedIndex.toDouble();
  }

  Future<double> initializePlayedYears(String playedYears) async {
    debugPrint('playedYears: $playedYears');
    int extractedIndex = UserProfile.playedYearsList.indexOf(playedYears);
    debugPrint('initializePlayedYears extractedIndex: ${extractedIndex}');
    return extractedIndex.toDouble();
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

  Future<List<bool>> initializePlayStyleIsSelected(String playStyle) async {
    if (playStyle == '공격') {
      playStyleIsSelected = [true, false];
    } else if (playStyle == '수비') {
      playStyleIsSelected = [false, true];
    }
    //notifyListeners();
    return playStyleIsSelected;
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

  Future<List<bool>> initializeRubberIsSelected(String rubber) async {
    if (rubber == '평면') {
      rubberIsSelected = [true, false, false, false];
    } else if (rubber == '핌플') {
      rubberIsSelected = [false, true, false, false];
    } else if (rubber == '기타') {
      rubberIsSelected = [false, false, true, false];
    } else if (rubber == '미정') {
      rubberIsSelected = [false, false, false, true];
    }
    //notifyListeners();
    return rubberIsSelected;
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

  Future<List<bool>> initializeRacketIsSelected(String racket) async {
    if (racket == '펜홀더') {
      racketIsSelected = [true, false, false, false];
    } else if (racket == '쉐이크') {
      racketIsSelected = [false, true, false, false];
    } else if (racket == '중펜') {
      racketIsSelected = [false, false, true, false];
    } else if (racket == '미정') {
      racketIsSelected = [false, false, false, true];
    }
    //notifyListeners();
    return racketIsSelected;
  }
}


