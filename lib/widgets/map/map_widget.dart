
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../statusUpdate/mapWidgetUpdate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
// class MapWidget extends StatefulWidget {
//
//   MapWidget(this.nLatLng);
//
//   NLatLng nLatLng;
//
//   @override
//   State<MapWidget> createState() => _MapWidgetState();
// }
//
// class _MapWidgetState extends State<MapWidget> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: NaverMap(
//         options: NaverMapViewOptions(
//           initialCameraPosition: NCameraPosition(
//             target: widget.nLatLng, //NLatLng(37.5666, 126.979),
//             zoom: 10,
//             bearing: 0,
//             tilt: 0,
//           ),
//         ),
//         onMapReady: (controller) {
//           Provider.of<MapWidgetUpdate>(context, listen: false).naverController =
//               controller;
//           setState(() {
//             // Provider.of<MapWidgetUpdate>(context, listen: false).cameraMove(widget.nLatLng);
//           });
//         },
//         onMapTapped: (point, latLng) {
//           debugPrint(latLng);
//         },
//         onSymbolTapped: (symbol) {},
//         onCameraChange: (position, reason) {},
//         onCameraIdle: () {},
//         onSelectedIndoorChanged: (indoor) {},
//       ),
//     );
//   }
// }

class MapWidget extends StatelessWidget {
  NLatLng nLatLng;

  MapWidget({required this.nLatLng});

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: nLatLng,
          zoom: 10,
          bearing: 0,
          tilt: 0,
        ),
      ),
      onMapReady: (controller) {
        Provider.of<MapWidgetUpdate>(context, listen: false).updateNaverController(controller);
      },
      onMapTapped: (point, latLng) {
        debugPrint("$latLng");
      },
      onSymbolTapped: (symbol) {},
      onCameraChange: (position, reason) {},
      onCameraIdle: () {},
      onSelectedIndoorChanged: (indoor) {},
    );
  }
}

