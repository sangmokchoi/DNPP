import 'dart:convert';
import 'dart:io';

import 'package:dnpp/statusUpdate/googleAnalytics.dart';
import 'package:dnpp/statusUpdate/CurrentPageProvider.dart';
import 'package:dnpp/view/chat_screen.dart';
import 'package:dnpp/view/home_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:http/http.dart' as http;
// import 'package:html/dom.dart';
// import 'package:html/dom_parsing.dart';
// import 'package:html/html_escape.dart';
// import 'package:html/parser.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:dnpp/constants.dart';

import 'package:dnpp/view/chatList_Screen.dart';
import 'package:dnpp/view/loading_screen.dart';
import 'package:dnpp/viewModel/CalendarScreen_ViewModel.dart';
import 'package:dnpp/viewModel/LoadingScreen_ViewModel.dart';
import 'package:dnpp/viewModel/MainScreen_ViewModel.dart';
import 'package:dnpp/viewModel/MapScreen_ViewModel.dart';
import 'package:dnpp/viewModel/MatchingScreen_ViewModel.dart';
import 'package:dnpp/viewModel/SettingScreen_ViewModel.dart';
import 'package:dnpp/statusUpdate/courtAppointmentUpdate.dart';
import 'package:dnpp/statusUpdate/loadingUpdate.dart';
import 'package:dnpp/statusUpdate/othersPersonalAppointmentUpdate.dart';
import 'package:dnpp/statusUpdate/personalAppointmentUpdate.dart';
import 'package:dnpp/statusUpdate/loginStatusUpdate.dart';
import 'package:dnpp/statusUpdate/mapWidgetUpdate.dart';
import 'package:dnpp/statusUpdate/profileUpdate.dart';
import 'package:dnpp/statusUpdate/sharedPreference.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'LocalDataSource/firebase_realtime/users/DS_Local_FCMToken.dart';
import 'LocalDataSource/firebase_realtime/users/DS_Local_badge.dart';
import 'LocalDataSource/firebase_realtime/users/DS_Local_isUserInApp.dart';
import 'firebase_options.dart';
import 'models/moveToOtherScreen.dart';
import 'norification.dart';
import 'package:permission_handler/permission_handler.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotification.flutterLocalNotificationPlugin;
late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false; // 셋팅여부 판단 flag

/// 셋팅 메소드
Future<void> setupFlutterNotifications() async {
  print('setupFlutterNotifications 진입');
  if (isFlutterLocalNotificationsInitialized) {
    print('isFlutterLocalNotificationsInitialized 진입');
    return;
  }
  print('channel 직전');
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    // description
    importance: Importance.high,
  );
  print('channel 직후');
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  // iOS foreground notification 권한
  print('iOS foreground notification 권한');
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  print('setForegroundNotificationPresentationOptions');
  if (Platform.isIOS) {
    await FirebaseMessaging.instance.getNotificationSettings();
    // IOS background 권한 체킹 , 요청
    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    // save token to server
    print('newToken: $newToken');
  });
// save token to server
  print('FirebaseMessaging.onMessage.listen');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      print('여기서 notification 불림');
      FlutterLocalNotificationsPlugin().show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'high_importance_notification',
            importance: Importance.max,
            priority: Priority.max,
            showWhen: false,

          ),
        ),
      );
      print("Foreground 메시지 수신: ${message.notification!.body!}");
    }
  });
  // 토큰 요청
  await getToken();
  // 셋팅flag 설정
  isFlutterLocalNotificationsInitialized = true;
}

Future<void> getToken() async {
  // ios
  String? token;
  if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    token = await FirebaseMessaging.instance.getAPNSToken();
  }
  // aos
  else {
    token = await FirebaseMessaging.instance.getToken();
  }

  print('getToken 함수: $token');
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('백그라운드 _firebaseMessagingBackgroundHandler');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupFlutterNotifications(); // 셋팅 메소드
  showFlutterNotification(message); // 로컬노티
}

