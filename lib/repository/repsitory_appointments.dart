import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/repository/repository_userData.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/customAppointment.dart';
import '../models/pingpongList.dart';
import '../statusUpdate/courtAppointmentUpdate.dart';
import '../statusUpdate/loginStatusUpdate.dart';
import '../statusUpdate/othersPersonalAppointmentUpdate.dart';
import '../statusUpdate/personalAppointmentUpdate.dart';
import '../statusUpdate/profileUpdate.dart';

class RepositoryAppointments {

  FirebaseFirestore db = FirebaseFirestore.instance;


  Future<void> fetchCurrentUserAppointmentData(BuildContext context) async {
    print('fetchCurrentUserAppointmentData 시작');
    // 해당 함수는 유저가 로그인한 상태일 때 실행되어야 함

    try {
      db
          .collection("Appointments")
          .where("userUid",
          isEqualTo: Provider.of<LoginStatusUpdate>(context, listen: false)
              .currentUser
              .uid)
          .get()
          .then(
            (querySnapshot) {
          print("Successfully completed");

          for (var docSnapshot in querySnapshot.docs) {
            //final data = docSnapshot.data();
            //print("Document ID: ${docSnapshot.id}");
            final data = docSnapshot.data() as Map<String, dynamic>;

            List<Appointment>? _appointment =
            (data['appointments'] as List<dynamic>?)
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
              pingpongCourtName: data['pingpongCourtName'],
              pingpongCourtAddress: data['pingpongCourtAddress'],
              userUid: data['userUid'],
            );
            _customAppointment.id = docSnapshot.id;

            //print('_customAppointment: ${_customAppointment}');
            // //Provider.of<AppointmentUpdate>(context, listen: false).meetings.add(_appointment?.first);

            if (_appointment != null || _appointment.isNotEmpty) {
              Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                  .addCustomMeeting(_customAppointment);
              Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                  .addMeeting(_appointment.first);
            }
          }

          Provider.of<PersonalAppointmentUpdate>(context, listen: false)
              .personalDaywiseDurationsCalculate(
              true, true, 'title', 'roadAddress');
          Provider.of<PersonalAppointmentUpdate>(context, listen: false)
              .personalCountHours(true, true, 'title', 'roadAddress');
          // Provider.of<AppointmentUpdate>(context, listen: false)
          //     .updateRecentDays(0);
          //setState(() {});
        },
        onError: (e) =>
            print("fetchCurrentUserAppointmentData Error completing: $e"),
      );
    } catch (e) {
      print(e);
    } finally {
      print('fetchUserData 함수 완료');
    }

  }

  Future<void> fetchOtherUsersAppointmentData(BuildContext context) async {
    print('fetchOtherUsersAppointmentData 시작');

    try {
      db
          .collection("Appointments")
      // .where("userUid",
      // isNotEqualTo: Provider.of<LoginStatusUpdate>(context, listen: false)
      //     .currentUser
      //     .uid)
          .get()
          .then(
            (querySnapshot) {
          print("Successfully completed");

          for (var docSnapshot in querySnapshot.docs) {
            //final data = docSnapshot.data();
            //print("Document ID: ${docSnapshot.id}");
            final data = docSnapshot.data() as Map<String, dynamic>;

            List<Appointment>? _appointment =
            (data['appointments'] as List<dynamic>?)
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
              pingpongCourtName: data['pingpongCourtName'],
              pingpongCourtAddress: data['pingpongCourtAddress'],
              userUid: data['userUid'],
            );
            _customAppointment.id = docSnapshot.id;

            //print('_customAppointment: ${_customAppointment}');
            // //Provider.of<AppointmentUpdate>(context, listen: false).meetings.add(_appointment?.first);

            if (_appointment != null || _appointment.isNotEmpty) {
              Provider.of<OthersPersonalAppointmentUpdate>(context,
                  listen: false)
                  .addCustomMeeting(_customAppointment);
              Provider.of<OthersPersonalAppointmentUpdate>(context,
                  listen: false)
                  .addMeeting(_appointment.first);
            }
          }

          Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
              .personalDaywiseDurationsCalculate(
              true, true, 'title', 'roadAddress');
          Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
              .personalCountHours(true, true, 'title', 'roadAddress');
          // Provider.of<AppointmentUpdate>(context, listen: false)
          //     .updateRecentDays(0);
          //setState(() {});
        },
        onError: (e) =>
            print("fetchOtherUsersAppointmentData Error completing: $e"),
      );
    } catch (e) {
      print(e);
    } finally {
      print('fetchUserData 함수 완료');
    }

  }

  Future<void> fetchAppointmentDataForCalculatingByCourt(
      BuildContext context) async {
    print('fetchAppointmentData 시작');

    final pingpongCourt = Provider.of<ProfileUpdate>(context, listen: false)
        .userProfile
        .pingpongCourt;

    print('fetchAppointmentData pingpongCourt: $pingpongCourt');

    if (pingpongCourt != null) {
      try {
        await Future.forEach(pingpongCourt, (PingpongList pingpong) async {
          print('forEach pingpongCourtAddress: ${pingpong.roadAddress}');

          final querySnapshot = await db
              .collection("Appointments")
              .where("pingpongCourtAddress", isEqualTo: pingpong.roadAddress)
              .get();

          print("fetchAppointmentData Successfully completed");

          for (var docSnapshot in querySnapshot.docs) {
            final data = docSnapshot.data() as Map<String, dynamic>;
            //print('fetchAppointmentData data:\n $data');

            final String pingpongCourtName = data['pingpongCourtName'];
            final String pingpongCourtAddress = data['pingpongCourtAddress'];

            Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .addPingpongCourtNameList(pingpongCourtName);
            Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .addPingpongCourtAddressList(pingpongCourtAddress);

            List<Appointment>? _appointment =
            (data['appointments'] as List<dynamic>?)
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
              pingpongCourtName: data['pingpongCourtName'],
              pingpongCourtAddress: data['pingpongCourtAddress'],
              userUid: data['userUid'],
            );
            _customAppointment.id = docSnapshot.id;

            Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .addCustomMeeting(_customAppointment);
            Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .addMeeting(_appointment.first);
          }

          Provider.of<CourtAppointmentUpdate>(context, listen: false)
              .extractPingpongCourtAddressList();
        });

        Provider.of<CourtAppointmentUpdate>(context, listen: false)
            .courtDaywiseDurationsCalculate(
            true,
            false,
            Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .pingpongCourtNameList
                .first,
            Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .pingpongCourtAddressList
                .first);
        Provider.of<CourtAppointmentUpdate>(context, listen: false)
            .courtCountHours(
            true,
            false,
            Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .pingpongCourtNameList
                .first,
            Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .pingpongCourtAddressList
                .first);

        Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
            .extractCustomAppointments(
            Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .pingpongCourtNameList
                .first,
            Provider.of<CourtAppointmentUpdate>(context, listen: false)
                .pingpongCourtAddressList
                .first);
        // 여기서 탁구장별 유저 본인과 비슷한 시간대 찾음

        //setState(() {});
      } catch (e) {
        print("fetchAppointmentData Error completing: $e");
      }
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> allAppointments() {
    final snapshots = db.collection("Appointments").snapshots();

    return snapshots;
  }


}
