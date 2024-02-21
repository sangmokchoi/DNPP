
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
import '../repository/repository_userData.dart';
import '../repository/repsitory_appointments.dart';
import '../statusUpdate/othersPersonalAppointmentUpdate.dart';

class MatchingScreenViewModel extends ChangeNotifier {

  List<CustomAppointment> otherUserAppointments = [];

  Future<int> onTapGraphAppear(
      BuildContext context, Map<String, dynamic> user, int number) async {
    // var last28DaysHourlyCounts =
    //     Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
    //         .last28DaysHourlyCounts;
    // var last28DaysHourlyCountsByDaysOfWeek =
    //     Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
    //         .last28DaysHourlyCountsByDaysOfWeek;

    String selectedUserUid = user['uid'];

    List<Appointment> filteredAppointments =
    otherUserAppointments //getOtherUserAppointments
        .where((appointment) => appointment.userUid == selectedUserUid)
        .expand((appointment) => appointment.appointments)
        .toList();

    await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        .updateDefaultMeetings(filteredAppointments);
    await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        .personalDaywiseDurationsCalculate(false, true, 'title', 'roadAddress');
    await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        .personalCountHours(false, true, 'title', 'roadAddress');
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

  Stream<QuerySnapshot<Map<String, dynamic>>> similarUsersCourtStream = Stream.empty();
  Stream<QuerySnapshot<Map<String, dynamic>>> usersCourtStream = Stream.empty();
  Stream<QuerySnapshot<Map<String, dynamic>>> usersNeighborhoodStream = Stream.empty();
  Stream<QuerySnapshot<Map<String, dynamic>>> appointmentsStream = Stream.empty();

  Future<void> updateUsersNeighborhoodStream(String value) async {
    usersNeighborhoodStream = RepositoryUserData().constructNeighborhoodUsersStream(value);
    notifyListeners();
    return;
  }

  Future<void> updateUsersCourtStream(PingpongList value) async {
    usersCourtStream = RepositoryUserData().constructCourtUsersStream(value);
    notifyListeners();
    return;
  }

  Future<void> updateSimilarUsersCourtStream(BuildContext context, PingpongList value) async {
    similarUsersCourtStream = await RepositoryUserData().constructSimilarUsersCourtStream(context, value);
    notifyListeners();
    return;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? listenerAdd(BuildContext context) {
    print('listerAdd');
    UserProfile? currentUserProfile =
        Provider.of<ProfileUpdate>(context, listen: false).userProfile;
    print('currentUserProfile pingpongcourt: ${currentUserProfile.pingpongCourt}');
    print('currentUserProfile address: ${currentUserProfile.address}');


    if (currentUserProfile != null) {
      usersCourtStream =
          RepositoryUserData().usersCourtStream(currentUserProfile);
    } else {
      print('배포시 삭제 필요'); // 모든 유저 데이터가 와서는 안됨
      usersCourtStream = RepositoryUserData().allUserData();
    }

    if (currentUserProfile.pingpongCourt!.isNotEmpty) {
      similarUsersCourtStream =
          RepositoryUserData().similarUsersCourtStream(context);
    } else {

    }

    if (currentUserProfile.address.isNotEmpty) {
      usersNeighborhoodStream =
          RepositoryUserData().usersNeighborhoodStream(currentUserProfile);
      //updateUsersNeighborhoodStream(currentUserProfile.address.first);
      // 첫 동네 이름으로 세팅
    } else {
      print('배포시 삭제 필요'); // 모든 유저 데이터가 와서는 안됨
      usersNeighborhoodStream = RepositoryUserData().allUserData();
    }

    usersCourtStream.listen((data) {});
    similarUsersCourtStream.listen((data) {});
    usersNeighborhoodStream.listen((data) {});

    appointmentsStream = RepositoryAppointments().allAppointments();
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

      }
    });
    //notifyListeners();
  }

}