/// fcm 전경 처리 - 로컬 알림 보이기
@pragma('vm:entry-point')
void showFlutterNotification(RemoteMessage message) async {
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    // description
    importance: Importance.high,
  );

  const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1);

  print('Message: ${message}');
  print('Message data: ${message.data}');
  print('Message messageId: ${message.messageId}');
  print('Message mutableContent: ${message.mutableContent}');
  print('Message category: ${message.category}');
  print('Message from: ${message.from}');
  print('Message hashCode: ${message.hashCode}');
  print('Message notification: ${message.notification}');
  print(
      'Message notification title: ${message.notification?.title}'); // 콘솔에서 보낸 메시지의 제목
  print(
      'Message notification body: ${message.notification?.body}'); // 콘솔에서 보낸 메시지의 바디

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  print('notification: $notification');

  print('notification apple?.badge: ${notification?.apple?.badge}');
  print('notification apple?.subtitle: ${notification?.apple?.subtitle}');
  print('notification apple?.imageUrl: ${notification?.apple?.imageUrl}');
  print('android: $android');


  //notification != null 이면 ios
  //notification == null android

  // if (notification != null && android != null && !kIsWeb) { // 웹이 아니면서 안드로이드이고, 알림이 있는경우
  //   flutterLocalNotificationsPlugin.show(
  //     notification.hashCode,
  //     notification.title,
  //     notification.body,
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         channelDescription: channel.description,
  //         // TODO add a proper drawable resource to android, for now using
  //         //      one that already exists in example app.
  //         icon: null,//'launch_background',
  //       ),
  //     ),
  //   );
  // }

  if (isChatScreenActive) {
    print('isChatScreenActive: $isChatScreenActive');
  } else {
    print('isChatScreenActive: $isChatScreenActive');
  }

  if (notification?.apple == null) {
    // 안드로이드인 경우,
    print('안드로이드인 경우');

    final myCurrentBadge = await LocalDSBadge().downloadMyBadge();
    print('노티 수신 myCurrentBadge: $myCurrentBadge');
    await LocalDSBadge().updateMyBadge(myCurrentBadge);

    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.data['title'],
      message.data['body'],
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ID',//channel.id,
          '핑퐁플러스',//channel.name,
          channelDescription: 'Pingpong Plus', //channelDescription: channel.description,
            icon: null, //'launch_background',
          //importance: Importance.max,
          importance: Importance.high,
          //priority: Priority.max,
          //showWhen: false,
            ),
        // android: AndroidNotificationDetails(
        //   'high_importance_channel',
        //   'high_importance_notification',
        //   importance: Importance.max,
        //   priority: Priority.max,
        //   showWhen: false,
        // ),
      ),
    );
  }

  if (notification?.apple != null) { // ios 인 경우 *** ios 인 경우에는 별도로 .show를 하지 않아도 알아서 노티를 수신함 ***
    print('ios인 경우');

    await LocalDSBadge()
        .updateMyBadge(int.parse(notification?.apple!.badge ?? '0'));

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        // const NotificationDetails(
        //   iOS: DarwinNotificationDetails(
        //       //presentAlert: true,
        //       //presentBadge: true,
        //       //presentSound: true,
        //   )
        // ),
        null
      );
  }



}

bool isChatScreenActive = false; // 특정 뷰의 활성 여부를 추적하는 변수


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await NaverMapSdk.instance.initialize(
      clientId: '7evubnn4j6',
      onAuthFailed: (error) {
        print('Auth failed: $error');
      });

  try {
    kakao.KakaoSdk.init(nativeAppKey: '93a20d717a6ee1439f15045a460ac4cd');
  } catch (error) {
    print('KakaoSdk: $error');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final bool isUpdateNeeded = await checkAppVersion();
  print('runapp isUpdateNeeded: $isUpdateNeeded');

  if (!kDebugMode) {
    print('!kDebugMode');
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    );
  } else {
    print('kDebugMode');
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    );
  }
  //await ChatBackgroundListen().checkFcmToken();

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  //await FirebaseMessaging.instance.deleteToken();
  //await getToken();

  //await ChatBackgroundListen().checkFcmToken();

  //await FirebaseMessaging.instance.deleteToken();
  // String? _fcmToken = await FirebaseMessaging.instance.getToken();
  // print('_fcmToken: $_fcmToken');

  FlutterLocalNotification.init();
  FlutterLocalNotification.requestNotificationPermission();

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  //await FirebaseMessaging.instance.deleteToken().then((value) => 'deleToken 완료');
  //await ChatBackgroundListen().checkFcmToken().then((value) => 'checkFcmToken 완료');

  FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
    print("New token: $token");
    await LocalDSFCMToken().uploadFcmToken(token);
  });

  // foreground 수신처리
  //FirebaseMessaging.onMessage.listen(showFlutterNotification);
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Got a message whilst in the foreground!');
  //   print('Message data: ${message.data}');
  //
  //   if (message.notification != null) {
  //     print('Message also contained a notification: ${message.notification}');
  //   }
  //
  //   return showFlutterNotification(message);
  // });
  FirebaseMessaging.onMessage.listen(showFlutterNotification);

  // background 수신처리
  // FirebaseMessaging.onBackgroundMessage((RemoteMessage message){
  //   print('Got a message whilst in the background');
  //   return _firebaseMessagingBackgroundHandler(message);
  // });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // 알림 클릭시
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){ // 아이폰에서만 작동
    return print('onMessageOpenedApp 열림');
  });

  LocalDSIsUserInApp().setIsCurrentUserInApp();

  //FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
    print('crashlytics 사용가능');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MainScreenViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => MapWidgetUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => CalendarScreenViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => LoadingScreenViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => MapScreenViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => MatchingScreenViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => PersonalAppointmentUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => OthersPersonalAppointmentUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => CourtAppointmentUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginStatusUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => SharedPreference(),
        ),
        ChangeNotifierProvider(
          create: (context) => LoadingUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => GoogleAnalyticsNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => CurrentPageProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        //home: HomePage(isUpdateNeeded),
        home: HomePage(isUpdateNeeded),
        theme: theme,
        darkTheme: darkTheme,
      ),
    ),
  );
}

