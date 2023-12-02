import 'dart:async';
import 'dart:io';

// import 'dart:html';
//import 'dart:js_interop';

import 'package:dnpp/viewModel/profileUpdate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dnpp/models/map_geocode.dart';
import 'package:dnpp/models/search.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import '../models/locationData.dart';
import '../models/pingpongList.dart';
import '../viewModel/mapWidgetUpdate.dart';
import '../widgets/map/map_addressList_element.dart';
import '../widgets/map/map_widget.dart';
import '../widgets/map/map_pingpongList_element.dart';

import 'package:uni_links/uni_links.dart';
import 'package:dnpp/constants.dart';

import 'package:html_unescape/html_unescape.dart';

class MapScreen extends StatefulWidget {
  static String id = '/MapScreenID';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController _textFormFieldController = TextEditingController();

  StreamSubscription? _sub;

  late Future<void> myFuture;

  double _x = 0.0;
  double _y = 0.0;

  NLatLng nLatLng = NLatLng(37.5666, 126.979);

  @override
  void initState() {
    super.initState();

    _textFormFieldController.addListener(() { });
    //toggleLoading(true);

    // var searchResult = await search.fetchSearchData(addressText);
    // updatePPLocation(searchResult);
    // //var addressData = await mapGeocode.getData(addressText);
    // //var searchResult = await search.getData(addressText);
    //
    // //updateUI(addressData);

    //myFuture = fetchData();

    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) async {
    //     await fetchData();
    //   },
    // );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _textFormFieldController.dispose();
    super.dispose();
  }

