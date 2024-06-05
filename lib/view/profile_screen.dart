import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:dnpp/models/userProfile.dart';
import 'package:dnpp/repository/firebase_firestore_userData.dart';
import 'package:dnpp/view/map_screen.dart';
import 'package:dnpp/statusUpdate/profileUpdate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';
import '../models/launchUrl.dart';
import '../models/locationData.dart';

import '../models/moveToOtherScreen.dart';
import '../models/pingpongList.dart';
import '../statusUpdate/googleAnalytics.dart';
import '../LocalDataSource/firebase_fireStore/DS_Local_userData.dart';
import '../statusUpdate/CurrentPageProvider.dart';
import '../statusUpdate/loginStatusUpdate.dart';
import '../statusUpdate/mapWidgetUpdate.dart';

import 'package:sizer/sizer.dart';

class ProfileScreen extends StatefulWidget {
  static String id = '/ProfileScreenID';

  ProfileScreen({
    required this.isSignup,
  });

  bool isSignup;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    _viewVerticalScrollController.addListener(() {
      if (_viewVerticalScrollController.offset /
          MediaQuery.sizeOf(context).height >
          0.15) {
        setState(() {
          scrollDouble = true;
        });
      } else {
        setState(() {
          scrollDouble = false;
        });
      }
    });
    _nickNameTextFormFieldController.addListener(() {});
    _selfIntroductionTextFormFieldController.addListener(() {});

    initialize();
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    // });
    randomNumber = Random().nextInt(5) + 1;

