import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/models/customAppointment.dart';
import 'package:dnpp/models/main_chartBasic.dart';
import 'package:dnpp/models/pingpongList.dart';
import 'package:dnpp/view/profile_screen.dart';
import 'package:dnpp/viewModel/courtAppointmentUpdate.dart';
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
  int _currentimage = 0;
  int _currentPersonal = 0;
  int _currentCourt = 0;

  int _indexPersonal = -1;
  int _indexCourt = -1;
  bool isPersonal = false;

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
                false, isPersonal, _courtTitle, _courtRoadAddress);
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .personalCountHours(
                false, isPersonal, _courtTitle, _courtRoadAddress);
        await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
            .personalDaywiseDurationsCalculate(
            false, isPersonal, _courtTitle, _courtRoadAddress);
        await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
            .personalCountHours(
            false, isPersonal, _courtTitle, _courtRoadAddress);

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

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    FirebaseAuth.instance.idTokenChanges()
        .listen((User? user) async {

      final SharedPreferences prefs = await _prefs;

      if (user == null) {
        // user == null
        print('SignupScreen user isNotLoggedIn');
        print('SignupScreen user: $user');
        print('신규유저 이므로 프로필 생성 필요 또는 로그아웃한 상태');
        await Provider.of<LoginStatusUpdate>(context, listen: false).falseIsLoggedIn();

      } else {
        // user != null
        print('SignupScreen user isLoggedIn');
        print('SignupScreen user: $user');

        //Provider.of<LoginStatusUpdate>(context, listen: false).currentUser = user;
        //Provider.of<LoginStatusUpdate>(context, listen: false).trueIsLoggedIn();
        Provider.of<LoginStatusUpdate>(context, listen: false)
            .updateCurrentUser(user);

        if (user.providerData.isNotEmpty) {
          //print('user.providerData.isNotEmpty');
          print(
              'SignupScreen user.providerData: ${user.providerData.first.providerId.toString()}');

          String providerId = user.providerData.first.providerId.toString();
          switch (providerId) {
            case 'google.com':
              print('구글로 로그인');
            case 'apple.com':
              print('애플로 로그인');
          }
          //Provider.of<LoginStatusUpdate>(context, listen: false).updateProviderId(user.providerData.first.providerId.toString());
        } else if (user.providerData.isEmpty) {
          print('카카오로 로그인한 상태');
          print('user.providerData.isEmpty');
        }

        // 이전에 유저 정보가 있으면, 로그아웃했다가 다시 들어온 유저로 인식하고, 프로필 설정 화면으로 보낼 필요가 없음
        final QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
            .collection("UserData")
            .where("uid", isEqualTo: user.uid)
            .get();
       // print('이전에 유저 정보가 있으면, 로그아웃했다가 다시 들어온 유저로 인식하고, 프로필 설정 화면으로 보낼 필요가 없음');
        print('querySnapshot: $querySnapshot');

        if (querySnapshot.docs.isNotEmpty) {
          // 문서가 존재하면 이전에 저장한 유저 정보가 있다고 판단
          print('문서가 존재하면 이전에 저장한 유저 정보가 있다고 판단 UserData exists for ${user.uid}');
          await Provider.of<LoginStatusUpdate>(context, listen: false).updateIsUserDataExists(true);
          //Provider.of<ProfileUpdate>(context, listen: false).updateUserProfile(docRef as UserProfile);
          await Provider.of<LoginStatusUpdate>(context, listen: false)
              .updateIsAgreementChecked(true);
          await Provider.of<LoginStatusUpdate>(context, listen: false).trueIsLoggedIn();

        } else {
          // 문서가 존재하지 않으면 이전에 저장한 유저 정보가 없다고 판단
          print('문서가 존재하지 않으면 이전에 저장한 유저 정보가 없다고 판단 No UserData for ${user.uid}');
          await Provider.of<LoginStatusUpdate>(context, listen: false).updateIsUserDataExists(false);
          await prefs.setBool('isUserTried', true);
           // 프로필 사진 가져올지 문의
          //await Provider.of<LoginStatusUpdate>(context, listen: false).falseIsLoggedIn();
          //print('이때, 유저에게 이용약관 동의 요청 필요');
          // if (Provider.of<LoginStatusUpdate>(context, listen: false).isLogInButtonClicked) { // 유저가 로그인 버튼을 눌렀을 떄를 인
          //   _showAgreementDialog(context);
          // }
          if (Provider.of<ProfileUpdate>(context, listen: false).userProfileUpdated == false) { // userprofile이 업데이트 되지 않았다면, 회원가입을 시도하는 것으로 간주
            await _showAgreementDialog(context);
          } else {
            Navigator.pop(context);
            print('Navigator.pop(context); 끝');
          }
        }

        // 로그인 버튼 클릭 여부 초기화
        await Provider.of<LoginStatusUpdate>(context, listen: false).updateIsLogInButtonClicked(false);

      }

      setState(() {
        print('main screen 로그인 버튼 클릭 여부 초기화 이후의 setstate');
      });

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

        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .personalDaywiseDurationsCalculate(
                false, isPersonal, _courtTitle, _courtRoadAddress);
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .personalCountHours(
                false, isPersonal, _courtTitle, _courtRoadAddress);

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

  Future<void> _showAgreementDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LoginStatusUpdate>(
            builder: (context, loginStatus, child) {
              return AlertDialog(
                insetPadding: EdgeInsets.only(left: 15.0, right: 15.0),
                shape: kRoundedRectangleBorder,
                title: Text('이용약관 및 개인정보 처리방침 동의'),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: Provider.of<LoginStatusUpdate>(context, listen: false)
                          .isAgreementChecked,
                      onChanged: (value) async {
                        await Provider.of<LoginStatusUpdate>(context, listen: false)
                            .toggleIsAgreementChecked();
                        // You can add any additional logic here if needed
                      },
                    ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black // 다크 모드일 때 텍스트 색상
                              : Colors.white,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: '(필수) '),
                          TextSpan(
                            text: '이용약관',
                            style: TextStyle(
                              color: kMainColor,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await _launchUrl('https://www.naver.com/');
                              },
                          ),
                          TextSpan(text: ' 및 '),
                          TextSpan(
                            text: '개인정보 처리방침',
                            style: TextStyle(
                              color: kMainColor,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await _launchUrl('https://www.naver.com/');
                              },
                          ),
                          TextSpan(text: '에\n동의합니다')
                        ],
                      ),
                    )
                  ],
                ),
                actions: [
                  Provider.of<LoginStatusUpdate>(context, listen: false)
                      .isAgreementChecked ==
                      true
                      ? TextButton(
                      style: kConfirmButtonStyle,
                      onPressed: () {
                        Navigator.pop(context);
                        _showProfilePictureAskDialog(context);
                      },
                      child: ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              '확인',
                              textAlign: TextAlign.center,
                              style: kTextButtonTextStyle,
                            ),
                          ),
                        ],
                      ))
                      : SizedBox.shrink()
                ],
              );
            });
      },
    );
  }
  Future<void> _showProfilePictureAskDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          shape: kRoundedRectangleBorder,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "알림",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
          content:
          Text(
            "소셜 로그인 계정에서 프로필 사진을 가져올까요?",
            textAlign: TextAlign.start,
          ),
          actions: [
            ButtonBar(
              alignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: kAlertDialogTextButtonWidth,
                  child: TextButton(
                    style: kCancelButtonStyle,
                    child: Text(
                      "아니오",
                      textAlign: TextAlign.center,
                      style: kTextButtonTextStyle,
                    ),
                    onPressed: () async {
                      await Provider.of<ProfileUpdate>(context, listen: false)
                          .updateIsGetImageUrl(false);
                      Navigator.pop(context);

                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: ProfileScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                        PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                ),
                Container(
                  width: kAlertDialogTextButtonWidth,
                  child: TextButton(
                    style: kConfirmButtonStyle,
                    child: Text(
                      "예",
                      textAlign: TextAlign.center,
                      style: kTextButtonTextStyle,
                    ),
                    onPressed: () async {
                      await Provider.of<ProfileUpdate>(context, listen: false)
                          .updateIsGetImageUrl(true);
                      Navigator.pop(context);

                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: ProfileScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                        PageTransitionAnimation.cupertino,
                      ).then((value) {
                        // This code will be executed when SignupScreen is popped.
                        setState(() {
                          print('로그인 완료 후 복귀 setState');
                        });
                      });
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
  Future<void> _launchUrl(String _url) async {
    print('_launchURL 진입');
    final Uri _newUrl = Uri.parse(_url);
    if (!await launchUrl(_newUrl)) {
      throw Exception('Could not launch $_newUrl');
    }
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
