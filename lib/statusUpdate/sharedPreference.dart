

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference extends ChangeNotifier {

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool isUserTried = false;

  Future<void> initializeSharedPreferences() async {
    final SharedPreferences prefs = await _prefs;
    bool? _isUserTried = prefs.getBool('isUserTried');
    // Your logic using the retrieved value...

    if (isUserTried != null) {
      isUserTried = _isUserTried!;
      debugPrint('isUserTried: $isUserTried');
    }
    debugPrint('initializeSharedPreferences 끝');
    notifyListeners();
  }

}