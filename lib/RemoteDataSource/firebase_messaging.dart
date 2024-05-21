import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class FirebaseMessagingRemoteDataSource {

  Future<void> sendMessageData(String senderNickName, String messageBody, String token, int newBadge) async {

    debugPrint('senderNickName: $senderNickName');
    debugPrint('messageBody: $messageBody');
    debugPrint('token: $token');

    debugPrint('sendMessageData 시작');
    String baseUrl = 'https://sendchatnotitoopponent-dto7nx7sua-uc.a.run.app';
    String cloudUrl = '$baseUrl?senderNickName=$senderNickName&messageBody=$messageBody&token=$token&newBadge=$newBadge';

    final response = await http.get(Uri.parse(cloudUrl));
    debugPrint('sendMessageData response: ${response.headers}');
    debugPrint('sendMessageData response: ${response.body}');
    debugPrint('sendMessageData response: ${response.statusCode}');

    if (response.statusCode == 200) {
      debugPrint('정상 작동됨');
    } else {
      //await FirebaseMessaging.instance.deleteToken();
      //debugPrint('deleteToken됨');
    }

  }

}