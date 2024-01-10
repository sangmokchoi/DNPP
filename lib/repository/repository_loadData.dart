import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/customAppointment.dart';
import '../models/pingpongList.dart';
import '../models/userProfile.dart';
import '../viewModel/courtAppointmentUpdate.dart';
import '../viewModel/loginStatusUpdate.dart';
import '../viewModel/othersPersonalAppointmentUpdate.dart';
import '../viewModel/personalAppointmentUpdate.dart';
import '../viewModel/profileUpdate.dart';

class LoadData {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> fetchUserData(BuildContext context) async {
    print('fetchUserData Start');

    final User currentUser =
        Provider.of<LoginStatusUpdate>(context, listen: false).currentUser;

    final docRef = db.collection("UserData").doc(currentUser.uid);

    try {
      docRef.get().then(
        (DocumentSnapshot<Map<String, dynamic>> doc) async {
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;

            final _userProfile = UserProfile(
              uid: data['uid'] ?? '',
              email: data['email'] ?? '',
              nickName: data['nickName'] ?? '',
              photoUrl: data['photoUrl'],
              gender: data['gender'] ?? '',
              ageRange: data['ageRange'] ?? '',
              playedYears: data['playedYears'] ?? '',
              address: (data['address'] as List<dynamic>?)
                      ?.map<String>((dynamic item) => item.toString())
                      .toList() ??
                  [],
              pingpongCourt: (data['pingpongCourt'] as List<dynamic>?)
                  ?.map<PingpongList>((dynamic item) {
                return PingpongList(
                  title: item['title'],
                  link: item['link'],
                  description: item['description'],
                  telephone: item['telephone'],
                  address: item['address'],
                  roadAddress: item['roadAddress'],
                  mapx: item['mapx'] ?? 0.0,
                  mapy: item['mapy'] ?? 0.0,
                );
              }).toList(),
              playStyle: data['playStyle'] ?? '',
              rubber: data['rubber'] ?? '',
              racket: data['racket'] ?? '',
            );

            print(
                '_userProfile.pingpongCourt?.length: ${_userProfile.pingpongCourt?.length}');

            await Provider.of<ProfileUpdate>(context, listen: false)
                .updateUserProfile(_userProfile);

            await Provider.of<ProfileUpdate>(context, listen: false)
                .updateUserProfileUpdated(true);
            print('여기서 updateUserProfileUpdated true로 설정했는데?');

            await fetchCurrentUserAppointmentData(context);
            print('await fetchCurrentUserAppointmentData(); completed');

            await fetchOtherUsersAppointmentData(context);
            print('await fetchOtherUsersAppointmentData(); completed');

            await fetchAppointmentDataForCalculatingByCourt(context);
            print('await fetchAppointmentData(); completed');
          } else {
            print('Document does not exist');
            await Provider.of<ProfileUpdate>(context, listen: false)
                .updateUserProfileUpdated(false);
          }
        },
        onError: (e) => print("Error getting document: $e"),
      );
    } catch (e) {
      print('fetchUserData 에러: $e');
    } finally {
      print('fetchUserData 함수 완료');
    }
  }

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

    // final ref = db.collection("Appointments").where("userUid",
    //           isEqualTo: Provider.of<LoginStatusUpdate>(context, listen: false)
    //               .currentUser
    //               .uid).withConverter(
    //   fromFirestore: CustomAppointment.fromFirestore,
    //   toFirestore: (CustomAppointment customAppointment, _) => customAppointment.toFirestore(),
    // );
    // final docSnap = await ref.get();
    // for (var docSnapshot in docSnap.docs) {
    //   if (docSnapshot != null) {
    //     final data = docSnapshot.data() as Map<String, dynamic>;
    //     print(docSnapshot.reference);
    //   } else {
    //     print("No such docSnapshot.");
    //   }
    // }
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

    // final ref = db.collection("Appointments").where("userUid",
    //           isEqualTo: Provider.of<LoginStatusUpdate>(context, listen: false)
    //               .currentUser
    //               .uid).withConverter(
    //   fromFirestore: CustomAppointment.fromFirestore,
    //   toFirestore: (CustomAppointment customAppointment, _) => customAppointment.toFirestore(),
    // );
    // final docSnap = await ref.get();
    // for (var docSnapshot in docSnap.docs) {
    //   if (docSnapshot != null) {
    //     final data = docSnapshot.data() as Map<String, dynamic>;
    //     print(docSnapshot.reference);
    //   } else {
    //     print("No such docSnapshot.");
    //   }
    // }
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

// Future<void> refreshData(BuildContext context) async {
//
//   try {
//
//     await Future.delayed(Duration(seconds: 1));
//     await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
//         .resetMeetings();
//     await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
//         .resetDaywiseDurations();
//     await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
//         .resetHourlyCounts();
//
//     await Provider.of<CourtAppointmentUpdate>(context, listen: false)
//         .resetMeetings();
//     await Provider.of<CourtAppointmentUpdate>(context, listen: false)
//         .resetDaywiseDurations();
//     await Provider.of<CourtAppointmentUpdate>(context, listen: false)
//         .resetHourlyCounts();
//
//     await fetchUserData(context);
//     //setState(() {});
//   } catch (e) {
//     print(e);
//   }
// }
}
