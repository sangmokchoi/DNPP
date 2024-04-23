import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/statusUpdate/profileUpdate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../constants.dart';
import '../models/customAppointment.dart';
import '../models/pingpongList.dart';
import '../models/userProfile.dart';
import '../repository/chatBackgroundListen.dart';
import '../repository/repository_userData.dart';
import '../repository/repsitory_appointments.dart';
import '../statusUpdate/othersPersonalAppointmentUpdate.dart';

class MatchingScreenViewModel extends ChangeNotifier {

  ScrollController scrollController = ScrollController();
  ScrollController courtScrollController = ScrollController();
  ScrollController neighborhoodScrollController = ScrollController(

  );

  List<CustomAppointment> otherUserAppointments = [];

  Map<int, bool> itemExpandStates = {};

  bool isShowGraphZero = false;
  bool isShowGraphFirst = false;
  bool isShowGraphSecond = false;

  int clickedIndex0 = -1;
  int clickedIndex1 = -1;
  int clickedIndex2 = -1;

  bool ignoringZero = false;
  double opacityZero = 1.0;

  bool ignoringFirst = false;
  double opacityFirst = 1.0;

  bool ignoringSecond = false;
  double opacitySecond = 1.0;

  Color headTitleColor1 = kMainColor;
  Color headTitleColor2 = Colors.grey;

  Future<void> toggleHeadTitleColor(bool isHeadTitleColor1) async {
    if (isHeadTitleColor1){
      headTitleColor1 = kMainColor;
      headTitleColor2 = Colors.grey;
    } else {
      headTitleColor1 = Colors.grey;
      headTitleColor2 = kMainColor;
    }
    notifyListeners();
  }

  Future<void> updateClickedIndex0(int value) async {
    clickedIndex0 = value;
    notifyListeners();
  }

  Future<void> updateClickedIndex1(int value) async {
    clickedIndex1 = value;
    notifyListeners();
  }

  Future<void> updateClickedIndex2(int value) async {
    clickedIndex2 = value;
    notifyListeners();
  }

  Future<void> clearClickedIndex() async {
    clickedIndex0 = -1;
    clickedIndex1 = -1;
    clickedIndex2 = -1;
    notifyListeners();
  }

  Future<void> clearAllShowGraph() async {
    isShowGraphZero = false;
    isShowGraphFirst = false;
    isShowGraphSecond = false;
    notifyListeners();
  }

