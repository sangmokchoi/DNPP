import '../LocalDataSource/firebase_realtime/push/DS_Local_push.dart';

class RepositoryRealtimePush {

  final _localDSPush = LocalDSPush();

  // _localDSBlockedList
  Future<List<Map<String, String>>> getAllPush() async {
    return await _localDSPush.loadAllPush();
  }

  Future<List<Map<String, String>>> getPublicPush() async {
    return await _localDSPush.loadPublicPush();
  }

  Future<List<Map<String, String>>> getPrivatePush() async {
    return await _localDSPush.loadPrivatePush();
  }
}