import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapGeocode {
  //MapGeocode(this.url);

  final String url = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=";

  Future<Map<String, dynamic>> getData(String query) async {
    final finalUrl = '${url}${query}&coordinate=127.1054328,36.3595963';

    try {
      final response = await http.get(Uri.parse(finalUrl), headers: {
        "X-NCP-APIGW-API-KEY-ID": "7evubnn4j6",
        "X-NCP-APIGW-API-KEY": "fUsXDvLXKgY6SJoh3zLjceHJY8L7V9Kd9hro9sKj",
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw error;
    }
  }
}


