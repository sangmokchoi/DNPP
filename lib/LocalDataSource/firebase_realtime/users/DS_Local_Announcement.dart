
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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
      print('updateAdBannerVisibleConfirmTime e: $e');

    }

  }

  Future<DateTime?> downloadAnnouncementVisibleTime() async {

    DatabaseReference adBannerVisibleConfirmTimeRef =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}/adBannerVisibleConfirmTime");

    try {
      DatabaseEvent event = await adBannerVisibleConfirmTimeRef.once();
      final timeStamp = event.snapshot.value;
      print('downloadAdBannerVisibleConfirmTime timeStamp: $timeStamp');

      if (timeStamp != null) {
        print('if (timeStamp != null) {');
        if (timeStamp is int) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);
          print('if (timeStamp is int) {');
          print('dateTime: $dateTime');
          print('dateTime.runtimeType: ${dateTime.runtimeType}');
          return dateTime;
        } else {
          final dateTime =
          DateTime.parse((timeStamp as Timestamp).toDate().toString());
          print('} else {');
          return dateTime;
        }
      } else {
        print('return null;');
        return null;
      }

    } catch (e) {
      print('downloadAdBannerVisibleConfirmTime e: $e');
      return null;
    }

  }
}