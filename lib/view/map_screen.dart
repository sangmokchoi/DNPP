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
import 'package:flutter/widgets.dart';
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
  late BuildContext _context;

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

  void toggleLoading(BuildContext context, bool isLoading) {
    setState(() {

      if (isLoading) {
        // 로딩 바를 화면에 표시
        print('mapscreen 로딩 바를 화면에 표시');
        showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: false,
          builder: (context) {
            return Center(
              child: kCustomCircularProgressIndicator, // 로딩 바 표시
            );
          },
        );
      } else {
        print('toggleLoading 로딩 바 제거');
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

  void showAlert(BuildContext context) {

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

  Future<void> updatePPLocation(Map<String, dynamic> searchResult) async {
    print('updatePPLocation 시작');

    if (searchResult['items'].isEmpty) {
      print('검색 결과 없음');

      showAlert(_context);
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
    _context = context;
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Consumer<ProfileUpdate>(builder: (context, taskData, child) {
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: kMainColor, // 원하는 색상으로 변경
                size: 24.0, // 아이콘 크기 설정
              ),
              titleTextStyle: kAppbarTextStyle,
              backgroundColor: Colors.transparent,
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
                                    margin: EdgeInsets.only(right: 7.0),
                                    padding: EdgeInsets.only(left: 10.0, right: 5.0, top: 5.0, bottom: 5.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: kMainColor),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          Provider.of<ProfileUpdate>(context,
                                                  listen: false)
                                              .pingpongList[index]
                                              .title,
                                          style: TextStyle(color: kMainColor),
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

                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                                              shape: kRoundedRectangleBorder,
                                              title: Text("선택한 탁구장을 삭제할까요?"),
                                              content: Text(
                                                  "삭제 시 해당 탁구장으로 등록한 일정도 함께 사라집니다"),
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

                                    },
                                    icon: Icon(
                                      CupertinoIcons.clear_circled,
                                      color: Colors.grey,
                                    ),
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.zero),
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
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10.0, left: 20.0, right: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _textFormFieldController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey), // 밑줄 색상
                            ),
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

                          toggleLoading(context, true);

                          try {
                            print('try');
                            var searchResult = await search.fetchSearchData(
                                _textFormFieldController.text);
                            print('searchResult: $searchResult');
                            toggleLoading(context, false);

                            await updatePPLocation(searchResult);

                            // 나머지 작업 수행
                          } catch (error) {
                            print('try end');
                            toggleLoading(context, false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                //,
                MapWidget(nLatLng: nLatLng),

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
                            //color: Colors.black,
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