// 파이어베이스 버전 확인
Future<bool> checkAppVersion() async {

  final remoteConfig = FirebaseRemoteConfig.instance;

  // 데이터 가져오기 시간 간격 : 12시간
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(minutes: 5),
  ));

  await remoteConfig.fetchAndActivate();

  // 앱 버전 정보 가져오기
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appName = packageInfo.appName;
  String packageName = packageInfo.packageName;
  String appVersion = packageInfo.version ?? '';
  String buildNumber = packageInfo.buildNumber;

  print('appName :$appName');
  print('packageName :$packageName');
  print('appVersion :$appVersion');
  print('buildNumber :$buildNumber');

  // 파이어베이스 버전 정보 가져오기 remote config
  // (매개변수명 latest_version)

  String firebaseVersion = '';

  try {
    firebaseVersion = remoteConfig.getString("latest_version");
  } catch (e) {
    print('firebaseVersion e: $e');
  }

  print('firebaseVersion: $firebaseVersion');
  print('appVersion: $appVersion');

  double doubleFirebaseVersion = 1.0;
  double doubleAppVersion = 1.0;

  if (firebaseVersion != '' || appVersion != '') { // 앱 버전 또는 파이어베이스에서 앱 버전을 가져오는동안 문제가 없을때

    String truncatedFirebaseVersion = truncateVersion(firebaseVersion) ?? '';
    String truncatedAppVersion = truncateVersion(appVersion) ?? '';

    print('Truncated firebaseVersion: $truncatedFirebaseVersion'); // Truncated firebaseVersion: 1.0
    print('Truncated appVersion: $truncatedAppVersion'); // Truncated appVersion: 1.0

    doubleFirebaseVersion = double.parse(truncatedFirebaseVersion); // 1.0
    doubleAppVersion = double.parse(truncatedAppVersion); // 1.0

    print('if (firebaseVersion != '' || appVersion != '') doubleFirebaseVersion: $doubleFirebaseVersion');
    print('if (firebaseVersion != '' || appVersion != '') doubleAppVersion: $doubleAppVersion');

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

  print('firebaseVersion: $firebaseVersion');
  print('appVersion: $appVersion');
  print('isUpdateNeeded: $isUpdateNeeded');
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
  //   print('firebaseVersion: $firebaseVersion');
  //   print('appVersion: $appVersion');
  //   print('isUpdateNeeded: $isUpdateNeeded');
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
  //     //       print("jsonResponse: $jsonResponse");
  //     //
  //     //       if (jsonResponse['resultCount'] != 0) {
  //     //         final result = jsonResponse['results'][0];
  //     //         print("result version: ${result['version']}");
  //     //         final appVersion = result['version']; //Stirng
  //     //
  //     //         print('appVersion: $appVersion');
  //     //
  //     //         if (appVersion != appVersion) {
  //     //           print('앱 버전 업데이트가 필요합니다.');
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
  //     //       print('앱 버전 체크 ios의 경우 Request failed with status: ${response.statusCode}.');
  //     //       isUpdateNeeded = false;
  //     //     }
  //     //   } catch (e) {
  //     //     // 네트워크 요청 실패 또는 JSON 파싱 실패 시 처리
  //     //     print('앱 버전 체크 ios의 경우 Error: $e');
  //     //     isUpdateNeeded = false;
  //     //   }
  //     // }
  //
  //   } else {
  //
  //   }
  //
  //   print('isUpdateNeeded: $isUpdateNeeded');
  //   print('checkAppVersion 종료');
  //
  //   return isUpdateNeeded;
  // }

}

