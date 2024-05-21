import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class FirebaseAuthRemoteDataSource {

  final String url = 'https://us-central1-dnpp-402403.cloudfunctions.net/createCustomToken';

  Future<String> createCustomToken(Map<String, dynamic> user) async {

    final customTokenResponse = await http.post(Uri.parse(url), body: user);
    debugPrint('customTokenResponse: ${customTokenResponse.headers}');
    debugPrint('customTokenResponse: ${customTokenResponse.statusCode}');
    debugPrint('customTokenResponse: ${customTokenResponse.body}');

    return customTokenResponse.body;
  }
}