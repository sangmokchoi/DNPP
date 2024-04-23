import 'package:http/http.dart' as http;

class FirebaseMessagingRemoteDataSource {

  Future<void> sendMessageData(String senderNickName, String messageBody, String token, int newBadge) async {

    print('senderNickName: $senderNickName');
    print('messageBody: $messageBody');
    print('token: $token');

    print('sendMessageData 시작');
    String baseUrl = 'https://sendchatnotitoopponent-dto7nx7sua-uc.a.run.app';
    String cloudUrl = '$baseUrl?senderNickName=$senderNickName&messageBody=$messageBody&token=$token&newBadge=$newBadge';

    final response = await http.get(Uri.parse(cloudUrl));
    print('sendMessageData response: ${response.headers}');
    print('sendMessageData response: ${response.body}');
    print('sendMessageData response: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('정상 작동됨');
    } else {
      //await FirebaseMessaging.instance.deleteToken();
      //print('deleteToken됨');
    }

  }

}