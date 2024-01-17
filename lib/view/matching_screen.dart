import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/models/pingpongList.dart';
import 'package:dnpp/view/signup_screen.dart';
import 'package:dnpp/widgets/paging/main_graphs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../constants.dart';
import '../models/customAppointment.dart';
import '../models/pingpongList.dart';
import '../models/userProfile.dart';
import '../viewModel/loginStatusUpdate.dart';
import '../viewModel/othersPersonalAppointmentUpdate.dart';
import '../viewModel/personalAppointmentUpdate.dart';
import '../viewModel/profileUpdate.dart';

class MatchingScreen extends StatefulWidget {
  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  ScrollController _scrollController = ScrollController();
  ScrollController _courtScrollController = ScrollController();
  ScrollController _neighborhoodScrollController = ScrollController();

  late Future<void> myFuture;

  late Stream<QuerySnapshot<Map<String, dynamic>>> similarUsersCourtStream =
      Stream.empty();
  late Stream<QuerySnapshot<Map<String, dynamic>>> usersCourtStream =
      Stream.empty();
  late Stream<QuerySnapshot<Map<String, dynamic>>> usersNeighborhoodStream =
      Stream.empty();
  late Stream<QuerySnapshot<Map<String, dynamic>>> appointmentsStream =
      Stream.empty();

  List<CustomAppointment> otherUserAppointments = [];

  List<Stream<QuerySnapshot<Map<String, dynamic>>>> usersStreamList = [];
  List<String?> userRoadAddressList = [];

  String chosenCourthood = '탁구장';
  String chosenNeighborhood = '동네';

  int selectedIndex = 0;
  bool isShowGraphZero = false;
  bool isShowGraphFirst = false;
  bool isShowGraphSecond = false;

  Future<void> onTapGraphAppear(Map<String, dynamic> user, int number) async {
    var last28DaysHourlyCounts =
        Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
            .last28DaysHourlyCounts;
    var last28DaysHourlyCountsByDaysOfWeek =
        Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
            .last28DaysHourlyCountsByDaysOfWeek;

    print(
        'last28DaysHourlyCounts: $last28DaysHourlyCounts'); // 여기서 월별 다른 유저들의 모든 시간대 확인 가능
    print(
        'last28DaysHourlyCountsByDaysOfWeek: $last28DaysHourlyCountsByDaysOfWeek'); // 여기서 요일별 다른 유저들의 시간대 확인 가능

    print('onTapGraphAppear number: $number');
    String selectedUserUid = user['uid'];

    print('selectedUserUid: $selectedUserUid');

    List<Appointment> filteredAppointments = otherUserAppointments
        .where((appointment) => appointment.userUid == selectedUserUid)
        .expand((appointment) => appointment.appointments)
        .toList();

    await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        .updateDefaultMeetings(filteredAppointments);
    await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        .personalDaywiseDurationsCalculate(false, true, 'title', 'roadAddress');
    await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        .personalCountHours(false, true, 'title', 'roadAddress');

    setState(() {
      if (number == 0) {
        isShowGraphZero = !isShowGraphZero;
      }

      if (number == 1) {
        isShowGraphFirst = !isShowGraphFirst;
      }

      if (number == 2) {
        isShowGraphSecond = !isShowGraphSecond;
      }
    });
  }

