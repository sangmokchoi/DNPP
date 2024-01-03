//import 'dart:js_interop';

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';
import '../../models/pingpongList.dart';
import '../../viewModel/mapWidgetUpdate.dart';
import '../../viewModel/profileUpdate.dart';

class PingpongListElement extends StatelessWidget {
  PingpongListElement(this._element);

  PingpongList _element;

  void doubleToString() {
    String mapxString = _element.mapx.toStringAsFixed(7); // 7자리로 고정된 소수점 형식
    String mapyString = _element.mapy.toStringAsFixed(7);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        final latlng = NLatLng(_element.mapy, _element.mapx);
        Provider.of<MapWidgetUpdate>(context, listen: false)
            .cameraMove(latlng, 15.0);
      },
      title: Padding(
        padding:
            EdgeInsets.only(top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: Text(
                    _element.title,
                    style: kMapPingponglistElementTitleTextStyle,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Provider.of<ProfileUpdate>(context, listen: false)
                                  .pingpongList
                                  .contains(_element)
                              ? Colors.blueGrey
                              : kMainColor,
                      textStyle: TextStyle(fontSize: 15),
                    ),
                    onPressed: () {
                      if (!Provider.of<ProfileUpdate>(context, listen: false)
                          .pingpongList
                          .contains(_element)) {
                        if (Provider.of<ProfileUpdate>(context, listen: false)
                                .pingpongList
                                .length <
                            5) {
                          Provider.of<ProfileUpdate>(context, listen: false)
                              .addPingpongList(_element);
                        } else {
                          print('활동 탁구장 등록은 총 5개까지만 가능합니다');

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                insetPadding:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                                shape: kRoundedRectangleBorder,
                                title: Text("알림"),
                                content: Text("활동 탁구장 등록은 총 5개까지만 가능합니다"),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    child: const Text("확인"),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        print('이미 선택된 탁구장입니다.');

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              insetPadding:
                                  EdgeInsets.only(left: 10.0, right: 10.0),
                              shape: kRoundedRectangleBorder,
                              title: Text("이미 선택된 탁구장입니다"),
                              content: Text("다른 탁구장을 선택해주세요"),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    textStyle:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                  child: const Text("확인"),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Provider.of<ProfileUpdate>(context, listen: false)
                            .pingpongList
                            .contains(_element)
                        ? Text(
                            '해제',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            '팔로우',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(_element.address,
                            style: kMapPingponglistElementAddressTextStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(_element.roadAddress,
                            style: kMapPingponglistElementAddressTextStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: IconButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      textStyle: TextStyle(fontSize: 15),
                    ),
                    onPressed: () async {
                      print('더보기 완료');
                      final encodedTitle = Uri.encodeComponent(_element.title);
                      final url =
                          'nmap://search?query=$encodedTitle&appname=com.simonwork.dnpp.dnpp';

                      final Uri _url = Uri.parse(url);

                      if (await launchUrl(_url)) {
                        print('Could launch $url');
                      } else {
                        print('Could not launch $url');
                      }
                    },
                    icon: Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
            if (_element.description.isNotEmpty)
              Text(
                _element.description,
                style: kMapPingponglistElementEtcTextStyle,
              ),
            if (_element.telephone.isNotEmpty)
              Text(
                _element.telephone,
                style: kMapPingponglistElementEtcTextStyle,
              ),
            if (_element.link.isNotEmpty)
              Text(
                _element.link,
                style: kMapPingponglistElementEtcTextStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            Divider(thickness: 2.0),
          ],
        ),
      ),
    );
  }
}