String truncateVersion(String version) {
  RegExp regex = RegExp(r'^(\d+\.\d+)');
  Match? match = regex.firstMatch(version);
  if (match != null) {
    return match.group(1)!; // 첫 번째 그룹을 반환 (null 방지를 위해 non-null assertion 사용)
  } else {
    return version; // 정규 표현식과 매치되지 않는 경우, 원본 버전 반환
  }
}

ThemeData theme = ThemeData(
    fontFamily: 'NanumSquare',
    //fontFamily: 'NotoSansKR',
    //fontFamily: 'NanumMyeongjo',
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    ),
    //   appBarTheme: AppBarTheme(
    //     systemOverlayStyle: SystemUiOverlayStyle.light,
    //   ),
    textTheme: const TextTheme(
      // bodySmall: TextStyle(
      //   fontSize: 15.0
      // ),
        bodyMedium: TextStyle(
          fontSize: 16.0,
        )),
    primaryColor: kMainColor,
    // 라이트 모드의 primaryColor 설정
    colorScheme: ColorScheme.fromSeed(
      seedColor: kMainColor,
      secondary: Colors.grey,
      brightness: Brightness.light,
      background: Colors.white,
    ),
    secondaryHeaderColor: kMainColor.withOpacity(0.95),
    inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: TextStyle(color: kMainColor),
        focusedBorder: UnderlineInputBorder(
          borderSide:
          BorderSide(style: BorderStyle.solid, color: kMainColor),
        )));

ThemeData darkTheme = ThemeData.dark().copyWith(
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ),
  ),
  // appBarTheme: AppBarTheme(
  //   systemOverlayStyle: SystemUiOverlayStyle.dark,
  // ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    headlineMedium: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    headlineSmall: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    displayLarge: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    displayMedium: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    displaySmall: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    bodyLarge: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    bodyMedium: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    bodySmall: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    titleLarge: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    titleMedium: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    titleSmall: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    labelLarge: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    labelMedium: TextStyle(
      fontFamily: 'NanumSquare',
    ),
    labelSmall: TextStyle(
      fontFamily: 'NanumSquare',
    ),

  ),
  primaryColor: kMainColor,
  // 다크 모드의 primaryColor 설정
  colorScheme: ColorScheme.fromSeed(
    seedColor: kMainColor,
    secondary: Colors.blueGrey,
    brightness: Brightness.dark,
    background: Colors.black,
  ),
  secondaryHeaderColor: Colors.blueGrey,
  inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: TextStyle(color: kMainColor),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(style: BorderStyle.solid, color: kMainColor),
      )),
);

class HomePage extends StatefulWidget {

  HomePage(this.isUpdateNeeded);

  bool isUpdateNeeded;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    setupInteractedMessage();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        print('App is in background');
        //WidgetsBinding.instance!.addPostFrameCallback((_) async {
         // CurrentPageProvider().setCurrentPage('', 'main');
        // ChatBackgroundListen().updateMyIsInRoom(FirebaseAuth.instance.currentUser?.uid.toString() ?? '', chatRoomId, messagesList.length ?? 0); // 채팅방에서 나감을 선언

        Future.microtask(() async {
          final currentPage = Provider.of<CurrentPageProvider>(context, listen: false).currentPage;
          print('App is in background currentPage: $currentPage');
          await Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
              .startTimer(currentPage);

          Provider.of<CurrentPageProvider>(context, listen: false).setInitialCurrentPage();
          final myCurrentBadge = await LocalDSBadge().downloadMyBadge();
          print('노티 수신 myCurrentBadge: $myCurrentBadge');
          await LocalDSBadge().updateMyBadge(myCurrentBadge);

          // await Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
          //   .cancelAndLogBoardingTime(currentPage);

        });

        print('App is in background');
        //});
        break;
      case AppLifecycleState.resumed:
        print('App is in foreground');
        break;
      case AppLifecycleState.inactive:
      // Not in use on Android, this is the state in which the app is not receiving user input and running in the background.
        print('App is in inactive');
        break;
      case AppLifecycleState.detached:
        print('App is in detached');
      // The application is still hosted on a flutter engine but is detached from any host views.
        break;
      case AppLifecycleState.hidden:
        print('App is in hidden');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return (widget.isUpdateNeeded == false) ? // 업데이트가 필요없는 경우
    GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [observer],

        home: LoadingScreen(),

        // home: AnimatedSplashScreen(
        //   backgroundColor: kMainColor, //Theme.of(context).primaryColor,
        //   splash: Container(
        //     decoration: BoxDecoration(
        //       image: DecorationImage(
        //         image: AssetImage('images/핑퐁플러스 로고.png'),
        //         //fit: BoxFit.cover,
        //       ),
        //     ),
        //   ),
        //   nextScreen: LoadingScreen(), //LoadingScreen(),//HomeScreen(),
        //   splashTransition: SplashTransition.fadeTransition,
        // ),