  void showLoginGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          shape: kRoundedRectangleBorder,
          content: Text('로그인을 하시면 다른 유저와의 매칭 기능이 활성화됩니다'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                '뒤로',
                style: kTextButtonTextStyle,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                '로그인',
                style: kTextButtonTextStyle,
              ),
            )
          ],
        );
      },
    );
  }

  Future<List<CustomAppointment>> filterAppointments(
      List<CustomAppointment> otherUserAppointments,
      DateTime targetTime) async {
    var next28daysHourlyCounts =
        Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .next28daysHourlyCounts;
    var next28daysHourlyCountsByDaysOfWeek =
        Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .next28daysHourlyCountsByDaysOfWeek;

    print('next28daysHourlyCounts: $next28daysHourlyCounts');
    print(
        'next28daysHourlyCountsByDaysOfWeek: $next28daysHourlyCountsByDaysOfWeek');
    List<CustomAppointment> filteredAppointments = otherUserAppointments
        .where((appointment) => appointment.appointments.any((app) =>
            app.startTime.isBefore(targetTime) &&
            app.endTime.isAfter(targetTime)))
        .toList();
    return filteredAppointments;
  }

  @override
  void initState() {
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   loadData();
    // });

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

    loadData();
    //showLoginGuideDialog(context);

    super.initState();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? loadData() {
    UserProfile? currentUserProfile =
        Provider.of<ProfileUpdate>(context, listen: false).userProfile;

    if (currentUserProfile != null &&
        currentUserProfile.pingpongCourt!.isNotEmpty &&
        currentUserProfile.address.isNotEmpty) {
      usersCourtStream = FirebaseFirestore.instance
          .collection("UserData")
          .where("pingpongCourt", arrayContainsAny: [
        if (currentUserProfile.pingpongCourt?[0] != null)
          currentUserProfile.pingpongCourt![0].toFirestore(),
      ]).snapshots();

      usersCourtStream.listen((data) {
        for (var doc in data.docs) {
          var userDocs = doc.data();
          print('usersCourtStream data uid: ${userDocs['uid']}');
        }
      });

      usersNeighborhoodStream = FirebaseFirestore.instance
          .collection("UserData")
          .where("address", arrayContainsAny: currentUserProfile.address)
          .snapshots();

      // usersStreamList.add(usersStream);
      print('usersNeighborhoodStream: ${usersNeighborhoodStream.length}');

      usersNeighborhoodStream.listen((data) {
        for (var doc in data.docs) {
          var userDocs = doc.data();
          print('usersNeighborhoodStream data uid: ${userDocs['uid']}');
        }
      });

      for (int index = 0;
          index < currentUserProfile.pingpongCourt!.length;
          index++) {
        print('index: $index');
        String? userRoadAddress =
            currentUserProfile.pingpongCourt?[index].roadAddress;
        //userRoadAddressList.add(userRoadAddress);

        print(
            'currentUserProfile.pingpongCourt![index]: ${currentUserProfile.pingpongCourt![index].title}');
        print('currentUserProfile.address: ${currentUserProfile.address}/');
      }

      similarUsersCourtStream = FirebaseFirestore.instance
          .collection("UserData")
          .where("uid",
              whereIn: Provider.of<OthersPersonalAppointmentUpdate>(context,
                      listen: false)
                  .extractCustomAppointmentsUserUids)
          .snapshots();

      similarUsersCourtStream.listen((data) {
        for (var doc in data.docs) {
          var userDocs = doc.data();
          print('similarUsersCourtStream data uid: ${userDocs['uid']}');
        }
      });
    } else {
      print('5646584698516');
      usersNeighborhoodStream =
          FirebaseFirestore.instance.collection("UserData").snapshots();
      usersCourtStream =
          FirebaseFirestore.instance.collection("UserData").snapshots();

      //usersStreamList.add(usersNeighborhoodStream);
    }

    appointmentsStream =
        FirebaseFirestore.instance.collection('Appointments').snapshots();

    appointmentsStream.listen((data) {
      for (var doc in data.docs) {
        var userDocs = doc.data();

        List<Appointment>? _appointment =
            (userDocs['appointments'] as List<dynamic>?)
                ?.map<Appointment>((dynamic item) {
          return Appointment(
            startTime: (item['startTime'] as Timestamp).toDate(),
            endTime: (item['endTime'] as Timestamp).toDate(),
            subject: item['subject'] as String,
            isAllDay: item['isAllDay'] as bool,
            notes: item['notes'] as String,
            recurrenceRule: item['recurrenceRule'] as String,
          );
        }).toList();

        CustomAppointment _customAppointment = CustomAppointment(
          appointments: _appointment!,
          pingpongCourtName: userDocs['pingpongCourtName'],
          pingpongCourtAddress: userDocs['pingpongCourtAddress'],
          userUid: userDocs['userUid'],
        );
        _customAppointment.id = doc.id;

        otherUserAppointments.add(_customAppointment);
        //print('otherUserAppointments uid: ${_customAppointment.userUid}');
      }
    });

    return null;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> constructNeighborhoodUsersStream(
      String neighborhood) {
    return FirebaseFirestore.instance
        .collection("UserData")
        .where("address", arrayContainsAny: [neighborhood]).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> constructCourtUsersStream(
      PingpongList pingpongList) {
    return FirebaseFirestore.instance
        .collection("UserData")
        .where("pingpongCourt", arrayContainsAny: [
      pingpongList.toFirestore(),
    ]).snapshots();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      constructSimilarUsersCourtStream(PingpongList pingpongList) async {
    await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        .extractCustomAppointments(
            pingpongList.title, pingpongList.roadAddress);

    var userUids =
        Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
            .extractCustomAppointmentsUserUids;

    // Check if userUids is not empty before using whereIn
    if (userUids.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection("UserData")
          .where("uid", whereIn: userUids)
          .snapshots();
    } else {
      // Return an empty stream if userUids is empty
      return Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<OthersPersonalAppointmentUpdate>(
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
            ),
            body: Provider.of<LoginStatusUpdate>(context, listen: false)
                    .isLoggedIn
                ? SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: similarUsersCourtStream,
                            builder: (context, snapshot) {
                              // Handle real-time data from the stream correctly
                              List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                  userDocs = snapshot.data?.docs ?? [];
                              print('userDocs: $userDocs');

                              if (userDocs.isEmpty) {
                                return Center(
                                  child: Text('No users found'),
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
                                    child: Row(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: '나와 비슷한 시간에 나오는 ',
                                            style: Theme.of(context)
                                                        .brightness ==
                                                    Brightness.light
                                                ? kMatchingScreenTextHeaderTextStyle
                                                    .copyWith(
                                                        color: Colors.black)
                                                : kMatchingScreenTextHeaderTextStyle
                                                    .copyWith(
                                                        color: Colors.white),
                                            children: [
                                              TextSpan(
                                                text: chosenCourthood,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' 사람들',
                                              ),
                                            ],
                                          ),
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
                                        //print('user[pingpongCourt][1].roadAddress: ${user['pingpongCourt'][1]['roadAddress']}');
                                        // 맨 처음 item에 왼쪽에 8.0의 패딩 추가
                                        EdgeInsets padding =
                                            EdgeInsets.only(left: 8.0);
                                        if (index == 0) {
                                          padding = EdgeInsets.only(left: 8.0);
                                        }
                                        // 맨 마지막 item에 오른쪽에 8.0의 패딩 추가
                                        else if (index == userDocs.length - 1) {
                                          padding = EdgeInsets.only(right: 8.0);
                                        }

                                        return Padding(
                                          padding: padding,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await onTapGraphAppear(user, 0);
                                            },
                                            child: Stack(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Container(
                                                  width: 200,
                                                  decoration: BoxDecoration(
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
                                                                  NetworkImage(user[
                                                                      'photoUrl']),
                                                            )
                                                          : Icon(Icons.person),
                                                      SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Text(
                                                        user['nickName'],
                                                        style:
                                                            kMatchingScreen_FirstNicknameTextStyle,
                                                      ),
                                                      Text(
                                                        '${user['playStyle']} / ${user['racket']} / ${user['playedYears']} / ${user['rubber']}',
                                                        style:
                                                            kMatchingScreen_FirstUserInfoTextStyle,
                                                      ),
                                                      Text(
                                                        chosenCourthood,
                                                        style:
                                                            kMatchingScreen_FirstAddressTextStyle,
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
                                                    print(
                                                        '이 유저와 함께 탁구를 쳐보자는 메시지를 보낼까요?');
                                                  },
                                                ),
                                              ),
                                            ]),
                                          ),
                                        );

                                        // return Column(
                                        //   children: [
                                        //     user['photoUrl'].isNotEmpty
                                        //           ? CircleAvatar(
                                        //         backgroundImage: NetworkImage(user['photoUrl']),
                                        //       ) : Icon(Icons.person),
                                        //     Text(user['uid']),
                                        //     Text(user['uid'])
                                        //   ],
                                        // );
                                      },
                                    ),
                                  ),
                                ],
                              );
                              // return Container(
                              //   height: 200,
                              //   width: 200,
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(8.0),
                              //     child: Container(
                              //       decoration: BoxDecoration(
                              //         color: Theme.of(context)
                              //             .secondaryHeaderColor,
                              //         borderRadius:
                              //             BorderRadius.circular(8.0),
                              //       ),
                              //       child: const Padding(
                              //         padding: EdgeInsets.symmetric(
                              //           vertical: 15.0,
                              //           horizontal: 5.0,
                              //         ),
                              //         child: Column(
                              //           children: [
                              //             Icon(Icons.person),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // );
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
                            stream: usersCourtStream,
                            builder: (context, snapshot) {
                              // Handle real-time data from the stream correctly
                              List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                  userDocs = snapshot.data?.docs ?? [];
                              print('userDocs: $userDocs');

                              if (userDocs.isEmpty) {
                                return Center(
                                  child: Text('No users found'),
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
                                    child: Row(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: '나와 같은 ',
                                            style: Theme.of(context)
                                                        .brightness ==
                                                    Brightness.light
                                                ? kMatchingScreenTextHeaderTextStyle
                                                    .copyWith(
                                                        color: Colors.black)
                                                : kMatchingScreenTextHeaderTextStyle
                                                    .copyWith(
                                                        color: Colors.white),
                                            children: [
                                              TextSpan(
                                                text: chosenCourthood,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' 사람들',
                                              ),
                                            ],
                                          ),
                                        ),
                                        DropdownButtonHideUnderline(
                                          child: Expanded(
                                            child: DropdownButton(
                                              isExpanded: true,
                                              value: null,
                                              //chosenNeighborhood,
                                              isDense: true,
                                              items: (chosenCourthood != '탁구장')
                                                  ? Provider.of<ProfileUpdate>(
                                                          context,
                                                          listen: false)
                                                      .userProfile
                                                      .pingpongCourt
                                                      ?.map((element) =>
                                                          DropdownMenuItem(
                                                            value: element,
                                                            child: Text(
                                                              element.title,
                                                              style:
                                                                  kAppointmentTextButtonStyle,
                                                            ),
                                                          ))
                                                      .toList()
                                                  : [],
                                              onChanged: (value) async {
                                                var _value =
                                                    value as PingpongList;
                                                print('_value: ${_value}');
                                                chosenCourthood = _value.title;
                                                // usersCourtStream =
                                                //     constructCourtUsersStream(
                                                //         chosenCourthood);
                                                // Find the index of the selected item
                                                selectedIndex =
                                                    Provider.of<ProfileUpdate>(
                                                                context,
                                                                listen: false)
                                                            .userProfile
                                                            .pingpongCourt
                                                            ?.indexWhere(
                                                                (element) =>
                                                                    element ==
                                                                    value) ??
                                                        0;
                                                print(
                                                    'selectedIndex: $selectedIndex');

                                                usersCourtStream =
                                                    constructCourtUsersStream(
                                                        value);

                                                similarUsersCourtStream =
                                                    await constructSimilarUsersCourtStream(
                                                        value);
                                                setState(() {});
                                              },
                                            ),
                                          ),
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
                                        //print('user[pingpongCourt][1].roadAddress: ${user['pingpongCourt'][1]['roadAddress']}');
                                        EdgeInsets padding =
                                            EdgeInsets.only(left: 8.0);
                                        if (index == 0) {
                                          padding = EdgeInsets.only(left: 8.0);
                                        }
                                        // 맨 마지막 item에 오른쪽에 8.0의 패딩 추가
                                        else if (index == userDocs.length - 1) {
                                          padding = EdgeInsets.only(right: 8.0);
                                        }
                                        return Padding(
                                          padding: padding,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await onTapGraphAppear(user, 1);
                                            },
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Container(
                                                    width: 200,
                                                    decoration: BoxDecoration(
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
                                                          height: 5.0,
                                                        ),
                                                        Text(
                                                          user['nickName'],
                                                          style:
                                                              kMatchingScreen_FirstNicknameTextStyle,
                                                        ),
                                                        Text(
                                                          '${user['playStyle']} / ${user['racket']} / ${user['playedYears']} / ${user['rubber']}',
                                                          style:
                                                              kMatchingScreen_FirstUserInfoTextStyle,
                                                        ),
                                                        Text(
                                                          chosenCourthood,
                                                          style:
                                                              kMatchingScreen_FirstAddressTextStyle,
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
                                                      print(
                                                          '이 유저와 함께 탁구를 쳐보자는 메시지를 보낼까요?');
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );

                                        // return Column(
                                        //   children: [
                                        //     user['photoUrl'].isNotEmpty
                                        //           ? CircleAvatar(
                                        //         backgroundImage: NetworkImage(user['photoUrl']),
                                        //       ) : Icon(Icons.person),
                                        //     Text(user['uid']),
                                        //     Text(user['uid'])
                                        //   ],
                                        // );
                                      },
                                    ),
                                  ),
                                ],
                              );
                              // return Container(
                              //   height: 200,
                              //   width: 200,
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(8.0),
                              //     child: Container(
                              //       decoration: BoxDecoration(
                              //         color: Theme.of(context)
                              //             .secondaryHeaderColor,
                              //         borderRadius:
                              //             BorderRadius.circular(8.0),
                              //       ),
                              //       child: const Padding(
                              //         padding: EdgeInsets.symmetric(
                              //           vertical: 15.0,
                              //           horizontal: 5.0,
                              //         ),
                              //         child: Column(
                              //           children: [
                              //             Icon(Icons.person),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // );
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
                          stream: usersNeighborhoodStream,
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
                              return Center(
                                child: Text('No users found'),
                              );
                            }

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
                                  child: Row(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: '나와 같은 ',
                                          style: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? kMatchingScreenTextHeaderTextStyle
                                                  .copyWith(color: Colors.black)
                                              : kMatchingScreenTextHeaderTextStyle
                                                  .copyWith(
                                                      color: Colors.white),
                                          children: [
                                            TextSpan(
                                              text: chosenNeighborhood,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' 사람들',
                                            ),
                                          ],
                                        ),
                                      ),
                                      DropdownButtonHideUnderline(
                                        child: Expanded(
                                          child: DropdownButton(
                                            isExpanded: true,
                                            value: null,
                                            //chosenNeighborhood,
                                            isDense: true,
                                            items: (chosenNeighborhood != '동네')
                                                ? Provider.of<ProfileUpdate>(
                                                        context,
                                                        listen: false)
                                                    .userProfile
                                                    .address
                                                    ?.map((element) =>
                                                        DropdownMenuItem(
                                                          value: element,
                                                          child: Text(
                                                            element,
                                                            style:
                                                                kAppointmentTextButtonStyle,
                                                          ),
                                                        ))
                                                    .toList()
                                                : [],
                                            onChanged: (value) {
                                              setState(() {
                                                print('value: $value');
                                                chosenNeighborhood =
                                                    value.toString();
                                                usersNeighborhoodStream =
                                                    constructNeighborhoodUsersStream(
                                                        chosenNeighborhood);
                                              });
                                            },
                                          ),
                                        ),
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
                                      //print('user[pingpongCourt][1].roadAddress: ${user['pingpongCourt'][1]['roadAddress']}');
                                      return GestureDetector(
                                        onTap: () async {
                                          await onTapGraphAppear(user, 2);
                                        },
                                        child: ListTile(
                                          leading: user['photoUrl'].isNotEmpty
                                              ? CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      user['photoUrl']),
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
                                              Icons.arrow_forward_ios_rounded,
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
                                              print(
                                                  '이 유저와 함께 탁구를 쳐보자는 메시지를 보낼까요?');
                                            },
                                          ),
                                        ),
                                      );

                                      // return Column(
                                      //   children: [
                                      //     user['photoUrl'].isNotEmpty
                                      //           ? CircleAvatar(
                                      //         backgroundImage: NetworkImage(user['photoUrl']),
                                      //       ) : Icon(Icons.person),
                                      //     Text(user['uid']),
                                      //     Text(user['uid'])
                                      //   ],
                                      // );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          // Adjust the duration as needed
                          height: isShowGraphSecond ? 380 : 0,
                          child: SingleChildScrollView(
                            //physics: NeverScrollableScrollPhysics(),
                            child: GraphsWidget(
                                isCourt: false,
                                titleText: '위젯',
                                backgroundColor: kMainColor,
                                isMine: false),
                          ),
                        ),
                      ],
                    ),
                  )
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
                                    stream: usersCourtStream,
                                    builder: (context, snapshot) {
                                      // Handle real-time data from the stream correctly
                                      List<
                                              QueryDocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          userDocs = snapshot.data?.docs ?? [];
                                      print('userDocs: $userDocs');

                                      if (userDocs.isEmpty) {
                                        return Center(
                                          child: Text('No users found'),
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
                                              child: Text('나와 같은 탁구장 사람들'),
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
                                  stream: usersNeighborhoodStream,
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
                                      return Center(
                                        child: Text('No users found'),
                                      );
                                    }

                                    // 데이터가 있는 경우
                                    return Column(
                                      children: [
                                        if (Provider.of<ProfileUpdate>(context,
                                                listen: false)
                                            .userProfile
                                            .address!
                                            .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Text('나와 같은 동네 사람들'),
                                          ),
                                        ListView.builder(
                                          //scrollDirection: Axis.horizontal,
                                          controller:
                                              _neighborhoodScrollController,
                                          shrinkWrap: true,
                                          itemCount: snapshot.data?.docs.length,
                                          itemBuilder: (context, index) {
                                            var user = snapshot
                                                .data?.docs[index]
                                                .data() as Map<String, dynamic>;
                                            //print('user[pingpongCourt][1].roadAddress: ${user['pingpongCourt'][1]['roadAddress']}');
                                            return ListTile(
                                              leading: user['photoUrl']
                                                      .isNotEmpty
                                                  ? CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                              user['photoUrl']),
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
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: SignupScreen(),
                                      withNavBar: false,
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.fade,
                                    );
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
                  ));
      }),
    );
  }
}
