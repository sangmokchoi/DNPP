import 'dart:io';

class AdHelper {

  static String get chatListBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7181550207731095/9862925764';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7181550207731095/7889259303';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get mainBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7181550207731095/7189495110';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7181550207731095/2184580440';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get matchingMatchingAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7181550207731095/5876413440';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7181550207731095/5732943211';
    }
    throw UnsupportedError("Unsupported platform");
  }
}