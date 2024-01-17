import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../constants.dart';
import '../models/pingpongList.dart';
import '../widgets/map/map_addressList_element.dart';
import '../widgets/map/map_pingpongList_element.dart';

class MapWidgetUpdate with ChangeNotifier {

  List<AddressListElement> addressListElements = [];

  String x = '';
  String y = '';
  String roadAddress = '';
  String jibunAddress = '';
  String longName = '';

  final List<PingpongList> pPListElements = [];
  late NaverMapController naverController;

  Future<void> updateNaverController(NaverMapController controller) async{
    naverController = controller;
    notifyListeners();
  }


  void updateUI(dynamic addressData) {
    if (addressData == null) {
      return;
    } else {
      var addresses = addressData['addresses'];

      for (dynamic address in addresses) {
        roadAddress = address['roadAddress'];
        jibunAddress = address['jibunAddress'];
        print(roadAddress);
        print(jibunAddress);

        //print(address);
        x = address['x'];
        y = address['y'];
        print(x);
        print(y);
        final addressListElement = AddressListElement(
          roadAddress: roadAddress,
          jibunAddress: jibunAddress,
          x: x,
          y: y,
        );
        addressListElements.add(addressListElement);

        dynamic addressElements = address['addressElements'];
        print('주소 요소:');
        for (dynamic element in addressElements) {
          String longName = element['longName'];
          String shortName = element['shortName'];
          print(' - ${element['types'][0]}: $longName ($shortName)');
        }
      }
    }
  }

  Future<void> clearAddressListElements() async {
    addressListElements.clear();
    notifyListeners();
  }

  void overlayMake() {
    print('overlayMake 진입');

    double mapx = 0.0;
    double mapy = 0.0;

    double maxMapX = 0.0;
    double maxMapY = 0.0;
    int count = 0;

    for (PingpongList pPListElement in pPListElements) {
      final index = pPListElements.indexOf(pPListElement);
      final latlng = NLatLng(pPListElement.mapy, pPListElement.mapx);
      final nMarker = NMarker(id: '$index', position: latlng);

      mapx = mapx + pPListElement.mapx;
      mapy = mapy + pPListElement.mapy;

      if (mapx > maxMapX) {
        maxMapX = pPListElement.mapx;
      }
      if (mapy > maxMapY) {
        maxMapY = pPListElement.mapy;
      }

      count++;

      naverController.addOverlay(nMarker);
      nMarker.setOnTapListener((NMarker marker) async {
        print('마커가 터치되었습니다. id: ${marker}');

        final onMarkerInfoWindow = NInfoWindow.onMarker(
            id: nMarker.info.id, text: pPListElement.title);
        nMarker.openInfoWindow(onMarkerInfoWindow);

      });

      nMarker.setIconTintColor(kMainColor);
    }

    double absMapY = (maxMapY - mapy/count).abs();
    double absMapX = (maxMapX - mapx/count).abs();

    final cameraMovelatlng = NLatLng(mapy/count, mapx/count);

    if (absMapY > 2 || absMapX > 2) {
      print('absMapY > 2 || absMapX > 2');
      print('absMapY: ${absMapY}');
      print('absMapX: ${absMapX}');
      cameraMove(cameraMovelatlng, 5.0);
    } else if (absMapY > 1 || absMapX > 1) { // 탁구장
      print('absMapY > 1 || absMapX > 1');
      print('absMapY: ${absMapY}');
      print('absMapX: ${absMapX}');
      cameraMove(cameraMovelatlng, 5.5);
    } else if (absMapY > 0.5 || absMapX > 0.5) {
    print('absMapY > 0.5 || absMapX > 0.5');
    print('absMapY: ${absMapY}');
    print('absMapX: ${absMapX}');
    cameraMove(cameraMovelatlng, 5.75);
    } else if (absMapY > 0.2 || absMapX > 0.2) { // 온센
      print('absMapY > 0.2 || absMapX > 0.2');
      print('absMapY: ${absMapY}');
      print('absMapX: ${absMapX}');
      cameraMove(cameraMovelatlng, 6.0);
    } else if (absMapY > 0.05 || absMapX > 0.05) { // 메가커피
      print('absMapY > 0.05 || absMapX > 0.05');
      print('absMapY: ${absMapY}');
      print('absMapX: ${absMapX}');
      cameraMove(cameraMovelatlng, 7.5);
    } else if (absMapY > 0.01 || absMapX > 0.01) { //동작구 탁구장
      print('absMapY > 0.01 || absMapX > 0.01');
      print('absMapY: ${absMapY}');
      print('absMapX: ${absMapX}');
      cameraMove(cameraMovelatlng, 12.0);
    } else {
      print('absMapY, absMapX else');
      cameraMove(cameraMovelatlng, 14.0);
    }

    notifyListeners();
  }

  Future clearOverlays() async {
    naverController.clearOverlays();
    notifyListeners();
  }

  void cameraMove(NLatLng latlng, double zoom) {

    final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
      target: latlng,
      zoom: zoom,
    );
    cameraUpdate.setAnimation(
        animation: NCameraAnimation.fly, duration: Duration(seconds: 1));
    naverController.updateCamera(cameraUpdate);
    notifyListeners();
  }

  void updatePPListElements(PingpongList element) {
    pPListElements.add(element);
    notifyListeners();
  }

  Future clearPPListElements() async {
    pPListElements.clear();
    notifyListeners();
  }
}