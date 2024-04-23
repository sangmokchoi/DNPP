import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'main.dart';

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

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<PermissionStatus> requestNotificationPermission() async {

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    if (Platform.isAndroid) {

      final int sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

      if (sdkInt >= 33) {

        PermissionStatus status = await Permission.notification.request();
        print('notification PermissionStatus status: $status');
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
          //await ChatBackgroundListen().toggleNotification(false);
        } else {
          //await ChatBackgroundListen().toggleNotification(true);
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
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('User granted permission');
          return PermissionStatus.granted;
        } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
          print('User granted provisional permission');
          return PermissionStatus.granted;
        } else {
          print('User declined or has not accepted permission');
          return PermissionStatus.denied;
        }

      }
    } else {

      final getNotificationSettings = await FirebaseMessaging.instance.getNotificationSettings();
      final notificationCenter = getNotificationSettings.notificationCenter;
      print('notificationCenter: $notificationCenter');

      switch (notificationCenter){
        case AppleNotificationSetting.disabled:
          //await ChatBackgroundListen().toggleNotification(false);
          print('notificationCenter: $notificationCenter');
          //return;
          return PermissionStatus.denied;
        case AppleNotificationSetting.enabled:
          //await ChatBackgroundListen().toggleNotification(true);
          print('notificationCenter: $notificationCenter');
          //return;
          return PermissionStatus.granted;
        default:
          //await ChatBackgroundListen().toggleNotification(false);
          print('notificationCenter: $notificationCenter');
          //return;
          return PermissionStatus.denied;
      }

    }

  }

  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel id', 'channel name',
            channelDescription: 'channel description',
            importance: Importance.max,
            priority: Priority.max,
            showWhen: false);

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1));

    await flutterLocalNotificationsPlugin.show(
        0, 'test title', 'test body', notificationDetails);
  }
}
