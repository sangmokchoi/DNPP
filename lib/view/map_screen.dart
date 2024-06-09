import 'dart:async';

import 'package:dnpp/viewModel/MapScreen_ViewModel.dart';
import 'package:dnpp/statusUpdate/profileUpdate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../models/launchUrl.dart';
import '../models/pingpongList.dart';
import '../repository/naver_map.dart';
import '../statusUpdate/ShowToast.dart';
import '../statusUpdate/mapWidgetUpdate.dart';
import '../widgets/map/map_widget.dart';
import '../widgets/map/map_pingpongList_element.dart';

import 'package:dnpp/constants.dart';

class MapScreen extends StatefulWidget {
  static String id = '/MapScreenID';

  // List<PingpongList>? pingpongList;
  //
  // MapScreen({required this.pingpongList});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController _textFormFieldController = TextEditingController();
  late BuildContext _context;

  late Future<void> myFuture;
  //late List<PingpongList> _pingpongList;

  @override
  void initState() {
    //_pingpongList = widget.pingpongList ?? [];

    _textFormFieldController.addListener(() {});

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      debugPrint('맵 스크린 에서 실행됨');
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _context = context;
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

    return PopScope(
      canPop: false,
        onPopInvoked: (_) {
        FocusScope.of(context).unfocus();
        debugPrint("PopScope 에서 $_");
        if ( _ == false){
          // false 면 안드로이드에서 back버튼 누른 상태
          ShowToast().showToast("우측 상단의 '완료' 버튼을 눌러주세요");
        }

        },
      child: Consumer<MapScreenViewModel>(
          builder: (context, currentUserUpdate, child) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Consumer<ProfileUpdate>(
              builder: (context, profileUpdate, child) {
            return Scaffold(
              key: const ValueKey("MapScreen"),
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
                        Future.microtask(() async {
                          if (mounted) {
                            debugPrint('마운트 됨');
                          }
                        }).then((value) {
                          Navigator.pop(context, profileUpdate.userProfile.pingpongCourt);
                        });
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
                    padding:
                    (profileUpdate.userProfile.pingpongCourt?.isEmpty ?? true)
                        ? EdgeInsets.zero
                        :
                    EdgeInsets.only(
                            left: 0.0, right: 0.0, top: 15.0, bottom: 0.0),
                    child:
                    (profileUpdate.userProfile.pingpongCourt?.isEmpty ?? true)
                        ? null
                        :
                    Container(
                            height: 35.0,
                            alignment: Alignment.centerLeft,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              controller: profileUpdate.horizontalScrollController,
                              shrinkWrap: true,
                              itemCount: profileUpdate.userProfile.pingpongCourt?.length ?? 0,
                              itemBuilder: (context, index) {

                                debugPrint(' profileUpdate.userProfile.pingpongCourt?.length: ${ profileUpdate.userProfile.pingpongCourt?.length}');
                                var margin = EdgeInsets.zero;

                                if (index == 0) {
                                  margin = EdgeInsets.only(left: 15.0);
                                } else if (index == profileUpdate.userProfile.pingpongCourt!.length - 1) {
                                  margin = EdgeInsets.only(right: 15.0);
                                }

                                return Container(
                                  margin: margin,
                                  child: Stack(
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
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              profileUpdate.userProfile.pingpongCourt?[index].title ?? '',
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
                                          debugPrint('IconButton 클릭');

                                          LaunchUrl().alertOkAndCancelFunc(
                                              context,
                                              '선택한 탁구장을 삭제할까요?',
                                              '삭제를 원한다면\n확인 버튼을 클릭해주세요',
                                              '취소',
                                              '확인',
                                              kMainColor,
                                              kMainColor, () {
                                            Navigator.pop(context);
                                          }, () {
                                            //Navigator.pop(context);
                                            setState(() {
                                              profileUpdate.userProfile.pingpongCourt?.removeAt(index);
                                            });

                                            //setState(() {
                                            // Provider.of<ProfileUpdate>(context,
                                            //         listen: false)
                                            //     .removeByIndexPingpongList(index);
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
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  // 등록한 탁구장 리스트
                  Container(
                    padding: const EdgeInsets.only(
                        bottom: 15.0, left: 20.0, right: 10.0),
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
                      Center(
                        child: Column(
                          children: [
                            Text('우리 동네의 탁구장을 검색한다면,\n"OO동 탁구장"처럼 검색해주세요',
                                style: _guideTextStyle),
                            Text('검색 결과는 총 5개가 출력됩니다\n', style: _guideTextStyle),
                            Text('(지도 검색은 네이버 지도 API를 이용합니다)',
                                style: _guideTextStyle),
                          ],
                        ),
                      ),
                      Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible:
                            Provider.of<MapWidgetUpdate>(context, listen: false)
                                .pPListElements
                                .isNotEmpty,
                        child: Container(
                          height: MediaQuery.sizeOf(context).height / 3,
                          width: MediaQuery.sizeOf(context).width,
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
      }),
    );
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
      var searchResult = await RepositoryNaverMap()
          .getFetchSearchData(_textFormFieldController.text);
      debugPrint('searchResult: $searchResult');

      await MapScreenViewModel()
          .updatePPLocation(context, searchResult)
          .then((value) {
        setState(() {
          MapScreenViewModel().toggleLoading(context, false);

          if (Provider.of<MapWidgetUpdate>(context, listen: false)
              .pPListElements
              .isEmpty) {
            MapScreenViewModel().showAlert(context);
          }
        });
      });

      // 나머지 작업 수행
    } catch (error) {
      debugPrint('try end');
      setState(() {
        MapScreenViewModel().toggleLoading(context, false);
      });
    }
  }
}
