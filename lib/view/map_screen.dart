import 'dart:async';
import 'dart:io';

// import 'dart:html';
//import 'dart:js_interop';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dnpp/models/map_geocode.dart';
import 'package:dnpp/models/search.dart';
import 'package:provider/provider.dart';
import '../viewModel/mapWidgetUpdate.dart';
import '../widgets/map/map_addressList_element.dart';
import '../widgets/map/map_widget.dart';
import '../widgets/map/map_pingpongList_element.dart';

import 'package:uni_links/uni_links.dart';
import 'package:dnpp/constants.dart';

bool _initialUriIsHandled = false;

class MapScreen extends StatefulWidget {
  static String id = '/MapScreenID';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController _textFormFieldController = TextEditingController();
  List<AddressListElement> addressListElements = [];

  bool isLoading = false;

  String x = '';
  String y = '';
  String roadAddress = '';
  String jibunAddress = '';
  String longName = '';

  Uri? _initialUri;
  Uri? _latestUri;
  Object? _err;

  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    // _handleIncomingLinks();
    // _handleInitialUri();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // void _handleIncomingLinks() {
  //     _sub = uriLinkStream.listen((Uri? uri) {
  //       if (!mounted) return;
  //       print('got uri: $uri');
  //       setState(() {
  //         _latestUri = uri;
  //         _err = null;
  //       });
  //     }, onError: (Object err) {
  //       if (!mounted) return;
  //       print('got err: $err');
  //       setState(() {
  //         _latestUri = null;
  //         if (err is FormatException) {
  //           _err = err;
  //         } else {
  //           _err = null;
  //         }
  //       });
  //     });
  //
  // }
  //
  // Future<void> _handleInitialUri() async {
  //
  //   if (!_initialUriIsHandled) {
  //     _initialUriIsHandled = true;
  //     try {
  //       final uri = await getInitialUri();
  //       if (uri == null) {
  //         print('no initial uri');
  //       } else {
  //         print('got initial uri: $uri');
  //       }
  //       if (!mounted) return;
  //       setState(() => _initialUri = uri);
  //     } on PlatformException {
  //       // Platform messages may fail but we ignore the exception
  //       print('falied to get initial uri');
  //     } on FormatException catch (err) {
  //       if (!mounted) return;
  //       print('malformed initial uri');
  //       setState(() => _err = err);
  //     }
  //   }
  // }

  void toggleLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;

      if (isLoading) {
        // 로딩 바를 화면에 표시
        print('로딩 바를 화면에 표시');
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
        Navigator.of(context).pop();
      }
    });
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

  Future<void> updatePPLocation(Map<String, dynamic> searchResult) async {
    print('updatePPLocation 시작');

    if (searchResult['items'].isEmpty) {
      print('검색 결과 없음');
      if (Platform.isAndroid) {
        showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("검색 결과가 없습니다",
                    style:
                    TextStyle(fontWeight: FontWeight.normal),),
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
              title: Text("검색 결과가 없습니다",
                style:
                TextStyle(fontWeight: FontWeight.normal),),
              content: Text("단어를 바꿔서 검색해주세요"),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("확인",
                    style:
                    TextStyle(fontWeight: FontWeight.normal),
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

    } else {
      print('updatePPLocation 진입');
      final mapWidgetUpdate =
          Provider.of<MapWidgetUpdate>(context, listen: false);
      var items = searchResult["items"];

      for (dynamic item in items) {
        final pPListElement = PPListElement(
          title: item['title'],
          link: item['link'],
          description: item['description'],
          telephone: item['telephone'],
          address: item['address'],
          roadAddress: item['roadAddress'],
          mapx: double.parse(item['mapx']) / 10000000,
          mapy: double.parse(item['mapy']) / 10000000,
        );
        print(item);
        mapWidgetUpdate.updatePPListElements(pPListElement);
      }

      setState(() {
        mapWidgetUpdate.overlayMake(
            Provider.of<MapWidgetUpdate>(context, listen: false).controller);
      });
    }
    print('updatePPLocation 완료');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            titleTextStyle: kAppbarTextStyle,
            title: Text('지도 검색'),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _textFormFieldController,
                          decoration: InputDecoration(
                            labelText: '탁구장 검색',
                            hintText: '주소 또는 탁구장 이름을 입력해주세요',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _textFormFieldController.clear();
                            addressListElements.clear();
                            final mapWidgetUpdate =
                                Provider.of<MapWidgetUpdate>(context,
                                    listen: false);
                            mapWidgetUpdate.clearPPListElements();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          String searchText = _textFormFieldController.text;
                          // 여기서 searchText를 사용하여 검색 동작 수행
                          MapGeocode mapGeocode = MapGeocode();
                          Search search = Search();

                          toggleLoading(true);

                          // var searchResult = await search.fetchSearchData(addressText);
                          // updatePPLocation(searchResult);
                          // //var addressData = await mapGeocode.getData(addressText);
                          // //var searchResult = await search.getData(addressText);
                          //
                          // //updateUI(addressData);

                          try {
                            var searchResult = await search
                                .fetchSearchData(_textFormFieldController.text);

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
              MapWidget(),
              // if (addressListElements.isNotEmpty)
              //   Expanded(
              //     child: (addressListElements.isNotEmpty) ? ListView.builder(
              //       itemCount: addressListElements.length,
              //       itemBuilder: (context, index) {
              //         final element = addressListElements[index];
              //         return AddressListElement(
              //           roadAddress: element.roadAddress,
              //           jibunAddress: element.jibunAddress,
              //           x: element.x,
              //           y: element.y,
              //         );
              //       },
              //     ) : Container(), // 비어 있는 경우, 높이가 0인 Container를 반환
              //   ),
              if (Provider.of<MapWidgetUpdate>(context, listen: false)
                  .pPListElements
                  .isNotEmpty)
                Expanded(
                    child: (Provider.of<MapWidgetUpdate>(context, listen: false)
                            .pPListElements
                            .isNotEmpty)
                        ? ListView.builder(
                            itemCount: Provider.of<MapWidgetUpdate>(context,
                                    listen: false)
                                .pPListElements
                                .length,
                            itemBuilder: (context, index) {
                              final element = Provider.of<MapWidgetUpdate>(
                                      context,
                                      listen: false)
                                  .pPListElements[index];
                              return PPListElement(
                                  title: element.title,
                                  link: element.link,
                                  description: element.description,
                                  telephone: element.telephone,
                                  address: element.address,
                                  roadAddress: element.roadAddress,
                                  mapx: element.mapx,
                                  mapy: element.mapy);
                            },
                          )
                        : Container(
                      height: 150.0,
                      color: Colors.black,
                      child: Text('검색 결과가 없습니다'),
                    )
                    // AlertDialog(
                    //   title: Text('검색된 결과가 없습니다'),
                    //   actions: [
                    //     TextButton(
                    //       onPressed: () {
                    //         Navigator.pop(context);
                    //       },
                    //       child: Text('확인'),
                    //     )
                    //   ],
                    // ), // 비어 있는 경우, 높이가 0인 Container를 반환
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
