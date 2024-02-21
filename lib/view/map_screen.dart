import 'dart:async';

import 'package:dnpp/viewModel/MapScreen_ViewModel.dart';
import 'package:dnpp/statusUpdate/profileUpdate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dnpp/models/search.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../models/pingpongList.dart';
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
    super.initState();
  }

  @override
  void dispose() {
    _textFormFieldController.dispose();
    super.dispose();
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
    return Consumer<MapScreenViewModel>(
        builder: (context, currentUserUpdate, child) {
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
                        : EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
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
                                        borderRadius:
                                            BorderRadius.circular(20.0),
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
                                              insetPadding: EdgeInsets.only(
                                                  left: 10.0, right: 10.0),
                                              shape: kRoundedRectangleBorder,
                                              title: Text("선택한 탁구장을 삭제할까요?"),
                                              content: Text(
                                                  "삭제 시 해당 탁구장으로 등록한 일정도 함께 사라집니다"),
                                              actions: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    textStyle: Theme.of(context)
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
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge,
                                                  ),
                                                  child: const Text("확인"),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      Provider.of<ProfileUpdate>(
                                                              context,
                                                              listen: false)
                                                          .removePingpongList(
                                                              index);
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
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            Search search = Search();
                            setState(() {
                              MapScreenViewModel().toggleLoading(context, true);
                            });

                            try {
                              print('try');
                              var searchResult = await search.fetchSearchData(
                                  _textFormFieldController.text);
                              print('searchResult: $searchResult');
                              setState(() {
                                MapScreenViewModel()
                                    .toggleLoading(context, false);
                              });

                              await MapScreenViewModel()
                                  .updatePPLocation(context, searchResult);

                              // 나머지 작업 수행
                            } catch (error) {
                              print('try end');
                              setState(() {
                                MapScreenViewModel()
                                    .toggleLoading(context, false);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  //,
                  MapWidget(nLatLng: MapScreenViewModel().nLatLng),

                  if (Provider.of<MapWidgetUpdate>(context, listen: false)
                      .pPListElements
                      .isNotEmpty)
                    Expanded(
                      child:
                          (Provider.of<MapWidgetUpdate>(context, listen: false)
                                  .pPListElements
                                  .isNotEmpty)
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: ListView.builder(
                                      itemCount: Provider.of<MapWidgetUpdate>(
                                              context,
                                              listen: false)
                                          .pPListElements
                                          .length,
                                      itemBuilder: (context, index) {
                                        final PingpongList element =
                                            Provider.of<MapWidgetUpdate>(
                                                    context,
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
    });
  }
}
