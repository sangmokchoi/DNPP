
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LocalDSRemoteConfig {

  String _truncateVersion(String version) {
    RegExp regex = RegExp(r'^(\d+\.\d+)');
    Match? match = regex.firstMatch(version);
    if (match != null) {
      return match.group(1)!; // 첫 번째 그룹을 반환 (null 방지를 위해 non-null assertion 사용)
    } else {
      return version; // 정규 표현식과 매치되지 않는 경우, 원본 버전 반환
    }
  }

  FirebaseRemoteConfig _firebaseRemoteConfig = FirebaseRemoteConfig.instance;
  //String getString(String key) => _firebaseRemoteConfig.getString(key);

  Future<void> remoteConfigFetchAndActivate() async {
    try {
      // 데이터 가져오기 시간 간격 : 12시간
      await _firebaseRemoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 12),
      ));

      await _firebaseRemoteConfig.fetchAndActivate();
      debugPrint('remoteConfigFetchAndActivate done');
      //return _firebaseRemoteConfig;

    } catch (e) {
      debugPrint('remoteConfigFetchAndActivate e: $e');
    }
  }



  // 앱 버전 확인
  Future<bool> checkAppVersion() async {

    // await _remoteConfigFetchAndActivate();

    // 앱 버전 정보 가져오기
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String appVersion = packageInfo.version ?? '';
    String buildNumber = packageInfo.buildNumber;

    debugPrint('appName :$appName');
    debugPrint('packageName :$packageName');
    debugPrint('appVersion :$appVersion');
    debugPrint('buildNumber :$buildNumber');

    // 파이어베이스 버전 정보 가져오기 remote config
    // (매개변수명 latest_version)

    String firebaseVersion = '';

    try {
      firebaseVersion = _firebaseRemoteConfig.getString("latest_version");
    } catch (e) {
      debugPrint('firebaseVersion e: $e');
    }

    debugPrint('firebaseVersion: $firebaseVersion');
    debugPrint('appVersion: $appVersion');

    double doubleFirebaseVersion = 1.0;
    double doubleAppVersion = 1.0;

    if (firebaseVersion != '' || appVersion != '') { // 앱 버전 또는 파이어베이스에서 앱 버전을 가져오는동안 문제가 없을때

      String truncatedFirebaseVersion = _truncateVersion(firebaseVersion) ?? '';
      String truncatedAppVersion = _truncateVersion(appVersion) ?? '';

      debugPrint('Truncated firebaseVersion: $truncatedFirebaseVersion'); // Truncated firebaseVersion: 1.0
      debugPrint('Truncated appVersion: $truncatedAppVersion'); // Truncated appVersion: 1.0

      doubleFirebaseVersion = double.parse(truncatedFirebaseVersion); // 1.0
      doubleAppVersion = double.parse(truncatedAppVersion); // 1.0

      debugPrint('if (firebaseVersion != '' || appVersion != '') doubleFirebaseVersion: $doubleFirebaseVersion');
      debugPrint('if (firebaseVersion != '' || appVersion != '') doubleAppVersion: $doubleAppVersion');

    } else { // 앱 버전 또는 파이어베이스에서 앱 버전을 가져오는동안 문제가 있는 경우,
      //doubleAppVersion == doubleFirebaseVersion 로 되게끔 별도의 설정을 안함
    }

    bool isUpdateNeeded = false;

    if (doubleAppVersion < doubleFirebaseVersion) { // 앱 업데이트 필요

      if (firebaseVersion == '') {
        isUpdateNeeded = false;
      } else { // 스토어에서 업데이트 필요
        isUpdateNeeded = true;
      }

    } else { // doubleAppVersion >= doubleFirebaseVersion
      // 앱 업데이트 불필요 (또는 심사를 거치는 경우)
      isUpdateNeeded = false;
    }

    debugPrint('firebaseVersion: $firebaseVersion');
    debugPrint('appVersion: $appVersion');
    debugPrint('isUpdateNeeded: $isUpdateNeeded');
    return isUpdateNeeded;

    // if (Platform.isAndroid) { // 앱 버전 체크
    //
    //
    //   if (doubleAppVersion < doubleFirebaseVersion) { // 앱 업데이트 필요
    //
    //     if (firebaseVersion == '') {
    //       isUpdateNeeded = false;
    //     } else { // 스토어에서 업데이트 필요
    //       isUpdateNeeded = true;
    //     }
    //
    //   } else { // doubleAppVersion >= doubleFirebaseVersion
    //     // 앱 업데이트 불필요 (또는 심사를 거치는 경우)
    //     isUpdateNeeded = false;
    //   }
    //
    //   debugPrint('firebaseVersion: $firebaseVersion');
    //   debugPrint('appVersion: $appVersion');
    //   debugPrint('isUpdateNeeded: $isUpdateNeeded');
    //   return isUpdateNeeded;
    //
    // } else { // 앱 버전 체크 ios의 경우
    //
    //   if (firebaseVersion != appVersion) {
    //     isUpdateNeeded = true;
    //     // if (firebaseVersion == '') {
    //     //   isUpdateNeeded = false;
    //     // } else { // 스토어에서 업데이트 필요
    //     //   //isUpdateNeeded = true;
    //     //
    //     //   final dnppAppId = '6478840964';
    //     //   //final otherAppId = '6470111015';
    //     //   final _url = "https://itunes.apple.com/kr/lookup?id=$dnppAppId";
    //     //
    //     //   try {
    //     //     final response = await http.get(Uri.parse(_url));
    //     //     if (response.statusCode == 200) {
    //     //       // 서버가 JSON 형태로 응답을 보냈습니다.
    //     //       var jsonResponse = jsonDecode(response.body);
    //     //       debugPrint("jsonResponse: $jsonResponse");
    //     //
    //     //       if (jsonResponse['resultCount'] != 0) {
    //     //         final result = jsonResponse['results'][0];
    //     //         debugPrint("result version: ${result['version']}");
    //     //         final appVersion = result['version']; //Stirng
    //     //
    //     //         debugPrint('appVersion: $appVersion');
    //     //
    //     //         if (appVersion != appVersion) {
    //     //           debugPrint('앱 버전 업데이트가 필요합니다.');
    //     //           isUpdateNeeded = true;
    //     //
    //     //         } else {
    //     //           isUpdateNeeded = false;
    //     //         }
    //     //
    //     //       } else { // 불러온 내용이 없음 {resultCount: 0, results: []}
    //     //         isUpdateNeeded = false;
    //     //       }
    //     //
    //     //     } else {
    //     //       // 서버로부터 에러 응답을 받았을 경우 처리
    //     //       debugPrint('앱 버전 체크 ios의 경우 Request failed with status: ${response.statusCode}.');
    //     //       isUpdateNeeded = false;
    //     //     }
    //     //   } catch (e) {
    //     //     // 네트워크 요청 실패 또는 JSON 파싱 실패 시 처리
    //     //     debugPrint('앱 버전 체크 ios의 경우 Error: $e');
    //     //     isUpdateNeeded = false;
    //     //   }
    //     // }
    //
    //   } else {
    //
    //   }
    //
    //   debugPrint('isUpdateNeeded: $isUpdateNeeded');
    //   debugPrint('checkAppVersion 종료');
    //
    //   return isUpdateNeeded;
    // }

  }

  Future<Map<String, String>> checkUrgentNews() async {

    Map<String, String> result = {};

    try {
      final urgentNewsTitle = _firebaseRemoteConfig.getString("urgentNews_title");
      final urgentNewsContent = _firebaseRemoteConfig.getString("urgentNews_content");
      debugPrint('urgentNewsTitle: $urgentNewsTitle'); // urgentNewsTitle는 빈 문자열 '' 임
      debugPrint('urgentNewsContent: $urgentNewsContent'); // urgentNewsContent 빈 문자열 '' 임

      if (urgentNewsTitle != '' && urgentNewsContent != '') {
        result = {
          "urgentNewsTitle": urgentNewsTitle,
          "urgentNewsContent": urgentNewsContent,
        };

      }
      return result;

    } catch (e) {
      debugPrint('firebaseVersion e: $e');
      return {};
    }

  }

  Future<String> downloadNaverMapSdk() async {

    // await _remoteConfigFetchAndActivate();

    String naverMapSdk = '';

    try {
      naverMapSdk = _firebaseRemoteConfig.getString("naverMapSdk");
    } catch (e) {
      debugPrint('downloadNaverMapSdk e: $e');
    }

    return naverMapSdk;
  }
  Future<String> downloadKakaoSdk() async {

    // await _remoteConfigFetchAndActivate();

    String kakaoSdk = '';

    try {
      kakaoSdk = _firebaseRemoteConfig.getString("kakaoSdk");
    } catch (e) {
      debugPrint('downloadKakaoSdk e: $e');
    }

    return kakaoSdk;
  }
  Future<String> downloadPolicyInChatList() async {

    // await _remoteConfigFetchAndActivate();

    String policyInChatList = '';

    try {
      policyInChatList = _firebaseRemoteConfig.getString("policyInChatList");
      policyInChatList = policyInChatList.replaceAll(r'\n', '\n');

    } catch (e) {
      debugPrint('downloadPolicyInChatList e: $e');
    }

    return policyInChatList;
  }

}