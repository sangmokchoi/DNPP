import 'dart:io';

import 'package:dnpp/repository/firebase_realtime_users.dart';
import 'package:dnpp/repository/firebase_remoteConfig.dart';
import 'package:dnpp/statusUpdate/googleAnalytics.dart';
import 'package:dnpp/statusUpdate/CurrentPageProvider.dart';
import 'package:dnpp/statusUpdate/reportUpdate.dart';
import 'package:dnpp/view/PrivateMail_Screen.dart';

import 'package:dnpp/view/home_screen.dart';
import 'package:dnpp/view/signup_screen.dart';
import 'package:dnpp/viewModel/ChatScreen_ViewModel.dart';
import 'package:dnpp/viewModel/PrivateMailScreen_ViewModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
import 'notification.dart';
import 'package:permission_handler/permission_handler.dart';


// 위젯을 저장할 Map을 선언합니다.
Map<String, GlobalKey> widgetRegistry = {};

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotification.flutterLocalNotificationPlugin;
late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false; // 셋팅여부 판단 flag

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

  debugPrint('getToken 함수: $token');
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서 탭하면 열림 (안드로이드는 확인, ios 확인 필요)
  debugPrint('백그라운드 _firebaseMessagingBackgroundHandler');

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  AppleNotification? apple = message.notification?.apple;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (notification?.apple == null) { // 안드로이드인 경우
    if (message?.data['From'] != 'server') {
      // 백그라운드에서 열 때 아래 부분이 실행되지 않고 있음
      try {
        await RepositoryRealtimeUsers()
            .getDownloadMyBadge().then((value) async {
          debugPrint('노티 수신 value: $value');
          await RepositoryRealtimeUsers().getUpdateMyBadge(value + 1);
        });

      } catch (e) {
        debugPrint('노티 수신 myCurrentPrivateMailBadge e: $e');
      }
    } else { // message.data['From'] == 'server'
      // notification apple?.badge가 null 로 나타남
      await RepositoryRealtimeUsers()
          .getUpdatePrivateMailBadge(); // 기존 배지에다가 1을 더함
    }
  }

  if (notification?.apple != null) {
    if (message?.data['From'] != 'server') {
      await RepositoryRealtimeUsers()
          .getUpdateMyBadge(int.parse(apple!.badge ?? '0'));
    } else { // message.data['From'] == 'server'
      // notification apple?.badge가 null 로 나타남
      await RepositoryRealtimeUsers()
          .getUpdatePrivateMailBadge(); // 기존 배지에다가 1을 더함
    }
  }

}