  void toggleLoading(bool isLoading) {
    setState(() {

      if (isLoading) {
        // 로딩 바를 화면에 표시
        print('maoscreen 로딩 바를 화면에 표시');
        showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: false,
          builder: (context) {
            return Center(
              child: CircularProgressIndicator(), // 로딩 바 표시
            );
          },
        );
      } else {
        print('로딩 바 제거');
        Navigator.pop(context);
        //Navigator.of(context).pop();
      }
    });
  }

  // Future<void> fetchData() async {
  //   toggleLoading(true);
  //
  //   try {
  //     Search search = Search();
  //     var searchResult = await search.fetchSearchData(
  //         '${Provider.of<ProfileUpdate>(context, listen: false).userProfile.address.first} 탁구장'); //('서울특별시 동작구 신대방1동 탁구장');
  //
  //     await updatePPLocation(searchResult);
  //     toggleLoading(false);
  //   } catch (error) {
  //     toggleLoading(false);
  //   }
  //   print('fetchData done');
  //
  //   setState(() {
  //     nLatLng = LocationData().addressNLatLng[
  //     Provider.of<ProfileUpdate>(context, listen: false)
  //         .userProfile
  //         .address
  //         .first]!;
  //
  //     print('nLatLng: $nLatLng');
  //
  //     Provider.of<MapWidgetUpdate>(context, listen: false).cameraMove(nLatLng, 12.0);
  //   });
  //
  // }

  String removeHtmlTags(String input) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return input.replaceAll(exp, '');
  }

  void showAlert() {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
    } else if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              "검색 결과가 없습니다",
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            content: Text("단어를 바꿔서 검색해주세요"),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "확인",
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              )
            ],
          );
        },
      );
    }
  }

  Future<void> updatePPLocation(Map<String, dynamic> searchResult) async {
    print('updatePPLocation 시작');

    if (searchResult['items'].isEmpty) {
      print('검색 결과 없음');

      showAlert();
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

      setState(() {
        Provider.of<MapWidgetUpdate>(context, listen: false).overlayMake();
      });
    }
    print('updatePPLocation 완료');

  }

  // List<String> searchedResultList= [];
  // List<String> pickedResultList = [];

  Future clearTextField() async {
    await Provider.of<MapWidgetUpdate>(context, listen: false)
        .clearAddressListElements();

    setState(() {
      //searchedResultList.clear();
      _textFormFieldController.clear();

      final mapWidgetUpdate =
          Provider.of<MapWidgetUpdate>(context, listen: false);
      mapWidgetUpdate.clearOverlays();
      mapWidgetUpdate.clearPPListElements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Consumer<ProfileUpdate>(builder: (context, taskData, child) {
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.blue, // 원하는 색상으로 변경
                size: 24.0, // 아이콘 크기 설정
              ),
              titleTextStyle: kAppbarTextStyle,
              title: Text('지도 검색'),
              backgroundColor: Colors.white,
              elevation: 0.0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: Provider.of<ProfileUpdate>(context, listen: false)
                          .pingpongList
                          .isEmpty
                      ? EdgeInsets.zero
                      : EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                  child: Provider.of<ProfileUpdate>(context, listen: false)
                          .pingpongList
                          .isEmpty
                      ? null
                      : Container(
                          height: 35.0,
                          alignment: Alignment.centerLeft,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: Provider.of<ProfileUpdate>(context,
                                    listen: false)
                                .horizontalScrollController,
                            shrinkWrap: true,
                            itemCount: Provider.of<ProfileUpdate>(context,
                                    listen: false)
                                .pingpongList
                                .length,
                            itemBuilder: (context, index) {
                              return Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 5.0),
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          Provider.of<ProfileUpdate>(context,
                                                  listen: false)
                                              .pingpongList[index]
                                              .title,
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        SizedBox(
                                          width: 24.0,
                                        )
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      print('IconButton 클릭');
                                      if (Platform.isAndroid) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("선택할 탁구장을 삭제할까요?"),
                                              content: Text(
                                                  "삭제를 원한다면 확인 버튼을 클릭해주세요"),
                                              actions: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    textStyle:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .labelLarge,
                                                  ),
                                                  child: const Text("취소"),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    textStyle:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .labelLarge,
                                                  ),
                                                  child: const Text("확인"),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    setState(() {

                                                      Provider.of<ProfileUpdate>(context, listen: false)
                                                          .removePingpongList(index);

                                                    });
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else if (Platform.isIOS) {
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (context) {
                                            return CupertinoAlertDialog(
                                              title: Text("선택할 탁구장을 삭제할까요?"),
                                              content: Text(
                                                  "삭제를 원한다면 확인 버튼을 클릭해주세요"),
                                              actions: [
                                                CupertinoDialogAction(
                                                  isDefaultAction: false,
                                                  child: Text(
                                                    "취소",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .normal),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                CupertinoDialogAction(
                                                  isDefaultAction: true,
                                                  child: Text(
                                                    "확인",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .normal),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    setState(() {

                                                      Provider.of<ProfileUpdate>(context, listen: false)
                                                          .removePingpongList(index);
                                                    });
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      CupertinoIcons.clear_circled,
                                      color: Colors.grey,
                                    ),
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.zero),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.grey),
                                    ),
                                    iconSize: 18.0, // IconButton의 크기 설정
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                ),
                // 등록한 탁구장 리스트
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _textFormFieldController,
                            decoration: InputDecoration(
                              labelText: '탁구장 검색',
                              hintText: '주소 또는 탁구장 이름을 입력해주세요',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: clearTextField,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {

                            Search search = Search();

                            toggleLoading(true);

                            try {
                              var searchResult = await search.fetchSearchData(
                                  _textFormFieldController.text);

                              await updatePPLocation(searchResult);
                              // 성공적으로 데이터를 받아온 후 로딩 바 닫기
                              toggleLoading(false);

                              // 나머지 작업 수행
                            } catch (error) {
                              toggleLoading(false);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                //,
                MapWidget(nLatLng),

                if (Provider.of<MapWidgetUpdate>(context, listen: false)
                    .pPListElements
                    .isNotEmpty)
                  Expanded(
                    child: (Provider.of<MapWidgetUpdate>(context, listen: false)
                            .pPListElements
                            .isNotEmpty)
                        ? Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: ListView.builder(
                                itemCount: Provider.of<MapWidgetUpdate>(context,
                                        listen: false)
                                    .pPListElements
                                    .length,
                                itemBuilder: (context, index) {
                                  final PingpongList element =
                                      Provider.of<MapWidgetUpdate>(context,
                                              listen: false)
                                          .pPListElements[index];

                                  return PingpongListElement(element);
                                }),
                          )
                        : Container(
                            height: 150.0,
                            color: Colors.black,
                            child: Text('검색 결과가 없습니다'),
                          ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
