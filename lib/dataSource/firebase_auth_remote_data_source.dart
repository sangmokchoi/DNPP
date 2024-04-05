import 'package:http/http.dart' as http;

class FirebaseAuthRemoteDataSource {

  final String url = 'https://us-central1-dnpp-402403.cloudfunctions.net/createCustomToken';

  Future<String> createCustomToken(Map<String, dynamic> user) async {

    final customTokenResponse = await http.post(Uri.parse(url), body: user);
    print('customTokenResponse: ${customTokenResponse.headers}');
    print('customTokenResponse: ${customTokenResponse.statusCode}');
    print('customTokenResponse: ${customTokenResponse.body}');

    return customTokenResponse.body;
  }
}