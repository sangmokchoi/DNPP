import 'dart:async';
import 'package:dnpp/models/userProfile.dart';
import 'package:dnpp/view/profile_screen.dart';
import 'package:dnpp/view/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/statusUpdate/courtAppointmentUpdate.dart';
import 'package:dnpp/statusUpdate/loadingUpdate.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_Announcement.dart';
import '../models/launchUrl.dart';
import '../models/moveToOtherScreen.dart';
import '../repository/firebase_realtime_users.dart';
import '../statusUpdate/googleAnalytics.dart';
import '../statusUpdate/CurrentPageProvider.dart';
import '../statusUpdate/loginStatusUpdate.dart';
import '../statusUpdate/profileUpdate.dart';
import '../statusUpdate/personalAppointmentUpdate.dart';
import '../viewModel/MainScreen_ViewModel.dart';
import '../widgets/paging/main_personalChartPage.dart';
import '../widgets/paging/main_courtChartPage.dart';

class MainScreen extends StatefulWidget {
  static String id = '/MainScreenID';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final PageController _imagePageController = PageController(initialPage: 0);
  int _currentImage = 0;

  final PageController _firstBarChartPageController = PageController();
  final PageController _secondBarChartPageController = PageController(
    viewportFraction: 0.90, // 보이는 영역의 비율 조절
  );
  final PageController _thirdBarChartPageController = PageController(
    viewportFraction: 0.90, // 보이는 영역의 비율 조절
  );

  TextEditingController _textEditingController = TextEditingController();

  late Future<bool> myFuture;

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

  late MainScreenViewModel viewModel;

