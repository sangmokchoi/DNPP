import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../widgets/map/map_pingpongList_element.dart';

class MapWidgetUpdate with ChangeNotifier {
  final List<PPListElement> pPListElements = [];
  late NaverMapController controller;

  void overlayMake(NaverMapController controller) {
    print('overlayMake 진입');
    for (PPListElement pPListElement in pPListElements) {
      final index = pPListElements.indexOf(pPListElement);
      final latlng = NLatLng(pPListElement.mapy, pPListElement.mapx);
      final nMarker = NMarker(id: '$index', position: latlng);

      controller.addOverlay(nMarker);
      nMarker.setOnTapListener((NMarker marker) async {
        print('마커가 터치되었습니다. id: ${marker}');
        print(latlng);

        final onMarkerInfoWindow = NInfoWindow.onMarker(
            id: nMarker.info.id, text: pPListElement.title);
        nMarker.openInfoWindow(onMarkerInfoWindow);

        final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
          target: latlng,
          zoom: 10,
        );
        cameraUpdate.setAnimation(
            animation: NCameraAnimation.fly, duration: Duration(seconds: 1));
        controller.updateCamera(cameraUpdate);
      });
      nMarker.setIconTintColor(Colors.cyan);
    }

    notifyListeners();
  }

  void updatePPListElements(PPListElement element) {
    pPListElements.add(element);
    notifyListeners();
  }

  void clearPPListElements() {
    pPListElements.clear();
    notifyListeners();
  }
}