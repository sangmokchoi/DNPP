import 'package:flutter/material.dart';

class CurrentPageProvider with ChangeNotifier {
  String currentPage = 'MainScreen';
  String initialCurrentPage = 'MainScreen';

  Future<void> setCurrentPage(String page) async {
    currentPage = page;
    notifyListeners();
    debugPrint('$page _currentPage: $currentPage');
  }

  Future<void> setInitialCurrentPage() async {
    currentPage = initialCurrentPage;
    notifyListeners();
    debugPrint('setInitialCurrentPage: $currentPage');
  }
}