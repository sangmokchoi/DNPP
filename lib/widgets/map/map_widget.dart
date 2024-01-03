import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../viewModel/mapWidgetUpdate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapWidget extends StatefulWidget {
  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  void updateOverlays() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NaverMap(
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(37.5666, 126.979),
            zoom: 5,
            bearing: 0,
            tilt: 0,
          ),
        ),
        onMapReady: (controller) {
          Provider.of<MapWidgetUpdate>(context, listen: false).controller =
              controller;
          setState(() {});
        },
        onMapTapped: (point, latLng) {
          print(latLng);
        },
        onSymbolTapped: (symbol) {},
        onCameraChange: (position, reason) {},
        onCameraIdle: () {},
        onSelectedIndoorChanged: (indoor) {},
      ),
    );
  }
}
