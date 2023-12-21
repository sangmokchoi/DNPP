import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/models/customAppointment.dart';
import 'package:dnpp/models/main_chartBasic.dart';
import 'package:dnpp/models/pingpongList.dart';
import 'package:dnpp/viewModel/courtAppointmentUpdate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:dnpp/widgets/map/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/userProfile.dart';
import '../repository/repository_loadData.dart';
import '../viewModel/loginStatusUpdate.dart';
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
  int _currentimage = 0;
  int _currentPersonal = 0;
  int _currentCourt = 0;

  int _indexPersonal = -1;
  int _indexCourt = -1;
  bool isMyTime = false;

  Map<String?, Uint8List?> imageMap = {};
  Map<String?, String?> urlMap = {};
  Map<String, String> refStringList = {};

  int count = 0;

  late Future<void> myFuture;

  FirebaseFirestore db = FirebaseFirestore.instance;

  bool isLoading = false;
  bool isRefresh = false;

  String _courtTitle = '';
  String _courtRoadAddress = '';

  Future<void> downloadAllImages() async {
    setState(() {
      isLoading = true;
    });

    final gsReference =
        FirebaseStorage.instance.refFromURL("gs://dnpp-402403.appspot.com");

    Reference imageReference = gsReference.child("main_images");
    Reference urlReference = gsReference.child("main_urls");

    // ListResult의 items를 통해 해당 폴더에 있는 파일들을 가져옵니다.
    ListResult imageListResult = await imageReference.list();
    ListResult urlListResult = await urlReference.list();

    try {
      for (Reference imageRef in imageListResult.items) {
        try {
          print('imageRef.fullPath: ${imageRef.fullPath}');
          List<String> parts = imageRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('Result: $result');
          const oneMegabyte = 1024 * 1024;
          final Uint8List? imageData = await imageRef.getData(oneMegabyte);

          imageMap['$result'] = imageData;

          refStringList['$count'] = result;
          count++;
        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }

      for (Reference urlRef in urlListResult.items) {
        try {
          print('urlRef.fullPath: ${urlRef.fullPath}');
          List<String> parts = urlRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('Result: $result');

          final Uint8List? urlData = await urlRef.getData();
          // Assuming the content of the text file is UTF-8 encoded
          String? urlContent = utf8.decode(urlData!); // Convert bytes to string

          urlMap['$result'] = urlContent;
        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }
    } catch (e) {
      print("Error in downloadAllImages: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    print('downloadAllImages 완료');

    print('loadDoc 완료');
  }

  Future<void> loadData() async {
    try {
      await downloadAllImages();
      print('await downloadAllImages(); completed');

      if (Provider.of<LoginStatusUpdate>(context, listen: false).isLoggedIn) {
        await LoadData().fetchUserData(context);

        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .personalDaywiseDurationsCalculate(
                false, isMyTime, _courtTitle, _courtRoadAddress);
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .personalCountHours(
                false, isMyTime, _courtTitle, _courtRoadAddress);
        await Provider.of<CourtAppointmentUpdate>(context, listen: false)
            .courtDaywiseDurationsCalculate(
                false, false, _courtTitle, _courtRoadAddress);
        await Provider.of<CourtAppointmentUpdate>(context, listen: false)
            .courtCountHours(false, false, _courtTitle, _courtRoadAddress);

        setState(() {
          _secondBarChartPageController.animateTo(
            _secondBarChartPageController.position.minScrollExtent,
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );

          _thirdBarChartPageController.animateTo(
            _thirdBarChartPageController.position.minScrollExtent,
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        });

      } else {

      }
      print('await fetchUserData(); completed');
    } catch (e) {
      print(e);
    }

    isRefresh = false;
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
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        // user == null
        print('SignupScreen user isNotLoggedIn');
        print('SignupScreen user: $user');
        print('신규유저 이므로 프로필 생성 필요 또는 로그아웃한 상태');

        Provider.of<LoginStatusUpdate>(context, listen: false)
            .falseIsLoggedIn();
      } else {
        // user != null
        print('SignupScreen user isLoggedIn');
        print('SignupScreen user: $user');

        //Provider.of<LoginStatusUpdate>(context, listen: false).currentUser = user;
        Provider.of<LoginStatusUpdate>(context, listen: false).trueIsLoggedIn();
        Provider.of<LoginStatusUpdate>(context, listen: false)
            .updateCurrentUser(user);

        if (user.providerData.isNotEmpty) {
          //print('user.providerData.isNotEmpty');
          print(
              'SignupScreen user.providerData: ${user.providerData.first.providerId.toString()}');

          String providerId = user.providerData.first.providerId.toString();
          switch (providerId) {
            case 'google.com':
              return print('구글로 로그인');
            case 'apple.com':
              return print('애플로 로그인');
          }
          //Provider.of<LoginStatusUpdate>(context, listen: false).updateProviderId(user.providerData.first.providerId.toString());
        } else if (user.providerData.isEmpty) {
          print('카카오로 로그인한 상태');
          print('user.providerData.isEmpty');
        }

        // 이전에 유저 정보가 있으면, 로그아웃했다가 다시 들어온 유저로 인식하고, 프로필 설정 화면으로 보낼 필요가 없음
        final docRef = db.collection("UserData").doc(user.uid);
        DocumentSnapshot doc = await docRef.get();

        if (doc.exists) {
          // 문서가 존재하면 이전에 저장한 유저 정보가 있다고 판단
          print('문서가 존재하면 이전에 저장한 유저 정보가 있다고 판단 UserData exists for ${user.uid}');
          Provider.of<LoginStatusUpdate>(context, listen: false).updateIsUserDataExists(true);
        } else {
          // 문서가 존재하지 않으면 이전에 저장한 유저 정보가 없다고 판단
          print('문서가 존재하지 않으면 이전에 저장한 유저 정보가 없다고 판단 No UserData for ${user.uid}');
          Provider.of<LoginStatusUpdate>(context, listen: false).updateIsUserDataExists(false);
        }
      }
    });

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
          isMyTime = false;
          print('isMyTime: $isMyTime');
        } else {
          _indexPersonal = _currentPersonal;
          isMyTime = true;
          print('isMyTime: $isMyTime');
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

        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .personalDaywiseDurationsCalculate(
                false, isMyTime, _courtTitle, _courtRoadAddress);
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .personalCountHours(
                false, isMyTime, _courtTitle, _courtRoadAddress);

        // Provider.of<AppointmentUpdate>(context, listen: false)
        //     .updateRecentDays(0);
        setState(() {});
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

        await Provider.of<CourtAppointmentUpdate>(context, listen: false)
            .courtDaywiseDurationsCalculate(
                false, false, _courtTitle, _courtRoadAddress);
        await Provider.of<CourtAppointmentUpdate>(context, listen: false)
            .courtCountHours(false, false, _courtTitle, _courtRoadAddress);

        // Provider.of<AppointmentUpdate>(context, listen: false)
        //     .updateRecentDays(0);
        setState(() {});
      }
    });

    myFuture = loadData();
    super.initState(); // downloadAllImages()가 완료된 후에 initState()를 호출
  }

  @override
  Widget build(BuildContext context) {
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
                      return loadData(); //LoadData().refreshData(context);
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
                          imageMap: imageMap,
                          urlMap: urlMap,
                          refStringList: refStringList,
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
                                    width: 100.0,
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
                                      child: Text(Provider.of<
                                                  PersonalAppointmentUpdate>(
                                              context,
                                              listen: false)
                                          .isSelectedString[index]),
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
                                pageController: _secondBarChartPageController);
                          },
                        ),

                        // MainPersonalChartPageView(
                        //     pageController: _secondBarChartPageController
                        // ),
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
                                pageController: _thirdBarChartPageController);
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
            if (isLoading)
              IgnorePointer(
                ignoring: isLoading,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  // Semi-transparent black
                  child: Center(
                    child: isRefresh ? null : CircularProgressIndicator(),
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}
