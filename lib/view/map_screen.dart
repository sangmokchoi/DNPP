import 'dart:async';

import 'package:dnpp/viewModel/MapScreen_ViewModel.dart';
import 'package:dnpp/statusUpdate/profileUpdate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dnpp/RemoteDataSource/naver_map_search.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../models/launchUrl.dart';
import '../models/pingpongList.dart';
import '../repository/naver_map.dart';
import '../statusUpdate/googleAnalytics.dart';
import '../statusUpdate/CurrentPageProvider.dart';
import '../statusUpdate/mapWidgetUpdate.dart';
import '../widgets/map/map_widget.dart';
import '../widgets/map/map_pingpongList_element.dart';

import 'package:dnpp/constants.dart';

class MapScreen extends StatefulWidget {
  static String id = '/MapScreenID';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController _textFormFieldController = TextEditingController();
  late BuildContext _context;

  late Future<void> myFuture;

  @override
  void initState() {
    _textFormFieldController.addListener(() {});
    Provider.of<GoogleAnalyticsNotifier>(context, listen: false).startTimer('ProfileScreen');

    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();

    Future.microtask(() {
      //if (mounted) {
        Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
            .startTimer('MapScreen');
      //}
    });

  }

  @override
  void dispose() {
    _textFormFieldController.dispose();
    super.dispose();
  }

  // List<String> searchedResultList= [];
  // List<String> pickedResultList = [];
  TextStyle _guideTextStyle = TextStyle(color: Colors.grey, fontSize: 14.0);

