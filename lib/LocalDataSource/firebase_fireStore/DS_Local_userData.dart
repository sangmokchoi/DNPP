import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/LocalDataSource/firebase_fireStore/DS_Local_appointments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../models/pingpongList.dart';
import '../../models/userProfile.dart';
import '../../statusUpdate/courtAppointmentUpdate.dart';
import '../../statusUpdate/othersPersonalAppointmentUpdate.dart';
import '../../statusUpdate/personalAppointmentUpdate.dart';
import '../../statusUpdate/profileUpdate.dart';

class LocalDSUserData {

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> setProfile(String value, UserProfile newProfile) async {
    final docRef = db
        .collection("UserData")
        .withConverter(
          fromFirestore: UserProfile.fromFirestore,
          toFirestore: (UserProfile newProfile, options) =>
              newProfile.toFirestore(),
        )
        .doc(value);

    await docRef.set(newProfile);
  }

  Future<void> fetchUserData(BuildContext context) async {
    print('func fetchUserData Start');

    try {

      await Provider.of<PersonalAppointmentUpdate>(
          context,
          listen: false)
          .clear();
      print("fetchUserData 에서 Provider.of<PersonalAppointmentUpdate>(context).newMeetings.length: ${Provider.of<PersonalAppointmentUpdate>(context, listen: false).newMeetings.length}");

      await Provider.of<OthersPersonalAppointmentUpdate>(
          context,
          listen: false)
          .clear();
      print("fetchUserData 에서 Provider.of<PersonalAppointmentUpdate>(context).newMeetings.length: ${Provider.of<PersonalAppointmentUpdate>(context, listen: false).newMeetings.length}");

      await Provider.of<CourtAppointmentUpdate>(
          context,
          listen: false)
          .clear();

      print("fetchUserData 에서 Provider.of<PersonalAppointmentUpdate>(context).newMeetings.length: ${Provider.of<PersonalAppointmentUpdate>(context, listen: false).newMeetings.length}");

      try {
        await LocalDSUserData().refreshData(context);

        try {

          final User? currentUser = FirebaseAuth.instance.currentUser;
          //Provider.of<LoginStatusUpdate>(context, listen: false).currentUser;
          print('currentUser?.uid: ${currentUser?.uid}');

          final docRef = db.collection("UserData").doc(currentUser?.uid);

          await docRef.get().then(
                (DocumentSnapshot<Map<String, dynamic>> doc) async {
              if (doc.exists) {
                print('Document exist');
                final data = doc.data() as Map<String, dynamic>;

                final _userProfile = UserProfile(
                  uid: data['uid'] ?? '',
                  email: data['email'] ?? '',
                  nickName: data['nickName'] ?? '',
                  selfIntroduction: data['selfIntroduction'] ?? '',
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

                await LocalDSAppointments()
                    .fetchCurrentUserAppointmentData(context, currentUser!).then((value) async {
                  await LocalDSAppointments()
                      .fetchOtherUsersAppointmentData(context, currentUser!).then((value) async {
                    print('await fetchOtherUsersAppointmentData(); completed');
                    await LocalDSAppointments()
                        .fetchAppointmentDataForCalculatingByCourt(context);
                    print('await fetchAppointmentData(); completed');
                    return;
                  });

                });
                print('await fetchCurrentUserAppointmentData(); completed');

                //return;
              } else {
                print('Document does not exist');
                await Provider.of<ProfileUpdate>(context, listen: false)
                    .updateUserProfileUpdated(false);
                return;
              }
            },
            onError: (e) => print("Error getting document: $e"),
          );
        } catch (e) {
          print('fetchUserData e: $e');
        }

      } catch (e) {
        print('refresh fetchUserData e: $e');
      }

    } catch (e) {
      print('clear fetchUserData e: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      final querySnapshot =
          await db.collection("UserData").where("uid", isEqualTo: uid).get();

      // userUid 필드가 일치하는 문서가 있는지 확인
      if (querySnapshot.docs.isNotEmpty) {
        // 검색된 문서 중 첫 번째 문서를 삭제
        final documentId = querySnapshot.docs[0].id;
        await db.collection("UserData").doc(documentId).delete();
        // 문서 삭제 성공
        print("해당 userUid를 가진 문서를 삭제했습니다.");
      } else {
        // 해당 userUid를 가진 문서가 없음
        print("해당 userUid를 가진 문서가 없습니다.");
      }
    } catch (e) {
      print('deleteUser e: $e');
      //LaunchUrl().alertFunc(context, '알림', '유저 정보 삭제 중 에러가 발생했습니다', '확인', () { });
    }
  }

  Future<void> refreshData(BuildContext context) async {
    await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        .resetMeetings();
    await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        .resetDaywiseDurations();
    await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        .resetHourlyCounts();

    await Provider.of<CourtAppointmentUpdate>(context, listen: false)
        .resetMeetings();
    await Provider.of<CourtAppointmentUpdate>(context, listen: false)
        .resetDaywiseDurations();
    await Provider.of<CourtAppointmentUpdate>(context, listen: false)
        .resetHourlyCounts();

    // await RepositoryUserData().fetchUserData(context);
    return;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> constructCourtUsersStream(
      PingpongList pingpongList) {
    final snapshots = db
        .collection("UserData")
        .where("pingpongCourt", arrayContainsAny: [
          pingpongList.toFirestore(),
        ])
        .where('uid', isNotEqualTo: auth.currentUser?.uid)
        .snapshots();

    return snapshots;
  }

  // Stream<QuerySnapshot<Map<String, dynamic>>> constructSimilarUsersCourtStream(
  //     BuildContext context, PingpongList pingpongList) async* {
  //   print('constructSimilarUsersCourtStream 진입');
  //   print('pingpongList.title: ${pingpongList.title}');
  //   print('pingpongList.roadAddress: ${pingpongList.roadAddress}');
  //
  //   var userUids = await Provider.of<OthersPersonalAppointmentUpdate>(context,
  //           listen: false)
  //       .extractCustomAppointments(
  //           pingpongList.title, pingpongList.roadAddress, true);
  //   print('userUids: $userUids');
  //
  //   // var userUids =
  //   //     Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
  //   //         .extractCustomAppointmentsUserUids;
  //
  //   // Check if userUids is not empty before using whereIn
  //   if (userUids.isNotEmpty) {
  //     print('if (userUids.isNotEmpty) {');
  //     final snapshots = db
  //         .collection("UserData")
  //         .where("pingpongCourt", arrayContainsAny: [
  //       pingpongList.toFirestore(),
  //     ])
  //         .where("uid", whereIn: userUids)
  //         .where('uid', isNotEqualTo: auth.currentUser?.uid)
  //         .snapshots();
  //     yield* snapshots;
  //   } else {
  //     print('Return an empty stream if userUids is empty');
  //     final snapshots = Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
  //     print('snapshots: $snapshots');
  //
  //     yield* snapshots;
  //   }
  // }

  Stream<QuerySnapshot<Map<String, dynamic>>> constructNeighborhoodUsersStream(
      String neighborhood) {
    final snapshots = db
        .collection("UserData")
        .where("address", arrayContainsAny: [neighborhood])
        .where('uid', isNotEqualTo: auth.currentUser?.uid)
        .snapshots();

    return snapshots;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> allUserData() {
    final snapshots = db.collection("UserData").snapshots();

    return snapshots;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> usersCourtStream(
      UserProfile? currentUserProfile) {

    if (auth.currentUser != null &&
        (currentUserProfile?.pingpongCourt!.isNotEmpty ?? false)) {

      final snapshots = db
          .collection("UserData")
          .where("pingpongCourt", arrayContainsAny: [
            currentUserProfile?.pingpongCourt?[0].toFirestore(),
          ])
          .where('uid', isNotEqualTo: auth.currentUser?.uid)
          .snapshots();
      print('usersCourtStream 진행중');
      return snapshots;

    } else {
      return Stream.empty();
    }
  }

  // Stream<QuerySnapshot<Map<String, dynamic>>> similarUsersCourtStream(
  //     BuildContext context, UserProfile? currentUserProfile) async* {
  //   Stream<QuerySnapshot<Map<String, dynamic>>> snapshots;
  //
  //   if (auth.currentUser != null &&
  //       (currentUserProfile?.pingpongCourt!.isNotEmpty ?? false)) {
  //
  //     // final similarUsersUids =
  //     //     Provider
  //     //         .of<OthersPersonalAppointmentUpdate>(context, listen: false)
  //     //         .extractCustomAppointmentsUserUids;
  //     var userUids = await Provider.of<OthersPersonalAppointmentUpdate>(context,
  //         listen: false)
  //         .extractCustomAppointments(
  //         currentUserProfile!.pingpongCourt![0].title, currentUserProfile!.pingpongCourt![0].roadAddress, true);
  //
  //     final currentUser = FirebaseAuth.instance.currentUser;
  //
  //     if (userUids.isNotEmpty) {
  //       print('similarUsersCourtStream 시작 if (similarUsersUids.isNotEmpty) {');
  //       snapshots = db
  //           .collection("UserData")
  //           .where("pingpongCourt", arrayContainsAny: [
  //         currentUserProfile?.pingpongCourt?[0].toFirestore(),
  //       ])
  //           .where("uid", whereIn: userUids)
  //           .where('uid', isNotEqualTo: currentUser?.uid)
  //           .snapshots();
  //       print('snapshots: ${snapshots}');
  //     } else {
  //       print('if (similarUsersUids.isEmpty) {');
  //       if (currentUser != null) {
  //         // 유저가 로그인은 된 상태인데, 현재 비슷한 시간대의 유저가 없는 상황
  //         print('if (currentUser != null) {');
  //         print('유저가 로그인은 된 상태인데, 현재 비슷한 시간대의 유저가 없는 상황');
  //         // snapshots =
  //         //     db.collection("UserData")
  //         //         //.where("uid", whereNotIn: [currentUser.uid])
  //         //         .where('uid', isNotEqualTo: currentUser.uid)
  //         //         .snapshots();
  //         snapshots = Stream.empty();
  //       } else {
  //         snapshots = Stream.empty();
  //       }
  //     }
  //   } else {
  //     snapshots = Stream.empty();
  //   }
  //
  //   yield* snapshots;
  // }

  Stream<QuerySnapshot<Map<String, dynamic>>> usersNeighborhoodStream(
      UserProfile? currentUserProfile) {
    final snapshots = db
        .collection("UserData")
        //.where("address", arrayContainsAny: currentUserProfile?.address) // 모든 동 유저가 불려짐
        .where("address", arrayContains: currentUserProfile?.address.first)
        .where('uid', isNotEqualTo: currentUserProfile?.uid)
        .snapshots();

    return snapshots;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> oneUserData(String uid) {
    final snapshots =
        db.collection("UserData").where('uid', isEqualTo: uid).snapshots();

    return snapshots;
  }
}
