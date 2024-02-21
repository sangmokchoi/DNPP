import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/models/pingpongList.dart';
import 'package:dnpp/view/chatList_Screen.dart';

import 'package:dnpp/view/signup_screen.dart';
import 'package:dnpp/viewModel/MatchingScreen_ViewModel.dart';
import 'package:dnpp/widgets/paging/main_graphs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../repository/launchUrl.dart';
import '../repository/moveToOtherScreen.dart';
import '../statusUpdate/loadingUpdate.dart';
import '../statusUpdate/loginStatusUpdate.dart';
import '../statusUpdate/othersPersonalAppointmentUpdate.dart';
import '../statusUpdate/profileUpdate.dart';

class MatchingScreen extends StatefulWidget {
  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  late Future<void> myFuture;

  final PageController _imagePageController = PageController(initialPage: 0);
  int _currentimage = 0;

  String chosenCourthood = '탁구장';
  String chosenNeighborhood = '동네';

  int selectedIndex = 0;

  ScrollController _scrollController = ScrollController();
  ScrollController _courtScrollController = ScrollController();
  ScrollController _neighborhoodScrollController = ScrollController();

  Map<int, bool> itemExpandStates = {};

  int _clickedIndex1 = -1;
  int _clickedIndex2 = -1;
  int _clickedIndex3 = -1;

  bool isShowGraphZero = false;
  bool isShowGraphFirst = false;
  bool isShowGraphSecond = false;

  late MatchingScreenViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<MatchingScreenViewModel>(context, listen: false);

    if (Provider.of<ProfileUpdate>(context, listen: false)
        .userProfile
        .address
        .isNotEmpty) {
      print('.address[0].isNotEmpty');
      chosenNeighborhood = Provider.of<ProfileUpdate>(context, listen: false)
          .userProfile
          .address[0];
    }

    if (Provider.of<ProfileUpdate>(context, listen: false)
        .userProfile
        .pingpongCourt!
        .isNotEmpty) {
      print('.pingpongCourt![0].title.isNotEmpty');
      chosenCourthood = Provider.of<ProfileUpdate>(context, listen: false)
          .userProfile
          .pingpongCourt![0]
          .title;
    }

