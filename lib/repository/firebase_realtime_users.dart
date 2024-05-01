import 'package:dnpp/LocalDataSource/firebase_realtime/users/DS_Local_Announcement.dart';

import '../LocalDataSource/firebase_realtime/users/DS_Local_FCMToken.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_badge.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_deviceId.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_isNotificationAble.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_isUserInApp.dart';
import '../LocalDataSource/firebase_realtime/users/DS_Local_recentVisit.dart';

class RepositoryRealtimeUsers {

  final _localDSAnnouncement = LocalDSAnnouncement();
  final _localDSBadge = LocalDSBadge();
  final _localDSDeviceId = LocalDSDeviceId();
  final _localDSFCMToken = LocalDSFCMToken();
  final _localDSIsNotificationAble = LocalDSIsNotificationAble();
  final _localDSIsUserInApp = LocalDSIsUserInApp();
  final _localDSRecentVisit = LocalDSRecentVisit();

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


  // _localDSDeviceId
  Future<String> getCheckMyDeviceId(String uid) async {
    return await _localDSDeviceId.checkMyDeviceId(uid);
  }
  Future<void> getUploadMyDeviceId(String deviceId) async {
    return await _localDSDeviceId.uploadMyDeviceId(deviceId);
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
}