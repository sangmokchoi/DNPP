
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/LocalDataSource/firebase_fireStore/DS_Local_appointments.dart';
import 'package:dnpp/LocalDataSource/firebase_realtime/messages/DS_Local_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../LocalDataSource/firebase_fireStore/DS_Local_userData.dart';
import '../RemoteDataSource/firebase_messaging.dart';
import '../models/customAppointment.dart';
import '../models/pingpongList.dart';
import '../models/userProfile.dart';

class RepositoryFirestoreAppointments {

  final _localDSAppointments = LocalDSAppointments();

  // _localDSAppointments
  Future<void> getAddAppointment(CustomAppointment newCustomAppointment) async {
    return await _localDSAppointments.addAppointment(newCustomAppointment);
  }
  Future<void> getReAddAppointment(String value, CustomAppointment newCustomAppointment) async {
    return await _localDSAppointments.reAddAppointment(value, newCustomAppointment);
  }
  Future<void> getUpdateAppointment(String value, CustomAppointment newCustomAppointment) async {
    return await _localDSAppointments.updateAppointment(value, newCustomAppointment);
  }
  Future<void> getRemoveAppointment(String value) async {
    return await _localDSAppointments.removeAppointment(value);
  }
  Future<void> getDeleteUserAppointment(String uid) async {
    return await _localDSAppointments.deleteUserAppointment(uid);
  }
  Future<void> getFetchCurrentUserAppointmentData(BuildContext context, User currentUser) async {
    return await _localDSAppointments.fetchCurrentUserAppointmentData(context, currentUser);
  }
  Future<void> getFetchOtherUsersAppointmentData(BuildContext context, User currentUser) async {
    return await _localDSAppointments.fetchOtherUsersAppointmentData(context, currentUser);
  }
  Future<void> getFetchAppointmentDataForCalculatingByCourt(BuildContext context) async {
    return await _localDSAppointments.fetchAppointmentDataForCalculatingByCourt(context);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllAppointments() {
    return _localDSAppointments.allAppointments();
  }
}