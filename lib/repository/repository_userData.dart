import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/repository/repsitory_appointments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/pingpongList.dart';
import '../models/userProfile.dart';

import '../statusUpdate/loginStatusUpdate.dart';
import '../statusUpdate/othersPersonalAppointmentUpdate.dart';
import '../statusUpdate/profileUpdate.dart';

class RepositoryUserData {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> fetchUserData(BuildContext context) async {
    print('fetchUserData Start');

    final User? currentUser = FirebaseAuth.instance.currentUser;
    //Provider.of<LoginStatusUpdate>(context, listen: false).currentUser;
    print('currentUser?.uid: ${currentUser?.uid}');

    final docRef = db.collection("UserData").doc(currentUser?.uid);

    docRef.get().then(
      (DocumentSnapshot<Map<String, dynamic>> doc) async {
        if (doc.exists) {
          print('Document exist');
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

          await RepositoryAppointments()
              .fetchCurrentUserAppointmentData(context);
          print('await fetchCurrentUserAppointmentData(); completed');

          await RepositoryAppointments()
              .fetchOtherUsersAppointmentData(context);
          print('await fetchOtherUsersAppointmentData(); completed');

          await RepositoryAppointments()
              .fetchAppointmentDataForCalculatingByCourt(context);
          print('await fetchAppointmentData(); completed');
        } else {
          print('Document does not exist');
          await Provider.of<ProfileUpdate>(context, listen: false)
              .updateUserProfileUpdated(false);
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );

  }

  Stream<QuerySnapshot<Map<String, dynamic>>> similarUsersCourtStream(
      BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> snapshots;

    final userUids =
        Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
            .extractCustomAppointmentsUserUids;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (userUids.isNotEmpty) {
      snapshots =
          db.collection("UserData")
              .where("uid", whereIn: userUids)
              //.where('uid', isNotEqualTo: currentUser?.uid)
              .snapshots();
    } else {
      if (currentUser != null) {
        snapshots =
            db.collection("UserData")
                .where("uid", whereNotIn: [currentUser.uid])
                //.where('uid', isNotEqualTo: currentUser.uid)
                .snapshots();
      } else {
        snapshots = Stream.empty();
      }
    }

    return snapshots;
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      constructSimilarUsersCourtStream(
          BuildContext context, PingpongList pingpongList) async {
    await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        .extractCustomAppointments(
            pingpongList.title, pingpongList.roadAddress);

    var userUids =
        Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
            .extractCustomAppointmentsUserUids;

    // Check if userUids is not empty before using whereIn
    if (userUids.isNotEmpty) {
      return db
          .collection("UserData")
          .where("uid", whereIn: userUids)
      //.where('uid', isNotEqualTo: auth.currentUser?.uid)
          .snapshots();
    } else {
      // Return an empty stream if userUids is empty
      return Stream.empty();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> constructCourtUsersStream(
      PingpongList pingpongList) {
    final snapshots =
        db.collection("UserData")
            .where("pingpongCourt", arrayContainsAny: [
      pingpongList.toFirestore(),
    ]).where('uid', isNotEqualTo: auth.currentUser?.uid).snapshots();

    return snapshots;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> constructNeighborhoodUsersStream(
      String neighborhood) {
    final snapshots = db
        .collection("UserData")
        .where("address", arrayContainsAny: [neighborhood])
        .where('uid', isNotEqualTo: auth.currentUser?.uid).snapshots();

    return snapshots;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> allUserData() {
    final snapshots = db.collection("UserData").snapshots();

    return snapshots;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> usersCourtStream(
      UserProfile? currentUserProfile) {
    final snapshots =
        db.collection("UserData").where("pingpongCourt", arrayContainsAny: [
      if (currentUserProfile?.pingpongCourt?[0] != null)
        currentUserProfile?.pingpongCourt![0].toFirestore(),
    ]).
        where('uid', isNotEqualTo: auth.currentUser?.uid).snapshots();

    return snapshots;
  }

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
}
