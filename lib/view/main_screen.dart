import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/models/customAppointment.dart';
import 'package:dnpp/models/main_chartBasic.dart';
import 'package:dnpp/models/pingpongList.dart';
import 'package:dnpp/repository/launchUrl.dart';
import 'package:dnpp/repository/loadFromFirebase.dart';
import 'package:dnpp/view/profile_screen.dart';
import 'package:dnpp/viewModel/courtAppointmentUpdate.dart';
import 'package:dnpp/viewModel/loadingUpdate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:dnpp/widgets/map/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/userProfile.dart';
import '../repository/repository_loadData.dart';
import '../viewModel/loginStatusUpdate.dart';
import '../viewModel/othersPersonalAppointmentUpdate.dart';
import '../viewModel/profileUpdate.dart';
import '../widgets/chart/main_barChart.dart';

import '../viewModel/personalAppointmentUpdate.dart';
import '../widgets/chart/main_lineChart.dart';
import '../widgets/paging/main_bannerPage.dart';
import '../widgets/paging/main_chartPage.dart';
import '../widgets/paging/main_courtPage.dart';
import '../widgets/paging/main_graphs.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class MainScreen extends StatefulWidget {
  static String id = '/MainScreenID';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _imagePageController = PageController(initialPage: 0);
  final PageController _firstBarChartPageController = PageController();
  final PageController _secondBarChartPageController = PageController(
    viewportFraction: 0.90, // 보이는 영역의 비율 조절
  );
  final PageController _thirdBarChartPageController = PageController(
    viewportFraction: 0.90, // 보이는 영역의 비율 조절
  );

  late Future<void> myFuture;

  FirebaseFirestore db = FirebaseFirestore.instance;

  int _currentPersonal = 0;
  int _currentCourt = 0;

  int _indexPersonal = -1;
  int _indexCourt = -1;
  bool isPersonal = false;

  //bool isLoading = false;
  bool isRefresh = false;

  String _courtTitle = '';
  String _courtRoadAddress = '';

  Future<void> mainScreenMyFuture(BuildContext context) async {
    // setState(() {
    //   isLoading = true;
    //   print('isLoading: $isLoading');
    // });

    //Provider.of<LoadingUpdate>(context, listen: false)
    //    .downloadAllImages();

    //Provider.of<LoadingUpdate>(context, listen: false)
    //    .loadData(context, isPersonal, _courtTitle, _courtRoadAddress);
  }

  @override
  void dispose() {
    _firstBarChartPageController.dispose();
    _secondBarChartPageController.dispose();
    _thirdBarChartPageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _secondBarChartPageController.addListener(() async {

      final int newPage = _secondBarChartPageController.page?.round() ?? 0;

      if (newPage != _currentPersonal) {
        _currentPersonal = newPage;
        print('_currentPersonal: $_currentPersonal');
        //setState(() {
        // 요일 버튼 눌린 것이 초기화 되어야 함
        Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .resetSelectedList();
        //Provider.of<CourtAppointmentUpdate>(context, listen: false).resetSelectedList();
        //});

        if (_currentPersonal != 0) {
          _indexPersonal = _currentPersonal - 1;
          isPersonal = false;
          print('isMyTime: $isPersonal');
        } else {
          _indexPersonal = _currentPersonal;
          isPersonal = true;
          print('isMyTime: $isPersonal');
        }
        print('_currentPersonal index: $_indexPersonal');

        _courtTitle = Provider.of<ProfileUpdate>(context, listen: false)
                .userProfile
                .pingpongCourt?[_indexPersonal]
                .title ??
            '';
        _courtRoadAddress = Provider.of<ProfileUpdate>(context, listen: false)
                .userProfile
                .pingpongCourt?[_indexPersonal]
                .roadAddress ??
            '';

        // await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        //     .personalDaywiseDurationsCalculate(
        //         false, isPersonal, _courtTitle, _courtRoadAddress);
        // await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        //     .personalCountHours(
        //         false, isPersonal, _courtTitle, _courtRoadAddress);
        //
        // // Provider.of<AppointmentUpdate>(context, listen: false)
        // //     .updateRecentDays(0);
        //
        // setState(() {});
      }
    });

    _thirdBarChartPageController.addListener(() async {
      final int newPage = _thirdBarChartPageController.page?.round() ?? 0;

      if (newPage != _currentCourt) {
        _currentCourt = newPage;
        print('_currentCourt: $_currentCourt');
        //setState(() {
        // 요일 버튼 눌린 것이 초기화 되어야 함
        Provider.of<CourtAppointmentUpdate>(context, listen: false)
            .resetSelectedList();
        //Provider.of<CourtAppointmentUpdate>(context, listen: false).resetSelectedList();
        //});

        // if (_currentCourt != 0) {
        //   _indexCourt = _currentCourt - 1;
        //
        // } else {
        _indexCourt = _currentCourt;
        //}

        print('_currentCourt index: $_indexCourt');

        _courtTitle = Provider.of<ProfileUpdate>(context, listen: false)
                .userProfile
                .pingpongCourt?[_indexCourt]
                .title ??
            '';
        _courtRoadAddress = Provider.of<ProfileUpdate>(context, listen: false)
                .userProfile
                .pingpongCourt?[_indexCourt]
                .roadAddress ??
            '';

        // await Provider.of<CourtAppointmentUpdate>(context, listen: false)
        //     .courtDaywiseDurationsCalculate(
        //         false, false, _courtTitle, _courtRoadAddress);
        // await Provider.of<CourtAppointmentUpdate>(context, listen: false)
        //     .courtCountHours(false, false, _courtTitle, _courtRoadAddress);

        // Provider.of<AppointmentUpdate>(context, listen: false)
        //     .updateRecentDays(0);

        //setState(() {});
      }
    });

    super.initState(); // downloadAllImages()가 완료된 후에 initState()를 호출
  }

  @override
  Widget build(BuildContext context) {
    myFuture = mainScreenMyFuture(context);

    double width = MediaQuery.of(context).size.width;
    double height = width * 3 / 4;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            FutureBuilder<void>(
              future: myFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: width,
                    height: height,
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    Timer.periodic(Duration(seconds: 1), (timer) {
                      // if (_currentimage < imageList.length - 1) {
                      //   _currentimage++;
                      // } else {
                      //   _currentimage = 0;
                      // }

                      // _imagePageController.animateToPage(
                      //   _currentimage,
                      //   duration: Duration(seconds: 1),
                      //   curve: Curves.easeInOut,
                      // );
                    });
                  });
                  // CustomMaterialIndicator // onRefresh: refreshData,
                  return CustomMaterialIndicator(
                    //LoadData().fetchUserData(context)
                    onRefresh: () {
                      isRefresh = true;
                      return Provider.of<LoadingUpdate>(context, listen: false)
                          .loadData(context, isPersonal, _courtTitle,
                              _courtRoadAddress)
                          .whenComplete(() => setState(() {
                                _secondBarChartPageController.animateTo(
                                  _secondBarChartPageController
                                      .position.minScrollExtent,
                                  duration: Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );

                                _thirdBarChartPageController.animateTo(
                                  _thirdBarChartPageController
                                      .position.minScrollExtent,
                                  duration: Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                                isRefresh = false;
                              })); //LoadData().refreshData(context);
                    },
                    indicatorBuilder: (context, controller) {
                      return Icon(
                        Icons.refresh,
                        color: Colors.grey,
                        size: 30,
                      );
                    },
                    child: ListView(
                      children: [
                        MainBannerPageView(
                          pageController: _imagePageController,
                          width: width,
                          height: height,
                          imageMap:
                              Provider.of<LoadingUpdate>(context, listen: false)
                                  .imageMap,
                          urlMap:
                              Provider.of<LoadingUpdate>(context, listen: false)
                                  .urlMap,
                          refStringList:
                              Provider.of<LoadingUpdate>(context, listen: false)
                                  .refStringList,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 10),
                          child: SizedBox(
                            height: 30.0,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              controller: _firstBarChartPageController,
                              itemCount: Provider.of<PersonalAppointmentUpdate>(
                                      context,
                                      listen: false)
                                  .isSelectedString
                                  .length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 3.0, right: 3.0),
                                  child: Container(
                                    width: 115.0,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          //spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: Offset(0, 0.1),
                                        ),
                                      ],
                                    ),
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        print('OutlinedButton 클릭');
                                        setState(() {
                                          Provider.of<PersonalAppointmentUpdate>(
                                                  context,
                                                  listen: false)
                                              .updateChart(index);

                                          Provider.of<CourtAppointmentUpdate>(
                                                  context,
                                                  listen: false)
                                              .updateChart(index);
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide.none,
                                        foregroundColor:
                                            Provider.of<PersonalAppointmentUpdate>(
                                                        context,
                                                        listen: false)
                                                    .isSelected[index]
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.5),
                                        backgroundColor: Provider.of<
                                                        PersonalAppointmentUpdate>(
                                                    context,
                                                    listen: false)
                                                .isSelected[index]
                                            ? Colors.lightBlue.withOpacity(0.9)
                                            : Colors.lightBlue.withOpacity(0.5),
                                        shape: kRoundedRectangleBorder,
                                      ),
                                      child: Text(
                                        Provider.of<PersonalAppointmentUpdate>(
                                                context,
                                                listen: false)
                                            .isSelectedString[index],
                                        style: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ), // toggleButtons

                        // Consumer<CourtAppointmentUpdate>(
                        //   builder: (context, taskData, child) {
                        //     return BarChart(
                        //         individualBarDataCourt(),
                        //     );
                        //   },
                        // ) :
                        Consumer<PersonalAppointmentUpdate>(
                          builder: (context, taskData, child) {
                            return MainPersonalChartPageView(
                              pageController: _secondBarChartPageController,
                              currentPersonal: _currentPersonal,
                              indexPersonal: _indexPersonal,
                              courtTitle: _courtTitle,
                              courtRoadAddress: _courtRoadAddress,
                            );
                          },
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              '탁구장 방문 데이터',
                              style: kAppointmentTextStyle,
                            ),
                          ),
                        ),

                        // Consumer<CourtAppointmentUpdate>(
                        //   builder: (context, taskData, child) {
                        //     return BarChart(
                        //         individualBarDataCourt(),
                        //     );
                        //   },
                        // ) :
                        // Consumer<PersonalAppointmentUpdate>(
                        //   builder: (context, taskData, child) {
                        //       return BarChart(
                        //         individualBarDataPersonal(),
                        //     );
                        //   },
                        // );
                        // MainCourtChartPageView(
                        //     pageController: _thirdBarChartPageController
                        // ),
                        Consumer<CourtAppointmentUpdate>(
                          builder: (context, taskData, child) {
                            return MainCourtChartPageView(
                              pageController: _thirdBarChartPageController,
                              currentCourt: _currentCourt,
                              indexCourt: _indexCourt,
                              courtTitle: _courtTitle,
                              courtRoadAddress: _courtRoadAddress,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    width: width,
                    height: height,
                  );
                }
              },
            ),
            // if (isLoading) // 로딩 화면
            //   IgnorePointer(
            //     ignoring: isLoading,
            //     child: Container(
            //       color: Colors.black.withOpacity(0.5),
            //       // Semi-transparent black
            //       child: Center(
            //         child: isRefresh ? null : kCustomCircularProgressIndicator,
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