  Timer? _timer;
  final Duration _timerDuration = Duration(seconds: 7);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startTimer();
    } else {
      _timer?.cancel();
    }
  }

  void startTimer() {
    _timer = Timer.periodic(_timerDuration, (timer) {

      if (Provider.of<LoadingUpdate>(context, listen: false)
          .refStringListMain
          .length > 1) {

        if (_currentImage < Provider
            .of<LoadingUpdate>(context, listen: false)
            .refStringListMain
            .length -
            1) {
          _currentImage++;
        } else {
          _currentImage = 0;
        }

        _imagePageController.animateToPage(
          _currentImage,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );

      }
    });
  }

  @override
  void initState() {
    _secondBarChartPageController.addListener(() async {
      final int newPage = _secondBarChartPageController.page?.round() ?? 0;

      if (newPage != _currentPersonal) {
        _currentPersonal = newPage;
        print('_currentPersonal: $_currentPersonal');

        // 요일 버튼 눌린 것이 초기화 되어야 함
        Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .resetSelectedList();

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
      }
    });
    _thirdBarChartPageController.addListener(() async {
      final int newPage = _thirdBarChartPageController.page?.round() ?? 0;

      if (newPage != _currentCourt) {
        _currentCourt = newPage;
        print('_currentCourt: $_currentCourt');

        // 요일 버튼 눌린 것이 초기화 되어야 함
        Provider.of<CourtAppointmentUpdate>(context, listen: false)
            .resetSelectedList();

        _indexCourt = _currentCourt;

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
      }
    });

    viewModel = Provider.of<MainScreenViewModel>(context, listen: false);
    myFuture = calculateConfirmTime();

    super.initState(); // downloadAllImages()가 완료된 후에 initState()를 호출

    WidgetsBinding.instance!.addObserver(this);

    startTimer();
  }

  @override
  void dispose() {
    _firstBarChartPageController.dispose();
    _secondBarChartPageController.dispose();
    _thirdBarChartPageController.dispose();

    WidgetsBinding.instance!.removeObserver(this);
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // final currentPageProvider = Provider.of<CurrentPageProvider>(context, listen: false);
    // currentPageProvider.setCurrentPage('MainScreen');

    WidgetsBinding.instance!.addPostFrameCallback((_) async {

      try {
        _secondBarChartPageController.jumpToPage(0);
        _thirdBarChartPageController.jumpToPage(0);
      } catch (e) {
        print('jumpToPage: $e');
      }

      if (Provider.of<ProfileUpdate>(context, listen: false).userProfile != UserProfile.emptyUserProfile) {
        await GoogleAnalytics().setAnalyticsUserProfile(context, Provider.of<ProfileUpdate>(context, listen: false).userProfile);
      }
      await Provider.of<CurrentPageProvider>(context, listen: false).setCurrentPage('MainScreen');
      await GoogleAnalytics().trackScreen(context, 'MainScreen');

      // Timer.periodic(Duration(seconds: 7), (timer) {
      //
      //   _currentImage = _imagePageController.page!.toInt();
      //   if (Provider.of<LoadingUpdate>(context, listen: false)
      //       .refStringListMain
      //       .length > 1 ){
      //
      //     if (_currentImage <
      //         Provider.of<LoadingUpdate>(context, listen: false)
      //             .refStringListMain
      //             .length -
      //             1) {
      //       _currentImage++;
      //     } else {
      //       _currentImage = 0;
      //     }
      //
      //     _imagePageController.animateToPage(
      //       _currentImage,
      //       duration: Duration(seconds: 1),
      //       curve: Curves.easeInOut,
      //     );
      //
      //   }
      //
      // });
    });

    double width = MediaQuery.of(context).size.width;
    double height = width * 3 / 4;

    Color sectionColor = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).colorScheme.background
        : ThemeData.dark().colorScheme.background;

    return Consumer<MainScreenViewModel>(
      builder: (context, mainScreenViewModel, child) {
        return SafeArea(
          child: Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0,
                centerTitle: false,
                titleTextStyle: kAppbarTextStyle,
                title: Text(
                  'Home',
                  style: Theme.of(context).brightness == Brightness.light
                      ? TextStyle(color: Colors.black)
                      : TextStyle(color: Colors.white),
                ),
                 backgroundColor: Colors.transparent,
                elevation: 0.0,
                actions: [
                  TextButton(
                    child: Text('이용안내'),
                    onPressed: () async {

                      await viewModel.updateHowToUseCurrentPage(0);
                      await viewModel.updateIsHowToUseVisible();
                    },
                  ),
                  TextButton(
                    child: Text('공지사항'),
                      onPressed: () async {
                        await viewModel.updateAnnouncementCurrentPage(0);
                        await viewModel.updateIsAdBannerVisible();
                      },
                  ),
                  // TextButton(
                  //   onPressed: () => throw Exception(),
                  //   child: const Text("Throw Test Exception"),
                  // ),
                  TextButton(
                    onPressed: () {

                    },
                    child: const Text("Device Info"),
                  ),
                ],
              ),
            //   body: CustomMaterialIndicator(
            // onRefresh: () {
            //   isRefresh = true;
            //   return Provider.of<LoadingUpdate>(context, listen: false)
            //       .loadData(context, isPersonal, _courtTitle, _courtRoadAddress)
            //       .whenComplete(() => setState(() {
            //             _secondBarChartPageController.animateTo(
            //               _secondBarChartPageController.position.minScrollExtent,
            //               duration: Duration(milliseconds: 250),
            //               curve: Curves.easeInOut,
            //             );
            //
            //             _thirdBarChartPageController.animateTo(
            //               _thirdBarChartPageController.position.minScrollExtent,
            //               duration: Duration(milliseconds: 250),
            //               curve: Curves.easeInOut,
            //             );
            //             isRefresh = false;
            //           })); //LoadData().refreshData(context);
            // },
            // indicatorBuilder: (context, controller) {
            //   return Icon(
            //     Icons.refresh,
            //     color: kMainColor,
            //     size: 30,
            //   );
            // },
            // child: Stack(
            body: Stack(
              children: [
                ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 0.0),
                      child: Container(
                        height: height, // or any desired height
                        width: width, // 4:3 aspect ratio
                        child: PageView.builder(
                          controller: _imagePageController,
                          itemCount:
                              Provider.of<LoadingUpdate>(context, listen: false)
                                  .refStringListMain
                                  .length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {

                                // await GoogleAnalytics().bannerClickEvent(
                                //     context,
                                //     'mainScreen',
                                //     index,
                                //     Provider.of<LoadingUpdate>(context, listen: false).urlMapMain[
                                //     Provider.of<LoadingUpdate>(
                                //         context,
                                //         listen: false).refStringListMain['$index']
                                //     ]!);

                                await GoogleAnalytics().bannerClickEvent(
                                    context,
                                    'mainScreen',
                                    index,
                                    Provider.of<LoadingUpdate>(
                                        context,
                                        listen: false).refStringListMain['$index']!,
                                    Provider.of<LoadingUpdate>(context, listen: false).urlMapMain[
                                    Provider.of<LoadingUpdate>(
                                        context,
                                        listen: false).refStringListMain['$index']
                                    ]!);

                                //await GoogleAnalytics().setUserProperty(context, "name0", "value0");

                                await LaunchUrl().myLaunchUrl(
                                    "${Provider.of<LoadingUpdate>(context, listen: false).urlMapMain[Provider.of<LoadingUpdate>(context, listen: false).refStringListMain['$index']]}");

                                },
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(Provider.of<LoadingUpdate>(
                                                    context,
                                                    listen: false)
                                                .imageMapMain[
                                            Provider.of<LoadingUpdate>(context,
                                                    listen: false)
                                                .refStringListMain['$index']] ??
                                        Uint8List(0)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ), // 광고 배너

                    Container(
                      margin: EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 5.0),
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
                      child: (FirebaseAuth.instance.currentUser != null) ?
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 15.0, left: 15.0),
                                  child: Text(
                                    '반갑습니다, ${Provider.of<ProfileUpdate>(context,
                                        listen: false)
                                        .userProfile
                                        .nickName} 님',
                                    style: kAppointmentTextStyle.copyWith(
                                      fontSize: 20.0
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.0,),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0, right: 15.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    await MoveToOtherScreen()
                                        .persistentNavPushNewScreen(
                                        context,
                                        ProfileScreen(
                                          isSignup: false,
                                        ),
                                        false,
                                        PageTransitionAnimation.cupertino);
                                  },
                                    child: Icon(Icons.arrow_right_alt, size: 20.0, ),),
                              ),

                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 5.0, left: 15.0, right: 15.0),
                            child: Text.rich(
                                TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '경력 ',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${Provider.of<ProfileUpdate>(context,
                                            listen: false)
                                            .userProfile.playedYears}\n',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      TextSpan(
                                        text: '스타일 ',
                                        style: TextStyle(
                                          fontSize: 14.0,

                                        ),
                                      ),
                                      TextSpan(
                                        text: '${Provider.of<ProfileUpdate>(context,
                                            listen: false)
                                            .userProfile.playStyle}  ',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' 라켓 ',
                                        style: TextStyle(
                                          fontSize: 14.0,

                                        ),
                                      ),
                                      TextSpan(
                                        text: '${Provider.of<ProfileUpdate>(context,
                                            listen: false)
                                            .userProfile.racket}  ',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' 러버 ',
                                        style: TextStyle(
                                          fontSize: 14.0,

                                        ),
                                      ),
                                      TextSpan(
                                        text: '${Provider.of<ProfileUpdate>(context,
                                            listen: false)
                                            .userProfile.rubber}',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ]
                                )
                            ),
                          ), // 스펙
                          Padding(
                            padding:
                            const EdgeInsets.only(top: 10.0, bottom: 5.0, left: 15.0, right: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '활동 탁구장   ',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 26,
                                              //margin: EdgeInsets.only(top: 5.0, bottom: 0.0),
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: (Provider.of<ProfileUpdate>(context,
                                                      listen: false)
                                                      .userProfile.pingpongCourt?.length != 0) ? Provider.of<ProfileUpdate>(context,
                                                      listen: false)
                                                      .userProfile.pingpongCourt?.length : 1,
                                                  itemBuilder: (itemBuilder, index) {
                                                    var padding =
                                                        EdgeInsets.zero;

                                                    if (index ==
                                                        0) {
                                                      padding = EdgeInsets.only(left: 0.0);
                                                    } else if (index ==
                                                        Provider.of<ProfileUpdate>(context, listen: false).pingpongList.length - 1) {
                                                      padding = EdgeInsets.only(right: 0.0);
                                                    }

                                                    if (Provider.of<ProfileUpdate>(context,
                                                        listen: false)
                                                        .userProfile.pingpongCourt?.length != 0) { // 활동 탁구장이 있는 경우,
                                                      return Padding(
                                                        padding: padding,
                                                        child: Container(
                                                            margin: EdgeInsets.only(right: 7.0),
                                                            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0, bottom: 3.0),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: kMainColor),
                                                              borderRadius: BorderRadius.circular(20.0),
                                                            ),
                                                            child: Text('${Provider.of<ProfileUpdate>(context,
                                                                listen: false)
                                                                .userProfile.pingpongCourt?[index].title}',
                                                              style: TextStyle(color: kMainColor, fontSize: 12.0),)),
                                                      );
                                                    } else { //활동 탁구장이 없는 경우,
                                                      return Center(
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              '활동 탁구장을 추가해주세요 ',
                                                              style: TextStyle(color: Colors.grey,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                await MoveToOtherScreen()
                                                                    .persistentNavPushNewScreen(
                                                                    context,
                                                                    ProfileScreen(
                                                                      isSignup: false,
                                                                    ),
                                                                    false,
                                                                    PageTransitionAnimation.cupertino);
                                                              },
                                                              child: Icon(Icons.add_circle_outline, size: 15, color: kMainColor,),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }

                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '활동 지역   ',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 26,
                                              //margin: EdgeInsets.only(top: 5.0, bottom: 0.0),
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: (Provider.of<ProfileUpdate>(context,
                                                      listen: false)
                                                      .userProfile.address?.length != 0) ? Provider.of<ProfileUpdate>(context,
                                                      listen: false)
                                                      .userProfile.address?.length : 1,
                                                  itemBuilder: (itemBuilder, index) {
                                                    var padding =
                                                        EdgeInsets.zero;

                                                    if (index ==
                                                        0) {
                                                      padding = EdgeInsets.only(left: 0.0);
                                                    } else if (index ==
                                                        Provider.of<ProfileUpdate>(context,
                                                            listen: false)
                                                            .userProfile.address.length - 1) {
                                                      padding = EdgeInsets.only(right: 0.0);
                                                    }

                                                    // print('Provider.of<ProfileUpdate>(context,listen: false).userProfile.address: '
                                                    //     '${Provider.of<ProfileUpdate>(context,
                                                    // listen: false)
                                                    //     .userProfile.address}');
                                                    if (Provider.of<ProfileUpdate>(context,
                                                        listen: false)
                                                        .userProfile.address?.length != 0 && Provider.of<ProfileUpdate>(context,
                                                        listen: false)
                                                        .userProfile.address.first != '동네를 추가해주세요') { // 활동 탁구장이 있는 경우,
                                                      return Padding(
                                                        padding: padding,
                                                        child: Container(
                                                            margin: EdgeInsets.only(right: 7.0),
                                                            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0, bottom: 3.0),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: kMainColor),
                                                              borderRadius: BorderRadius.circular(20.0),
                                                            ),
                                                            child: Text('${Provider.of<ProfileUpdate>(context,
                                                                listen: false)
                                                                .userProfile.address[index]}',
                                                              style: TextStyle(color: kMainColor, fontSize: 12.0),)),
                                                      );
                                                    } else { //활동 지역이 없는 경우,
                                                      return Center(
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              '활동 지역을 추가해주세요 ',
                                                              style: TextStyle(color: Colors.grey,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                await MoveToOtherScreen()
                                                                    .persistentNavPushNewScreen(
                                                                    context,
                                                                    ProfileScreen(
                                                                      isSignup: false,
                                                                    ),
                                                                    false,
                                                                    PageTransitionAnimation.cupertino);
                                                              },
                                                              child: Icon(Icons.add_circle_outline, size: 15, color: kMainColor),
                                                            ),

                                                          ],
                                                        ),
                                                      );
                                                    }

                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ) :
                      SizedBox(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('핑퐁플러스 이용을 위해서\n로그인 해주세요', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold), textAlign: TextAlign.end,),
                            SizedBox(width: 15.0,),
                            IconButton(
                              onPressed: () {
                                MoveToOtherScreen().persistentNavPushNewScreen(
                                    context,
                                    SignupScreen(0),
                                    false,
                                    PageTransitionAnimation.fade);
                              },
                              icon: Icon(Icons.arrow_right_alt, size: 20.0, ),
                            ),
                            SizedBox(width: 15.0,)
                          ],
                        ),
                      ),
                    ), // 프로필
                    Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: SizedBox(
                        height: 30.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: _firstBarChartPageController,
                          //padding: EdgeInsets.only(left: 0.0, right: 3.0),
                          itemCount: Provider.of<PersonalAppointmentUpdate>(context,
                                  listen: false)
                              .isSelectedString
                              .length,
                          itemBuilder: (BuildContext context, int index) {
                            var padding = EdgeInsets.only(left: 3.0, right: 3.0);

                            var margin = EdgeInsets.zero;

                            if (index == 0) {
                              margin = EdgeInsets.only(left: 10.0, right: 0.0);
                            } else if (index ==
                                Provider.of<PersonalAppointmentUpdate>(context,
                                            listen: false)
                                        .isSelectedString
                                        .length -
                                    1) {
                              margin = EdgeInsets.only(left: 0.0, right: 10.0);
                            }

                            return Container(
                              width: 130.0,
                              padding: padding,
                              margin: margin,
                              decoration: BoxDecoration(
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.grey.withOpacity(0.1),
                                //     //spreadRadius: 5,
                                //     blurRadius: 1,
                                //     offset: Offset(3, 3),
                                //   ),
                                // ],
                              ),
                              child: OutlinedButton(
                                onPressed: () async {
                                  print('최근 일자 클릭');
                                    await Provider.of<PersonalAppointmentUpdate>(context,
                                            listen: false)
                                        .updateChart(index);

                                    await Provider.of<CourtAppointmentUpdate>(context,
                                            listen: false)
                                        .updateChart(index);
                                  setState(() {
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
                                  backgroundColor:
                                      Provider.of<PersonalAppointmentUpdate>(
                                                  context,
                                                  listen: false)
                                              .isSelected[index]
                                          ? Colors.lightBlue.withOpacity(0.9)
                                          : Colors.lightBlue.withOpacity(0.5),
                                  shape: kRoundedRectangleBorder,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    Provider.of<PersonalAppointmentUpdate>(context,
                                            listen: false)
                                        .isSelectedString[index],
                                    maxLines: 1,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0, left: 35.0),
                          child: Text(
                            '나의 연습 시간은 얼마나 될까?',
                            style: kAppointmentTextStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0, left: 35.0),
                          child: Text(
                            '각 요일을 누르면 해당 요일에 이뤄진 일정들의 시간대가 표현됩니다',
                            style: kAppointmentTextStyle.copyWith(
                                color: Colors.grey,
                                fontSize: 11.0,
                            ),
                          ),
                        ),
                        Consumer<PersonalAppointmentUpdate>(
                            builder: (context, taskData, child) {
                            return MainPersonalChartPageView(
                              pageController: _secondBarChartPageController,
                              currentPersonal: _currentPersonal,
                              indexPersonal: _indexPersonal,
                              courtTitle: _courtTitle,
                              courtRoadAddress: _courtRoadAddress,
                            );
                          }
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 5.0, left: 35.0),
                          child: Text(
                            '우리 탁구장이 붐비는 시간은 언제일까?',
                            style: kAppointmentTextStyle,
                          ),
                        ), // 탁구장 방문 데이터
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0, left: 35.0),
                          child: Text(
                            '각 요일을 누르면 해당 요일에 이뤄진 일정들의 시간대가 표현됩니다',
                            style: kAppointmentTextStyle.copyWith(
                              color: Colors.grey,
                                fontSize: 11.0,
                            ),
                          ),
                        ),
                        Consumer<CourtAppointmentUpdate>(
                          builder: (context, taskData, child) {
                            return MainCourtChartPageView(
                              pageController: _thirdBarChartPageController,
                              currentCourt: _currentCourt,
                              indexCourt: _indexCourt,
                              courtTitle: _courtTitle,
                              courtRoadAddress: _courtRoadAddress,
                            );
                          }
                        ),
                      ],
                    ),
                  ],
                ),

                // 공지사항 및 배너
                FutureBuilder(
                  future: myFuture,
                  builder: (context, snapshot) {

                    print('공지사항 및 배너 snapshot.connectionState: ${snapshot.connectionState}');
                    print('공지사항 및 배너 snapshot.data: ${snapshot.data}');
                    if (snapshot.data != null){
                      return Visibility(
                        visible: viewModel.isAdBannerVisible,
                        child: mainScreenViewModel.announcementWidget(
                            context, true, width, height, viewModel.falseIsAdBannerVisible),
                      );
                    } else {
                      return Container();
                    }

                  }
                ),

                // 이용 안내
                Visibility(
                  visible: viewModel.isHowToUseVisible,
                  child: mainScreenViewModel.announcementWidget(
                      context, false, width, height, viewModel.falseIsHowToUseVisible),
                ),
              ],
            ),
          //),
        ),
        );
      }
    );
  }

  Future<bool> calculateConfirmTime() async {

    final DateTime currentVisit = Provider.of<LoginStatusUpdate>(context, listen: false).currentVisit;
    final DateTime? confirmTime = await RepositoryRealtimeUsers().getDownloadAnnouncementVisibleTime();
    print('confirmTime: $confirmTime');

    if (confirmTime != null) {

      final currentVisitString = DateFormat('yyyy-MM-dd').format(currentVisit);
      final confirmTimeString = DateFormat('yyyy-MM-dd').format(confirmTime);

      final now = DateFormat('yyyy-MM-dd').parse(currentVisitString);
      final visit = DateFormat('yyyy-MM-dd').parse(confirmTimeString);

      if (visit.isBefore(now)) {
        print('now가 더 빠릅니다.'); // 오늘 하루 보지 않음이 적용되지 않음
        await viewModel.trueIsAdBannerVisible();
        return true;
      } else if (visit.isAfter(now)) {
        print('confirmTime이 now가 보다 더 빠릅니다.');
        await viewModel.falseIsAdBannerVisible(); // 사실상 불가능
        return false;
      } else {
        print('두 날짜가 같습니다.');
        await viewModel.falseIsAdBannerVisible();
        return false;
      }

    } else { //confirmTime 이 없으므로 광고 배너가 보여야함
      await viewModel.trueIsAdBannerVisible();
      return true;
    }

  }

}
