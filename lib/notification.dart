import 'package:app_settings/app_settings.dart';
import 'package:dnpp/repository/firebase_realtime_users.dart';
import 'package:dnpp/statusUpdate/CurrentPageProvider.dart';
import 'package:dnpp/statusUpdate/googleAnalytics.dart';
import 'package:dnpp/view/PrivateMail_Screen.dart';
import 'package:dnpp/view/chatList_Screen.dart';
import 'package:dnpp/view/home_screen.dart';
import 'package:dnpp/view/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'models/launchUrl.dart';
import 'models/moveToOtherScreen.dart';

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();

  static init() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      /// 포그라운드에서 노티를 열때 작동
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {

        debugPrint('onDidReceiveNotificationResponse 작동');
        debugPrint('notificationResponse id: ${notificationResponse}');
        debugPrint('notificationResponse id: ${notificationResponse.id}');
        debugPrint('notificationResponse actionId: ${notificationResponse.actionId}');
        debugPrint('notificationResponse input: ${notificationResponse.input}');
        debugPrint('notificationResponse payload: ${notificationResponse.payload}');
        debugPrint('notificationResponse payload: ${notificationResponse.payload.runtimeType}');
        debugPrint('notificationResponse notificationResponseType: ${notificationResponse.notificationResponseType}');
        // 안드로이드에서 열 떄 나타남
        // final currentPage = Provider.of<CurrentPageProvider>(context, listen: false).currentPage;
        debugPrint('navigatorKey: ${navigatorKey}');
        debugPrint('navigatorKey.currentState: ${navigatorKey.currentState}');
        debugPrint('navigatorKey.currentState!.context: ${navigatorKey.currentState!.context}');
        debugPrint('navigatorKey.currentContext: ${navigatorKey.currentContext}');
        debugPrint('navigatorKey.currentWidget: ${navigatorKey.currentWidget}');
        debugPrint('navigatorKey.currentWidget?.key: ${navigatorKey.currentWidget?.key}');

        final currentPage = Provider.of<CurrentPageProvider>(navigatorKey.currentState!.context, listen: false).currentPage;
        debugPrint('currentPage: $currentPage');

        if ( notificationResponse.payload == 'server') {
          // 이 경우는 안내문, 이벤트 내용등을 수신할 떄
          // if (currentPage == 'HomeScreen' || currentPage == 'MainScreen'){
          //
          // } else { // 홈 화면에 있는게 아니라면 홈화면으로 보내서 배너 보게끔 함
          await GoogleAnalytics().setNotificationOpen('server');

        if (currentPage == 'PrivateMailScreen') {
          // 현재 페이지가 PrivateMailScreen인 경우에는 동작하지 않도록 처리

        } else {
          /// 서버에서 수신 시, 프라이빗 메일함으로 보냄

          await MoveToOtherScreen()
              .initializeGASetting(navigatorKey.currentContext!, 'PrivateMailScreen').then((value) async {

          }).then((value) {
            MoveToOtherScreen().persistentNavPushNewScreen(
                navigatorKey.currentContext!, PrivateMailScreen(), false, PageTransitionAnimation.cupertino).then((value) async {

              await MoveToOtherScreen().initializeGASetting(
                  navigatorKey.currentContext!, '$currentPage');

            }); // ga 세팅을 살려야 함
          });
        }


          //}
          // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
          // NavigatorState? currentState = navigatorKey.currentState;

        } else {
          // 이 경우는 다른 유저가 현재 유저에게 메시지를 보냈을때
          await GoogleAnalytics().setNotificationOpen('user');
          
          if (currentPage == 'ChatListView') {
            // 현재 페이지가 ChatListView인 경우에는 동작하지 않도록 처리
          } else if (currentPage == 'ChatScreen') {
            // 다른 유저와의 채팅방에 있다면, 그냥 뒤로 가게끔 유도
            await MoveToOtherScreen()
                .initializeGASetting(navigatorKey.currentContext!, 'ChatScreen').then((value) async {

            }).then((value) async {

              Navigator.of(navigatorKey.currentContext!).pop();

            });

          } else {
            // 채팅방 화면에 있는게 아니라면 채팅방 화면으로 보게끔 함

            // MoveToOtherScreen().persistentNavPushNewScreen(
            //     context, ChatListView(), false, PageTransitionAnimation.cupertino);


            await MoveToOtherScreen()
                .initializeGASetting(navigatorKey.currentContext!, 'ChatListScreen').then((value) async {

            }).then((value) {
              MoveToOtherScreen().persistentNavPushNewScreen(
                  navigatorKey.currentContext!, ChatListView(), false, PageTransitionAnimation.cupertino).then((value) async {

                await MoveToOtherScreen().initializeGASetting(
                    navigatorKey.currentContext!, '$currentPage');

              }); // ga 세팅을 살려야 함
            });

          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );


  }



  @pragma('vm:entry-point')
  static Future<void> notificationTapBackground(NotificationResponse notificationResponse) async {
    // final payload = notificationResponse.payload;
    // flutterLocalNotificationsPlugin.show(
    //     message.hashCode,
    //     message!.data['title'],
    //     message!.data['body'],
    //     const NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         'ID',//channel.id,
    //         '핑퐁플러스',//channel.name,
    //         channelDescription: 'Pingpong Plus', //channelDescription: channel.description,
    //         icon: 'mipmap/ic_launcher', //'launch_background',
    //         //importance: Importance.max,
    //         importance: Importance.max,
    //         //priority: Priority.high,
    //         //showWhen: false,
    //
    //       ),
    //       // android: AndroidNotificationDetails(
    //       //   'high_importance_channel',
    //       //   'high_importance_notification',
    //       //   importance: Importance.max,
    //       //   priority: Priority.high,
    //       //   showWhen: false,
    //       // ),
    //     ),
    //     payload: payload // == 'server'
    // );

    debugPrint('notificationTapBackground 작동');
    debugPrint('notificationResponse id: ${notificationResponse.id}');
    debugPrint('notificationResponse actionId: ${notificationResponse.actionId}');
    debugPrint('notificationResponse input: ${notificationResponse.input}');
    debugPrint('notificationResponse payload: ${notificationResponse.payload}');
    debugPrint('notificationResponse payload: ${notificationResponse.payload.runtimeType}');
    debugPrint('notificationResponse notificationResponseType: ${notificationResponse.notificationResponseType}');
    // 안드로이드에서 열 떄 나타남
    // final currentPage = Provider.of<CurrentPageProvider>(context, listen: false).currentPage;
    debugPrint('navigatorKey: ${navigatorKey}');
    debugPrint('navigatorKey.currentState: ${navigatorKey.currentState}');
    debugPrint('navigatorKey.currentState!.context: ${navigatorKey.currentState!.context}');
    debugPrint('navigatorKey.currentContext: ${navigatorKey.currentContext}');
    debugPrint('navigatorKey.currentWidget: ${navigatorKey.currentWidget}');
    debugPrint('navigatorKey.currentWidget?.key: ${navigatorKey.currentWidget?.key}');

    final currentContext = navigatorKey.currentContext!;
    // 로그인을 한 경우와 로그인을 하지 않은 경우 구분 필요
    final uid = FirebaseAuth.instance.currentUser?.uid.toString();
    debugPrint('setupInteractedMessage uid: $uid');
    //로그인 안하면 null로 나타남

    if (uid == null) {
      // 로그인이 안된 상태
      // 로그인 하는 페이지로 가야함
      await MoveToOtherScreen()
          .initializeGASetting(currentContext, 'SignupScreen').then((value) async {

        await MoveToOtherScreen()
            .persistentNavPushNewScreen(
            currentContext,
            SignupScreen(0),
            false,
            PageTransitionAnimation.cupertino)
            .then((value) async {

          await MoveToOtherScreen().initializeGASetting(
              currentContext, 'MainScreen');

        });
      });
    } else {

    }


    final currentPage = Provider.of<CurrentPageProvider>(navigatorKey.currentState!.context, listen: false).currentPage;
    debugPrint('노티 탭해서 열림 currentPage: $currentPage');

    if (notificationResponse.payload == 'server') {
      // 이 경우는 안내문, 이벤트 내용등을 수신할 떄
      // if (currentPage == 'HomeScreen'){
      //
      // } else {
      //   // MoveToOtherScreen().persistentNavPushNewScreen(
      //   //     context, HomeScreen(), false, PageTransitionAnimation.cupertino);
      //
      //   // await MoveToOtherScreen()
      //   //     .initializeGASetting(context, 'PrivateMailScreen').then((value) async {
      //   //
      //   //   await MoveToOtherScreen()
      //   //       .persistentNavPushNewScreen(
      //   //       context,
      //   //       PrivateMailScreen(),
      //   //       false,
      //   //       PageTransitionAnimation.cupertino)
      //   //       .then((value) async {
      //   //
      //   //         debugPrint('main.dart에서 돌아옴');
      //   //
      //   //     await MoveToOtherScreen().initializeGASetting(
      //   //         context, 'MainScreen');
      //   //
      //   //   });
      //   // });
      //
      //   // MoveToOtherScreen().persistentNavPushNewScreen(
      //   //     currentContext, HomeScreen(), false, PageTransitionAnimation.cupertino);
      // }
      await GoogleAnalytics().setNotificationOpen('server');

      await MoveToOtherScreen()
          .initializeGASetting(currentContext, 'PrivateMailScreen').then((value) async {

      }).then((value) {
        MoveToOtherScreen().persistentNavPushNewScreen(
            currentContext, PrivateMailScreen(), false, PageTransitionAnimation.cupertino).then((value) async {

          await MoveToOtherScreen().initializeGASetting(
              currentContext, 'MainScreen');

        }); // ga 세팅을 살려야 함
      });


      // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
      // NavigatorState? currentState = navigatorKey.currentState;

    } else {
      await GoogleAnalytics().setNotificationOpen('user');
      // 이 경우는 다른 유저가 현재 유저에게 메시지를 보냈을때
      if (currentPage == 'ChatListView') {
        // 현재 페이지가 ChatListView인 경우에는 동작하지 않도록 처리
      } else if (currentPage == 'ChatScreen') {
        // 다른 유저와의 채팅방에 있다면, 그냥 뒤로 가게끔 유도
        await MoveToOtherScreen()
            .initializeGASetting(currentContext, 'ChatScreen').then((value) async {

        }).then((value) async {

          Navigator.of(currentContext).pop();

        });

      } else {
        // MoveToOtherScreen().persistentNavPushNewScreen(
        //     context, ChatListView(), false, PageTransitionAnimation.cupertino);

        await MoveToOtherScreen()
            .initializeGASetting(currentContext, 'ChatListScreen').then((value) async {

        }).then((value) {
          MoveToOtherScreen().persistentNavPushNewScreen(
              currentContext, ChatListView(), false, PageTransitionAnimation.cupertino).then((value) async {

            await MoveToOtherScreen().initializeGASetting(
                currentContext, 'MainScreen');

          }); // ga 세팅을 살려야 함
        });

        // MoveToOtherScreen().persistentNavPushNewScreen(
        //     currentContext, ChatListView(), false, PageTransitionAnimation.cupertino);
      }
    }

    //await GoogleAnalytics().setNotificationOpen();


  }

  static Future<PermissionStatus> requestNotificationPermission() async {

    debugPrint('requestNotificationPermission 진입');

    if (Platform.isAndroid) {

      final int sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      debugPrint('sdkInt: $sdkInt');
      if (sdkInt >= 33) {

        PermissionStatus status = await Permission.notification.request();
        debugPrint('notification PermissionStatus status: $status');
        // if ( status == PermissionStatus.denied) {
        //   await ChatBackgroundListen().toggleNotification(false);
        // } else if (status == PermissionStatus.permanentlyDenied) {
        //   await ChatBackgroundListen().toggleNotification(false);
        // } else if (status == PermissionStatus.restricted) {
        //   await ChatBackgroundListen().toggleNotification(false);
        //
        // } else if (status == PermissionStatus.granted) {
        //   await ChatBackgroundListen().toggleNotification(true);
        // } else if (status == PermissionStatus.limited) {
        //   await ChatBackgroundListen().toggleNotification(true);
        // } else if (status == PermissionStatus.provisional) {
        //   await ChatBackgroundListen().toggleNotification(true);
        // }
        if (status == PermissionStatus.denied ||
            status == PermissionStatus.permanentlyDenied ||
            status == PermissionStatus.restricted) {
          // 권한 재요청 또는 설정으로 보내야 함
          // await Permission.notification.request();
          LaunchUrl().alertFunc(
              navigatorKey.currentContext!,
              '알림 권한',
              '현재 디바이스에서 핑퐁플러스 알림이 꺼진 상태입니다.\n원활한 수신을 위해서는 "설정"에서 핑퐁플러스 알림 권한을 활성화해주세요.',
              '확인', () {
            Navigator.pop(navigatorKey.currentContext!);
            AppSettings.openAppSettings(type: AppSettingsType.notification);
          });

        } else {

        }
        return status;

      } else {


        NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        debugPrint('settings: $settings');

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          debugPrint('User granted permission');
          return PermissionStatus.granted;
        } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
          debugPrint('User granted provisional permission');
          return PermissionStatus.granted;
        } else {
          debugPrint('User declined or has not accepted permission');
          //AppSettings.openAppSettings(type: AppSettingsType.notification);
          LaunchUrl().alertFunc(
              navigatorKey.currentContext!,
              '알림 권한',
              '현재 디바이스에서 핑퐁플러스 알림이 꺼진 상태입니다.\n원활한 수신을 위해서는 "설정"에서 핑퐁플러스 알림 권한을 활성화해주세요.',
              '확인', () {
            Navigator.pop(navigatorKey.currentContext!);
            //AppSettings.openAppSettings(type: AppSettingsType.notification);
          });
          return PermissionStatus.denied;
        }

      }
    } else {
      // ios

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      final getNotificationSettings = await FirebaseMessaging.instance.getNotificationSettings();
      final notificationCenter = getNotificationSettings.notificationCenter;
      debugPrint('notificationCenter: $notificationCenter');

      switch (notificationCenter){
        case AppleNotificationSetting.disabled:
          debugPrint('notificationCenter: $notificationCenter');
          LaunchUrl().alertFunc(
              navigatorKey.currentContext!,
              '알림 권한',
              '현재 디바이스에서 핑퐁플러스 알림이 꺼진 상태입니다.\n원활한 수신을 위해서는 "설정"에서 핑퐁플러스 알림 권한을 활성화해주세요.',
              '확인', () {
            Navigator.pop(navigatorKey.currentContext!);
            //AppSettings.openAppSettings(type: AppSettingsType.notification);
          });
          return PermissionStatus.denied;
        case AppleNotificationSetting.enabled:
          debugPrint('notificationCenter: $notificationCenter');
          return PermissionStatus.granted;
        default:
          debugPrint('notificationCenter: $notificationCenter');
          LaunchUrl().alertFunc(
              navigatorKey.currentContext!,
              '알림 권한',
              '현재 디바이스에서 핑퐁플러스 알림이 꺼진 상태입니다.\n원활한 수신을 위해서는 "설정"에서 핑퐁플러스 알림 권한을 활성화해주세요.',
              '확인', () {
            Navigator.pop(navigatorKey.currentContext!);
            //AppSettings.openAppSettings(type: AppSettingsType.notification);
          });
          return PermissionStatus.denied;
      }

    }

  }

  static Future<void> showNotification() async { // ios 에서 작동 x
    debugPrint('showNotification 진입');
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel id', 'channel name',
            channelDescription: 'channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          icon: null
        );

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1));

    // await flutterLocalNotificationsPlugin.show(
    //     0, 'test title', 'test body', notificationDetails);
  }
}
