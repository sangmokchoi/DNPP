import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:dnpp/models/pingpongList.dart';
import 'package:dnpp/models/userProfile.dart';
import 'package:dnpp/statusUpdate/othersPersonalAppointmentUpdate.dart';
import 'package:dnpp/view/chatList_Screen.dart';
import 'package:dnpp/view/signup_screen.dart';
import 'package:dnpp/viewModel/MatchingScreen_ViewModel.dart';
import 'package:dnpp/widgets/paging/graphWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import '../LocalDataSource/firebase_realtime/users/DS_Local_badge.dart';
import '../constants.dart';
import '../models/launchUrl.dart';
import '../models/moveToOtherScreen.dart';
import '../repository/firebase_realtime_users.dart';
import '../statusUpdate/googleAnalytics.dart';
import '../statusUpdate/CurrentPageProvider.dart';
import '../statusUpdate/loginStatusUpdate.dart';
import '../statusUpdate/profileUpdate.dart';
import '../viewModel/LoadingScreen_ViewModel.dart';

class MatchingScreen extends StatefulWidget {
  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with WidgetsBindingObserver {
  final PageController _imagePageController = PageController(
    initialPage: 0,
  );

  int _currentImage = 0;

  PingpongList chosenPingpongList = PingpongList.emptyPingpongList;

  String chosenCourthood = '탁구장을 추가해주세요';

  String chosenNeighborhood = '동네를 추가해주세요';

  int selectedIndex = 0;

  bool asdf = true;

  late MatchingScreenViewModel viewModel;

  Map<String, dynamic> firstOpponentUser = {
    'nickName': '',
  };

  Map<String, dynamic> secondOpponentUser = {
    'nickName': '',
  };

  Map<String, dynamic> thirdOpponentUser = {
    'nickName': '',
  };

  Stream<QuerySnapshot<Map<String, dynamic>>> matchinStream = Stream.empty();

  Stream<int>? floatingButtonStream =
      RepositoryRealtimeUsers().getMyBadgeListen(); //Stream.empty();

  Future<void> initMatchingScreen(BuildContext context) async {
    debugPrint('매칭 스크린 initstate 진입');
    //if (Provider.of<LoginStatusUpdate>(context, listen: false).isLoggedIn) {
    debugPrint('매칭 스크린 initstate isloggedin');
    //viewModel.addStreamListener(context);
    viewModel.setListener(context);
    viewModel.clearClickedIndex();
    viewModel.clearAllShowGraph();
    viewModel.notifyListeners();
    floatingButtonStream = RepositoryRealtimeUsers().getMyBadgeListen();
    //}

    //await viewModel.initializeListeners();
    //viewModel.listenerAdd(context, currentUserProfile);

    if (Provider.of<ProfileUpdate>(context, listen: false)
        .userProfile
        .address
        .isNotEmpty) {
      debugPrint('.address[0].isNotEmpty');
      chosenNeighborhood = Provider.of<ProfileUpdate>(context, listen: false)
          .userProfile
          .address[0];
      debugPrint('chosenNeighborhood: $chosenNeighborhood');
    }

    if (Provider.of<ProfileUpdate>(context, listen: false)
        .userProfile
        .pingpongCourt!
        .isNotEmpty) {
      debugPrint('.pingpongCourt![0].title.isNotEmpty');
      chosenPingpongList = Provider.of<ProfileUpdate>(context, listen: false)
          .userProfile
          .pingpongCourt![0];

      chosenCourthood = Provider.of<ProfileUpdate>(context, listen: false)
          .userProfile
          .pingpongCourt![0]
          .title;
      debugPrint('chosenCourthood: $chosenCourthood');
    }
  }

  @override
  void initState() {
    viewModel = Provider.of<MatchingScreenViewModel>(context, listen: false);
    viewModel.addStreamListener(context);

    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    startTimer();
  }

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
      if (Provider.of<LoadingScreenViewModel>(context, listen: false)
              .refStringListMatchingScreen
              .length >
          1) {
        if (_currentImage <
            Provider.of<LoadingScreenViewModel>(context, listen: false)
                    .refStringListMatchingScreen
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
  void dispose() {
    debugPrint('매칭스크린 디스포스!!!');
    WidgetsBinding.instance!.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  bool isRefresh = false;

  // @override
  @override
  Widget build(BuildContext context) {
    //viewModel = Provider.of<MatchingScreenViewModel>(context, listen: false);

//final badge = await ChatBackgroundListen().downloadMyBadge();

    // final currentPageProvider = Provider.of<CurrentPageProvider>(context, listen: false);
    // currentPageProvider.setCurrentPage('MatchingScreen');

    debugPrint('매칭스크린 build!');

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      // Timer.periodic(Duration(seconds: 7), (timer) {
      //   // if (_imagePageController.page! < _currentimage) {
      //   //
      //   // }
      //   if (Provider.of<LoadingScreenViewModel>(context, listen: false)
      //       .refStringListMatchingScreen
      //       .length > 1) {
      //
      //     _currentImage = _imagePageController.page!.toInt();
      //     debugPrint('matchingScreen _currentimage: $_currentImage');
      //     debugPrint('matchingScreen _currentimage: ${Provider.of<LoadingScreenViewModel>(context, listen: false)
      //         .refStringListMatchingScreen
      //         .length}');
      //
      //     if (_currentImage <
      //         Provider
      //             .of<LoadingScreenViewModel>(context, listen: false)
      //             .refStringListMatchingScreen
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
      // });

      await GoogleAnalytics().trackScreen(context, 'MatchingScreen');
      await Provider.of<CurrentPageProvider>(context, listen: false)
          .setCurrentPage('MatchingScreen');

      await initMatchingScreen(context);
      //debugPrint('매칭스크린 build!');
    });

    return Consumer<MatchingScreenViewModel>(
        builder: (context, matchingScreenViewModel, child) {
      return Consumer<LoginStatusUpdate>(builder: (context, loginData, child) {
        return SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            key: const ValueKey("MatchingScreen"),
            appBar: AppBar(
              scrolledUnderElevation: 0,
              centerTitle: false,
              titleTextStyle: kAppbarTextStyle,
              title: Text(
                'Matching',
                style: Theme.of(context).brightness == Brightness.light
                    ? TextStyle(color: Colors.black)
                    : TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              //Theme.of(context).colorScheme.background,
              actions: [
                IconButton(
                  onPressed: () {
                    LaunchUrl().alertOkAndCancelFuncNoPop(
                        context,
                        '알림',
                        '새로고침 하시겠습니까?\n다른 유저들의 일정을 새롭게 불러옵니다',
                        '뒤로',
                        '새로고침',
                        kMainColor,
                        kMainColor, () {
                      Navigator.of(context, rootNavigator: true).pop();
                    }, () {
                      Navigator.of(context, rootNavigator: true).pop();

                      bool isPersonal = false;

                      showDialog(
                          context: context,
                          builder: (context) {
                            return AbsorbPointer(
                              absorbing: true,
                              child: Container(
                                height: MediaQuery.sizeOf(context).height,
                                width: MediaQuery.sizeOf(context).width,
                                child: Center(
                                    child: kCustomCircularProgressIndicator),
                              ),
                            );
                          });

                      Provider.of<LoadingScreenViewModel>(context, listen: false)
                          .loadData(context, isPersonal, '', '')
                          .then((value) {
                        setState(() {
                          Navigator.of(context, rootNavigator: true).pop();
                        });
                      });
                    });
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.grey,
                    size: 25,
                  ),
                ),
              ],
            ),
            floatingActionButton: loginData.isLoggedIn
                ? Stack(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 15.0, right: 2.0),
                        child: FloatingActionButton(
                          heroTag: 'toChatList',
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: Icon(
                            CupertinoIcons.chat_bubble_2_fill,
                            //size: 30,
                          ),
                          onPressed: () async {
                            //Navigator.push(context, LaunchUrl.createRouteChatListView());
                            await Provider.of<GoogleAnalyticsNotifier>(context,
                                    listen: false)
                                .startTimer('MatchingScreen')
                                .then((value) {
                              MoveToOtherScreen().persistentNavPushNewScreen(
                                  context,
                                  ChatListView(),
                                  false,
                                  PageTransitionAnimation.cupertino);
                            });
                          },
                        ),
                      ),
                      // 채팅 개수 표시하는 빨간점
                      StreamBuilder<int>(
                          stream: floatingButtonStream,
                          builder: (builder, snapshot) {
                            debugPrint(
                                'ChatBackgroundListen().myBadgeListen() snapshot: $snapshot');
                            debugPrint(
                                'ChatBackgroundListen().myBadgeListen() snapshot.data: ${snapshot.data}');

                            final data = snapshot.data;
                            debugPrint(
                                'ChatBackgroundListen().myBadgeListen() data: $data');

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (data == 0 || data == null) {
                                return Container(
                                  width: 0,
                                  height: 0,
                                );
                              } else {
                                return Positioned(
                                  right: 5,
                                  top: 5,
                                  child: SizedBox(
                                    width: 15.0,
                                    height: 15.0,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                );
                              }
                            } else if (snapshot.connectionState ==
                                ConnectionState.active) {
                              if (data == 0 || data == null) {
                                return Container(
                                  width: 0,
                                  height: 0,
                                );
                              } else {
                                return Positioned(
                                  right: 5,
                                  top: 5,
                                  child: SizedBox(
                                    width: 15.0,
                                    height: 15.0,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                );
                              }
                            } else {
                              return Container(
                                width: 0,
                                height: 0,
                              );
                            }
                          }),
                    ],
                  )
                : null,
            body: Consumer<ProfileUpdate>(
              builder: (context, profileUpdate, child) {
                debugPrint(
                    'profileUpdate.userProfile: ${profileUpdate.userProfile.toFirestore()}');
                debugPrint(
                    'UserProfile.emptyUserProfile.address: ${UserProfile.emptyUserProfile.address}');

                if (profileUpdate.userProfile.address !=
                    UserProfile.emptyUserProfile.address) {
                  debugPrint(
                      'profileUpdate.userProfile.address: ${profileUpdate.userProfile.address}');

                  return Consumer<OthersPersonalAppointmentUpdate>(builder:
                      (context, othersPersonalAppointmentUpdate, child) {
                    return SingleChildScrollView(
                      controller: matchingScreenViewModel.scrollController,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 0.0,
                                left: 15.0,
                                bottom: 20.0,
                                right: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        viewModel.toggleHeadTitleColor(true);
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '동네 사람들',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: viewModel.headTitleColor1,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Container(
                                            height: 2.0,
                                            width: 50.0,
                                            color: matchingScreenViewModel
                                                .headTitleColor1,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.0,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        viewModel.toggleHeadTitleColor(false);
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '탁구장 사람들',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: viewModel.headTitleColor2,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Container(
                                            height: 2.0,
                                            width: 50.0,
                                            color: viewModel.headTitleColor2,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    LaunchUrl().alertFunc(
                                        context, '알림', '필터 기능은 준비중입니다', '확인',
                                        () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    });
                                  },
                                  child: Icon(
                                    Icons.filter_alt_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ), // 사람들 구분
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width - 25,
                              height:
                                  (MediaQuery.sizeOf(context).width - 25) / 5,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: PageView.builder(
                                controller: _imagePageController,
                                itemCount: Provider.of<LoadingScreenViewModel>(context,
                                        listen: false)
                                    .refStringListMatchingScreen
                                    .length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      await GoogleAnalytics().bannerClickEvent(
                                          context,
                                          'matchingScreen',
                                          index,
                                          Provider.of<LoadingScreenViewModel>(context,
                                                      listen: false)
                                                  .refStringListMatchingScreen[
                                              '$index']!,
                                          Provider.of<LoadingScreenViewModel>(context,
                                                  listen: false)
                                              .urlMapMatchingScreen[Provider.of<
                                                          LoadingScreenViewModel>(
                                                      context,
                                                      listen: false)
                                                  .refStringListMatchingScreen[
                                              '$index']]!);

                                      await LaunchUrl().myLaunchUrl(
                                          "${Provider.of<LoadingScreenViewModel>(context, listen: false).urlMapMatchingScreen[Provider.of<LoadingScreenViewModel>(context, listen: false).refStringListMatchingScreen['$index']]}");
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            //spreadRadius: 5,
                                            blurRadius: 5,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        image: DecorationImage(
                                          image: MemoryImage(
                                            Provider.of<LoadingScreenViewModel>(context,
                                                            listen: false)
                                                        .imageMapMatchingScreen[
                                                    Provider.of<LoadingScreenViewModel>(
                                                                context,
                                                                listen: false)
                                                            .refStringListMatchingScreen[
                                                        '$index']] ??
                                                Uint8List(0),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ), // 광고 배너

                          if (matchingScreenViewModel.headTitleColor1 ==
                              kMainColor) // 동네사람들
                            Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Column(
                                  children: [
                                    StreamBuilder<
                                        QuerySnapshot<Map<String, dynamic>>>(
                                      stream: viewModel.usersNeighborhoodStream,
                                      builder: (context, snapshot) {
                                        List<
                                                QueryDocumentSnapshot<
                                                    Map<String, dynamic>>>
                                            userDocs =
                                            snapshot.data?.docs ?? [];
                                        // debugPrint(
                                        //     'viewModel.usersNeighborhoodStream snapshot.data: ${snapshot.data}');
                                        // debugPrint(
                                        //     'usersNeighborhoodStream userDocs: $userDocs');
                                        // debugPrint(
                                        //     'usersNeighborhoodStream userDocs isEmpty: ${userDocs.isEmpty}');
                                        // debugPrint(
                                        //     'usersNeighborhoodStream userDocs snapshot.connectionState: ${snapshot.connectionState}');
                                        //

                                        if (userDocs.isEmpty == true) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0,
                                                    right: 15.0,
                                                    top: 15.0,
                                                    bottom: 15.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    if (chosenNeighborhood ==
                                                        '동네를 추가해주세요')
                                                      Text(
                                                          '동네를 추가해주세요\n(더보기 > 프로필 설정 > 활동 지역 추가)'),
                                                    DropdownButtonHideUnderline(
                                                      child: DropdownButton(
                                                        //isExpanded: true,
                                                        value:
                                                            chosenNeighborhood,
                                                        //null,
                                                        isDense: true,
                                                        items: (chosenNeighborhood !=
                                                                '동네를 추가해주세요')
                                                            ? Provider.of<
                                                                        ProfileUpdate>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .userProfile
                                                                .address
                                                                ?.map(
                                                                  (element) =>
                                                                      DropdownMenuItem(
                                                                    value:
                                                                        element,
                                                                    child: Text(
                                                                      element,
                                                                      style:
                                                                          kMatchingScreenTextHeaderTextStyle,
                                                                      //kAppointmentTextButtonStyle,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                )
                                                                .toList()
                                                            : [],
                                                        onChanged:
                                                            (value) async {
                                                          debugPrint(
                                                              'chosenNeighborhood value: $value');
                                                          chosenNeighborhood =
                                                              value.toString();

                                                          await viewModel
                                                              .clearClickedIndex();

                                                          await viewModel
                                                              .updateUsersNeighborhoodStream(
                                                                  chosenNeighborhood)
                                                              .then(
                                                                  (value) async {
                                                            await viewModel
                                                                .clearAllShowGraph();
                                                            //scrollDown80();
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0,
                                                    right: 15.0,
                                                    bottom: 15.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            '우리 동네 사람들 모여라!',
                                                            style: Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .light
                                                                ? kMatchingScreenBigTextHeaderTextStyle
                                                                    .copyWith(
                                                                        color: Colors
                                                                            .black)
                                                                : kMatchingScreenBigTextHeaderTextStyle
                                                                    .copyWith(
                                                                        color: Colors
                                                                            .white),
                                                          ),
                                                        ),
                                                        //Icon(Icons.arrow_drop_up),
                                                      ],
                                                    ),
                                                    // Row(
                                                    //   children: [
                                                    //     Text('활동 지역을 추가해주세요',
                                                    //       style:
                                                    //       kMatchingScreenTextHeaderTextStyle,),
                                                    //
                                                    //   ],
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 200,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                    child: Text('데이터 없음')),
                                              )
                                            ],
                                          );
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child:
                                                kCustomCircularProgressIndicator,
                                          );
                                        } else if (snapshot.hasError) {
                                          return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'),
                                          );
                                        } else {
                                          // 데이터가 있는 경우
                                          // debugPrint(
                                          //     'MediaQuery.of(context).size.height - 250 - 65: ${MediaQuery.of(context).size.height - 250 - 65}');
                                          // debugPrint(
                                          //     'MediaQuery.of(context).size.height * 0.5: ${MediaQuery.of(context).size.height * 0.5}');
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0,
                                                    right: 15.0,
                                                    top: 15.0,
                                                    bottom: 15.0),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 15.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton(
                                                              //isExpanded: true,
                                                              value:
                                                                  chosenNeighborhood,
                                                              //null,
                                                              isDense: true,
                                                              items: (chosenNeighborhood !=
                                                                      '동네를 추가해주세요')
                                                                  ? Provider.of<ProfileUpdate>(
                                                                              context,
                                                                              listen: false)
                                                                          .userProfile
                                                                          .address
                                                                          ?.map(
                                                                            (element) =>
                                                                                DropdownMenuItem(
                                                                              value: element,
                                                                              child: Text(
                                                                                element,
                                                                                style: kMatchingScreenTextHeaderTextStyle,
                                                                                //kAppointmentTextButtonStyle,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          )
                                                                          .toList() ??
                                                                      []
                                                                  : [],
                                                              onChanged:
                                                                  (value) async {
                                                                debugPrint(
                                                                    'chosenNeighborhood value: $value');
                                                                chosenNeighborhood =
                                                                    value
                                                                        .toString();

                                                                await viewModel
                                                                    .clearClickedIndex();

                                                                await viewModel
                                                                    .updateUsersNeighborhoodStream(
                                                                        chosenNeighborhood)
                                                                    .then(
                                                                        (value) async {
                                                                  await viewModel
                                                                      .clearAllShowGraph();
                                                                  //scrollDown80();
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                '우리 동네 사람들 모여라!',
                                                                style: Theme.of(context)
                                                                            .brightness ==
                                                                        Brightness
                                                                            .light
                                                                    ? kMatchingScreenBigTextHeaderTextStyle
                                                                        .copyWith(
                                                                            color: Colors
                                                                                .black)
                                                                    : kMatchingScreenBigTextHeaderTextStyle
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.white),
                                                              ),
                                                            ),
                                                            // SizedBox(width: 30.0,),
                                                            // Transform(
                                                            //   transform: Matrix4.rotationY(math.pi), // 아이콘을 Y축을 중심으로 180도 회전하여 좌우 대칭으로 만듭니다.
                                                            //   child: GestureDetector(
                                                            //     onTap: (){
                                                            //
                                                            //     },
                                                            //       child: Icon(Icons.refresh)),
                                                            // )
                                                          ],
                                                        ),
                                                        Text(
                                                          '${userDocs.length}명',
                                                          style: TextStyle(
                                                              fontSize: 15.0),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    top: 0.0,
                                                    left: 8.0,
                                                    right: 8.0,
                                                    bottom: 0.0),
                                                //height: MediaQuery.of(context).size.height - Scaffold.of(context).appBarMaxHeight!.toDouble() * 6,
                                                //height: MediaQuery.of(context).size.height - (((MediaQuery.of(context).size.width - 25) / 5) * 5) - Scaffold.of(context).appBarMaxHeight!.toDouble(),
                                                //height: MediaQuery.of(context).size.height - Scaffold.of(context).appBarMaxHeight!.toDouble() - 250 - 65,
                                                height: ((MediaQuery.of(context)
                                                                .size
                                                                .height -
                                                            300 -
                                                            65) <
                                                        (MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.5))
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .height -
                                                        300 -
                                                        65
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.49,
                                                child: ListView.builder(
                                                  //scrollDirection: Axis.horizontal,
                                                  controller: viewModel
                                                      .neighborhoodScrollController,
                                                  shrinkWrap: true,
                                                  itemCount: snapshot
                                                      .data?.docs.length,
                                                  //30,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var user = snapshot.data
                                                                ?.docs[index]
                                                                .data()
                                                            as Map<String,
                                                                dynamic>? ??
                                                        {};
                                                    // var user = snapshot.data?.docs[0]
                                                    //     .data() as Map<String, dynamic>;
                                                    // debugPrint(
                                                    //     'matchingScreen 1155줄 user: $user');
                                                    // debugPrint(
                                                    //     'viewModel.clickedIndex2: ${matchingScreenViewModel.clickedIndex2}');

                                                    if (user != {}) {
                                                      if (viewModel
                                                              .clickedIndex2 ==
                                                          -1) {
                                                        // 모두 클릭 가능
                                                        viewModel
                                                                .ignoringSecond =
                                                            false;
                                                        viewModel
                                                                .opacitySecond =
                                                            1.0;
                                                      } else {
                                                        if (index ==
                                                            viewModel
                                                                .clickedIndex2) {
                                                          // 클릭되지 않은 나머니 위젯들이 블러 처리 및 ignore 되어야 함
                                                          viewModel
                                                                  .ignoringSecond =
                                                              false;
                                                          viewModel
                                                                  .opacitySecond =
                                                              1.0;
                                                        } else {
                                                          viewModel
                                                                  .ignoringSecond =
                                                              true;
                                                          viewModel
                                                                  .opacitySecond =
                                                              0.5;
                                                        }
                                                      }

                                                      return IgnorePointer(
                                                        ignoring: viewModel
                                                            .ignoringSecond,
                                                        child: Opacity(
                                                          opacity: viewModel
                                                              .opacitySecond,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async {
                                                              debugPrint(
                                                                  'viewModel.ignoringSecond on tap');
                                                              if (viewModel
                                                                      .clickedIndex2 ==
                                                                  -1) {
                                                                await viewModel
                                                                    .updateClickedIndex2(
                                                                        index);
                                                              } else {
                                                                await viewModel
                                                                    .updateClickedIndex2(
                                                                        -1);
                                                              }

                                                              final number =
                                                                  await matchingScreenViewModel
                                                                      .onTapGraphAppear(
                                                                          context,
                                                                          user,
                                                                          2);

                                                              thirdOpponentUser =
                                                                  user;

                                                              await matchingScreenViewModel
                                                                  .onTapGraphAppearAfter(
                                                                      number,
                                                                      context,
                                                                      index);

                                                              for (int i = 0;
                                                                  i <
                                                                      matchingScreenViewModel
                                                                          .itemExpandStates
                                                                          .length;
                                                                  i++) {
                                                                if (i !=
                                                                    index) {
                                                                  await matchingScreenViewModel
                                                                      .updateItemExpandStates(
                                                                          i,
                                                                          false);
                                                                }
                                                              }

                                                              await matchingScreenViewModel
                                                                  .updateItemExpandStates(
                                                                      index,
                                                                      !(matchingScreenViewModel
                                                                              .itemExpandStates[index] ??
                                                                          false));
                                                            },
                                                            child: Column(
                                                              children: [
                                                                ListTile(
                                                                  isThreeLine:
                                                                      true,
                                                                  dense: true,
                                                                  leading: user[
                                                                              'photoUrl']
                                                                          .isNotEmpty
                                                                      ? SizedBox(
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              50,
                                                                          child:
                                                                              CircleAvatar(
                                                                            backgroundImage:
                                                                                NetworkImage(user['photoUrl']),
                                                                          ),
                                                                        )
                                                                      : Icon(Icons
                                                                          .person),
                                                                  title: Text(
                                                                    user[
                                                                        'nickName'],
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    style:
                                                                        kMatchingScreen_SecondNicknameTextStyle,
                                                                  ),
                                                                  subtitle: Text
                                                                      .rich(TextSpan(
                                                                          children: [
                                                                        TextSpan(
                                                                          text:
                                                                              '경력 ',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14.0,
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              '${user['playedYears']}\n',
                                                                          style: TextStyle(
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              '스타일 ',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14.0,
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              '${user['playStyle']}  ',
                                                                          style: TextStyle(
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ' 라켓 ',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14.0,
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              '${user['racket']}  ',
                                                                          style: TextStyle(
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ' 러버 ',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14.0,
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              '${user['rubber']}',
                                                                          style: TextStyle(
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ])),
                                                                  //     Text(
                                                                  //   '스타일: ${user['playStyle']} / 경력: ${user['playedYears']}\n라켓: ${user['racket']} / 러버: ${user['rubber']}',
                                                                  //   style:
                                                                  //       kMatchingScreen_SecondUserInfoTextStyle,
                                                                  // ),
                                                                ),
                                                                // if (user['pingpongCourt'].isNotEmpty)
                                                                //   Container(
                                                                //     height: 35,
                                                                //     width: MediaQuery.of(
                                                                //         context)
                                                                //         .size
                                                                //         .width,
                                                                //     margin: EdgeInsets.only(top: 5.0, bottom: 0.0),
                                                                //     child: ListView.builder(
                                                                //         scrollDirection: Axis.horizontal,
                                                                //         itemCount: user['pingpongCourt'].length,
                                                                //         itemBuilder: (itemBuilder, index) {
                                                                //           var padding =
                                                                //               EdgeInsets.zero;
                                                                //
                                                                //           if (index ==
                                                                //               0) {
                                                                //             padding = EdgeInsets.only(left: 10.0);
                                                                //           } else if (index ==
                                                                //               Provider.of<ProfileUpdate>(context, listen: false).pingpongList.length - 1) {
                                                                //             padding = EdgeInsets.only(right: 10.0);
                                                                //           }
                                                                //           return Padding(
                                                                //             padding: padding,
                                                                //             child: Container(
                                                                //                 margin: EdgeInsets.only(right: 7.0),
                                                                //                 padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                                                                //                 decoration: BoxDecoration(
                                                                //                   border: Border.all(color: kMainColor),
                                                                //                   borderRadius: BorderRadius.circular(20.0),
                                                                //                 ),
                                                                //                 child: Text('${user['pingpongCourt'][index]['title']}',
                                                                //                   style: TextStyle(color: kMainColor),)),
                                                                //           );
                                                                //         }),
                                                                //   ), // 활동 탁구장 리스트
                                                                AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          250),
                                                                  height: (matchingScreenViewModel
                                                                              .isShowGraphSecond) &&
                                                                          (matchingScreenViewModel.opacitySecond ==
                                                                              1.0)
                                                                      ? 380
                                                                      : 0,
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    //physics: NeverScrollableScrollPhysics(),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        // if (user['pingpongCourt'].isNotEmpty)
                                                                        // Container(
                                                                        //   height: 35,
                                                                        //   width: MediaQuery.of(
                                                                        //       context)
                                                                        //       .size
                                                                        //       .width,
                                                                        //   margin: EdgeInsets.only(top: 5.0, bottom: 0.0),
                                                                        //   child: ListView.builder(
                                                                        //       scrollDirection: Axis.horizontal,
                                                                        //       itemCount: user['pingpongCourt'].length,
                                                                        //       itemBuilder: (itemBuilder, index) {
                                                                        //         var padding =
                                                                        //             EdgeInsets.zero;
                                                                        //
                                                                        //         if (index ==
                                                                        //             0) {
                                                                        //           padding = EdgeInsets.only(left: 10.0);
                                                                        //         } else if (index ==
                                                                        //             Provider.of<ProfileUpdate>(context, listen: false).pingpongList.length - 1) {
                                                                        //           padding = EdgeInsets.only(right: 10.0);
                                                                        //         }
                                                                        //         return Padding(
                                                                        //           padding: padding,
                                                                        //           child: Container(
                                                                        //               margin: EdgeInsets.only(right: 7.0),
                                                                        //               padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                                                                        //               decoration: BoxDecoration(
                                                                        //                 border: Border.all(color: kMainColor),
                                                                        //                 borderRadius: BorderRadius.circular(20.0),
                                                                        //               ),
                                                                        //               child: Text('${user['pingpongCourt'][index]['title']}',
                                                                        //                 style: TextStyle(color: kMainColor),)),
                                                                        //         );
                                                                        //       }),
                                                                        // ), // 활동 탁구장 리스트

                                                                        Stack(
                                                                          children: [
                                                                            GraphsWidget(
                                                                              titleText: '${thirdOpponentUser['nickName']}님의 최근 연습 현황',
                                                                              backgroundColor: kMainColor,
                                                                              number: 2, // 0은 currentuser, 1은 탁구장별 데이터, 2은 다른 유저의 데이터
                                                                            ),
                                                                            Positioned(
                                                                              top: 13.0,
                                                                              right: 5.0,
                                                                              child: IconButton(
                                                                                icon: Icon(
                                                                                  Icons.account_circle_rounded,
                                                                                  size: 20,
                                                                                  color: Colors.white,
                                                                                ),
                                                                                onPressed: () {
                                                                                  LaunchUrl().openBottomSheetMoveToChat(context, thirdOpponentUser);
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                )),
                          if (matchingScreenViewModel.headTitleColor2 ==
                              kMainColor) // 탁구장 사람들
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                children: [
                                  StreamBuilder<
                                          QuerySnapshot<Map<String, dynamic>>>(
                                      stream: matchingScreenViewModel
                                          .usersCourtStream,
                                      builder: (context, snapshot) {
                                        debugPrint(
                                            'snapshot : ${snapshot.connectionState}');
                                        debugPrint(
                                            'snapshot.data : ${snapshot.data}');

                                        List<
                                                QueryDocumentSnapshot<
                                                    Map<String, dynamic>>>
                                            userDocs =
                                            snapshot.data?.docs ?? [];

                                        debugPrint(
                                            'usersCourtStream userDocs: $userDocs');
                                        if (userDocs.isEmpty) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0,
                                                    left: 15.0,
                                                    right: 15.0,
                                                    bottom: 15.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    if (chosenCourthood ==
                                                        '탁구장을 추가해주세요')
                                                      Text(
                                                          '탁구장을 추가해주세요\n(더보기 > 프로필 설정 > 활동 탁구장 추가)'),
                                                    DropdownButtonHideUnderline(
                                                      child: DropdownButton(
                                                        //isExpanded: true,
                                                        value:
                                                            chosenPingpongList,
                                                        // chosenCourthood,
                                                        //chosenNeighborhood,
                                                        isDense: true,
                                                        items: (chosenCourthood !=
                                                                '탁구장을 추가해주세요')
                                                            ? Provider.of<
                                                                        ProfileUpdate>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .userProfile
                                                                .pingpongCourt
                                                                ?.map((element) =>
                                                                    DropdownMenuItem(
                                                                      value:
                                                                          element,
                                                                      child:
                                                                          Text(
                                                                        element
                                                                            .title,
                                                                        style:
                                                                            kMatchingScreenTextHeaderTextStyle,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ))
                                                                .toList()
                                                            : [],
                                                        onChanged:
                                                            (value) async {
                                                          var _value = value
                                                              as PingpongList;
                                                          debugPrint(
                                                              '_value: ${_value.title}');
                                                          chosenPingpongList =
                                                              _value;
                                                          chosenCourthood =
                                                              _value.title;

                                                          // Find the index of the selected item
                                                          selectedIndex = Provider.of<
                                                                          ProfileUpdate>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .userProfile
                                                                  .pingpongCourt
                                                                  ?.indexWhere(
                                                                      (element) =>
                                                                          element ==
                                                                          value) ??
                                                              0;
                                                          debugPrint(
                                                              'selectedIndex: $selectedIndex');

                                                          await viewModel
                                                              .clearClickedIndex();

                                                          await viewModel
                                                              .updateUsersCourtStream(
                                                                  value);
                                                          // await viewModel
                                                          //     .updateSimilarUsersCourtStream(
                                                          //         context, value);
                                                          await viewModel
                                                              .clearAllShowGraph();
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0,
                                                    right: 15.0,
                                                    bottom: 15.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        '우리 탁구장 사람들 모여라!',
                                                        style: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.light
                                                            ? kMatchingScreenBigTextHeaderTextStyle
                                                                .copyWith(
                                                                    color: Colors
                                                                        .black)
                                                            : kMatchingScreenBigTextHeaderTextStyle
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white),
                                                      ),
                                                    ),
                                                    //Icon(Icons.arrow_drop_up),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 200,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                    child: Text('데이터 없음')),
                                              )
                                            ],
                                          );
                                          //return Container();
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child: Center(
                                              child:
                                                  kCustomCircularProgressIndicator,
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'),
                                          );
                                        } else {
                                          return Column(
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15.0,
                                                            right: 15.0,
                                                            top: 15.0,
                                                            bottom: 15.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              DropdownButtonHideUnderline(
                                                                child:
                                                                    DropdownButton(
                                                                  //isExpanded: true,
                                                                  value:
                                                                      chosenPingpongList,
                                                                  // chosenCourthood,
                                                                  //chosenNeighborhood,
                                                                  isDense: true,
                                                                  items: (chosenCourthood !=
                                                                          '탁구장을 추가해주세요')
                                                                      ? Provider.of<ProfileUpdate>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .userProfile
                                                                          .pingpongCourt
                                                                          ?.map((element) =>
                                                                              DropdownMenuItem(
                                                                                value: element,
                                                                                child: Text(
                                                                                  element.title,
                                                                                  style: kMatchingScreenTextHeaderTextStyle,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ))
                                                                          .toList()
                                                                      : [],
                                                                  onChanged:
                                                                      (value) async {
                                                                    var _value =
                                                                        value
                                                                            as PingpongList;
                                                                    debugPrint(
                                                                        '_value: ${_value.title}');
                                                                    chosenPingpongList =
                                                                        _value;
                                                                    chosenCourthood =
                                                                        _value
                                                                            .title;

                                                                    // Find the index of the selected item
                                                                    selectedIndex = Provider.of<ProfileUpdate>(context, listen: false)
                                                                            .userProfile
                                                                            .pingpongCourt
                                                                            ?.indexWhere((element) =>
                                                                                element ==
                                                                                value) ??
                                                                        0;
                                                                    debugPrint(
                                                                        'selectedIndex: $selectedIndex');

                                                                    await matchingScreenViewModel
                                                                        .clearClickedIndex();

                                                                    await matchingScreenViewModel
                                                                        .updateUsersCourtStream(
                                                                            value);
                                                                    // await viewModel
                                                                    //     .updateSimilarUsersCourtStream(
                                                                    //         context, value);
                                                                    await matchingScreenViewModel
                                                                        .clearAllShowGraph();
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    '우리 탁구장 사람들 모여라!',
                                                                    style: Theme.of(context).brightness ==
                                                                            Brightness
                                                                                .light
                                                                        ? kMatchingScreenBigTextHeaderTextStyle.copyWith(
                                                                            color: Colors
                                                                                .black)
                                                                        : kMatchingScreenBigTextHeaderTextStyle.copyWith(
                                                                            color:
                                                                                Colors.white),
                                                                  ),
                                                                ),
                                                                // SizedBox(width: 30.0,),
                                                                // Transform(
                                                                //   transform: Matrix4.rotationY(math.pi), // 아이콘을 Y축을 중심으로 180도 회전하여 좌우 대칭으로 만듭니다.
                                                                //   child: GestureDetector(
                                                                //     onTap: (){
                                                                //
                                                                //     },
                                                                //       child: Icon(Icons.refresh)),
                                                                // ),
                                                              ],
                                                            ),
                                                            Text(
                                                              '${userDocs.length}명',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // 명 수
                                                  Container(
                                                    height: 200,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    margin: EdgeInsets.only(
                                                        bottom: 5.0),
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      controller: viewModel
                                                          .courtScrollController,
                                                      physics: viewModel
                                                              .isShowGraphZero
                                                          ? NeverScrollableScrollPhysics()
                                                          : AlwaysScrollableScrollPhysics(),
                                                      //shrinkWrap: true,
                                                      itemCount:
                                                          userDocs.length,
                                                      //snapshot.data?.docs.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        // var user = snapshot.data?.docs[index]
                                                        //     .data() as Map<String, dynamic>;

                                                        var user = snapshot
                                                                .data
                                                                ?.docs[
                                                                    index] // index
                                                                .data()
                                                            as Map<String,
                                                                dynamic>;

                                                        EdgeInsets padding =
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        4.0);
                                                        if (index == 0) {
                                                          padding =
                                                              EdgeInsets.only(
                                                                  left: 8.0,
                                                                  right: 4.0);
                                                        }
                                                        // 맨 마지막 item에 오른쪽에 8.0의 패딩 추가
                                                        else if (index ==
                                                            userDocs.length -
                                                                1) {
                                                          padding =
                                                              EdgeInsets.only(
                                                                  left: 4.0,
                                                                  right: 8.0);
                                                        }

                                                        if (viewModel
                                                                .clickedIndex0 ==
                                                            -1) {
                                                          // 모두 클릭 가능
                                                          viewModel
                                                                  .ignoringZero =
                                                              false;
                                                          viewModel
                                                                  .opacityZero =
                                                              1.0;
                                                        } else {
                                                          if (index ==
                                                              viewModel
                                                                  .clickedIndex0) {
                                                            // 클릭되지 않은 나머니 위젯들이 블러 처리 및 ignore 되어야 함

                                                            viewModel
                                                                    .ignoringZero =
                                                                false;
                                                            viewModel
                                                                    .opacityZero =
                                                                1.0;
                                                          } else {
                                                            viewModel
                                                                    .ignoringZero =
                                                                true;
                                                            viewModel
                                                                    .opacityZero =
                                                                0.5;
                                                          }
                                                        }
                                                        return IgnorePointer(
                                                          ignoring: viewModel
                                                              .ignoringZero,
                                                          child: Opacity(
                                                            opacity: viewModel
                                                                .opacityZero,
                                                            child: Padding(
                                                              padding: padding,
                                                              child:
                                                                  GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  debugPrint(
                                                                      'matchingScreenViewModel.ignoringZero on tap');
                                                                  if (matchingScreenViewModel
                                                                          .clickedIndex0 ==
                                                                      -1) {
                                                                    await matchingScreenViewModel
                                                                        .updateClickedIndex0(
                                                                            index);
                                                                  } else {
                                                                    await matchingScreenViewModel
                                                                        .updateClickedIndex0(
                                                                            -1);
                                                                  }
                                                                  final number =
                                                                      await matchingScreenViewModel.onTapGraphAppear(
                                                                          context,
                                                                          user,
                                                                          0);

                                                                  firstOpponentUser =
                                                                      user;

                                                                  await matchingScreenViewModel
                                                                      .onTapGraphAppearAfter(
                                                                          number,
                                                                          context,
                                                                          index);
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          5.0),
                                                                  child:
                                                                      Container(
                                                                    width: 190,
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            5.0),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5),
                                                                          //spreadRadius: 5,
                                                                          blurRadius:
                                                                              5,
                                                                          offset: Offset(
                                                                              0,
                                                                              0.5),
                                                                        ),
                                                                      ],
                                                                      color:
                                                                          kMainColor,
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(20.0)),
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        user['photoUrl'].isNotEmpty
                                                                            ? SizedBox(
                                                                                width: 50,
                                                                                height: 50,
                                                                                child: CircleAvatar(
                                                                                  backgroundImage: NetworkImage(user['photoUrl']),
                                                                                ),
                                                                              )
                                                                            : Icon(
                                                                                Icons.person,
                                                                                size: 60,
                                                                              ),
                                                                        SizedBox(
                                                                          height:
                                                                              2.5,
                                                                        ),
                                                                        Text(
                                                                          user[
                                                                              'nickName'],
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              kMatchingScreen_FirstNicknameTextStyle,
                                                                        ),
                                                                        // Text(
                                                                        //   '${user['playStyle']} / ${user['racket']} / ${user['playedYears']} / ${user['rubber']}',
                                                                        //   style:
                                                                        //       kMatchingScreen_FirstUserInfoTextStyle,
                                                                        // ),
                                                                        Text(
                                                                          chosenCourthood,
                                                                          style:
                                                                              kMatchingScreen_FirstAddressTextStyle,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              2.5,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 10.0,
                                                                              vertical: 2.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceAround,
                                                                            children: [
                                                                              RichText(
                                                                                text: TextSpan(
                                                                                  children: [
                                                                                    TextSpan(
                                                                                      text: '스타일 ',
                                                                                      style: kMatchingScreen_FirstUserInfoTextStyle,
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: '${user['playStyle']}\n',
                                                                                      style: kMatchingScreen_FirstUserInfoTextStyle.copyWith(
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: '라켓 ',
                                                                                      style: kMatchingScreen_FirstUserInfoTextStyle,
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: '${user['racket']}',
                                                                                      style: kMatchingScreen_FirstUserInfoTextStyle.copyWith(
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              RichText(
                                                                                text: TextSpan(
                                                                                  children: [
                                                                                    TextSpan(
                                                                                      text: '경력 ',
                                                                                      style: kMatchingScreen_FirstUserInfoTextStyle,
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: '${user['playedYears']}\n',
                                                                                      style: kMatchingScreen_FirstUserInfoTextStyle.copyWith(
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: '러버 ',
                                                                                      style: kMatchingScreen_FirstUserInfoTextStyle,
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: '${user['rubber']}',
                                                                                      style: kMatchingScreen_FirstUserInfoTextStyle.copyWith(
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 250),
                                                // Adjust the duration as needed
                                                height:
                                                    viewModel.isShowGraphZero
                                                        ? 380
                                                        : 0,
                                                child: SingleChildScrollView(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  child: Stack(
                                                    children: [
                                                      GraphsWidget(
                                                          titleText:
                                                              '${firstOpponentUser['nickName']}님의 최근 연습 현황',
                                                          backgroundColor:
                                                              kMainColor,
                                                          number:
                                                              2 // 0은 currentuser, 1은 탁구장별 데이터, 2은 다른 유저의 데이터
                                                          ),
                                                      Positioned(
                                                        top: 13.0,
                                                        right: 5.0,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .account_circle_rounded,
                                                            size: 20,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: () {
                                                            LaunchUrl()
                                                                .openBottomSheetMoveToChat(
                                                                    context,
                                                                    firstOpponentUser);
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              StreamBuilder(
                                                stream: viewModel.filterUsers(
                                                    userDocs,
                                                    context,
                                                    chosenPingpongList),
                                                builder: (context, snapshot) {
                                                  List<
                                                          QueryDocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>>
                                                      filteredUserDocs =
                                                      snapshot.data ?? [];

                                                  if (filteredUserDocs
                                                      .isEmpty) {
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      '나와 같은 요일에 나오는 사람은?',
                                                                      style: Theme.of(context).brightness ==
                                                                              Brightness.light
                                                                          ? kMatchingScreenBigTextHeaderTextStyle.copyWith(color: Colors.black)
                                                                          : kMatchingScreenBigTextHeaderTextStyle.copyWith(color: Colors.white),
                                                                    ),
                                                                  ),
                                                                  //Icon(Icons.arrow_drop_up),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 200,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Center(
                                                              child: Text(
                                                                  '데이터 없음')),
                                                        )
                                                      ],
                                                    );
                                                  }

                                                  // } else {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        '나와 같은 요일에 나오는 사람은?',
                                                                        style: Theme.of(context).brightness ==
                                                                                Brightness.light
                                                                            ? kMatchingScreenBigTextHeaderTextStyle.copyWith(color: Colors.black)
                                                                            : kMatchingScreenBigTextHeaderTextStyle.copyWith(color: Colors.white),
                                                                      ),
                                                                    ),
                                                                    // SizedBox(width: 30.0,),
                                                                    // Transform(
                                                                    //   transform: Matrix4.rotationY(math.pi), // 아이콘을 Y축을 중심으로 180도 회전하여 좌우 대칭으로 만듭니다.
                                                                    //   child: GestureDetector(
                                                                    //     onTap: (){
                                                                    //
                                                                    //     },
                                                                    //       child: Icon(Icons.refresh)),
                                                                    // ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  '${filteredUserDocs.length}명',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 200,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        margin: EdgeInsets.only(
                                                            bottom: 5.0),
                                                        child: ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          controller: viewModel
                                                              .courtScrollController,
                                                          physics: viewModel
                                                                  .isShowGraphFirst
                                                              ? NeverScrollableScrollPhysics()
                                                              : AlwaysScrollableScrollPhysics(),
                                                          //shrinkWrap: true,
                                                          itemCount:
                                                              filteredUserDocs
                                                                  .length,
                                                          //snapshot.data?.docs.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            debugPrint(
                                                                'filteredUserDocs snapshot: ${snapshot}');
                                                            debugPrint(
                                                                'filteredUserDocs snapshot.data: ${snapshot.data}');
                                                            var user = snapshot
                                                                    .data?[index]
                                                                    .data()
                                                                as Map<String,
                                                                    dynamic>;
                                                            // 맨 처음 item에 왼쪽에 8.0의 패딩 추가

                                                            EdgeInsets padding =
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            4.0);
                                                            if (index == 0) {
                                                              padding =
                                                                  EdgeInsets.only(
                                                                      left: 8.0,
                                                                      right:
                                                                          4.0);
                                                            }
                                                            // 맨 마지막 item에 오른쪽에 8.0의 패딩 추가
                                                            else if (index ==
                                                                userDocs.length -
                                                                    1) {
                                                              padding =
                                                                  EdgeInsets.only(
                                                                      left: 4.0,
                                                                      right:
                                                                          8.0);
                                                            }

                                                            if (viewModel
                                                                    .clickedIndex1 ==
                                                                -1) {
                                                              // 모두 클릭 가능
                                                              viewModel
                                                                      .ignoringFirst =
                                                                  false;
                                                              viewModel
                                                                      .opacityFirst =
                                                                  1.0;
                                                            } else {
                                                              if (index ==
                                                                  viewModel
                                                                      .clickedIndex1) {
                                                                // 클릭되지 않은 나머니 위젯들이 블러 처리 및 ignore 되어야 함
                                                                matchingScreenViewModel
                                                                        .ignoringFirst =
                                                                    false;
                                                                matchingScreenViewModel
                                                                        .opacityFirst =
                                                                    1.0;
                                                              } else {
                                                                matchingScreenViewModel
                                                                        .ignoringFirst =
                                                                    true;
                                                                matchingScreenViewModel
                                                                        .opacityFirst =
                                                                    0.5;
                                                              }
                                                            }

                                                            return IgnorePointer(
                                                              ignoring: viewModel
                                                                  .ignoringFirst,
                                                              child: Opacity(
                                                                opacity:
                                                                    matchingScreenViewModel
                                                                        .opacityFirst,
                                                                child: Padding(
                                                                  padding:
                                                                      padding,
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      debugPrint(
                                                                          'viewModel.ignoringFirst on tap');
                                                                      if (matchingScreenViewModel
                                                                              .clickedIndex1 ==
                                                                          -1) {
                                                                        await matchingScreenViewModel
                                                                            .updateClickedIndex1(index);
                                                                      } else {
                                                                        await matchingScreenViewModel
                                                                            .updateClickedIndex1(-1);
                                                                      }
                                                                      final number = await matchingScreenViewModel.onTapGraphAppear(
                                                                          context,
                                                                          user,
                                                                          1);
                                                                      secondOpponentUser =
                                                                          user;

                                                                      await matchingScreenViewModel.onTapGraphAppearAfter(
                                                                          number,
                                                                          context,
                                                                          index);
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          5.0),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            190,
                                                                        padding:
                                                                            EdgeInsets.symmetric(horizontal: 5.0),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.grey.withOpacity(0.5),
                                                                              //spreadRadius: 5,
                                                                              blurRadius: 5,
                                                                              offset: Offset(0, 0.5),
                                                                            ),
                                                                          ],
                                                                          color:
                                                                              kMainColor,
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(20.0)),
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            user['photoUrl'].isNotEmpty
                                                                                ? SizedBox(
                                                                                    height: 50,
                                                                                    width: 50,
                                                                                    child: CircleAvatar(
                                                                                      backgroundImage: NetworkImage(user['photoUrl']),
                                                                                    ),
                                                                                  )
                                                                                : Icon(Icons.person),
                                                                            SizedBox(
                                                                              height: 2.5,
                                                                            ),
                                                                            Text(
                                                                              user['nickName'],
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                              style: kMatchingScreen_FirstNicknameTextStyle,
                                                                            ),
                                                                            Text(
                                                                              chosenCourthood,
                                                                              style: kMatchingScreen_FirstAddressTextStyle,
                                                                            ),
                                                                            SizedBox(
                                                                              height: 2.5,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                children: [
                                                                                  RichText(
                                                                                    text: TextSpan(
                                                                                      children: [
                                                                                        TextSpan(
                                                                                          text: '스타일 ',
                                                                                          style: kMatchingScreen_FirstUserInfoTextStyle,
                                                                                        ),
                                                                                        TextSpan(
                                                                                          text: '${user['playStyle']}\n',
                                                                                          style: kMatchingScreen_FirstUserInfoTextStyle.copyWith(
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                        ),
                                                                                        TextSpan(
                                                                                          text: '라켓 ',
                                                                                          style: kMatchingScreen_FirstUserInfoTextStyle,
                                                                                        ),
                                                                                        TextSpan(
                                                                                          text: '${user['racket']}',
                                                                                          style: kMatchingScreen_FirstUserInfoTextStyle.copyWith(
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  RichText(
                                                                                    text: TextSpan(
                                                                                      children: [
                                                                                        TextSpan(
                                                                                          text: '경력 ',
                                                                                          style: kMatchingScreen_FirstUserInfoTextStyle,
                                                                                        ),
                                                                                        TextSpan(
                                                                                          text: '${user['playedYears']}\n',
                                                                                          style: kMatchingScreen_FirstUserInfoTextStyle.copyWith(
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                        ),
                                                                                        TextSpan(
                                                                                          text: '러버 ',
                                                                                          style: kMatchingScreen_FirstUserInfoTextStyle,
                                                                                        ),
                                                                                        TextSpan(
                                                                                          text: '${user['rubber']}',
                                                                                          style: kMatchingScreen_FirstUserInfoTextStyle.copyWith(
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                  //}
                                                },
                                              ),
                                              AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 250),
                                                margin: const EdgeInsets.only(
                                                    bottom: 15.0),
                                                // Adjust the duration as needed
                                                height:
                                                    viewModel.isShowGraphFirst
                                                        ? 380
                                                        : 0,
                                                child: SingleChildScrollView(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  child: Stack(
                                                    children: [
                                                      GraphsWidget(
                                                          titleText:
                                                              '${secondOpponentUser['nickName']}님의 최근 연습 현황',
                                                          backgroundColor:
                                                              kMainColor,
                                                          number:
                                                              2 // 0은 currentuser, 1은 탁구장별 데이터, 2은 다른 유저의 데이터
                                                          ),
                                                      Positioned(
                                                        top: 13.0,
                                                        right: 5.0,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .account_circle_rounded,
                                                            size: 20,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: () {
                                                            LaunchUrl()
                                                                .openBottomSheetMoveToChat(
                                                                    context,
                                                                    secondOpponentUser);
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      }),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  });
                } else {
                  return Stack(
                    children: [
                      Column(
                        children: [
                          IgnorePointer(
                            ignoring: true,
                            child: Stack(
                              children: [
                                StreamBuilder<
                                        QuerySnapshot<Map<String, dynamic>>>(
                                    stream: matchingScreenViewModel
                                        .usersCourtStream,
                                    //RepositoryDefineStream().usersCourtStream,//getUsersCourtStream,
                                    builder: (context, snapshot) {
                                      // Handle real-time data from the stream correctly
                                      List<
                                              QueryDocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          userDocs = snapshot.data?.docs ?? [];
                                      debugPrint(
                                          'usersCourtStream userDocs: $userDocs');

                                      if (userDocs.isEmpty) {
                                        return Center(
                                          child: Text(''),
                                        );
                                      } else if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child:
                                              kCustomCircularProgressIndicator,
                                        );
                                      } else if (snapshot.hasError) {
                                        return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'),
                                        );
                                      } else {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(0),
                                              topRight: Radius.circular(0),
                                              bottomRight: Radius.circular(20),
                                              bottomLeft: Radius.circular(20),
                                            ),
                                            color: Theme.of(context)
                                                .secondaryHeaderColor
                                                .withOpacity(0.5),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: Text('우리 탁구장 사람들 모여라!'),
                                              ),
                                              Container(
                                                height: 200,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                margin: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Container(
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    controller: viewModel
                                                        .courtScrollController,
                                                    //shrinkWrap: true,
                                                    itemCount: userDocs.length,
                                                    //snapshot.data?.docs.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var user = snapshot
                                                              .data?.docs[index]
                                                              .data()
                                                          as Map<String,
                                                              dynamic>;
                                                      //debugPrint('user[pingpongCourt][1].roadAddress: ${user['pingpongCourt'][1]['roadAddress']}');
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8.0,
                                                                vertical: 15.0),
                                                        child: Container(
                                                          width: 190,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: kMainColor,
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        20.0)),
                                                          ),
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                user['photoUrl']
                                                                        .isNotEmpty
                                                                    ? CircleAvatar(
                                                                        backgroundImage:
                                                                            NetworkImage(user['photoUrl']),
                                                                      )
                                                                    : Icon(Icons
                                                                        .person),
                                                                SizedBox(
                                                                  height: 5.0,
                                                                ),
                                                                Text(
                                                                  user[
                                                                      'nickName'],
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                ),
                                                                Text(
                                                                    '${user['playStyle']} / ${user['racket']} / ${user['playedYears']} / ${user['rubber']}'),
                                                                Text(
                                                                    '${user['pingpongCourt']}'),
                                                                Text(
                                                                    chosenCourthood),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }),
                                BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                )
                              ],
                            ),
                          ),
                          IgnorePointer(
                            ignoring: true,
                            child: Stack(
                              children: [
                                StreamBuilder<
                                    QuerySnapshot<Map<String, dynamic>>>(
                                  stream: matchingScreenViewModel
                                      .usersNeighborhoodStream,
                                  builder: (context, snapshot) {
                                    List<
                                            QueryDocumentSnapshot<
                                                Map<String, dynamic>>>
                                        userDocs = snapshot.data?.docs ?? [];

                                    if (userDocs.isEmpty) {
                                      return Center(
                                        child: Text(''),
                                      );
                                    } else if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: kCustomCircularProgressIndicator,
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: Text('Error: ${snapshot.error}'),
                                      );
                                    } else {
                                      // 데이터가 있는 경우
                                      return Column(
                                        children: [
                                          if (Provider.of<ProfileUpdate>(
                                                  context,
                                                  listen: false)
                                              .userProfile
                                              .address!
                                              .isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Text('우리 동네 사람들 모여라!'),
                                            ),
                                          ListView.builder(
                                            //scrollDirection: Axis.horizontal,
                                            controller: viewModel
                                                .neighborhoodScrollController,
                                            shrinkWrap: true,
                                            itemCount:
                                                snapshot.data?.docs.length,
                                            itemBuilder: (context, index) {
                                              var user = snapshot
                                                      .data?.docs[index]
                                                      .data()
                                                  as Map<String, dynamic>;
                                              //debugPrint('user[pingpongCourt][1].roadAddress: ${user['pingpongCourt'][1]['roadAddress']}');
                                              return ListTile(
                                                leading:
                                                    user['photoUrl'].isNotEmpty
                                                        ? CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(user[
                                                                    'photoUrl']),
                                                          )
                                                        : Icon(Icons.person),
                                                title: Text(
                                                  user['nickName'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                subtitle: Text(
                                                    '${user['playStyle']} / ${user['racket']} / ${user['playedYears']} / ${user['rubber']}'),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: MediaQuery.sizeOf(context).height / 2 -
                            100 -
                            65, // 65 는 네비게이션 바 높이
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 100,
                            width: MediaQuery.sizeOf(context).width - 80,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  // Shadow color
                                  spreadRadius: 2,
                                  // Spread radius
                                  blurRadius: 5,
                                  // Blur radius
                                  offset:
                                      Offset(0, 3), // Offset in x and y axes
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  '로그인하면 다른 유저와의\n매칭 기능이 활성화됩니다!',
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black // 다크 모드일 때 텍스트 색상
                                          : Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.normal),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    var returnResult = await MoveToOtherScreen()
                                        .persistentNavPushNewScreen(
                                            context,
                                            SignupScreen(2),
                                            false,
                                            PageTransitionAnimation.fade);

                                    if (returnResult == null) {
                                      // 로그인 마치고 돌아오면 setState 되게끔 설정
                                      setState(() {});
                                    }
                                  },
                                  child: Text(
                                    '로그인',
                                    style: kElevationButtonStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        );
      });
    });
  }
}
