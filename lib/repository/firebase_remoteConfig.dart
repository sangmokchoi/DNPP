

import 'package:dnpp/LocalDataSource/DS_Local_remoteConfig.dart';

class RepositoryRemoteConfig {

  final _localDSRemoteConfig = LocalDSRemoteConfig();

  Future<void> getRemoteConfigFetchAndActivate() async {
    return await _localDSRemoteConfig.remoteConfigFetchAndActivate();
  }
  Future<bool> getCheckAppVersion() async {
    return await _localDSRemoteConfig.checkAppVersion();
  }
  Future<Map<String, String>> getCheckUrgentNews() async {
    return await _localDSRemoteConfig.checkUrgentNews();
  }
  Future<String> getDownloadNaverMapSdk() async {
    return await _localDSRemoteConfig.downloadNaverMapSdk();
  }
  Future<String> getDownloadKakaoSdk() async {
    return await _localDSRemoteConfig.downloadKakaoSdk();
  }
  Future<String> getDownloadPolicyInChatList() async {
    return await _localDSRemoteConfig.downloadPolicyInChatList();
  }

}