/// fcm 전경 처리 - 로컬 알림 보이기
@pragma('vm:entry-point')
void showFlutterNotification(RemoteMessage message) async {

  debugPrint('showFlutterNotification 진입');

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

  debugPrint('Message: ${message}');
  debugPrint('Message data: ${message.data}');

  debugPrint('Message messageId: ${message.messageId}');
  debugPrint('Message mutableContent: ${message.mutableContent}');
  debugPrint('Message category: ${message.category}');
  debugPrint('Message from: ${message.from}');
  debugPrint('Message sentTime: ${message.data['message_sentTime']}');
  debugPrint('Message hashCode: ${message.hashCode}');
  debugPrint('Message notification: ${message.notification}');
  debugPrint(
      'Message notification title: ${message.notification?.title}'); // 콘솔에서 보낸 메시지의 제목
  debugPrint(
      'Message notification body: ${message.notification?.body}'); // 콘솔에서 보낸 메시지의 바디

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  AppleNotification? apple = message.notification?.apple;

  debugPrint('message?.toMap: ${message?.toMap()}');
  debugPrint('message.notification?.toMap: ${message.notification?.toMap()}');
  debugPrint('android?.toMap: ${android?.toMap()}');
  debugPrint('apple?.toMap: ${apple?.toMap()}');

  debugPrint('notification apple?: ${notification?.apple}');
  debugPrint('notification apple?.badge: ${notification?.apple?.badge}');
  debugPrint('notification apple?.subtitle: ${notification?.apple?.subtitle}');
  debugPrint('notification apple?.imageUrl: ${notification?.apple?.imageUrl}');
  debugPrint('android: ${android}');
  debugPrint('message.data[From]: ${message.data['From']}');

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
    debugPrint('isChatScreenActive: $isChatScreenActive');
  } else {
    debugPrint('isChatScreenActive: $isChatScreenActive');
  }

  if (notification?.apple == null) {
    // 안드로이드인 경우,
    debugPrint('안드로이드인 경우');
    debugPrint('안드로이드인 경우 message.data[From]: ${message.data['From']}');

    if (message.data['From'] != 'server') {

          try {
            await RepositoryRealtimeUsers()
                .getDownloadMyBadge().then((value) async {
              debugPrint('노티 수신 value: $value');
              await RepositoryRealtimeUsers().getUpdateMyBadge(value);
            });

          } catch (e) {
            debugPrint('노티 수신 myCurrentPrivateMailBadge e: $e');
          }

          await GoogleAnalytics().setNotificationReceive('user', 'fromUser');

    } else { // message.data['From'] == 'server'
      // 서버에서 수신
      // notification apple?.badge가 null 로 나타남
      await RepositoryRealtimeUsers()
          .getUpdatePrivateMailBadge();
    }

      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'ID', //channel.id,
            '핑퐁플러스', //channel.name,
            channelDescription: 'Pingpong Plus',
            //channelDescription: channel.description,
            icon: 'mipmap/ic_launcher',
            //'launch_background',
            //importance: Importance.max,
            importance: Importance.max,
            priority: Priority.high,
            //showWhen: false,
          ),
          // android: AndroidNotificationDetails(
          //   'high_importance_channel',
          //   'high_importance_notification',
          //   importance: Importance.max,
          //   priority: Priority.high,
          //   showWhen: false,
          // ),
        ),
        payload: message.data['From'] // == 'server'
        );

    await GoogleAnalytics().setNotificationReceive('server', message.notification!.title.toString());

  } // 안드로이드

  if (notification?.apple != null) {
    // ios 인 경우 *** ios 인 경우에는 별도로 .show를 하지 않아도 알아서 노티를 수신함 ***
    debugPrint('ios인 경우');

    if (message.data['From'] != 'server') {
      await RepositoryRealtimeUsers()
          .getUpdateMyBadge(int.parse(notification?.apple!.badge ?? '0'));
      await GoogleAnalytics().setNotificationReceive('user', 'fromUser');

    } else { // message.data['From'] == 'server'
      // notification apple?.badge가 null 로 나타남
      await RepositoryRealtimeUsers()
          .getUpdatePrivateMailBadge(); // 기존 배지에다가 1을 더함

      // if (message.data['From'] == 'server') {
      //   Future.microtask(() async {
      //     // 백그라운드에서 열 때 아래 부분이 실행되지 않고 있음
      //     try {
      //       await RepositoryRealtimeUsers()
      //           .getDownloadPrivateMailBadge().then((value) async {
      //         final myCurrentPrivateMailBadge = value;
      //         debugPrint('노티 수신 myCurrentPrivateMailBadge: $myCurrentPrivateMailBadge');
      //         await RepositoryRealtimeUsers().getUpdatePrivateMailBadge(myCurrentPrivateMailBadge + 1);
      //       });
      //
      //     } catch (e) {
      //       debugPrint('노티 수신 myCurrentPrivateMailBadge e: $e');
      //     }
      //   });
      // }

    }

    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        const NotificationDetails(
            iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        )),
        payload: message.data['From'] // payload
        );

    await GoogleAnalytics().setNotificationReceive('server', notification?.title.toString() ?? '');
  } // ios

}