        // theme: ThemeData(
        //   primaryColor: kMainColor,//Colors.blueAccent,
        //   //primarySwatch: Colors.blue,
        //   secondaryHeaderColor: Colors.grey,
        // ),
        theme: theme,
        darkTheme: darkTheme,
        // initialRoute: LoadingScreen.id,
        // routes: {
        //   // When navigating to the "/" route, build the FirstScreen widget.
        //   LoadingScreen.id: (context) => LoadingScreen(),
        //   HomeScreen.id: (context) => HomeScreen(), // '/'
        //   SignupScreen.id: (context) => SignupScreen(), // '/SignupScreenID'
        //   ProfileScreen.id: (context) => ProfileScreen(),// '/ProfileScreenID'
        //   MainScreen.id: (context) => MainScreen(), //MainScreenID
        //   MapScreen.id: (context) => MapScreen(), //MapScreenID
        //   CalendarScreen.id: (context) => CalendarScreen(),
        //   SettingScreen.id: (context) => SettingScreen(),//StatisticsScreenID
        // },
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ko', 'KR'),
          // Locale('es', ''), // Spanish, no country code
        ],
      ),
    ) : // 업데이트가 필요한 경우
    MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [observer],
      home: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: kMainColor,
        child: FutureBuilder(
            future: Future.delayed(Duration.zero), builder: (builder, snapshot){
              return AlertDialog(
                //insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                shape: kRoundedRectangleBorder,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "알림",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                content: Text(
                  "업데이트된 버전이 있습니다\n'확인' 버튼을 누르면 스토어로 이동합니다\n(업데이트 후에는 앱을 재실행해주세요)",
                  //textAlign: TextAlign.start,
                ),
                actions: [
                  TextButton(
                      onPressed: (){
                        setState(() {
                          SettingViewModel().settingMoveToStore(context);
                        });
                  }, child: Text('확인'))
                ],
              );
        },
        ),
      ),

      theme: theme,
      darkTheme: darkTheme,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ko', 'KR'),
        // Locale('es', ''), // Spanish, no country code
      ],
    );
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    print('setupInteractedMessage');
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {

      if (message != null) {
        //_handleMessage(message);
        MoveToOtherScreen().persistentNavPushNewScreen(
            context, ChatListView(), false, PageTransitionAnimation.cupertino);
      }
    });

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) { // ios에서만 작동
    // 내가 지정한 그 알람이면? 지정한 화면으로 이동
    // if (message.data['data1'] == 'value1') {
    //   Navigator.pushNamed(context, '/'); // main에서는 이동불가 Home에 들어와서 해줘야함
    // }

    //GoogleAnalytics().openNoti(seconds);
    print('_handleMessage 열림');
    print('_handleMessage message: $message');
    print('_handleMessage message: ${message.data}');
    print('_handleMessage message: ${message.from}');
    print('_handleMessage message: ${message.data['From']}');

    // WidgetsBinding.instance!.addPostFrameCallback((_) async {
    // Provider.of<LoadingScreenViewModel>(context, listen: false).initibnalize(context);
    // });

    // 이렇게 들어오게 되면 GA에 잡히나?

    final currentPage = Provider.of<CurrentPageProvider>(context, listen: false).currentPage;

    print('main.dart currentPage: $currentPage');
    print('message.data[From]: ${message.data['From']}');

    if (message.data['From'] == 'server'){

      // if (currentPage == 'HomeScreen' || currentPage == 'MainScreen' || currentPage == 'CalendarScreen' || currentPage == 'SettingScreen') {

      if (currentPage == 'HomeScreen'){

      } else {
        MoveToOtherScreen().persistentNavPushNewScreen(
            context, HomeScreen(), false, PageTransitionAnimation.cupertino);
      }

    } else {

      if (currentPage == 'ChatListView') {
        // 현재 페이지가 ChatListView인 경우에는 동작하지 않도록 처리
      } else {
        MoveToOtherScreen().persistentNavPushNewScreen(
            context, ChatListView(), false, PageTransitionAnimation.cupertino);
      }


    // MoveToOtherScreen().persistentNavPushNewScreen(
    //           context, ChatListView(), false, PageTransitionAnimation.cupertino);

    }

    //Navigator.push(context, MoveToOtherScreen.createRouteChatListView());

    // 서버에서 보낸 메시지면 home으로?
  } // 노티를 클릭했을때의 화면 전환 함수


}
