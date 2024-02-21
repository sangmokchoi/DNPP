import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';
import '../../models/pingpongList.dart';
import '../../statusUpdate/mapWidgetUpdate.dart';
import '../../statusUpdate/profileUpdate.dart';

class PingpongListElement extends StatelessWidget {
  PingpongListElement(this._element);

  PingpongList _element;

  // void doubleToString() {
  //   String mapxString = _element.mapx.toStringAsFixed(7); // 7자리로 고정된 소수점 형식
  //   String mapyString = _element.mapy.toStringAsFixed(7);
  // }
  Future<void> moveToNaverMap() async {
    final encodedTitle = Uri.encodeComponent(_element.title);
    final url =
        'nmap://search?query=$encodedTitle&appname=com.simonwork.dnpp.dnpp';

    final Uri _url = Uri.parse(url);

    if (await launchUrl(_url)) {
      print('Could launch $url');
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 5.0,
      contentPadding:
          EdgeInsets.only(top: 0.0, bottom: 0.0, left: 20.0, right: 20.0),
      onTap: () async {
        final latlng = NLatLng(_element.mapy, _element.mapx);
        Provider.of<MapWidgetUpdate>(context, listen: false)
            .cameraMove(latlng, 15.0);
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: Text(
                  _element.title,
                  style: kMapPingponglistElementTitleTextStyle,
                  maxLines: 1, // 최대 1줄로 설정
                  overflow: TextOverflow.ellipsis, // 넘치는 경우 생략 부호로 처리
                ),
              ),
              Flexible(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size(70, 20),
                    backgroundColor:
                        Provider.of<ProfileUpdate>(context, listen: false)
                                .pingpongList
                                .contains(_element)
                            ? Colors.blueGrey
                            : kMainColor,
                    textStyle: TextStyle(fontSize: 15),
                  ),
                  onPressed: () {
                    print(
                        'Provider.of<ProfileUpdate>(context, listen: false).pingpongList: '
                        '${Provider.of<ProfileUpdate>(context, listen: false).pingpongList}');

                    for (PingpongList item
                        in Provider.of<ProfileUpdate>(context, listen: false)
                            .pingpongList) {
                      print("item: $item");
                      print(item.title);
                      print(item.roadAddress);
                      print(item.address);
                    }

                    if (Provider.of<ProfileUpdate>(context, listen: false)
                        .pingpongList
                        .contains(_element)) {
                      print('contains true');
                      print(Provider.of<ProfileUpdate>(context, listen: false)
                          .pingpongList
                          .contains(_element));
                    } else {
                      print('contains false');
                      print(Provider.of<ProfileUpdate>(context, listen: false)
                          .pingpongList
                          .contains(_element));
                    }

                    print('_element: ${_element.title}');
                    print('_element: ${_element.roadAddress}');
                    print('_element: ${_element.address}');
                    if (!Provider.of<ProfileUpdate>(context, listen: false)
                        .pingpongList
                        .contains(_element)) {
                      if (Provider.of<ProfileUpdate>(context, listen: false)
                              .pingpongList
                              .length <
                          5) {
                        print('탁구장 추가됨');
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
                    backgroundColor: Colors.transparent,
                    textStyle: TextStyle(fontSize: 15),
                  ),
                  onPressed: () async {
                    print('더보기 완료');

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          //alignment: Alignment.bottomCenter,
                          insetPadding:
                              EdgeInsets.only(left: 10.0, right: 10.0),
                          shape: kRoundedRectangleBorder,
                          title: Text("알림"),
                          content: Text(
                              "네이버 지도에서 더 많은 정보를 확인하시겠습니까?\n확인 버튼을 누르면 네이버 지도로 이동합니다"),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                              child: const Text("취소"),
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                              child: const Text("확인"),
                              onPressed: () async {
                                Navigator.pop(context);
                                moveToNaverMap();
                              },
                            ),
                          ],
                        );
                      },
                    );
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
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 0.0),
            child: Divider(
              thickness: 2.0,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