  @override
  Widget build(BuildContext context) {
    _context = context;
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await GoogleAnalytics().trackScreen(context, 'MapScreen');
      await Provider.of<CurrentPageProvider>(context, listen: false).setCurrentPage('MapScreen');
    });

    return Consumer<MapScreenViewModel>(
        builder: (context, currentUserUpdate, child) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Consumer<ProfileUpdate>(builder: (context, taskData, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                '탁구장 추가',
                style: Theme.of(context).brightness == Brightness.light
                    ? kAppointmentTextStyle.copyWith(color: Colors.black)
                    : kAppointmentTextStyle,
                textAlign: TextAlign.center,
              ),
              iconTheme: IconThemeData(
                color: kMainColor, // 원하는 색상으로 변경
                size: 24.0, // 아이콘 크기 설정
              ),
              titleTextStyle: kAppbarTextStyle,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              // leading: IconButton(
              //   icon: Icon(Icons.arrow_back),
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
              leading: Icon(
                Icons.arrow_back,
                color: Colors.transparent,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '완료',
                      style: TextStyle(color: kMainColor),
                    ))
              ],
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
                      : EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 0.0, bottom: 0.0),
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
                                    padding: EdgeInsets.only(
                                        left: 10.0,
                                        right: 5.0,
                                        top: 5.0,
                                        bottom: 5.0),
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

                                      LaunchUrl().alertOkAndCancelFunc(
                                          context,
                                          '선택한 탁구장을 삭제할까요?',
                                          '삭제 시 해당 탁구장에 등록한 일정도 함께 사라집니다',
                                          '취소',
                                          '확인',
                                          kMainColor,
                                          kMainColor, () {
                                        Navigator.pop(context);
                                      }, () {
                                        //Navigator.pop(context);

                                        //setState(() {
                                        Provider.of<ProfileUpdate>(context,
                                                listen: false)
                                            .removeByIndexPingpongList(index);
                                        //});
                                      });

                                      // showDialog(
                                      //   context: context,
                                      //   builder: (context) {
                                      //     return AlertDialog(
                                      //       insetPadding: EdgeInsets.only(
                                      //           left: 10.0, right: 10.0),
                                      //       shape: kRoundedRectangleBorder,
                                      //       title: Text("선택한 탁구장을 삭제할까요?"),
                                      //       content: Text(
                                      //           "삭제 시 해당 탁구장으로 등록한 일정도 함께 사라집니다"),
                                      //       actions: [
                                      //         TextButton(
                                      //           style: TextButton.styleFrom(
                                      //             textStyle: Theme.of(context)
                                      //                 .textTheme
                                      //                 .labelLarge,
                                      //           ),
                                      //           child: const Text("취소"),
                                      //           onPressed: () async {
                                      //             Navigator.pop(context);
                                      //           },
                                      //         ),
                                      //         TextButton(
                                      //           style: TextButton.styleFrom(
                                      //             textStyle: Theme.of(context)
                                      //                 .textTheme
                                      //                 .labelLarge,
                                      //           ),
                                      //           child: const Text("확인"),
                                      //           onPressed: () async {
                                      //             Navigator.pop(context);
                                      //             setState(() {
                                      //               Provider.of<ProfileUpdate>(
                                      //                       context,
                                      //                       listen: false)
                                      //                   .removeByIndexPingpongList(
                                      //                       index);
                                      //             });
                                      //           },
                                      //         ),
                                      //       ],
                                      //     );
                                      //   },
                                      // );
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
                Container(
                  padding: const EdgeInsets.only(
                      bottom: 10.0, left: 20.0, right: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          autocorrect: false,
                          enableSuggestions: false,
                          controller: _textFormFieldController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey), // 밑줄 색상
                            ),
                            labelText: '탁구장 검색',
                            hintText: '주소 또는 탁구장 이름을 입력해주세요',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: clearTextField,
                            ),
                          ),
                          onFieldSubmitted: (value) async {
                            await searchMapData();
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          await searchMapData();
                        },
                      ),
                    ],
                  ),
                ),
                // 텍스트필드

                // if (Provider.of<MapWidgetUpdate>(context, listen: false)
                //     .pPListElements
                //     .isNotEmpty)
                // Stack(
                //   children: [
                //     MapWidget(nLatLng: MapScreenViewModel().nLatLng),
                //     if (Provider.of<MapWidgetUpdate>(context, listen: false)
                //         .pPListElements
                //         .isEmpty)
                //     Container(
                //       height: 300, //MediaQuery.of(context).size.height,
                //       width: 300, //MediaQuery.of(context).size.width,
                //       color: Colors.white,
                //     ),
                //   ],
                // ),
                Stack(
                  children: [
                    Center(child: Column(
                      children: [
                        Text('우리 동네의 탁구장을 검색한다면,\n"OO동 탁구장"처럼 검색해주세요', style: _guideTextStyle),
                        Text('검색 결과는 총 5개가 출력됩니다\n', style: _guideTextStyle),
                        Text('(지도 검색은 네이버 지도 API를 이용합니다)', style: _guideTextStyle),
                      ],
                    ),),
                    Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible:
                            Provider.of<MapWidgetUpdate>(context, listen: false)
                                .pPListElements
                                .isNotEmpty,
                        child: Container(
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width,
                          child: MapWidget(nLatLng: MapScreenViewModel().nLatLng),
                        ),
                    ),
                  ],
                ),

                // if (Provider.of<MapWidgetUpdate>(context, listen: false)
                //     .pPListElements
                //     .isEmpty)
                //   Center(
                //     child: Text('탁구장을 검색해주세요'),
                //   ),
                Expanded(
                  // width: MediaQuery.of(context).size.width,
                  // height: 150,
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
                          // height: 150.0,
                          // //color: Colors.black,
                          // child: Center(child: Text('검색 결과가 없습니다')),
                        ),
                ),
              ],
            ),
          );
        }),
      );
    });
  }

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

  Future<void> searchMapData() async {
    final mapWidgetUpdate =
        Provider.of<MapWidgetUpdate>(context, listen: false);
    await mapWidgetUpdate.clearPPListElements();

    setState(() {
      MapScreenViewModel().toggleLoading(context, true);
    });

    try {

      var searchResult =
          await RepositoryNaverMap().getFetchSearchData(_textFormFieldController.text);
      print('searchResult: $searchResult');

      await MapScreenViewModel().updatePPLocation(context, searchResult).then((value) {
        setState(() {
          MapScreenViewModel().toggleLoading(context, false);

          if (Provider.of<MapWidgetUpdate>(context, listen: false)
              .pPListElements
              .isEmpty){
            MapScreenViewModel().showAlert(context);
          }
        });
      });

      // 나머지 작업 수행
    } catch (error) {
      print('try end');
      setState(() {
        MapScreenViewModel().toggleLoading(context, false);
      });
    }
  }
}
