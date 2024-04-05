import 'dart:io';
import 'package:dnpp/constants.dart';
import 'package:dnpp/repository/chatBackgroundListen.dart';
import 'package:dnpp/repository/launchUrl.dart';
import 'package:dnpp/repository/moveToOtherScreen.dart';
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
import 'firebase_options.dart';
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupFlutterNotifications(); // 셋팅 메소드
  showFlutterNotification(message); // 로컬노티
}

/// fcm 전경 처리 - 로컬 알림 보이기
//@pragma('vm:entry-point')
void showFlutterNotification(RemoteMessage message) {
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

  print('Message data: ${message.data}');
  print('Message messageId: ${message.messageId}');
  print('Message mutableContent: ${message.mutableContent}');
  print('Message category: ${message.category}');
  print('Message from: ${message.from}');
  print('Message data: ${message.data}');
  print('Message hashCode: ${message.hashCode}');

  print('Message notification: ${message.notification}');
  print(
      'Message notification title: ${message.notification?.title}'); // 콘솔에서 보낸 메시지의 제목
  print(
      'Message notification body: ${message.notification?.body}'); // 콘솔에서 보낸 메시지의 바디

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  print('notification: $notification');
  print('notification apple: ${notification?.apple}');
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

  if (notification?.apple == null) {
    // 안드로이드인 경우,
    print('안드로이드인 경우');
    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: null //'launch_background',
            ),
      ),
    );
  }
  // if (notification?.apple != null) { // ios 인 경우 *** ios 인 경우에는 별도로 .show를 하지 않아도 알아서 노티를 수신함 ***
  //   print('ios인 경우');
  //     flutterLocalNotificationsPlugin.show(
  //       notification.hashCode,
  //       notification?.title,
  //       notification?.body,
  //       // const NotificationDetails(
  //       //   iOS: DarwinNotificationDetails(
  //       //       //presentAlert: true,
  //       //       //presentBadge: true,
  //       //       //presentSound: true,
  //       //   )
  //       // ),
  //       null
  //     );
  // }
}

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

    await ChatBackgroundListen().uploadFcmToken(token);
  });
  // foreground 수신처리
  FirebaseMessaging.onMessage.listen(showFlutterNotification);
  // background 수신처리
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // 알림 클릭시
  //FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
        theme: theme,
        darkTheme: darkTheme,
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
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
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

  void _handleMessage(RemoteMessage message) {
    // 내가 지정한 그 알람이면? 지정한 화면으로 이동
    // if (message.data['data1'] == 'value1') {
    //   Navigator.pushNamed(context, '/'); // main에서는 이동불가 Home에 들어와서 해줘야함
    // }
    print('_handleMessage message: $message');
    print('_handleMessage message: ${message.data}');
    print('_handleMessage message: ${message.from}');

    MoveToOtherScreen().persistentNavPushNewScreen(
        context, ChatListView(), false, PageTransitionAnimation.cupertino);
    //Navigator.push(context, MoveToOtherScreen.createRouteChatListView());
  }

  @override
  void initState() {
    setupInteractedMessage();

    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
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
    );
  }
}
