
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class LocalDSAnnouncement {

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> updateAnnouncementVisibleTime() async {

    DatabaseReference ref =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}");

    try {
      Map<String, dynamic> updateData = {
        'adBannerVisibleConfirmTime': DateTime.now().millisecondsSinceEpoch,
      };

      await ref.update(updateData);

    } catch (e) {
      debugPrint('updateAdBannerVisibleConfirmTime e: $e');

    }

  }

  Future<DateTime?> downloadAnnouncementVisibleTime() async {

    DatabaseReference adBannerVisibleConfirmTimeRef =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}/adBannerVisibleConfirmTime");

    try {
      DatabaseEvent event = await adBannerVisibleConfirmTimeRef.once();
      final timeStamp = event.snapshot.value;
      debugPrint('downloadAdBannerVisibleConfirmTime timeStamp: $timeStamp');

      if (timeStamp != null) {
        debugPrint('if (timeStamp != null) {');
        if (timeStamp is int) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);
          debugPrint('if (timeStamp is int) {');
          debugPrint('dateTime: $dateTime');
          debugPrint('dateTime.runtimeType: ${dateTime.runtimeType}');
          return dateTime;
        } else {
          final dateTime =
          DateTime.parse((timeStamp as Timestamp).toDate().toString());
          debugPrint('} else {');
          return dateTime;
        }
      } else {
        debugPrint('return null;');
        return null;
      }

    } catch (e) {
      debugPrint('downloadAdBannerVisibleConfirmTime e: $e');
      return null;
    }

  }
}