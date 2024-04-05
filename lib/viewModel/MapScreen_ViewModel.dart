import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/pingpongList.dart';
import '../statusUpdate/mapWidgetUpdate.dart';

class MapScreenViewModel extends ChangeNotifier {

  double _x = 0.0;
  double _y = 0.0;

  NLatLng nLatLng = NLatLng(37.5666, 126.979);

  Future<void> updatePPLocation(BuildContext context, Map<String, dynamic> searchResult) async {
    print('updatePPLocation 시작');

    try {
      if (searchResult['items'].isEmpty) {
        print('검색 결과 없음');
        //Navigator.pop(context);

        //await showAlert(context);
        //notifyListeners();

      } else {
        print('updatePPLocation 진입');

        var items = searchResult["items"];

        for (dynamic item in items) {
          final _pingpoingList = PingpongList(
            title: removeHtmlTags(item['title']),
            link: item['link'],
            description: removeHtmlTags(item['description']),
            telephone: item['telephone'],
            address: item['address'],
            roadAddress: item['roadAddress'],
            mapx: double.parse(item['mapx']) / 10000000,
            mapy: double.parse(item['mapy']) / 10000000,
          );

          Provider.of<MapWidgetUpdate>(context, listen: false)
              .updatePPListElements(_pingpoingList);
        }

        //setState(() {

        await Provider.of<MapWidgetUpdate>(context, listen: false).overlayMake();
        //});
      }
      print('updatePPLocation 완료');
    } catch (e) {
      print('updatePPLocation e: $e');
    }

  }

  void toggleLoading(BuildContext context, bool isLoading) {
    // setState(() {

      if (isLoading) {
        // 로딩 바를 화면에 표시
        print('mapscreen 로딩 바를 화면에 표시');
        showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: false,
          builder: (context) {
            return Center(
              child: kCustomCircularProgressIndicator,
            );
          },
        );

      } else {
        print('toggleLoading 로딩 바 제거');
        //Navigator.of(context, rootNavigator: true).pop();
         Navigator.pop(context);
        //Navigator.of(context).pop();
      }
    //});

  }

  String removeHtmlTags(String input) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return input.replaceAll(exp, '');
  }

  Future<void> showAlert(BuildContext context) async {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          shape: kRoundedRectangleBorder,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "검색 결과가 없습니다",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("단어를 바꿔서 검색해주세요"),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("확인"),
                ],
              ),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

  }


}