bool isChatScreenActive = false; // 특정 뷰의 활성 여부를 추적하는 변수

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await RepositoryRemoteConfig().getRemoteConfigFetchAndActivate();

  final kakaoSdk = await RepositoryRemoteConfig().getDownloadKakaoSdk();
  final naverMapSdk = await RepositoryRemoteConfig().getDownloadNaverMapSdk();
  debugPrint('kakaoSdk: $kakaoSdk');
  debugPrint('naverMapSdk: $naverMapSdk');

  await NaverMapSdk.instance.initialize(
      clientId: naverMapSdk, //'7evubnn4j6',
      onAuthFailed: (error) {
        debugPrint('Auth failed: $error');
      });

  try {
    //kakao.KakaoSdk.init(nativeAppKey: '93a20d717a6ee1439f15045a460ac4cd');
    kakao.KakaoSdk.init(nativeAppKey: kakaoSdk);
  } catch (error) {
    debugPrint('KakaoSdk: $error');
  }

  final bool isUpdateNeeded = await RepositoryRemoteConfig().getCheckAppVersion();
  final Map<String, String> checkUrgentNews = await RepositoryRemoteConfig().getCheckUrgentNews();

  debugPrint('runapp isUpdateNeeded: $isUpdateNeeded');

  if (!kDebugMode) {
    debugPrint('!kDebugMode');
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    );
  } else {
    debugPrint('kDebugMode');
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
  // debugPrint('_fcmToken: $_fcmToken');

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  //await FirebaseMessaging.instance.deleteToken().then((value) => 'deleToken 완료');
  //await ChatBackgroundListen().checkFcmToken().then((value) => 'checkFcmToken 완료');

  FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
    debugPrint("New token: $token");
    await RepositoryRealtimeUsers().getUploadFcmToken(token);
  });

  // foreground 수신처리
  //FirebaseMessaging.onMessage.listen(showFlutterNotification);
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   debugPrint('Got a message whilst in the foreground!');
  //   debugPrint('Message data: ${message.data}');
  //
  //   if (message.notification != null) {
  //     debugPrint('Message also contained a notification: ${message.notification}');
  //   }
  //
  //   return showFlutterNotification(message);
  // });
  FirebaseMessaging.onMessage.listen(showFlutterNotification); // 안드로이드는 여기로만 진입
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 알림 클릭시
  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){ // 아이폰에서만 작동
  //   return debugPrint('onMessageOpenedApp 열림');
  // });

  RepositoryRealtimeUsers().getSetIsCurrentUserInApp();

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
    debugPrint('crashlytics 사용가능');
  }

  FlutterLocalNotification.init();
  FlutterLocalNotification.requestNotificationPermission(); // 여기서 노티 권한 요청

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
          create: (context) => SettingScreenViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => MatchingScreenViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => PrivateMailScreenViewModel(),
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
          create: (context) => ReportUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => GoogleAnalyticsNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => CurrentPageProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatScreenViewModel(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [observer],
        navigatorKey: navigatorKey,
        home: HomePage(isUpdateNeeded, checkUrgentNews),
        theme: theme,
        darkTheme: darkTheme,
        // home: AnimatedSplashScreen(
        //   backgroundColor: kMainColor, //Theme.of(context).primaryColor,
        //   splash: Container(
        //     decoration: BoxDecoration(
        //       image: DecorationImage(
        //         image: AssetImage('images/logo.png'),
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
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ko', 'KR'),
          // Locale('es', ''), // Spanish, no country code
        ],
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
      ),
    ),
  );
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
          borderSide: BorderSide(style: BorderStyle.solid, color: kMainColor),
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
      ),
  ),
);

class HomePage extends StatefulWidget {
  HomePage(this.isUpdateNeeded, this.checkUrgentNews);

