
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LocalDSRecentVisit {

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<DateTime> updateMyRecentVisit() async {

    DatabaseReference ref =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}");

    DatabaseReference recentVisitRef =
    FirebaseDatabase.instance.ref("users/${currentUser?.uid}/recentVisit");

    try {
      // 데이터베이스에서 기존 데이터를 가져옵니다.
      DatabaseEvent event = await recentVisitRef.once();
      final timeStamp = event.snapshot.value;
      print('updateMyRecentVisit timeStamp: $timeStamp');
      print('updateMyRecentVisit timeStamp: ${timeStamp.runtimeType}');

      if (timeStamp != null) {
        // 데이터가 이미 존재하는 경우, 업데이트를 수행합니다.
        Map<String, dynamic> updateData = {
          'recentVisit': DateTime.now().millisecondsSinceEpoch,
        };

        // 데이터베이스에 데이터를 업데이트합니다.
        await ref.update(updateData);

        // final dateTime = DateTime.parse((timeStamp as Timestamp).toDate().toString());
        //
        // print('dateTime: $dateTime');
        // 데이터베이스에 저장된 timeStamp를 밀리초로 가정하여 DateTime으로 변환합니다.
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp as int);
        print('dateTime: $dateTime');
        return dateTime;
      } else {

        // 데이터베이스에 데이터를 추가합니다.
        await recentVisitRef.set(DateTime.now().millisecondsSinceEpoch);

        return DateTime.now();
      }

    } catch (e) {
      print('updateMyRecentVisit e: $e');

      return DateTime.now();
    }
  }
}