
import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/userProfile.dart';
import 'profileUpdate.dart';


class GoogleAnalyticsNotifier extends ChangeNotifier {

  Timer? timer; // 타이머를 저장할 변수

  int durationInSeconds = 0;

  Future<void> startTimer(String screenName) async {

    await cancelAndLogBoardingTime(screenName);

    timer = Timer.periodic(Duration(seconds: 1), (timer) {

      if (durationInSeconds < 60) {
        durationInSeconds++; // 앱이 백그라운드에 들어가도 동작함
      }
      //debugPrint('$screenName durationInSeconds: $durationInSeconds');
      //GoogleAnalytics().onboardingScreen(context, durationInSeconds);

    });
  }
  
  Future<void> cancelAndLogBoardingTime(String screenName) async {

    timer?.cancel();

    if (durationInSeconds > 1) {

      await FirebaseAnalytics.instance.logEvent(
        name: "boarding_seconds",
        parameters: {
          "screen": screenName,
          "seconds": durationInSeconds,
        },
      ).then((value) {
        durationInSeconds = 0;
        debugPrint('cancelAndLogBoardingTime 완료');
      });

    }

    notifyListeners();

    //GoogleAnalytics().onboardingScreen(value);
  }
  
}

class GoogleAnalytics {

  Future<void> bannerClickEvent(BuildContext context, String banner, int index, String imageName, String url) async {

    final currentUser = Provider.of<ProfileUpdate>(context, listen: false).userProfile;
    await FirebaseAnalytics.instance.logEvent(
      name: "${banner}_banner_${index}_click",
      parameters: {
        "image_name": imageName,
        "url_link": '$url',

        'gender': currentUser.gender,
        'ageRange': currentUser.ageRange,
        'playedYears': currentUser.playedYears,

        'playStyle': currentUser.playStyle,
        'rubber': currentUser.rubber,
        'racket': currentUser.racket,
      },
    );
  }

  Future<void> setUserProperty(BuildContext context, String name, String value) async {

    await FirebaseAnalytics.instance
        .setUserProperty(
      name: name,
        value: value,
    );

  }

  Future<void> trackScreen(BuildContext context, String screenName) async {
    // await FirebaseAnalytics.instance.logEvent(
    //   name: screenName,
    //   parameters: {
    //     '$screenName': screenName,
    //   },
    // );
    await FirebaseAnalytics.instance.logScreenView(screenName: screenName);
    debugPrint('trackScreen 완료');
  }

  Future<void> onboardingScreen(int seconds) async {
    await FirebaseAnalytics.instance.logEvent(
      name: "seconds",
      parameters: {
        "seconds": seconds,
      },
    );
  }

  Future<void> openNoti(int seconds) async {
    await FirebaseAnalytics.instance.logEvent(
      name: "notification_open",
      parameters: {
        "seconds": seconds,
      },
    );
  }


  Future<void> setAnalyticsUserProfile(BuildContext context, UserProfile userProfile) async {
    debugPrint('setAnalyticsUserProfile 진입');

    try {
      await setUserProperty(context, "userProfile_racket", userProfile.racket);
      await setUserProperty(context, "userProfile_rubber", userProfile.rubber);
      await setUserProperty(context, "userProfile_playStyle", userProfile.playStyle);
      await setUserProperty(context, "userProfile_playedYears", userProfile.playedYears);
      await setUserProperty(context, "userProfile_ageRange", userProfile.ageRange);
      await setUserProperty(context, "userProfile_gender", userProfile.gender);


      for (int number = 1; number <= 3; number++) {
        try {
          await setUserProperty(
              context, "userProfile_address$number", userProfile.address[number - 1]);
        } catch (e) {
          await setUserProperty(
              context, "userProfile_address$number", 'null');
        }
      }


      // if (userProfile.address.length != 0) {
      //
      //   int forAddress = 1; // 최대 3개
      //
      //   for (final address in userProfile.address) {
      //     await setUserProperty(
      //         context, "userProfile_address$forAddress", address).then((value) => forAddress++);
      //   }
      // } else { //없으면 없다고 설정 필요
      //   int forAddress = 1;
      //   await setUserProperty(
      //       context, "userProfile_address$forAddress", address).then((value) => forAddress++);
      // }

      if (userProfile.pingpongCourt!.isNotEmpty) {

        // int forPingpongCourt = 1; // 최대 5개
        //
        // for (final pingpongCourt in userProfile.pingpongCourt!) {
        //   await setUserProperty(
        //       context, "userProfile_ppCourt$forPingpongCourt", pingpongCourt.title).then((value) => forPingpongCourt++);
        // }

        for (int number = 1; number <= 5; number++) {
          try {
            await setUserProperty(
                context, "userProfile_ppCourt$number", userProfile.pingpongCourt![number - 1].title);
          } catch (e) {
            await setUserProperty(
                context, "userProfile_ppCourt$number", 'null');
          }
        }

      } else {
        for (int number = 1; number <= 5; number++) {

          await setUserProperty(
              context, "userProfile_ppCourt$number", 'null');

        }
      }

    } catch (e) {
      debugPrint('setAnalyticsUserProfile e: $e');
    }

  }

  Future<void> setAnalyticsLogEvent(BuildContext context, String screenName) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'screenName',
      parameters: {
        'screenName': screenName,
      },
    );
  }

}