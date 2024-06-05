

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportUpdate extends ChangeNotifier {

  List<String> reportReasonList = [];
  TextEditingController reportTextEditingController = TextEditingController();

  Future<void> addReportReasonList(String value) async {
    reportReasonList.add(value);
    notifyListeners();
    debugPrint('reportReasonList: $reportReasonList');
  }
  Future<void> removeReportReasonList(String value) async {
    reportReasonList.remove(value);
    notifyListeners();
    debugPrint('reportReasonList: $reportReasonList');
  }
  Future<void> clearReportReasonList() async {
    reportReasonList.clear();
    notifyListeners();
    debugPrint('reportReasonList: $reportReasonList');
  }

  Future<void> clearTextEditingController() async {
    reportTextEditingController.clear();
    notifyListeners();
  }

}