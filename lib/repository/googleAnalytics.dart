
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../statusUpdate/loadingUpdate.dart';
import '../statusUpdate/profileUpdate.dart';

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
    await FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'firebase_screen': screenName,
      },
    );
  }

}