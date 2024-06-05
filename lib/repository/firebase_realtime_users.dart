import 'package:dnpp/LocalDataSource/firebase_realtime/users/DS_Local_Announcement.dart';
import 'package:dnpp/LocalDataSource/firebase_realtime/users/DS_Local_PolicyCheck.dart';
import 'package:dnpp/LocalDataSource/firebase_realtime/users/DS_Local_reportedCount.dart';

import '../LocalDataSource/firebase_realtime/users/DS_Local_FCMToken.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_badge.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_deviceId.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_deviceName.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_isNotificationAble.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_isUserInApp.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_recentVisit.dart';

class RepositoryRealtimeUsers {

  final _localDSAnnouncement = LocalDSAnnouncement();
  final _localDSBadge = LocalDSBadge();
  final _localDSDeviceId = LocalDSDeviceId();
  final _localDSDeviceName = LocalDSDeviceName();
  final _localDSFCMToken = LocalDSFCMToken();
  final _localDSIsNotificationAble = LocalDSIsNotificationAble();
  final _localDSIsUserInApp = LocalDSIsUserInApp();
  final _localDSRecentVisit = LocalDSRecentVisit();
  final _localDSPolicyCheck = LocalDSPolicyCheck();
  final _localDSReportedCount = LocalDSReportedCount();

  // _localDSAnnouncement
  Future<DateTime?> getDownloadAnnouncementVisibleTime() async {
    return await _localDSAnnouncement.downloadAnnouncementVisibleTime();
  }
  Future<void> getUpdateAnnouncementVisibleTime() async {
    return await _localDSAnnouncement.updateAnnouncementVisibleTime();
  }


  // _localDSBadge
  Stream<int> getMyBadgeListen() async* {
    yield* _localDSBadge.myBadgeListen();
  }
  Future<int> getDownloadMyBadge() async {
    return await _localDSBadge.downloadMyBadge();
  }
  Future<void> getUpdateMyBadge(int currentBadge) async {
    return await _localDSBadge.updateMyBadge(currentBadge);
  }
  Future<void> getInitializeMyBadge() async {
    return await _localDSBadge.initializeMyBadge();
  }
  Future<int> getAddOpponentUserBadge(String opponentUid) async {
    return await _localDSBadge.addOpponentUserBadge(opponentUid);
  }
  Future<int> getAdjustOpponentBadge(String opponentUid, int lastSeen) async {
    return await _localDSBadge.adjustOpponentBadge(opponentUid, lastSeen);
  }
  Stream<int> getMyPrivateMailBadgeListen() async* {
    yield* _localDSBadge.myPrivateMailBadgeListen();
  }
  Future<int> getDownloadPrivateMailBadge() async {
    return await _localDSBadge.downloadPrivateMailBadge();
  }
  Future<void> getUpdatePrivateMailBadge() async {
    return await _localDSBadge.updatePrivateMailBadge();
  }
  Future<void> getInitializePrivateMailBadge() async {
    return await _localDSBadge.initializePrivateMailBadge();
  }
  Future<void> getSetDeviceBadge() async {
    return await _localDSBadge.setDeviceBadge();
  }


  // _localDSDeviceId
  Future<String> getCheckMyDeviceId(String uid) async {
    return await _localDSDeviceId.checkMyDeviceId(uid);
  }
  Future<void> getUploadMyDeviceId(String deviceId) async {
    return await _localDSDeviceId.uploadMyDeviceId(deviceId);
  }

  // _localDSDeviceName
  Future<String> getCheckMyDeviceName() async {
    return await _localDSDeviceName.checkMyDeviceName();
  }
  Future<void> getUploadMyDeviceName(String deviceName) async {
    return await _localDSDeviceName.uploadMyDeviceName(deviceName);
  }


  // _localDSFCMToken
  Future<void> getUploadFcmToken(String token) async {
    return await _localDSFCMToken.uploadFcmToken(token);
  }
  Future<String> getCheckFcmToken(String uid) async {
    return await _localDSFCMToken.checkFcmToken(uid);
  }


  // _localDSIsNotificationAble
  Future<void> getToggleNotification(bool value) async {
    return await _localDSIsNotificationAble.toggleNotification(value);
  }
  Stream<bool> getCheckUserNotification(String value) async* {
    yield* _localDSIsNotificationAble.checkUserNotification(value);
  }
  Future<bool> getCheckUserNotificationFunction(String value) async {
    return await _localDSIsNotificationAble.checkUserNotificationFunction(value);
  }


  // _localDSIsUserInApp
  Future<void> getDisconnectIsCurrentUserInApp() {
    return _localDSIsUserInApp.disconnectIsCurrentUserInApp();
  }
  Future<void> getSetIsCurrentUserInApp() {
    return _localDSIsUserInApp.setIsCurrentUserInApp();
  }
  Stream<bool> getCheckIsCurrentUserInApp(String uid) async* {
    yield* _localDSIsUserInApp.checkIsCurrentUserInApp(uid);
  }

  // _localDSRecentVisit
  Future<DateTime> getUpdateMyRecentVisit() {
    return _localDSRecentVisit.updateMyRecentVisit();
  }

  // _localDSPolicyChek
  Future<bool?> getDownloadPolicyCheck() async {
    return await _localDSPolicyCheck.downloadPolicyCheck();
  }
  Future<void> getUpdatePolicyCheck() async {
    return await _localDSPolicyCheck.updatePolicyCheck();
  }

  // _localDSReportedCount
  Future<int> getCheckMyReportedCount() async {
    return await _localDSReportedCount.checkMyReportedCount();
  }
  Future<int> getCheckMyReportLimitDays() async {
    return await _localDSReportedCount.checkMyReportLimitDays();
  }
  Future<int> getCheckOpponentReportedCount(String opponentUid) async {
    return await _localDSReportedCount.checkOpponentReportedCount(opponentUid);
  }
  Future<int> getAddOpponentReportedCount(String opponentUid) async {
    return await _localDSReportedCount.addOpponentReportedCount(opponentUid);
  }
  Future<void> getFlagOpponentLimitDays(String opponentUid) async {
    return await _localDSReportedCount.flagOpponentLimitDays(opponentUid);
  }
  Future<int?> getFlagOpponentReportedCount(String opponentUid, String chatRoomId, String reportedReason) async {
    return await _localDSReportedCount.flagOpponentReportedCount(opponentUid, chatRoomId, reportedReason);
  }

}