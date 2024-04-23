import 'dart:async';
import 'package:dnpp/models/userProfile.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/repository/launchUrl.dart';
import 'package:dnpp/statusUpdate/courtAppointmentUpdate.dart';
import 'package:dnpp/statusUpdate/loadingUpdate.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/chatBackgroundListen.dart';
import '../repository/googleAnalytics.dart';
import '../statusUpdate/loginStatusUpdate.dart';
import '../statusUpdate/profileUpdate.dart';
import '../statusUpdate/personalAppointmentUpdate.dart';
import '../viewModel/MainScreen_ViewModel.dart';
import '../widgets/paging/main_personalChartPage.dart';
import '../widgets/paging/main_courtChartPage.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

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

    WidgetsBinding.instance!.addPostFrameCallback((_) async {

      try {
        _secondBarChartPageController.jumpToPage(0);
        _thirdBarChartPageController.jumpToPage(0);
      } catch (e) {
        print('jumpToPage: $e');
      }


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

    return Consumer<MainScreenViewModel>(
      builder: (context, mainScreenViewModel, child) {
        return SafeArea(
          child: Scaffold(
              appBar: AppBar(
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
                ],
              ),
              body: CustomMaterialIndicator(
            onRefresh: () {
              isRefresh = true;
              return Provider.of<LoadingUpdate>(context, listen: false)
                  .loadData(context, isPersonal, _courtTitle, _courtRoadAddress)
                  .whenComplete(() => setState(() {
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
            child: Stack(
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
                    Padding(
                      padding: EdgeInsets.only(top: 15),
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
                              margin = EdgeInsets.only(left: 5.0, right: 0.0);
                            } else if (index ==
                                Provider.of<PersonalAppointmentUpdate>(context,
                                            listen: false)
                                        .isSelectedString
                                        .length -
                                    1) {
                              margin = EdgeInsets.only(left: 0.0, right: 5.0);
                            }

                            return Container(
                              width: 130.0,
                              padding: padding,
                              margin: margin,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    //spreadRadius: 5,
                                    blurRadius: 3,
                                    offset: Offset(3, 3),
                                  ),
                                ],
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
                          padding: const EdgeInsets.only(top: 15.0, left: 35.0),
                          child: Text(
                            '우리 탁구장이 붐비는 시간은 언제일까?',
                            style: kAppointmentTextStyle,
                          ),
                        ), // 탁구장 방문 데이터
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

                    print('snapshot.connectionState: ${snapshot.connectionState}');
                    print('snapshot.data: ${snapshot.data}');
                    if (snapshot.data != null){
                      return Visibility(
                        visible: viewModel.isAdBannerVisible,
                        child: mainScreenViewModel.announcementWidget(context, true, width, height, viewModel.falseIsAdBannerVisible),
                      );
                    } else {
                      return Container();
                    }

                  }
                ),

                // 이용 안내
                Visibility(
                  visible: viewModel.isHowToUseVisible,
                  child: mainScreenViewModel.announcementWidget(context, false, width, height, viewModel.falseIsHowToUseVisible),
                ),
              ],
            ),
          )),
        );
      }
    );
  }

  Future<bool> calculateConfirmTime() async {

    final DateTime currentVisit = Provider.of<LoginStatusUpdate>(context, listen: false).currentVisit;
    final DateTime? confirmTime = await ChatBackgroundListen().downloadAdBannerVisibleConfirmTime();
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
