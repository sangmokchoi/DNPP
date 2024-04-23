
import 'package:dnpp/LocalDataSource/firebase_realtime/messages/DS_Local_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../RemoteDataSource/firebase_messaging.dart';

class RepositoryRealtimeMessages {

  final _firebaseMessagingRemoteDataSource = FirebaseMessagingRemoteDataSource();
  final _localDSChat = LocalDSChat();

  Future<void> getSendMessageData(String senderNickName, String messageBody, String token, int newBadge) async {
    return await _firebaseMessagingRemoteDataSource.sendMessageData(
        senderNickName, messageBody, token, newBadge);
  }

  // _localDSChat
  Future<void> getUpdateIsMeInRoom(String currentUserProfileUid, String chatRoomId, int messagesListLength) async {
    return await _localDSChat.updateIsMeInRoom(currentUserProfileUid, chatRoomId, messagesListLength);
  }
  Future<void> getDeleteChatRoom(String chatRoomId) async {
    return await _localDSChat.deleteChatRoom(chatRoomId);
  }
  Future<void> getDeleteUsersData(String uid) async {
    return await _localDSChat.deleteUsersData(uid);
  }
  Future<void> getDeleteChatData(String uid) async {
    return await _localDSChat.deleteChatData(uid);
  }

}