  bool isUpdateNeeded;
  Map<String, String> checkUrgentNews;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    print('_initGoogleMobileAds 진입');
    return MobileAds.instance.initialize();
  }

  @override
  void initState() {
    // FlutterLocalNotification.init();
    // FlutterLocalNotification.requestNotificationPermission();
    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _initGoogleMobileAds();
    setupInteractedMessage();
    debugPrint('main에서 setupInteractedMessage(); 직후');
    WidgetsBinding.instance.addObserver(this);
    debugPrint('main에서 WidgetsBinding.instance.addObserver(this); 직후');
    super.initState();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        //WidgetsBinding.instance!.addPostFrameCallback((_) async {
        // ChatBackgroundListen().updateMyIsInRoom(FirebaseAuth.instance.currentUser?.uid.toString() ?? '', chatRoomId, messagesList.length ?? 0); // 채팅방에서 나감을 선언

        Future.microtask(() async {
          final currentPage =
              Provider.of<CurrentPageProvider>(navigatorKey.currentContext!, listen: false)
                  .currentPage;
          debugPrint('App is in background currentPage: $currentPage');
          widgetRegistry['$currentPage'] = GlobalKey();

          // await Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
          //     .startTimer(currentPage);

          await Provider.of<GoogleAnalyticsNotifier>(navigatorKey.currentContext!, listen: false).cancelAndLogBoardingTime(currentPage);
          // 화면 추적 종료

          Provider.of<CurrentPageProvider>(navigatorKey.currentContext!, listen: false)
              .setInitialCurrentPage();

          final myCurrentBadge =
              await RepositoryRealtimeUsers().getDownloadMyBadge();
          debugPrint('노티 수신 myCurrentBadge: $myCurrentBadge');
          await RepositoryRealtimeUsers().getUpdateMyBadge(myCurrentBadge);

          // await Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
          //   .cancelAndLogBoardingTime(currentPage);
        });

        debugPrint('App is in background');
        //});
        break;
      case AppLifecycleState.resumed:
        debugPrint('App is in foreground');

        final providerCurrentPage =
            Provider.of<CurrentPageProvider>(navigatorKey.currentContext!, listen: false)
                .currentPage;
        debugPrint('AppLifecycleState App is in foreground providerCurrentPage: $providerCurrentPage');

        final String currentPage = widgetRegistry.keys.isNotEmpty ? widgetRegistry.keys.first : providerCurrentPage; // 직전 화면의 스크린명

        await Provider.of<CurrentPageProvider>(navigatorKey.currentContext!, listen: false).setCurrentPage(currentPage).then((value) async {

          await Provider.of<GoogleAnalyticsNotifier>(navigatorKey.currentContext!, listen: false)
              .startTimer(currentPage).then((value) {

            debugPrint('AppLifecycleState App is in foreground currentPage: $currentPage');
            debugPrint('AppLifecycleState widgetRegistry: $widgetRegistry');
            //debugPrint('widgetRegistry: ${widgetRegistry.keys?.first}');

            widgetRegistry.clear();

          });
        });


        break;
      case AppLifecycleState.inactive:
        // Not in use on Android, this is the state in which the app is not receiving user input and running in the background.
        debugPrint('App is in inactive');
        break;
      case AppLifecycleState.detached:
        debugPrint('App is in detached');
        // The application is still hosted on a flutter engine but is detached from any host views.
        break;
      case AppLifecycleState.hidden:
        debugPrint('App is in hidden');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('main에서 WidgetsBinding.instance.removeObserver(this); 직후');
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    debugPrint('HomePage 에서 빌드');
    debugPrint('widget.isUpdateNeeded: ${widget.isUpdateNeeded}');
    debugPrint('widget.checkUrgentNews: ${widget.checkUrgentNews}');

    if (widget.isUpdateNeeded == false && widget.checkUrgentNews.isEmpty) {
      debugPrint('메인 다트에서 빌드 중');
      return LoadingScreen(); // 업데이트가 필요한 경우 ,  LoadingScreen 대신에 곧장 homeScreen으로 보내고, 로딩 뷰와 홈 뷰를 합쳐버리자

    } else {

      if (widget.checkUrgentNews.isNotEmpty){
        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          color: kMainColor,
          child: FutureBuilder(
            future: Future.delayed(Duration.zero),
            builder: (builder, snapshot) {
              return AlertDialog(
                //insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                shape: kRoundedRectangleBorder,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.checkUrgentNews['urgentNewsTitle']!,
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                content: Text(
                  widget.checkUrgentNews['urgentNewsContent']!,
                  //textAlign: TextAlign.start,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        exit(0);
                      },
                      child: Text('확인'))
                ],
              );
            },
          ),
        );
      } else { // widget.isUpdateNeeded == true
        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          color: kMainColor,
          child: FutureBuilder(
            future: Future.delayed(Duration.zero),
            builder: (builder, snapshot) {
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
                      onPressed: () {
                        setState(() {
                          SettingScreenViewModel().settingMoveToStore(context);
                        });
                      },
                      child: Text('확인'))
                ],
              );
            },
          ),
        );
      }
    }
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    // terminate 된 상태에서 상호작용하는 경우
    debugPrint('setupInteractedMessage 열림');
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {

      if (message != null) {
        // terminate에서 오픈하면 오게되는 곳

        // 로그인을 한 경우와 로그인을 하지 않은 경우 구분 필요
        final uid = FirebaseAuth.instance.currentUser?.uid.toString();
        debugPrint('setupInteractedMessage uid: $uid');
        //로그인 안하면 null로 나타남

        if (uid == null) {
          // 로그인이 안된 상태
          // 로그인 하는 페이지로 가야함
          await MoveToOtherScreen()
              .initializeGASetting(context, 'SignupScreen').then((value) async {

            await MoveToOtherScreen()
                .persistentNavPushNewScreen(
                context,
                SignupScreen(0),
                false,
                PageTransitionAnimation.cupertino)
                .then((value) async {

              await MoveToOtherScreen().initializeGASetting(
                  context, 'MainScreen');

            });
          });

        } else {
          // 로그인이 된 상태
          if (message.data['From'] == 'server') {

            await MoveToOtherScreen()
                .initializeGASetting(context, 'PrivateMailScreen').then((value) async {

              await MoveToOtherScreen()
                  .persistentNavPushNewScreen(
                  context,
                  PrivateMailScreen(),
                  false,
                  PageTransitionAnimation.cupertino)
                  .then((value) async {

                debugPrint('main.dart에서 돌아옴');

                await MoveToOtherScreen().initializeGASetting(
                    context, 'MainScreen');

              });
            });

          } else {
            //_handleMessage(message);

            // isNotificationable이 true인 경우에만 보여야 함

            MoveToOtherScreen().persistentNavPushNewScreen(
                context, ChatListView(), false, PageTransitionAnimation.cupertino);

            await MoveToOtherScreen()
                .initializeGASetting(context, 'ChatListScreen').then((value) async {

              await MoveToOtherScreen()
                  .persistentNavPushNewScreen(
                  context,
                  PrivateMailScreen(),
                  false,
                  PageTransitionAnimation.cupertino)
                  .then((value) async {

                debugPrint('main.dart에서 돌아옴');

                await MoveToOtherScreen().initializeGASetting(
                    context, 'MainScreen');

              });
            });
          }

        }

      }
    });


    if (initialMessage != null) {
      debugPrint('    if (initialMessage != null) { 에서 핸들 메시지');
      await _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleMessage(RemoteMessage message) async { // 백그라운드에서 노티 탭하면 작동하는 함수

    // 내가 지정한 그 알람이면? 지정한 화면으로 이동
    // if (message.data['data1'] == 'value1') {
    //   Navigator.pushNamed(context, '/'); // main에서는 이동불가 Home에 들어와서 해줘야함
    // }

    //GoogleAnalytics().openNoti(seconds);
    debugPrint('_handleMessage 열림');
    debugPrint('_handleMessage message: $message');
    debugPrint('_handleMessage message: ${message.data}');
    debugPrint('_handleMessage message: ${message.from}');
    debugPrint('_handleMessage message: ${message.data['From']}');

    // 이렇게 들어오게 되면 GA에 잡히나?

    // final currentPage =
    //     Provider.of<CurrentPageProvider>(context, listen: false).currentPage;
    //
    // // 백그라운드에서 노티를 클릭해서 들어오게되면,
    // // 디폴트 값인 mainscreen으로 currentPage가 설정되어 버림
    // widgetRegistry['$currentPage'] = GlobalKey();

    final providerCurrentPage =
        Provider.of<CurrentPageProvider>(navigatorKey.currentContext!, listen: false)
            .currentPage;
    debugPrint('App is in foreground providerCurrentPage: $providerCurrentPage');

    final String currentPage = widgetRegistry.keys.isNotEmpty ? widgetRegistry.keys.first : providerCurrentPage; // 직전 화면의 스크린명

    await Provider.of<CurrentPageProvider>(context, listen: false).setCurrentPage(currentPage).then((value) async {

      await Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
          .startTimer(currentPage).then((value) {

        debugPrint('App is in foreground currentPage: $currentPage');
        debugPrint('widgetRegistry: $widgetRegistry');
        //debugPrint('widgetRegistry: ${widgetRegistry.keys?.first}');

        widgetRegistry.clear();

      });
    });

    debugPrint('main.dart currentPage: $currentPage');
    debugPrint('message.data[From]: ${message.data['From']}');
    debugPrint('navigatorKey.currentWidget.key: ${navigatorKey.currentWidget?.key}');

    // 로그인을 한 경우와 로그인을 하지 않은 경우 구분 필요
    final uid = FirebaseAuth.instance.currentUser?.uid.toString();
    debugPrint('setupInteractedMessage uid: $uid');
    //로그인 안하면 null로 나타남

    if (uid == null) {
      // 로그인이 안된 상태
      // 로그인 하는 페이지로 가야함
      await MoveToOtherScreen()
          .initializeGASetting(context, 'SignupScreen').then((value) async {

        await MoveToOtherScreen()
            .persistentNavPushNewScreen(
            context,
            SignupScreen(0),
            false,
            PageTransitionAnimation.cupertino)
            .then((value) async {

          await MoveToOtherScreen().initializeGASetting(
              context, currentPage);

        });
      });

    } else {

      if (message.data['From'] == 'server') {
        // if (currentPage == 'HomeScreen' || currentPage == 'MainScreen' || currentPage == 'CalendarScreen' || currentPage == 'SettingScreen') {

        if (currentPage == 'HomeScreen') {

        } else {

          /// 최종: 앱을 이용하는 와중에 노티 클릭하면, 아무일 없게끔 설정 (이벤트 노티 수신 시)
          // 현재 다른 화면에 있는 상태에서 백그라운드에 진입했다가,
          // 노티를 수신해서 클릭해서 열게 되면, 그 원래 있던 다른 화면으로 돌아가게됨

          // final previousScreen = Provider.of<CurrentPageProvider>(context, listen: false).currentPage;
          // debugPrint('main.dart previousScreen: $previousScreen'); // 무조건 메인 페이지로 나타나는 중

          // await MoveToOtherScreen()
          //     .initializeGASetting(context, 'PrivateMailScreen').then((value) async {
          //
          //   await MoveToOtherScreen()
          //       .persistentNavPushNewScreen(
          //       context,
          //       PrivateMailScreen(),
          //       false,
          //       PageTransitionAnimation.cupertino)
          //       .then((value) async {
          //
          //         debugPrint('main.dart에서 돌아옴');
          //
          //     await MoveToOtherScreen().initializeGASetting(
          //         context, 'MainScreen');
          //
          //   });
          // });

          // MoveToOtherScreen().persistentNavPushNewScreen(
          //     context, HomeScreen(), false, PageTransitionAnimation.cupertino); // 홈스크린 대신에 프라이빗 메시지함으로 가야함. 단, ga 세팅을 살려야 함
        }

        /// GA 이벤트 중 notification_open 세부 세팅 필요

        //await GoogleAnalytics().


      } else {

        if (currentPage == 'ChatListView') {
          // 현재 페이지가 ChatListView인 경우에는 동작하지 않도록 처리

        } else {
          await MoveToOtherScreen()
              .initializeGASetting(context, 'ChatListScreen').then((value) async {

          }).then((value) {
            MoveToOtherScreen().persistentNavPushNewScreen(
                context, ChatListView(), false, PageTransitionAnimation.cupertino).then((value) async {

              await MoveToOtherScreen().initializeGASetting(
                  context, currentPage);

            }); // ga 세팅을 살려야 함
          });

        }

        // MoveToOtherScreen().persistentNavPushNewScreen(
        //           context, ChatListView(), false, PageTransitionAnimation.cupertino);
      }
    }
    //Navigator.push(context, MoveToOtherScreen.createRouteChatListView());

    // 서버에서 보낸 메시지면 home으로?
  } // 노티를 클릭했을때의 화면 전환 함수
}
