
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/LocalDataSource/firebase_realtime/messages/DS_Local_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../LocalDataSource/firebase_fireStore/DS_Local_userData.dart';
import '../RemoteDataSource/firebase_messaging.dart';
import '../models/pingpongList.dart';
import '../models/userProfile.dart';

class RepositoryFirestoreUserData {

  final _localDSUserData = LocalDSUserData();

  // _localDSChat
  Future<void> getSetProfile(String value, UserProfile newProfile) async {
    return await _localDSUserData.setProfile(value, newProfile);
  }
  Future<void> getFetchUserData(BuildContext context) async {
    return await _localDSUserData.fetchUserData(context);
  }
  Future<void> getDeleteUser(String uid) async {
    return await _localDSUserData.deleteUser(uid);
  }
  Future<void> getRefreshData(BuildContext context) async {
    return await _localDSUserData.refreshData(context);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getConstructCourtUsersStream(PingpongList pingpongList) {
    return _localDSUserData.constructCourtUsersStream(pingpongList);
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getConstructNeighborhoodUsersStream(String neighborhood) {
    return _localDSUserData.constructNeighborhoodUsersStream(neighborhood);
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUserData() {
    return _localDSUserData.allUserData();
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersCourtStream(UserProfile? currentUserProfile) {
    return _localDSUserData.usersCourtStream(currentUserProfile);
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersNeighborhoodStream(UserProfile? currentUserProfile) {
    return _localDSUserData.usersNeighborhoodStream(currentUserProfile);
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getOneUserData(String uid) {
    return _localDSUserData.oneUserData(uid);
  }
}