  Future<void> onTapGraphAppearAfter(int number, BuildContext context, int index) async {

    await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        .resetSelectedList();

    if (number == 0) {
      isShowGraphZero = !isShowGraphZero;

      isShowGraphFirst = false;
      isShowGraphSecond = false;

      // ignoringFirst = false;
      // _opacityFirst = 1.0;
      // ignoringSecond = false;
      // _opacitySecond = 1.0;

      //_clickedIndex0 = -1;
      clickedIndex1 = -1;
      clickedIndex2 = -1;

      if (clickedIndex0 != -1) {
        Future.delayed(Duration(milliseconds: 250)).then((value) {

          scrollController.animateTo(
            180,
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );

        });

      }
    }

    if (number == 1) {
      isShowGraphFirst = !isShowGraphFirst;

      isShowGraphZero = false;
      isShowGraphSecond = false;

      // ignoringZero = false;
      // _opacityZero = 1.0;
      // ignoringSecond = false;
      // _opacitySecond = 1.0;

      clickedIndex0 = -1;
      //_clickedIndex1 = -1;
      clickedIndex2 = -1;

      if (clickedIndex1 != -1) {
        Future.delayed(Duration(milliseconds: 250)).then((value) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent + 12,
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );

        });

      }
    }

    if (number == 2) {
      isShowGraphSecond = !isShowGraphSecond;

      isShowGraphZero = false;
      isShowGraphFirst = false;

      // ignoringZero = false;
      // _opacityZero = 1.0;
      // ignoringFirst = false;
      // _opacityFirst = 1.0;

      clickedIndex0 = -1;
      clickedIndex1 = -1;
      //_clickedIndex2 = -1;

      if (clickedIndex2 != -1) {
        Future.delayed(Duration(milliseconds: 250)).then((value) {
          print('MediaQuery.of(context).size.height * 0.5: ${MediaQuery.of(context).size.height * 0.5}');
          print('neighborhoodScrollController.offset: ${neighborhoodScrollController.offset}');

          if (index >= 1) {

            neighborhoodScrollController.animateTo(
              index * 83.0, // 72.0, // 위젯 크기만큼 아래로 스크롤
              duration: Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }

        });

      }
    }
    notifyListeners();
  }

  Future<void> updateItemExpandStates(int index, bool value) async {
    itemExpandStates[index] = value;
    notifyListeners();
  }

  Future<int> onTapGraphAppear(
      BuildContext context, Map<String, dynamic> user, int number) async {

    String selectedUserUid = user['uid'].toString();

    print('otherUserAppointments: $otherUserAppointments');
    print('otherUserAppointments.length: ${otherUserAppointments.length}');
    print('selectedUserUid: $selectedUserUid');

    List<Appointment> filteredAppointments =
    otherUserAppointments //getOtherUserAppointments
        .where((appointment) => appointment.userUid == selectedUserUid)
        .expand((appointment) => appointment.appointments)
        .toList();

    print('filteredAppointments: $filteredAppointments');

    await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        .updateDefaultMeetings(filteredAppointments).then((value) async {
      await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
          .daywiseDurationsCalculate(false, true, 'title', 'roadAddress');
      await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
          .personalCountHours(false, true, 'title', 'roadAddress');
    });

    //notifyListeners();
    return number;
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

// Future<List<CustomAppointment>> filterAppointments(
//     List<CustomAppointment> otherUserAppointments,
//     DateTime targetTime) async {
//   var next28daysHourlyCounts =
//       Provider.of<PersonalAppointmentUpdate>(context, listen: false)
//           .next28daysHourlyCounts;
//   var next28daysHourlyCountsByDaysOfWeek =
//       Provider.of<PersonalAppointmentUpdate>(context, listen: false)
//           .next28daysHourlyCountsByDaysOfWeek;
//
//   print('next28daysHourlyCounts: $next28daysHourlyCounts');
//   print(
//       'next28daysHourlyCountsByDaysOfWeek: $next28daysHourlyCountsByDaysOfWeek');
//   List<CustomAppointment> filteredAppointments = otherUserAppointments
//       .where((appointment) => appointment.appointments.any((app) =>
//           app.startTime.isBefore(targetTime) &&
//           app.endTime.isAfter(targetTime)))
//       .toList();
//   return filteredAppointments;
// }

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> usersCourtSubscription;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> similarUsersCourtSubscription;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> usersNeighborhoodSubscription;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> appointmentsSubscription;

  Stream<QuerySnapshot<Map<String, dynamic>>> usersCourtStream = Stream.empty();
  Stream<QuerySnapshot<Map<String, dynamic>>> similarUsersCourtStream = Stream.empty();
  Stream<QuerySnapshot<Map<String, dynamic>>> usersNeighborhoodStream = Stream.empty();
  Stream<QuerySnapshot<Map<String, dynamic>>> appointmentsStream = Stream.empty();

  Future<void> updateUsersNeighborhoodStream(String value) async {
    usersNeighborhoodStream = RepositoryUserData().constructNeighborhoodUsersStream(value);
    //notifyListeners();
    //return;
  }

  Future<void> updateUsersCourtStream(PingpongList value) async {
    usersCourtStream = RepositoryUserData().constructCourtUsersStream(value);
    //notifyListeners();
    //return;
  }

  // Future<void> updateSimilarUsersCourtStream(BuildContext context, PingpongList value) async {
  //   await RepositoryUserData().constructSimilarUsersCourtStream(context, value);
  //   //similarUsersCourtStream = RepositoryUserData().constructSimilarUsersCourtStream(context, value);
  //   //notifyListeners();
  //   //return;
  // }

  Future<void> addStreamListener(BuildContext context) async {
    print('addStreamListener 시작');

    usersCourtSubscription = usersCourtStream.listen((data) { });
    similarUsersCourtSubscription = similarUsersCourtStream.listen((data) { });
    usersNeighborhoodSubscription = usersNeighborhoodStream.listen((data) { });

    appointmentsStream = RepositoryAppointments().allAppointments(); // usersCourtStream;//
    appointmentsSubscription = appointmentsStream.listen((data) {
      print('appointmentsStream 시작');
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
        // print('otherUserAppointments _customAppointment: $_customAppointment');
        // if (_appointment != null || _appointment.isNotEmpty) {
        //   Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false).addCustomMeeting(_customAppointment);
        //   print('_customAppointment add 함');
        //   for (int i = 0; i < _appointment.length; i++) {
        //     Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false).addMeeting(_appointment[i]);
        //   }
        // }

      }
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? setListener(BuildContext context) {

    // similarUsersCourtSubscription.cancel();
    // usersCourtSubscription.cancel();
    // usersNeighborhoodSubscription.cancel();
    // appointmentsSubscription.cancel();

    UserProfile? currentUserProfile =
        Provider.of<ProfileUpdate>(context, listen: false).userProfile;

    if (currentUserProfile != UserProfile.emptyUserProfile) {
      print('if (currentUserProfile != null) {');

      usersCourtStream =
          RepositoryUserData().usersCourtStream(currentUserProfile);

      // if (currentUserProfile.pingpongCourt!.isNotEmpty) {
      //   print(' if (currentUserProfile.pingpongCourt!.isNotEmpty) {');
      //   similarUsersCourtStream =
      //       RepositoryUserData().similarUsersCourtStream(context, currentUserProfile);
      //   //similarUsersCourtStream = RepositoryUserData().constructSimilarUsersCourtStream(context, value);
      // }

      if (currentUserProfile.address.isNotEmpty) {
        print('if (currentUserProfile.address.isNotEmpty) {');
        usersNeighborhoodStream =
            RepositoryUserData().usersNeighborhoodStream(currentUserProfile);
        //updateUsersNeighborhoodStream(currentUserProfile.address.first);
        // 첫 동네 이름으로 세팅
      }

    }

    notifyListeners();
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> filterUsers(List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs, BuildContext context, PingpongList chosenCourt) async* {

    var userUids = await Provider.of<OthersPersonalAppointmentUpdate>(context,
        listen: false)
        .extractCustomAppointments(
        chosenCourt.title, chosenCourt.roadAddress, false);
    print('filterUsers userUids: $userUids');

    var filteredUsers = userDocs.where((DocumentSnapshot document) {
      final finalUserUid = document.data() as Map<String, dynamic>;
      bool isUserInList = userUids.contains(finalUserUid['uid']);
      return isUserInList;
    }).toList();

    yield filteredUsers;
    // 매칭스크린 진입 후 맨 처음에 출력되는 유저 리스트 들을 저장했다가 다시 사용하는 식으로 바꾸는게 나을듯
  }

  Future<void> initializeListeners() async {
    print('매칭스크린 초기화');
    similarUsersCourtSubscription.cancel();
    usersCourtSubscription.cancel();
    usersNeighborhoodSubscription.cancel();
    appointmentsSubscription.cancel();

    // similarUsersCourtStream = Stream.empty();
    // usersCourtStream = Stream.empty();
    // usersNeighborhoodStream = Stream.empty();
    // appointmentsStream = Stream.empty();


    notifyListeners();
  }
  Future notify() async {
    notifyListeners();
  }

}