    viewModel.listenerAdd(context);
    super.initState();
  }

  //List<CustomAppointment> otherUserAppointments = [];

  bool light1 = true;

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  void onTapGraphAppearAfter(int number) {
    if (number == 0) {
      isShowGraphZero = !isShowGraphZero;
    }

    if (number == 1) {
      isShowGraphFirst = !isShowGraphFirst;

      // _scrollController.animateTo(
      //   _scrollController.offset + 80, // 메뉴 타이틀로 스크롤
      //   duration: Duration(milliseconds: 240),
      //   curve: Curves.easeInOut,
      // );
    }

    if (number == 2) {
      isShowGraphSecond = !isShowGraphSecond;
      print('isShowGraphSecond: $isShowGraphSecond');

      if (_clickedIndex3 != -1) {
        _scrollController.animateTo(
          _scrollController.offset + 380.0, // 위젯 크기만큼 아래로 스크롤
          duration: Duration(milliseconds: 240),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void scrollDown80() {
    _scrollController.animateTo(
      _scrollController.offset + 80.0, // 위젯 크기만큼 아래로 스크롤
      duration: Duration(milliseconds: 240),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Timer.periodic(Duration(seconds: 49), (timer) {
        if (_currentimage <
            Provider.of<LoadingUpdate>(context, listen: false)
                    .refStringListMain
                    .length -
                1) {
          _currentimage++;
        } else {
          _currentimage = 0;
        }

        _imagePageController.animateToPage(
          _currentimage,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      });
    });

    return Consumer<MatchingScreenViewModel>(
        builder: (context, currentUserUpdate, child) {
      return SafeArea(child: Consumer<OthersPersonalAppointmentUpdate>(
          builder: (context, taskData, child) {
        return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              titleTextStyle: kAppbarTextStyle,
              title: Text(
                'Matching',
                style: Theme.of(context).brightness == Brightness.light
                    ? TextStyle(color: Colors.black)
                    : TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              actions: (Provider.of<LoginStatusUpdate>(context, listen: false)
                      .isLoggedIn)
                  ? [
                      Text('알림 수신'),
                      Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          activeColor: Theme.of(context).primaryColor,
                          thumbIcon: thumbIcon,
                          value: light1,
                          onChanged: (bool value) {
                            setState(() {
                              light1 = value;
                              if (light1 == true) {
                                print('알림 수신 YES');
                              } else {
                                print('알림 수신 NO');
                              }
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                            CupertinoIcons.chat_bubble_text_fill,
                            size: 30,
                        ),
                        onPressed: () {
                          //Navigator.push(context, LaunchUrl.createRouteChatListView());
                          MoveToOtherScreen().persistentNavPushNewScreen(
                              context,
                              ChatListView(),
                              false,
                              PageTransitionAnimation.cupertino);
                        },
                      )
                    ]
                  : [],
            ),
            body: Provider.of<LoginStatusUpdate>(context, listen: false)
                    .isLoggedIn
                // 로그인 한 유저
                ? SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 0.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 25,
                            height:
                                (MediaQuery.of(context).size.width - 25) / 5,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: PageView.builder(
                              controller: _imagePageController,
                              itemCount: Provider.of<LoadingUpdate>(context,
                                      listen: false)
                                  .refStringListMatchingScreen
                                  .length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    await LaunchUrl().myLaunchUrl(
                                        "${Provider.of<LoadingUpdate>(context, listen: false).urlMapMatchingScreen[Provider.of<LoadingUpdate>(context, listen: false).refStringListMatchingScreen['$index']]}");
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
                                          Provider.of<LoadingUpdate>(context,
                                                      listen: false)
                                                  .imageMapMatchingScreen[Provider
                                                          .of<LoadingUpdate>(
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
                        ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: viewModel.usersCourtStream,
                            builder: (context, snapshot) {
                              List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                  userDocs = snapshot.data?.docs ?? [];

                              if (userDocs.isEmpty) {
                                print('if (userDocs.isEmpty) {');
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  '같은 탁구장 사람들',
                                                  style: Theme.of(context)
                                                      .brightness ==
                                                      Brightness.light
                                                      ? kMatchingScreenBigTextHeaderTextStyle
                                                      .copyWith(
                                                      color: Colors.black)
                                                      : kMatchingScreenBigTextHeaderTextStyle
                                                      .copyWith(
                                                      color:
                                                      Colors.white),
                                                ),
                                              ),
                                              //Icon(Icons.arrow_drop_up),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                chosenCourthood,
                                                style:
                                                kMatchingScreenTextHeaderTextStyle,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(child: Text('데이터 없음')),
                                    )
                                  ],
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: Center(
                                    child: kCustomCircularProgressIndicator,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  '같은 탁구장 사람들',
                                                  style: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? kMatchingScreenBigTextHeaderTextStyle
                                                          .copyWith(
                                                              color:
                                                                  Colors.black)
                                                      : kMatchingScreenBigTextHeaderTextStyle
                                                          .copyWith(
                                                              color:
                                                                  Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                chosenCourthood,
                                                style:
                                                    kMatchingScreenTextHeaderTextStyle,
                                              ),
                                              DropdownButtonHideUnderline(
                                                child: Expanded(
                                                  child: DropdownButton(
                                                    isExpanded: true,
                                                    value: null,
                                                    //chosenNeighborhood,
                                                    isDense: true,
                                                    items: (chosenCourthood !=
                                                            '탁구장')
                                                        ? Provider.of<
                                                                    ProfileUpdate>(
                                                                context,
                                                                listen: false)
                                                            .userProfile
                                                            .pingpongCourt
                                                            ?.map((element) =>
                                                                DropdownMenuItem(
                                                                  value:
                                                                      element,
                                                                  child: Text(
                                                                    element
                                                                        .title,
                                                                    style:
                                                                        kAppointmentTextButtonStyle,
                                                                  ),
                                                                ))
                                                            .toList()
                                                        : [],
                                                    onChanged: (value) async {
                                                      var _value =
                                                          value as PingpongList;
                                                      print(
                                                          '_value: ${_value}');
                                                      chosenCourthood =
                                                          _value.title;

                                                      // Find the index of the selected item
                                                      selectedIndex = Provider
                                                                  .of<ProfileUpdate>(
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
                                                      print(
                                                          'selectedIndex: $selectedIndex');

                                                      await viewModel
                                                          .updateUsersCourtStream(
                                                              value);
                                                      await viewModel
                                                          .updateSimilarUsersCourtStream(
                                                              context, value);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        controller: _courtScrollController,
                                        //shrinkWrap: true,
                                        itemCount: userDocs.length,
                                        //snapshot.data?.docs.length,
                                        itemBuilder: (context, index) {
                                          // var user = snapshot.data?.docs[index]
                                          //     .data() as Map<String, dynamic>;
                                          var user = snapshot.data?.docs[0] // index
                                              .data() as Map<String, dynamic>;

                                          bool ignoring = false;
                                          double _opacity = 1.0;

                                          EdgeInsets padding =
                                              EdgeInsets.symmetric(horizontal: 4.0);
                                          if (index == 0) {
                                            padding =
                                                EdgeInsets.only(left: 8.0, right: 4.0);
                                          }
                                          // 맨 마지막 item에 오른쪽에 8.0의 패딩 추가
                                          else if (index ==
                                              userDocs.length - 1) {
                                            padding =
                                                EdgeInsets.only(left: 4.0, right: 8.0);
                                          }

                                          if (_clickedIndex1 == -1) {
                                            // 모두 클릭 가능
                                            ignoring = false;
                                            _opacity = 1.0;
                                          } else {
                                            if (index == _clickedIndex1) {
                                              // 클릭되지 않은 나머니 위젯들이 블러 처리 및 ignore 되어야 함
                                              ignoring = false;
                                              _opacity = 1.0;
                                            } else {
                                              ignoring = true;
                                              _opacity = 0.5;
                                            }
                                          }
                                          return IgnorePointer(
                                            ignoring: ignoring,
                                            child: Opacity(
                                              opacity: _opacity,
                                              child: Padding(
                                                padding: padding,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    if (_clickedIndex1 == -1) {
                                                      setState(() {
                                                        _clickedIndex1 =
                                                            index; // 클릭된 index 업데이트
                                                      });
                                                    } else {
                                                      setState(() {
                                                        _clickedIndex1 =
                                                            -1; // _clickedIndex1 초기화
                                                      });
                                                    }
                                                    final number =
                                                        await viewModel
                                                            .onTapGraphAppear(
                                                                context,
                                                                user,
                                                                0);

                                                    setState(() {
                                                      onTapGraphAppearAfter(
                                                          number);
                                                    });
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: Container(
                                                          width: 200,
                                                          decoration:
                                                              BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                //spreadRadius: 5,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    0, 0.5),
                                                              ),
                                                            ],
                                                            color: kMainColor,
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        20.0)),
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              user['photoUrl']
                                                                      .isNotEmpty
                                                                  ? SizedBox(
                                                                      width: 60,
                                                                      height:
                                                                          60,
                                                                      child:
                                                                          CircleAvatar(
                                                                        backgroundImage:
                                                                            NetworkImage(user['photoUrl']),
                                                                      ),
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .person,
                                                                      size: 60,
                                                                    ),
                                                              SizedBox(
                                                                height: 2.5,
                                                              ),
                                                              Text(
                                                                user[
                                                                    'nickName'],
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
                                                                height: 2.5,
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
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
                                                                      text:
                                                                          TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                '경력 ',
                                                                            style:
                                                                                kMatchingScreen_FirstUserInfoTextStyle,
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                '${user['playedYears']}\n',
                                                                            style:
                                                                                kMatchingScreen_FirstUserInfoTextStyle.copyWith(
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                '러버 ',
                                                                            style:
                                                                                kMatchingScreen_FirstUserInfoTextStyle,
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                '${user['rubber']}',
                                                                            style:
                                                                                kMatchingScreen_FirstUserInfoTextStyle.copyWith(
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
                                                      Positioned(
                                                        top: 10.0,
                                                        right: 5.0,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .arrow_forward_ios_rounded,
                                                            size: 15,
                                                            color: Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .light
                                                                ? Colors
                                                                    .black // 다크 모드일 때 텍스트 색상
                                                                : Colors.white,
                                                          ),
                                                          onPressed: () {
                                                            // 아이콘 버튼이 눌렸을 때 수행할 동작 추가
                                                            print(
                                                                'user; $user'); // opponent 정보 전달
                                                            print(
                                                                '이 유저와 함께 탁구를 쳐보자는 메시지를 보낼까요?');
                                                            LaunchUrl()
                                                                .openBottomSheetMoveToChat(
                                                                    context,
                                                                    user);
                                                          },
                                                        ),
                                                      ),
                                                    ],
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
                              }
                            }),

                        AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          // Adjust the duration as needed
                          height: isShowGraphZero ? 380 : 0,
                          child: SingleChildScrollView(
                            //physics: NeverScrollableScrollPhysics(),
                            child: GraphsWidget(
                                isCourt: false,
                                titleText: '위젯',
                                backgroundColor: kMainColor,
                                isMine: false),
                          ),
                        ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: viewModel.similarUsersCourtStream,
                            //RepositoryDefineStream().similarUsersCourtStream,//getSimilarUsersCourtStream,
                            builder: (context, snapshot) {
                              // Handle real-time data from the stream correctly
                              List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                  userDocs = snapshot.data?.docs ?? [];
                              print(
                                  'similarUsersCourtStream userDocs: $userDocs');

                              if (userDocs.isEmpty) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  '시간대가 같은 탁구장 사람들',
                                                  style: Theme.of(context)
                                                      .brightness ==
                                                      Brightness.light
                                                      ? kMatchingScreenBigTextHeaderTextStyle
                                                      .copyWith(
                                                      color: Colors.black)
                                                      : kMatchingScreenBigTextHeaderTextStyle
                                                      .copyWith(
                                                      color:
                                                      Colors.white),
                                                ),
                                              ),
                                              //Icon(Icons.arrow_drop_up),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                chosenCourthood,
                                                style:
                                                kMatchingScreenTextHeaderTextStyle,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                      SizedBox(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                        child: Center(child: Text('데이터 없음')),
                                      )
                                  ],
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: kCustomCircularProgressIndicator,
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '시간대가 같은 탁구장 사람들',
                                                style: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? kMatchingScreenBigTextHeaderTextStyle
                                                        .copyWith(
                                                            color: Colors.black)
                                                    : kMatchingScreenBigTextHeaderTextStyle
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                              ),
                                            ),
                                            //Icon(Icons.arrow_drop_up),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              chosenCourthood,
                                              style:
                                                  kMatchingScreenTextHeaderTextStyle,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      controller: _courtScrollController,
                                      //shrinkWrap: true,
                                      itemCount: userDocs.length,
                                      //snapshot.data?.docs.length,
                                      itemBuilder: (context, index) {
                                        var user = snapshot.data?.docs[index]
                                            .data() as Map<String, dynamic>;
                                        // 맨 처음 item에 왼쪽에 8.0의 패딩 추가
                                        bool ignoring = false;
                                        double _opacity = 1.0;

                                        EdgeInsets padding =
                                        EdgeInsets.symmetric(horizontal: 4.0);
                                        if (index == 0) {
                                          padding =
                                              EdgeInsets.only(left: 8.0, right: 4.0);
                                        }
                                        // 맨 마지막 item에 오른쪽에 8.0의 패딩 추가
                                        else if (index ==
                                            userDocs.length - 1) {
                                          padding =
                                              EdgeInsets.only(left: 4.0, right: 8.0);
                                        }


                                        if (_clickedIndex2 == -1) {
                                          // 모두 클릭 가능
                                          ignoring = false;
                                          _opacity = 1.0;
                                        } else {
                                          if (index == _clickedIndex2) {
                                            // 클릭되지 않은 나머니 위젯들이 블러 처리 및 ignore 되어야 함
                                            ignoring = false;
                                            _opacity = 1.0;
                                          } else {
                                            ignoring = true;
                                            _opacity = 0.5;
                                          }
                                        }

                                        return IgnorePointer(
                                          ignoring: ignoring,
                                          child: Opacity(
                                            opacity: _opacity,
                                            child: Padding(
                                              padding: padding,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  if (_clickedIndex2 == -1) {
                                                    setState(() {
                                                      _clickedIndex2 =
                                                          index; // 클릭된 index 업데이트
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _clickedIndex2 =
                                                          -1; // _clickedIndex2 초기화
                                                    });
                                                  }
                                                  final number = await viewModel
                                                      .onTapGraphAppear(
                                                          context, user, 1);

                                                  setState(() {
                                                    onTapGraphAppearAfter(
                                                        number);
                                                  });
                                                },
                                                child: Stack(children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Container(
                                                      width: 200,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            //spreadRadius: 5,
                                                            blurRadius: 5,
                                                            offset:
                                                                Offset(0, 0.5),
                                                          ),
                                                        ],
                                                        color: kMainColor,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0)),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          user['photoUrl']
                                                                  .isNotEmpty
                                                              ? CircleAvatar(
                                                                  backgroundImage:
                                                                      NetworkImage(
                                                                          user[
                                                                              'photoUrl']),
                                                                )
                                                              : Icon(
                                                                  Icons.person),
                                                          SizedBox(
                                                            height: 2.5,
                                                          ),
                                                          Text(
                                                            user['nickName'],
                                                            style:
                                                                kMatchingScreen_FirstNicknameTextStyle,
                                                          ),
                                                          Text(
                                                            chosenCourthood,
                                                            style:
                                                            kMatchingScreen_FirstAddressTextStyle,
                                                          ),
                                                          SizedBox(
                                                            height: 2.5,
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                10.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
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
                                                                  text:
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                        '경력 ',
                                                                        style:
                                                                        kMatchingScreen_FirstUserInfoTextStyle,
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                        '${user['playedYears']}\n',
                                                                        style:
                                                                        kMatchingScreen_FirstUserInfoTextStyle.copyWith(
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                        '러버 ',
                                                                        style:
                                                                        kMatchingScreen_FirstUserInfoTextStyle,
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                        '${user['rubber']}',
                                                                        style:
                                                                        kMatchingScreen_FirstUserInfoTextStyle.copyWith(
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
                                                  Positioned(
                                                    top: 10.0,
                                                    right: 5.0,
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        size: 15,
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.light
                                                            ? Colors
                                                                .black // 다크 모드일 때 텍스트 색상
                                                            : Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        // 아이콘 버튼이 눌렸을 때 수행할 동작 추가
                                                        print('user; $user');
                                                        print(
                                                            '이 유저와 함께 탁구를 쳐보자는 메시지를 보낼까요?');
                                                        LaunchUrl()
                                                            .openBottomSheetMoveToChat(
                                                                context, user);
                                                      },
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),

                        AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          // Adjust the duration as needed
                          height: isShowGraphFirst ? 380 : 0,
                          child: SingleChildScrollView(
                            //physics: NeverScrollableScrollPhysics(),
                            child: GraphsWidget(
                                isCourt: false,
                                titleText: '위젯',
                                backgroundColor: kMainColor,
                                isMine: false),
                          ),
                        ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: viewModel.usersNeighborhoodStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: kCustomCircularProgressIndicator,
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }

                            // 데이터가 없을 때
                            if (snapshot.data?.docs.isEmpty ?? true) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '같은 동네 사람들',
                                                style: Theme.of(context)
                                                    .brightness ==
                                                    Brightness.light
                                                    ? kMatchingScreenBigTextHeaderTextStyle
                                                    .copyWith(
                                                    color: Colors.black)
                                                    : kMatchingScreenBigTextHeaderTextStyle
                                                    .copyWith(
                                                    color:
                                                    Colors.white),
                                              ),
                                            ),
                                            //Icon(Icons.arrow_drop_up),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              chosenNeighborhood,
                                              style:
                                              kMatchingScreenTextHeaderTextStyle,
                                            ),
                                            DropdownButtonHideUnderline(
                                              child: Expanded(
                                                child: DropdownButton(
                                                  isExpanded: true,
                                                  value: null,
                                                  //chosenNeighborhood,
                                                  isDense: true,
                                                  items: (chosenNeighborhood !=
                                                      '동네')
                                                      ? Provider.of<
                                                      ProfileUpdate>(
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
                                                            style:
                                                            kAppointmentTextButtonStyle,
                                                          ),
                                                        ),
                                                  )
                                                      .toList()
                                                      : [],
                                                  onChanged: (value) async {
                                                    print('value: $value');
                                                    chosenNeighborhood =
                                                        value.toString();

                                                    await viewModel
                                                        .updateUsersNeighborhoodStream(
                                                        chosenNeighborhood).then((value) {

                                                      scrollDown80();

                                                    });


                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(child: Text('데이터 없음')),
                                  )
                                ],
                              );
                            } else {
                              // 데이터가 있는 경우
                              return Column(
                                children: [
                                  // if (Provider.of<ProfileUpdate>(context,
                                  //         listen: false)
                                  //     .userProfile
                                  //     .address!
                                  //     .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '같은 동네 사람들',
                                                style: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? kMatchingScreenBigTextHeaderTextStyle
                                                        .copyWith(
                                                            color: Colors.black)
                                                    : kMatchingScreenBigTextHeaderTextStyle
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                              ),
                                            ),
                                            //Icon(Icons.arrow_drop_up),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(chosenNeighborhood,
                                                style:
                                                    kMatchingScreenTextHeaderTextStyle),
                                            DropdownButtonHideUnderline(
                                              child: Expanded(
                                                child: DropdownButton(
                                                  isExpanded: true,
                                                  value: null,
                                                  //chosenNeighborhood,
                                                  isDense: true,
                                                  items: (chosenNeighborhood !=
                                                          '동네')
                                                      ? Provider.of<
                                                                  ProfileUpdate>(
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
                                                                style:
                                                                    kAppointmentTextButtonStyle,
                                                              ),
                                                            ),
                                                          )
                                                          .toList()
                                                      : [],
                                                  onChanged: (value) async {
                                                    print('value: $value');
                                                    chosenNeighborhood =
                                                        value.toString();

                                                    await viewModel
                                                        .updateUsersNeighborhoodStream(
                                                            chosenNeighborhood).then((value) {

                                                      //scrollDown80();

                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.builder(
                                      //scrollDirection: Axis.horizontal,
                                      controller: _neighborhoodScrollController,
                                      shrinkWrap: true,
                                      itemCount: snapshot.data?.docs.length,
                                      itemBuilder: (context, index) {
                                        var user = snapshot.data?.docs[index]
                                            .data() as Map<String, dynamic>;

                                        bool ignoring = false;
                                        double _opacity = 1.0;

                                        if (_clickedIndex3 == -1) {
                                          // 모두 클릭 가능
                                          ignoring = false;
                                          _opacity = 1.0;
                                        } else {
                                          if (index == _clickedIndex3) {
                                            // 클릭되지 않은 나머니 위젯들이 블러 처리 및 ignore 되어야 함
                                            ignoring = false;
                                            _opacity = 1.0;
                                          } else {
                                            ignoring = true;
                                            _opacity = 0.5;
                                          }
                                        }

                                        return IgnorePointer(
                                          ignoring: ignoring,
                                          child: Opacity(
                                            opacity: _opacity,
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (_clickedIndex3 == -1) {
                                                  setState(() {
                                                    _clickedIndex3 =
                                                        index; // 클릭된 index 업데이트
                                                  });
                                                } else {
                                                  setState(() {
                                                    _clickedIndex3 =
                                                        -1; // _clickedIndex3 초기화
                                                  });
                                                }

                                                final number = await viewModel
                                                    .onTapGraphAppear(
                                                        context, user, 2);

                                                setState(() {
                                                  onTapGraphAppearAfter(number);

                                                  for (int i = 0;
                                                      i <
                                                          itemExpandStates
                                                              .length;
                                                      i++) {
                                                    if (i != index) {
                                                      itemExpandStates[i] =
                                                          false;
                                                    }
                                                  }

                                                  itemExpandStates[index] =
                                                      !(itemExpandStates[
                                                              index] ??
                                                          false);
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    leading: user['photoUrl']
                                                            .isNotEmpty
                                                        ? CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(user[
                                                                    'photoUrl']),
                                                          )
                                                        : Icon(Icons.person),
                                                    title: Text(
                                                      user['nickName'],
                                                      style:
                                                          kMatchingScreen_SecondNicknameTextStyle,
                                                    ),
                                                    subtitle: Text(
                                                      '${user['playStyle']} / ${user['racket']} / ${user['playedYears']} / ${user['rubber']}',
                                                      style:
                                                          kMatchingScreen_SecondUserInfoTextStyle,
                                                    ),
                                                    trailing: IconButton(
                                                      icon: Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        size: 15.0,
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.light
                                                            ? Colors
                                                                .black // 다크 모드일 때 텍스트 색상
                                                            : Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        // 아이콘 버튼이 눌렸을 때 수행할 동작 추가
                                                        print('user; $user');
                                                        print(
                                                            '이 유저와 함께 탁구를 쳐보자는 메시지를 보낼까요?');
                                                        LaunchUrl()
                                                            .openBottomSheetMoveToChat(
                                                                context, user);
                                                      },
                                                    ),
                                                  ),
                                                  AnimatedContainer(
                                                    duration: Duration(
                                                        milliseconds: 250),
                                                    // Adjust the duration as needed
                                                    height: itemExpandStates[
                                                                index] ??
                                                            false
                                                        ? 380
                                                        : 0,
                                                    child:
                                                        SingleChildScrollView(
                                                      //physics: NeverScrollableScrollPhysics(),
                                                      child: GraphsWidget(
                                                          isCourt: false,
                                                          titleText: '위젯',
                                                          backgroundColor:
                                                              kMainColor,
                                                          isMine: false),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ) // 로그인한 유저
                ///////////////////
                // 로그인 안 한 유저
                : Stack(
                    children: [
                      Column(
                        children: [
                          IgnorePointer(
                            ignoring: true,
                            child: Stack(
                              children: [
                                StreamBuilder<
                                        QuerySnapshot<Map<String, dynamic>>>(
                                    stream: viewModel.usersCourtStream,
                                    //RepositoryDefineStream().usersCourtStream,//getUsersCourtStream,
                                    builder: (context, snapshot) {
                                      // Handle real-time data from the stream correctly
                                      List<
                                              QueryDocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          userDocs = snapshot.data?.docs ?? [];
                                      print(
                                          'usersCourtStream userDocs: $userDocs');

                                      if (userDocs.isEmpty) {
                                        return Center(
                                          child: Text(''),
                                        );
                                      }

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child:
                                              kCustomCircularProgressIndicator,
                                        );
                                      }

                                      if (snapshot.hasError) {
                                        return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'),
                                        );
                                      }

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
                                              child: Text('같은 탁구장 사람들'),
                                            ),
                                            SizedBox(
                                              height: 200,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Container(
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  controller:
                                                      _courtScrollController,
                                                  //shrinkWrap: true,
                                                  itemCount: userDocs.length,
                                                  //snapshot.data?.docs.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var user = snapshot
                                                            .data?.docs[index]
                                                            .data()
                                                        as Map<String, dynamic>;
                                                    //print('user[pingpongCourt][1].roadAddress: ${user['pingpongCourt'][1]['roadAddress']}');
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0,
                                                          vertical: 15.0),
                                                      child: Container(
                                                        width: 200,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: kMainColor,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20.0)),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            user['photoUrl']
                                                                    .isNotEmpty
                                                                ? CircleAvatar(
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                            user['photoUrl']),
                                                                  )
                                                                : Icon(Icons
                                                                    .person),
                                                            SizedBox(
                                                              height: 5.0,
                                                            ),
                                                            Text(user[
                                                                'nickName']),
                                                            Text(
                                                                '${user['playStyle']} / ${user['racket']} / ${user['playedYears']} / ${user['rubber']}'),
                                                            Text(
                                                                chosenCourthood),
                                                          ],
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
                                  stream: viewModel.usersNeighborhoodStream,
                                  //RepositoryDefineStream().usersNeighborhoodStream,//getUsersNeighborhoodStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: kCustomCircularProgressIndicator,
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Text('Error: ${snapshot.error}'),
                                      );
                                    }

                                    // 데이터가 없을 때
                                    if (snapshot.data?.docs.isEmpty ?? true) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(
                                                        '시간대가 같은 탁구장 사람들',
                                                        style: Theme.of(context)
                                                            .brightness ==
                                                            Brightness.light
                                                            ? kMatchingScreenBigTextHeaderTextStyle
                                                            .copyWith(
                                                            color: Colors.black)
                                                            : kMatchingScreenBigTextHeaderTextStyle
                                                            .copyWith(
                                                            color:
                                                            Colors.white),
                                                      ),
                                                    ),
                                                    //Icon(Icons.arrow_drop_up),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      chosenCourthood,
                                                      style:
                                                      kMatchingScreenTextHeaderTextStyle,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 200,
                                            width: MediaQuery.of(context).size.width,
                                            child: Center(child: Text('데이터 없음')),
                                          )
                                        ],
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
                                              child: Text('같은 동네 사람들'),
                                            ),
                                          ListView.builder(
                                            //scrollDirection: Axis.horizontal,
                                            controller:
                                                _neighborhoodScrollController,
                                            shrinkWrap: true,
                                            itemCount:
                                                snapshot.data?.docs.length,
                                            itemBuilder: (context, index) {
                                              var user = snapshot
                                                      .data?.docs[index]
                                                      .data()
                                                  as Map<String, dynamic>;
                                              //print('user[pingpongCourt][1].roadAddress: ${user['pingpongCourt'][1]['roadAddress']}');
                                              return ListTile(
                                                leading:
                                                    user['photoUrl'].isNotEmpty
                                                        ? CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(user[
                                                                    'photoUrl']),
                                                          )
                                                        : Icon(Icons.person),
                                                title: Text(user['nickName']),
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
                        top: MediaQuery.of(context).size.height / 2 -
                            100 -
                            65, // 65 는 네비게이션 바 높이
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 100,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '로그인해서 매칭 기능을 활성화하세요!',
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black // 다크 모드일 때 텍스트 색상
                                          : Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.normal),
                                ),
                                SizedBox(width: 8.0),
                                ElevatedButton(
                                  onPressed: () {
                                    MoveToOtherScreen()
                                        .persistentNavPushNewScreen(
                                            context,
                                            SignupScreen(),
                                            false,
                                            PageTransitionAnimation.fade);
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
                  )); // 로그인 안 한 유저
      }));
    });
  }
}
