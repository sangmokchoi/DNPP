import 'package:dnpp/LocalDataSource/firebase_realtime/blockedList/DS_Local_blockedList.dart';

class RepositoryRealtimeBlockedList {

  final _localDSBlockedList = LocalDSBlockedList();

  // _localDSBlockedList
  Future<void> getAddToBlockList(String currentUserProfileUid, dynamic element, bool reported) async {
    return await _localDSBlockedList.addToBlockList(currentUserProfileUid, element, reported);
  }
  Future<bool> getCheckIsOpponentBlockedMe(String opponentUid) async {
    return await _localDSBlockedList.checkIsOpponentBlockedMe(opponentUid);
  }
  Future<bool> getCheckIsOpponentBlocked(String opponentUid) async {
    return await _localDSBlockedList.checkIsOpponentBlocked(opponentUid);
  }

}