
import 'package:http/http.dart' as http;
import 'dart:convert';

class Search {
  //MapGeocode(this.url);

  final String url = "https://openapi.naver.com/v1/search/local.json?query=";

  Future<Map<String, dynamic>> getData(String query) async {
    final finalUrl = '${url}${query}&display=50&start=1&sort=random';

    try {
      final response = await http.get(Uri.parse(finalUrl), headers: {
        "X-Naver-Client-Id": "fnA7onW12CtWy2n_z9a5",
        "X-Naver-Client-Secret": "s13ITu_UsG",
      });

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = json.decode(response.body);
        print(data.runtimeType);
        return data;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print("Error: $error");
      throw error;
    }
  }

  // Future<Map<String, dynamic>> fetchSearchData(String query) async {
  //   final url = 'https://us-central1-dnpp-402403.cloudfunctions.net/searchLocal?query=$query';
  //   //
  //   //   try {
  //   //     final response = await http.get(url);
  //   //
  //   //     if (response.statusCode == 200) {
  //   //       final data = response.body; // API 응답 데이터
  //   //       print(data);
  //   //       // 여기서 데이터를 파싱하거나 사용합니다.
  //   //       final Map<String, dynamic> data1 = json.decode(response.body);
  //   //       print(data1);
  //   //       return data1;
  //   //
  //   //     } else {
  //   //       throw Exception('Failed to load data');
  //   //     }
  //   //   } catch (error) {
  //   //     print("Error: $error");
  //   //     throw error;
  //   //   }
  //   // }
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     print(response.statusCode);
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);
  //       return data;
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (error) {
  //     print("Error: $error");
  //     throw error;
  //   }
  // }

  Future<Map<String, dynamic>> fetchSearchData(String query) async {

    try {
      final response = await http.get(Uri.parse('https://us-central1-dnpp-402403.cloudfunctions.net/searchLocal?query=$query'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        return data;

      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print("Error: $error");
      throw error;
    }

  }

}