
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constants.dart';
import '../LocalDataSource/DS_Local_auth.dart';

class ShowToast {

  showToast(String msg) {

    try {
      Fluttertoast.showToast(
        msg: msg,
        timeInSecForIosWeb: 2,
        gravity: ToastGravity.NONE,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('showToast e: $e');
    }


    // fToast().showToast(
    //   child: toast,
    //   gravity: ToastGravity.BOTTOM,
    //   toastDuration: Duration(seconds: 2),
    // );
  }

  showToastMiddle(String msg) {

    try {
      Fluttertoast.showToast(
        msg: msg,
        timeInSecForIosWeb: 1,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('showToast e: $e');
    }


    // fToast().showToast(
    //   child: toast,
    //   gravity: ToastGravity.BOTTOM,
    //   toastDuration: Duration(seconds: 2),
    // );
  }
}