    debugPrint('프로필 이닛 스테이츠');

    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      // Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
      //     .startTimer('SettingScreen');
      // await Provider.of<CurrentPageProvider>(context, listen: false)
      //     .setCurrentPage('ProfileScreen');
      // await GoogleAnalytics().trackScreen(context, 'ProfileScreen');
    });
  }

  @override
  void dispose() {
    _viewVerticalScrollController.dispose();
    _nickNameTextFormFieldController.dispose();
    _locationTextFormFieldController.dispose();

    debugPrint('profile 디스포스!!!');
    super.dispose();
  }

  // List<PingpongList> _pingpongList = [];
  // List<String> newProfile.address = [];

  @override
  Widget build(BuildContext context) {
    Color sectionColor = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).colorScheme.background
        : ThemeData.dark().colorScheme.background;

    return PopScope(
      onPopInvoked: (_) {
        FocusScope.of(context).unfocus();
        // Future.microtask(() {
        //   Provider.of<GoogleAnalyticsNotifier>(context,
        //       listen: false)
        //       .startTimer('ProfileScreen');
        // });
      },
      child: Consumer<ProfileUpdate>(
          builder: (context, profileUpdate, child) {
          return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                key: const ValueKey("ProfileScreen"),
                appBar: AppBar(
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  leading: TextButton(
                    onPressed: () async {
                      // 첫 회원 가입 시에 뒤로를 클릭하게 되면, userprofile을 초기화 해야 함

                      if (!Provider.of<LoginStatusUpdate>(context, listen: false)
                          .isLoggedIn) {
                        LaunchUrl().alertOkAndCancelFunc(
                            context,
                            '알림',
                            '회원가입을 정말 취소하시겠습니까?',
                            '아니오',
                            '예',
                            Colors.red,
                            kMainColor, () {
                          Navigator.pop(context);
                        }, () async {
                          try {
                            await FirebaseAuth.instance.signOut().then((value) async {
                              await profileUpdate.resetUserProfile();
                              debugPrint('FirebaseAuth.instance.signOut 성공');

                              // Future.microtask(() {
                              //   Provider.of<GoogleAnalyticsNotifier>(context,
                              //           listen: false)
                              //       .startTimer('ProfileScreen');
                              // }).then((value) {
                              //   Navigator.pop(context);
                              // });
                              Navigator.pop(context);

                            });
                          } catch (error) {
                            debugPrint('FirebaseAuth.instance.signOut 실패: $error');

                            // Future.microtask(() {
                            //   Provider.of<GoogleAnalyticsNotifier>(context,
                            //           listen: false)
                            //       .startTimer('ProfileScreen');
                            // }).then((value) {
                            //   Navigator.pop(context);
                            // });
                            Navigator.pop(context);
                          }
                        });
                      } else {

                        LaunchUrl().alertOkAndCancelFunc(context, '알림', '변경사항이 저장되지 않습니다\n정말 프로필 수정 화면에서 나가시겠습니까?', '아니오', '예', kMainColor, kMainColor, () {
                          Navigator.pop(context);
                        }, () async {
                          final mapWidgetUpdate =
                          Provider.of<MapWidgetUpdate>(context, listen: false);

                          if (mapWidgetUpdate.pPListElements.isNotEmpty) {
                            await mapWidgetUpdate.clearPPListElements();
                          }

                          // Future.microtask(() {
                          //   Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
                          //       .startTimer('ProfileScreen');
                          // }).then((value) {
                          //   Navigator.pop(context);
                          // });
                          Navigator.pop(context);
                        });


                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '뒤로',
                          style: kElevationButtonStyle,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    '프로필 설정',
                    style: kAppointmentTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    if (scrollDouble)
                      TextButton(
                        onPressed: () async {
                          await uploadProfile(context);
                        },
                        child: Text('저장', style: kElevationButtonStyle
                            //     .copyWith(
                            //   color: kMainColor.withOpacity(0.3)
                            // ),
                            ),
                      )
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //   child: Icon(
                    //       Icons.arrow_downward,
                    //     //color: kMainColor,
                    //   ),
                    // ),
                  ],
                ),
                body: SingleChildScrollView(
                  controller: _viewVerticalScrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 35.0),
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AbsorbPointer(
                          absorbing: false, //isEditing ? false : true,
                          //isEditing == true이면, AbsorbPointer는 false여야 수정 가능
                          child: buildProfilePhoto(),
                        ), // 유저 프로필 사진
                        AbsorbPointer(
                          absorbing: false, //isEditing ? false : true,
                          //isEditing == true이면, AbsorbPointer는 false여야 수정 가능
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0,
                                        bottom: 10.0,
                                        left: 20.0,
                                        right: 20.0),
                                    child: Text(
                                      '자기소개',
                                      style: kAppointmentTextStyle,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 0.0),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            //spreadRadius: 3,
                                            blurRadius: 3,
                                            offset: Offset(3, 3),
                                          ),
                                        ],
                                        color: sectionColor,
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(10.0))),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0, right: 25.0, bottom: 0.0),
                                          child: TextFormField(
                                            autocorrect: false,
                                            enableSuggestions: false,
                                            // style: TextStyle(
                                            //   fontSize: 20.0
                                            // ),
                                            controller:
                                                _nickNameTextFormFieldController,
                                            maxLength: 15,
                                            decoration: const InputDecoration(
                                              labelText: '닉네임 (필수)',
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey), // 밑줄 색상
                                              ),
                                              hintText: '15자 이내',
                                              // hintStyle: TextStyle(
                                              //   fontSize: 14.0
                                              // ),
                                              // enabledBorder: const OutlineInputBorder(
                                              //   borderSide: BorderSide(color: Colors.red, width: 1.0),
                                              //   borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                              // ),
                                              // focusedBorder: const OutlineInputBorder(
                                              //   //borderSide: BorderSide(color: Colors.black, width: 2.0),
                                              //   borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                              // ),
                                            ),
                                          ),
                                        ),
                                        // 닉네임
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0, right: 25.0, bottom: 5.0),
                                          child: TextFormField(
                                            autocorrect: false,
                                            enableSuggestions: false,
                                            // style: TextStyle(
                                            //     fontSize: 20.0
                                            // ),
                                            controller:
                                                _selfIntroductionTextFormFieldController,
                                            maxLength: 30,
                                            decoration: const InputDecoration(
                                              labelText: '자기소개',
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey), // 밑줄 색상
                                              ),
                                              hintText: '15자 이내',
                                              // hintStyle: TextStyle(
                                              //     fontSize: 14.0
                                              // ),
                                              // enabledBorder: const OutlineInputBorder(
                                              //   borderSide: BorderSide(color: Colors.red, width: 1.0),
                                              //   borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                              // ),
                                              // focusedBorder: const OutlineInputBorder(
                                              //   //borderSide: BorderSide(color: Colors.black, width: 2.0),
                                              //   borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                              // ),
                                            ),
                                          ),
                                        ),
                                        // 자기소개
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25.0, vertical: 10.0),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text('성별',
                                                    style: kProfileTextStyle),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ToggleButtons(
                                                      borderRadius:
                                                          BorderRadius.circular(4.0),
                                                      color: kMainColor,
                                                      selectedColor: kMainColor,
                                                      isSelected: profileUpdate.genderIsSelected,
                                                      constraints: BoxConstraints(
                                                        minHeight: 40.0,
                                                        minWidth: _buttonwidth(
                                                            context,
                                                            profileUpdate
                                                                .genderIsSelected
                                                                .length),
                                                      ),
                                                      onPressed: (index) async {
                                                        setState(() {
                                                          profileUpdate
                                                              .updateGenderIsSelected(
                                                                  index);
                                                          newProfile.gender =
                                                              UserProfile
                                                                  .genderList[index];
                                                        });
                                                      },
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .genderList[0]),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .genderList[1]),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .genderList[2]),
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 성별
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25.0, vertical: 5.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('연령대',
                                                      style: kProfileTextStyle),
                                                  Text(
                                                      '${UserProfile.ageRangeList[_currentAgeRangeSliderValue.toInt()]}',
                                                      style: kProfileTextStyle),
                                                ],
                                              ),
                                              SliderTheme(
                                                data: SliderThemeData(
                                                  thumbColor:
                                                      Theme.of(context).primaryColor,
                                                  activeTrackColor: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.7),
                                                  inactiveTrackColor:
                                                      Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.3),
                                                  showValueIndicator:
                                                      ShowValueIndicator
                                                          .never, // 슬라이더의 썸의 색상
                                                ),
                                                child: Slider(
                                                  value: _currentAgeRangeSliderValue,
                                                  min: 0.0,
                                                  max: UserProfile.ageRangeList.length
                                                          .toDouble() -
                                                      1,
                                                  divisions: UserProfile
                                                          .ageRangeList.length
                                                          .toInt() -
                                                      1,
                                                  label:
                                                      '${UserProfile.ageRangeList[_currentAgeRangeSliderValue.toInt()]}',
                                                  onChanged: (double value) {
                                                    debugPrint("$value");
                                                    setState(() {
                                                      _currentAgeRangeSliderValue =
                                                          value;
                                                      newProfile
                                                          .ageRange = UserProfile
                                                              .ageRangeList[
                                                          _currentAgeRangeSliderValue
                                                              .toInt()];
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 연령대
                                      ],
                                    ),
                                  ),
                                ],
                              ), // 개인정보
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20.0,
                                        bottom: 10.0,
                                        left: 20.0,
                                        right: 20.0),
                                    child: Text(
                                      '어느 지역에 주로 계시나요?',
                                      style: kAppointmentTextStyle,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    padding: EdgeInsets.only(bottom: 15.0, top: 10.0),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            //spreadRadius: 3,
                                            blurRadius: 3,
                                            offset: Offset(3, 3),
                                          ),
                                        ],
                                        color: sectionColor,
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(10.0))),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0, right: 25.0, top: 0.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text('활동 탁구장',
                                                      style: kProfileTextStyle),
                                                  SizedBox(width: 5.0),
                                                  Text('(최대 5개)',
                                                      style: kProfileSubTextStyle),
                                                ],
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  debugPrint(MapScreen.id);
                                                  await MoveToOtherScreen().initializeGASetting(
                                                      context, 'MapScreen').then((value) async {

                                                    await Navigator.pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                MapScreen()
                                                                  //pingpongList: newProfile.pingpongCourt,
                                                                //),
                                                        ),
                                                            (route) => true).then((resultFromMapScreen) async {

                                                      await MoveToOtherScreen().initializeGASetting(
                                                          context, 'ProfileScreen').then((value) {
                                                        // 받은 데이터 출력
                                                        debugPrint('resultFromMapScreen: $resultFromMapScreen');
                                                        setState(() {
                                                          newProfile.pingpongCourt = resultFromMapScreen;
                                                        });

                                                      });
                                                    });
                                                  });

                                                },
                                                child: Text(
                                                  '추가',
                                                  style: kElevationButtonStyle.copyWith(

                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 활동 탁구장 (최대 5개) 추가
                                        Padding(
                                          padding: newProfile.pingpongCourt!.isEmpty
                                              ? EdgeInsets.zero
                                              : EdgeInsets.only(
                                                  left: 0.0,
                                                  right: 0.0,
                                                  top: 5.0,
                                                  bottom: 10.0),
                                          child: newProfile.pingpongCourt!.isEmpty
                                              ? Container(
                                                  height: 50.0,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '데이터 없음',
                                                    style:
                                                        kProfileSubTextStyle.copyWith(
                                                            color: Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness.light
                                                                ? Colors.black
                                                                : Colors.grey),
                                                  ),
                                                )
                                              : Container(
                                                  height: 35.0,
                                                  alignment: Alignment.centerLeft,
                                                  child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    //controller: _SecondHorizontalScrollController,
                                                    shrinkWrap: true,
                                                    itemCount: newProfile
                                                        .pingpongCourt?.length,
                                                    itemBuilder: (context, index) {
                                                      var padding = EdgeInsets.zero;

                                                      if (index == 0) {
                                                        padding = EdgeInsets.only(
                                                            left: 20.0);
                                                      } else if (index ==
                                                          newProfile.pingpongCourt!
                                                                  .length -
                                                              1) {
                                                        padding = EdgeInsets.only(
                                                            right: 20.0);
                                                      }

                                                      return Padding(
                                                        padding: padding,
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.centerRight,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.only(
                                                                  right: 7.0),
                                                              padding:
                                                                  EdgeInsets.only(
                                                                      left: 10.0,
                                                                      right: 5.0,
                                                                      top: 5.0,
                                                                      bottom: 5.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color:
                                                                        kMainColor),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    newProfile
                                                                        .pingpongCourt![
                                                                            index]
                                                                        .title,
                                                                    style: TextStyle(
                                                                        color:
                                                                            kMainColor),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 24.0,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                debugPrint(
                                                                    'IconButton 클릭');

                                                                LaunchUrl().alertOkAndCancelFunc(
                                                                    context,
                                                                    '선택한 탁구장을 삭제할까요?',
                                                                    '삭제를 원한다면\n확인 버튼을 클릭해주세요',
                                                                    '취소',
                                                                    '확인',
                                                                    kMainColor,
                                                                    kMainColor, () {
                                                                  Navigator.pop(
                                                                      context);
                                                                }, () {
                                                                  //Navigator.pop(context);
                                                                  setState(() {
                                                                    debugPrint(
                                                                        'profileUpdate.userProfile: ${profileUpdate.userProfile.pingpongCourt}');

                                                                    newProfile
                                                                        .pingpongCourt
                                                                        ?.removeAt(
                                                                            index);
                                                                    debugPrint(
                                                                        'PprofileUpdate.userProfile: ${profileUpdate.userProfile.pingpongCourt}');
                                                                    // profileUpdate
                                                                    //     .removeByIndexPingpongList(
                                                                    //         index);
                                                                  });
                                                                });
                                                              },
                                                              icon: Icon(
                                                                CupertinoIcons
                                                                    .clear_circled,
                                                                color: Colors.grey,
                                                              ),
                                                              style: ButtonStyle(
                                                                padding:
                                                                    MaterialStateProperty
                                                                        .all(EdgeInsets
                                                                            .zero),
                                                              ),
                                                              iconSize:
                                                                  18.0, // IconButton의 크기 설정
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                        ),
                                        // 탁구장 등록 리스트
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0, right: 25.0, top: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text('활동 지역',
                                                      style: kProfileTextStyle),
                                                  SizedBox(width: 5.0),
                                                  Text('읍/면/동까지 입력 (최대 3개)',
                                                      style: kProfileSubTextStyle),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 활동 지역 Text
                                        Padding(
                                          padding: newProfile.address.isEmpty
                                              ? EdgeInsets.zero
                                              : EdgeInsets.only(top: 10.0),
                                          child: newProfile.address.isEmpty
                                              ? null
                                              : Container(
                                                  height: 35.0,
                                                  alignment: Alignment.centerLeft,
                                                  child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    //reverse: true,
                                                    controller:
                                                        _FirstHorizontalScrollController,
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        newProfile.address.length,
                                                    itemBuilder: (context, index) {
                                                      var padding = EdgeInsets.zero;
                                                      //debugPrint('index: $index');

                                                      //debugPrint('pickedLocationList.length: ${pickedLocationList.length}');

                                                      if (index == 0) {
                                                        padding = EdgeInsets.only(
                                                            left: 20.0);
                                                      }
                                                      if (index ==
                                                          newProfile.address.length -
                                                              1) {
                                                        padding = EdgeInsets.only(
                                                            right: 20.0);
                                                      }
                                                      if (newProfile.address
                                                              .length ==
                                                          1) {
                                                        padding = EdgeInsets.only(
                                                            left: 20.0);
                                                      }
                                                      return Padding(
                                                        padding: padding,
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.centerRight,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.only(
                                                                  right: 7.0),
                                                              padding:
                                                                  EdgeInsets.only(
                                                                      left: 10.0,
                                                                      right: 5.0,
                                                                      top: 5.0,
                                                                      bottom: 5.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color:
                                                                        kMainColor),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    newProfile.address[
                                                                        index],
                                                                    style: TextStyle(
                                                                        color:
                                                                            kMainColor),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 24.0,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            //SizedBox(width: 5.0,),

                                                            IconButton(
                                                              onPressed: () {
                                                                LaunchUrl().alertOkAndCancelFunc(
                                                                    context,
                                                                    '선택한 지역을 삭제할까요?',
                                                                    '삭제를 원한다면\n확인 버튼을 클릭해주세요',
                                                                    '취소',
                                                                    '확인',
                                                                    kMainColor,
                                                                    kMainColor, () {
                                                                  Navigator.pop(
                                                                      context);
                                                                }, () {
                                                                  //Navigator.pop(context);
                                                                  setState(() {
                                                                    String
                                                                        deleteLocation =
                                                                        newProfile.address[
                                                                            index];
                                                                    newProfile.address
                                                                        .remove(
                                                                            deleteLocation);
                                                                  });
                                                                });
                                                              },
                                                              icon: Icon(
                                                                CupertinoIcons
                                                                    .clear_circled,
                                                                color: Colors.grey,
                                                              ),
                                                              style: ButtonStyle(
                                                                padding:
                                                                    MaterialStateProperty
                                                                        .all(EdgeInsets
                                                                            .zero),
                                                              ),
                                                              iconSize:
                                                                  18.0, // IconButton의 크기 설정
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                        ),
                                        // 등록된 활동 지역
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25.0, vertical: 10.0),
                                          child: TextFormField(
                                            autocorrect: false,
                                            enableSuggestions: false,
                                            controller:
                                                _locationTextFormFieldController,
                                            decoration: InputDecoration(
                                              hintText: '예) 신사동, 흥업면',
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey), // 밑줄 색상
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(Icons.clear),
                                                onPressed: clearTextField,
                                              ),
                                            ),
                                            onChanged: (text) {
                                              setState(() {
                                                if (text == '') {
                                                  filteredRegions.clear();
                                                  debugPrint('text == 111');
                                                } else {
                                                  pickedLocation = text;
                                                  filteredRegions = LocationData()
                                                      .address
                                                      .where((region) =>
                                                          region.contains(text))
                                                      .toList();
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        // 활동 지역 텍스트필드 // 화순 혜화동
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              20.0, 0.0, 20.0, 5.0),
                                          child: Container(
                                            child: filteredRegions.isEmpty
                                                ? Center(
                                                    child: Container(
                                                      child: Text('검색한 결과가 없습니다'),
                                                    ),
                                                  ) // filteredRegions가 비어있을 경우 아무것도 나타나지 않도록 합니다.
                                                : Scrollbar(
                                                    controller:
                                                        _addressVerticalScrollController,
                                                    trackVisibility: false,
                                                    child: Container(
                                                      constraints: BoxConstraints(
                                                          minHeight: 0.0,
                                                          maxHeight: 150),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0)),
                                                      ),
                                                      child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        controller:
                                                            _addressVerticalScrollController,
                                                        shrinkWrap: true,
                                                        padding: EdgeInsets.only(
                                                            bottom: 0.0),
                                                        // 여기를 추가 또는 수정합니다.
                                                        itemCount:
                                                            filteredRegions.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Column(
                                                            children: [
                                                              Stack(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                children: [
                                                                  ListTile(
                                                                    title: Text(
                                                                        filteredRegions[
                                                                            index]),
                                                                    onTap: () {
                                                                      Future.delayed(
                                                                        Duration(
                                                                            milliseconds:
                                                                                200),
                                                                        () {
                                                                          _FirstHorizontalScrollController
                                                                              .animateTo(
                                                                            _FirstHorizontalScrollController
                                                                                .position
                                                                                .maxScrollExtent,
                                                                            duration: Duration(
                                                                                milliseconds:
                                                                                    500),
                                                                            curve: Curves
                                                                                .easeInOut,
                                                                          );
                                                                        },
                                                                      );

                                                                      pickedLocation =
                                                                          filteredRegions[
                                                                              index];

                                                                      if (!newProfile.address
                                                                          .contains(
                                                                              pickedLocation)) {
                                                                        if (newProfile.address
                                                                                .length <
                                                                            3) {
                                                                          _locationTextFormFieldController
                                                                                  .text =
                                                                              pickedLocation;

                                                                          newProfile.address
                                                                              .add(
                                                                                  pickedLocation);

                                                                          // filteredRegions = LocationData()
                                                                          //     .address
                                                                          //     .where((region) =>
                                                                          //         region.contains(
                                                                          //             pickedLocation))
                                                                          //     .toList();


                                                                        } else {
                                                                          debugPrint(
                                                                              '활동 지역 등록은 총 3개까지만 가능합니다.');

                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return AlertDialog(
                                                                                insetPadding: EdgeInsets.only(
                                                                                    left: 10.0,
                                                                                    right: 10.0),
                                                                                shape:
                                                                                    kRoundedRectangleBorder,
                                                                                title:
                                                                                    Text(
                                                                                  "알림",
                                                                                  textAlign:
                                                                                      TextAlign.center,
                                                                                ),
                                                                                content:
                                                                                    Text(
                                                                                  "활동 지역 등록은\n총 3개까지만 가능합니다",
                                                                                  textAlign:
                                                                                      TextAlign.center,
                                                                                ),
                                                                                actions: [
                                                                                  ButtonBar(
                                                                                    alignment: MainAxisAlignment.center,
                                                                                    // mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      Container(
                                                                                        width: kAlertDialogTextButtonWidth,
                                                                                        child: TextButton(
                                                                                          style: kConfirmButtonStyle,
                                                                                          child: Text(
                                                                                            "확인",
                                                                                            textAlign: TextAlign.center,
                                                                                            style: kTextButtonTextStyle,
                                                                                          ),
                                                                                          onPressed: () async {
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            },
                                                                          );
                                                                        }
                                                                      } else {
                                                                        debugPrint(
                                                                            '이미 선택된 위치입니다.');

                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return AlertDialog(
                                                                              insetPadding: EdgeInsets.only(
                                                                                  left:
                                                                                      10.0,
                                                                                  right:
                                                                                      10.0),
                                                                              shape:
                                                                                  kRoundedRectangleBorder,
                                                                              title:
                                                                                  Text(
                                                                                "이미 선택된 지역입니다",
                                                                                textAlign:
                                                                                    TextAlign.center,
                                                                              ),
                                                                              content:
                                                                                  Text(
                                                                                "다른 지역을 선택해주세요",
                                                                                textAlign:
                                                                                    TextAlign.center,
                                                                              ),
                                                                              actions: [
                                                                                ButtonBar(
                                                                                  alignment:
                                                                                      MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Container(
                                                                                      width: kAlertDialogTextButtonWidth,
                                                                                      child: ElevatedButton(
                                                                                        style: kConfirmButtonStyle,
                                                                                        child: Text(
                                                                                          "확인",
                                                                                          textAlign: TextAlign.center,
                                                                                          style: kTextButtonTextStyle,
                                                                                        ),
                                                                                        onPressed: () async {
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                      }

                                                                      setState(() {
                                                                        _locationTextFormFieldController
                                                                            .text = '';
                                                                      });
                                                                    },
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                8.0),
                                                                    child: Icon(
                                                                      Icons
                                                                          .arrow_forward_ios_rounded,
                                                                      size: 15,
                                                                    ),
                                                                  ),
                                                                  if (index ==
                                                                      filteredRegions
                                                                              .length -
                                                                          1)
                                                                    Positioned(
                                                                      bottom: 0.0,
                                                                      left: 0.0,
                                                                      right: 0.0,
                                                                      child:
                                                                          Container(
                                                                        height: 10,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft:
                                                                                  Radius.circular(
                                                                                      10.0),
                                                                              bottomRight:
                                                                                  Radius.circular(10.0)),
                                                                          gradient:
                                                                              LinearGradient(
                                                                            colors: [
                                                                              Colors
                                                                                  .grey
                                                                                  .withOpacity(0.2),
                                                                              // 시작 색상
                                                                              Colors
                                                                                  .grey
                                                                                  .withOpacity(0.0),
                                                                              // 끝 색상 (투명)
                                                                            ],
                                                                            begin: Alignment
                                                                                .bottomCenter,
                                                                            end: Alignment
                                                                                .topCenter,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                ],
                                                              ),
                                                              if (index !=
                                                                  filteredRegions
                                                                          .length -
                                                                      1)
                                                                Divider(
                                                                  height: 1,
                                                                  color: Colors.grey
                                                                      .withOpacity(
                                                                          0.3),
                                                                ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        // 활동 지역 검색 결과
                                      ],
                                    ),
                                  ),
                                ],
                              ), // 어느 지역에서 활동하시나요?
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20.0,
                                        bottom: 10.0,
                                        left: 20.0,
                                        right: 20.0),
                                    child: Text(
                                      '어떤 탁구 스타일이세요?',
                                      style: kAppointmentTextStyle,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 0.0),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            //spreadRadius: 3,
                                            blurRadius: 3,
                                            offset: Offset(3, 3),
                                          ),
                                        ],
                                        color: sectionColor,
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(10.0))),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25.0, vertical: 10.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('경력',
                                                      style: kProfileTextStyle),
                                                  Text(
                                                      UserProfile.playedYearsList[
                                                          _currentPlayedYearsSliderValue
                                                              .toInt()],
                                                      style: kProfileTextStyle),
                                                ],
                                              ),
                                              SliderTheme(
                                                data: SliderThemeData(
                                                  thumbColor:
                                                      Theme.of(context).primaryColor,
                                                  activeTrackColor: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.7),
                                                  inactiveTrackColor:
                                                      Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.3),
                                                  showValueIndicator:
                                                      ShowValueIndicator.never,
                                                ),
                                                child: Slider(
                                                  value:
                                                      _currentPlayedYearsSliderValue,
                                                  min: 0.0,
                                                  max: UserProfile
                                                          .playedYearsList.length
                                                          .toDouble() -
                                                      1,
                                                  divisions: UserProfile
                                                          .playedYearsList.length
                                                          .toInt() -
                                                      1,
                                                  label: UserProfile.playedYearsList[
                                                      _currentPlayedYearsSliderValue
                                                          .toInt()],
                                                  onChanged: (double value) {
                                                    setState(() {
                                                      _currentPlayedYearsSliderValue =
                                                          value;
                                                      newProfile
                                                          .playedYears = UserProfile
                                                              .playedYearsList[
                                                          _currentPlayedYearsSliderValue
                                                              .toInt()];
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 경력
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25.0, vertical: 10.0),
                                          child: Column(
                                            children: [
                                              Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text('플레이 스타일',
                                                      style: kProfileTextStyle)),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ToggleButtons(
                                                      borderRadius:
                                                          BorderRadius.circular(4.0),
                                                      color: kMainColor,
                                                      selectedColor: kMainColor,
                                                      isSelected:
                                                      profileUpdate
                                                              .playStyleIsSelected,
                                                      constraints: BoxConstraints(
                                                        minHeight: 40.0,
                                                        minWidth: _buttonwidth(
                                                            context,
                                                            profileUpdate
                                                                .playStyleIsSelected
                                                                .length),
                                                      ),
                                                      onPressed: (index) async {
                                                        setState(() {
                                                          profileUpdate
                                                              .updatePlayStyleIsSelected(
                                                                  index);
                                                          newProfile.playStyle =
                                                              UserProfile
                                                                      .playStyleList[
                                                                  index];
                                                        });
                                                      },
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .playStyleList[0]),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .playStyleList[1]),
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 플레이 스타일
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25.0, vertical: 10.0),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text('러버',
                                                    style: kProfileTextStyle),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ToggleButtons(
                                                      borderRadius:
                                                          BorderRadius.circular(4.0),
                                                      color: kMainColor,
                                                      selectedColor: kMainColor,
                                                      isSelected:
                                                      profileUpdate
                                                              .rubberIsSelected,
                                                      constraints: BoxConstraints(
                                                        minHeight: 40.0,
                                                        minWidth: _buttonwidth(
                                                            context,
                                                            profileUpdate
                                                                .rubberIsSelected
                                                                .length),
                                                      ),
                                                      onPressed: (index) async {
                                                        setState(() {
                                                          profileUpdate
                                                              .updateRubberIsSelected(
                                                                  index);
                                                          newProfile.rubber =
                                                              UserProfile
                                                                  .rubberList[index];
                                                        });
                                                      },
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .rubberList[0]),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .rubberList[1]),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .rubberList[2]),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .rubberList[3]),
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 러버
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25.0, vertical: 10.0),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text('라켓',
                                                    style: kProfileTextStyle),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ToggleButtons(
                                                      borderRadius:
                                                          BorderRadius.circular(4.0),
                                                      color: kMainColor,
                                                      selectedColor: kMainColor,
                                                      isSelected:
                                                      profileUpdate
                                                              .racketIsSelected,
                                                      constraints: BoxConstraints(
                                                        minHeight: 40.0,
                                                        minWidth: _buttonwidth(
                                                            context,
                                                            profileUpdate
                                                                .racketIsSelected
                                                                .length),
                                                      ),
                                                      onPressed: (index) async {
                                                        setState(() {
                                                          profileUpdate
                                                              .updateRacketIsSelected(
                                                                  index);
                                                          newProfile.racket =
                                                              UserProfile
                                                                  .racketList[index];
                                                        });
                                                      },
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .racketList[0]),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .racketList[1]),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .racketList[2]),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal: 8.0),
                                                          child: Text(UserProfile
                                                              .racketList[3]),
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 라켓
                                      ],
                                    ),
                                  ),
                                ],
                              ), // 어떤 탁구 스타일이세요?
                              SizedBox(
                                height: 5.0,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    // newProfile.pingpongCourt = _pingpongList;
                                    // newProfile.address = _pickedLocationList;
                                    await uploadProfile(context);
                                  },
                                  child: Text('저장'))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        }
      ),
    );
  }

  bool isEditing = false;

  late User _currentUser;

  final auth = FirebaseAuth.instance;

  double _currentAgeRangeSliderValue = 0.0;
  double _currentPlayedYearsSliderValue = 0.0;

  TextEditingController _nickNameTextFormFieldController =
      TextEditingController();
  TextEditingController _selfIntroductionTextFormFieldController =
      TextEditingController();
  TextEditingController _locationTextFormFieldController =
      TextEditingController();

  ScrollController _FirstHorizontalScrollController = ScrollController();
  ScrollController _SecondHorizontalScrollController = ScrollController();
  ScrollController _viewVerticalScrollController = ScrollController();
  ScrollController _addressVerticalScrollController =
      ScrollController(); // 주소 vertical 컨트롤러

  FirebaseFirestore db = FirebaseFirestore.instance;

  XFile? _image; //이미지를 담을 변수 선언
  final ImagePicker picker = ImagePicker();

  String dropdownValue = LocationData().regions.first;
  List<String> filteredRegions = [];
  String pickedLocation = '';

  String userPhotoUrl = '';

  int randomNumber = 0;

  bool scrollDouble = false;

  UserProfile newProfile = UserProfile(
      uid: '',
      email: '',
      nickName: '',
      selfIntroduction: '',
      photoUrl:
          'https://firebasestorage.googleapis.com/v0/b/dnpp-402403.appspot.com/o/main_images%2FSimonwork_profile.png?alt=media&token=0222c22b-8380-4398-955e-44a3d6da23a2',
      gender: UserProfile.genderList[2],
      ageRange: UserProfile.ageRangeList[0],
      playedYears: UserProfile.playedYearsList[0],
      address: [],
      pingpongCourt: [],
      playStyle: UserProfile.playStyleList[0],
      rubber: UserProfile.rubberList[3],
      racket: UserProfile.racketList[3]);

  Future<void> uploadProfile(BuildContext context) async {
    if (newProfile.nickName.isEmpty &&
        _nickNameTextFormFieldController.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                shape: kRoundedRectangleBorder,
                title: Text(
                  "알림",
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  "닉네임을 입력해주세요",
                  textAlign: TextAlign.center,
                ),
                actions: [
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: kAlertDialogTextButtonWidth,
                        child: TextButton(
                          style: kConfirmButtonStyle,
                          child: Text(
                            "확인",
                            textAlign: TextAlign.center,
                            style: kTextButtonTextStyle,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ]);
          });
    } else {
      //toggleLoading(true, context);

      await LaunchUrl().alertOkAndCancelFunc(context, '프로필 저장',
          '위 내용을 토대로 프로필을 저장합니다', '취소', '확인', kMainColor, kMainColor, () {
        toggleLoading(false, context);
      }, () async {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return Center(
              child: kCustomCircularProgressIndicator, // 로딩 바 표시
            );
          },
        );

//updateUserProfile
//           profileUpdate
//               .userProfile
//               .pingpongCourt = newProfile.pingpongCourt;

        newProfile.uid = _currentUser.uid;
        newProfile.nickName = _nickNameTextFormFieldController.text;
        newProfile.selfIntroduction =
            _selfIntroductionTextFormFieldController.text;

        var imageName = _currentUser.uid;
        var storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_photos/$imageName.jpg');

        //userPhotoUrl
        if (_image == null && userPhotoUrl == '') {
          final gsReference = FirebaseStorage.instance.refFromURL(
              "gs://dnpp-402403.appspot.com/profile_photos/empty_profile_${randomNumber}.png");
          final imageUrl = await gsReference.getDownloadURL();
          debugPrint('imageUrl: $imageUrl');
          newProfile.photoUrl = imageUrl.toString();
        } else if (_image != null && userPhotoUrl != '') {
          String filePath = _image!.path;
          debugPrint('filePath: $filePath');
          debugPrint('_image: $_image');
          File file = File(filePath);

          var uploadTask = storageRef.putFile(file);
          var downloadUrl = await (await uploadTask).ref.getDownloadURL();
          debugPrint('downloadUrl: $downloadUrl');
          newProfile.photoUrl = downloadUrl.toString();
        }

        await Provider.of<ProfileUpdate>(context, listen: false).updateUserProfile(newProfile);

        await RepositoryFirestoreUserData()
            .getSetProfile(_currentUser.uid, newProfile)
            .then((value) async {
          await GoogleAnalytics().setAnalyticsUserProfile(context,
              Provider.of<ProfileUpdate>(context, listen: false).userProfile);
        });

        // if (Provider.of<ProfileUpdate>(context, listen: false).userProfile != UserProfile.emptyUserProfile) {
        //   await GoogleAnalytics().setAnalyticsUserProfile(context, Provider.of<ProfileUpdate>(context, listen: false).userProfile);
        // } // 수정된 프로필로 애널리틱스 사용자 속성 업데이트

        await RepositoryFirestoreUserData()
            .getFetchUserData(context)
            .then((value) async {
          //setState(() {
          isEditing = false;
          //});

          _viewVerticalScrollController.animateTo(
            0.0,
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );

          await Provider.of<LoginStatusUpdate>(context, listen: false)
              .trueIsLoggedIn();
          // debugPrint('profile screen 저장 버튼 클릭');

          String message = '';

          if (widget.isSignup == true) {
            message = '회원가입이 완료되었습니다';
            debugPrint('회원가입이 완료되었습니다');
          } else {
            message = '수정이 완료되었습니다';
            debugPrint('수정이 완료되었습니다');
          }

          LaunchUrl().alertFunc(context, '알림', message, '확인', () {
            //setState(() {
            //toggleLoading(false, context);

            //Navigator.of(context, rootNavigator: true).pop();

            if (message == '수정이 완료되었습니다') {
              Navigator.pop(context);

              toggleLoading(false, context);
              Navigator.pop(context);

              //toggleLoading(false, context);
            } else if (message != '수정이 완료되었습니다') {
              Navigator.pop(context);

              toggleLoading(false, context);
              Navigator.pop(context);

              toggleLoading(false, context);
            }

            //});
          });
        });
      });
    }
  }

  Future<void> initialize() async {
    _currentUser =
        Provider.of<LoginStatusUpdate>(context, listen: false).currentUser;

    UserProfile? currentUserProfile =
        Provider.of<ProfileUpdate>(context, listen: false).userProfile;

    if (Provider.of<ProfileUpdate>(context, listen: false).userProfileUpdated !=
        false) {

      //newProfile = currentUserProfile;
      newProfile = UserProfile.copy(currentUserProfile);

      debugPrint('userProfile이 서버에 등록된 경우');

      _nickNameTextFormFieldController.text = newProfile.nickName;
      _selfIntroductionTextFormFieldController.text =
          newProfile.selfIntroduction;
      newProfile.email = _currentUser.email ?? '';

      await Provider.of<ProfileUpdate>(context, listen: false)
          .initializeGenderIsSelected(newProfile.gender);

      _currentAgeRangeSliderValue =
          await Provider.of<ProfileUpdate>(context, listen: false)
              .initializeAgeRange(newProfile.ageRange);
      debugPrint(
          'profile screen initialize() _currentAgeRangeSliderValue: ${_currentAgeRangeSliderValue}');

      debugPrint('newProfile.playedYears: ${newProfile.playedYears}');

      _currentPlayedYearsSliderValue =
          await Provider.of<ProfileUpdate>(context, listen: false)
              .initializePlayedYears(newProfile.playedYears);
      debugPrint(
          'profile screen initialize() _currentPlayedYearsSliderValue: ${_currentPlayedYearsSliderValue}');

      await Provider.of<ProfileUpdate>(context, listen: false)
          .initializePlayStyleIsSelected(newProfile.playStyle);
      await Provider.of<ProfileUpdate>(context, listen: false)
          .initializeRubberIsSelected(newProfile.rubber);
      await Provider.of<ProfileUpdate>(context, listen: false)
          .initializeRacketIsSelected(newProfile.racket);

      userPhotoUrl = newProfile.photoUrl;

    } else {
      // 여기서 newProfile을 미선언하거나 기본값으로 초기화할 수 있습니다.
      debugPrint('userProfile이 서버에 등록되지 않은 경우');

      //_image = XFile(Provider.of<ProfileUpdate>(context, listen: false).imageUrl);
      _nickNameTextFormFieldController.text =
          Provider.of<ProfileUpdate>(context, listen: false)
              .userProfile
              .nickName;

      if (_nickNameTextFormFieldController.text == '' ||
          _nickNameTextFormFieldController.text == null) {
        _selfIntroductionTextFormFieldController.text = '안녕하세요';
      } else {
        _selfIntroductionTextFormFieldController.text =
            '안녕하세요, ${_nickNameTextFormFieldController.text}입니다';
      }

      debugPrint(
          'if 문 이전 isGetImageUrl: ${Provider.of<ProfileUpdate>(context, listen: false).isGetImageUrl}');

      if (Provider.of<ProfileUpdate>(context, listen: false).isGetImageUrl ==
          true) {
        userPhotoUrl = Provider.of<ProfileUpdate>(context, listen: false)
            .userProfile
            .photoUrl;
        newProfile.photoUrl = Provider.of<ProfileUpdate>(context, listen: false)
            .userProfile
            .photoUrl;
      }

      debugPrint(
          'if 문 이후 isGetImageUrl: ${Provider.of<ProfileUpdate>(context, listen: false).isGetImageUrl}');

      newProfile.email = Provider.of<ProfileUpdate>(context, listen: false)
              .userProfile
              .email ??
          '';

      debugPrint('_image: ${_image}');
      debugPrint('userPhotoUrl: ${userPhotoUrl}');

    }

    setState(() {});
  }

  double _buttonwidth(BuildContext context, int buttoncount) {
    //final maxwidth = 80.0;
    final width = (MediaQuery.sizeOf(context).width - 80) / buttoncount;
    return width;

    // if (width < maxwidth) {
    //   return width;
    // } else {
    //   return maxwidth;
    // }
  }

  //이미지를 가져오는 함수
  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장
      });
    }
  }

  Widget buildProfilePhoto() {
    return Stack(
      children: [
        Positioned(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: (userPhotoUrl !=
                    '') //(_image != null) || (userPhotoUrl != '')
                ? Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(40.0)),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: (_image != null)
                              ? FileImage(File(_image!.path))
                              : NetworkImage(newProfile.photoUrl)
                                  as ImageProvider<Object>, //,
                        ) //가져온 이미지를 화면에 띄워주는 코드
                        ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                            'images/empty_profile_${randomNumber}.png'),
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 50,
          left: 60,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              CupertinoIcons.pencil,
              size: 40,
            ),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                    shape: kRoundedRectangleBorder,
                    title: Text("프로필 수정", textAlign: TextAlign.center),
                    content: Text(
                      "프로필 사진 변경을 위한 방법을\n선택해주세요",
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: kAlertDialogTextButtonWidth,
                            child: TextButton(
                              style: kConfirmButtonStyle,
                              child: Text(
                                "카메라 촬영",
                                textAlign: TextAlign.center,
                                style: kTextButtonTextStyle,
                              ),
                              onPressed: () async {
                                getImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Container(
                            width: kAlertDialogTextButtonWidth,
                            child: TextButton(
                              style: kConfirmButtonStyle,
                              child: Text(
                                "사진첩 선택",
                                textAlign: TextAlign.center,
                                style: kTextButtonTextStyle,
                              ),
                              onPressed: () async {
                                getImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void toggleLoading(bool isLoading, BuildContext context) {
    //setState(() {
    if (isLoading) {
      // 로딩 바를 화면에 표시
      debugPrint('profileScreen 로딩 바를 화면에 표시');
      showDialog(
        context: context,
        builder: (inFunccontext) {
          return Center(
            child: kCustomCircularProgressIndicator, // 로딩 바 표시
          );
        },
      );
    } else {
      debugPrint('로딩 바 제거');
      //Navigator.pop(context);
      Navigator.of(context, rootNavigator: true).pop();
    }
    //});
  }

  void clearTextField() {
    setState(() {
      filteredRegions.clear();
      _locationTextFormFieldController.clear();
    });
  }
}
