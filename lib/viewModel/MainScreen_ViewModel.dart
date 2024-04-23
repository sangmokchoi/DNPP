import 'dart:typed_data';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../repository/chatBackgroundListen.dart';
import '../repository/googleAnalytics.dart';
import '../repository/launchUrl.dart';
import '../statusUpdate/loadingUpdate.dart';
import '../statusUpdate/loginStatusUpdate.dart';
import '../statusUpdate/profileUpdate.dart';

class MainScreenViewModel extends ChangeNotifier {
  bool isAdBannerVisible = true;
  bool isHowToUseVisible = false;

  Future<void> updateIsAdBannerVisible() async {
    isAdBannerVisible = !isAdBannerVisible;
    notifyListeners();
  }

  Future<void> falseIsAdBannerVisible() async {
    isAdBannerVisible = false;
    notifyListeners();
  }

  Future<void> trueIsAdBannerVisible() async {
    isAdBannerVisible = true;
    notifyListeners();
  }

  Future<void> updateIsHowToUseVisible() async {
    isHowToUseVisible = !isHowToUseVisible;
    notifyListeners();
  }

  Future<void> falseIsHowToUseVisible() async {
    isHowToUseVisible = false;
    notifyListeners();
  }

  int howToUseCurrentPage = 0;

  Future<void> updateHowToUseCurrentPage (int value) async {
    howToUseCurrentPage = value;
    notifyListeners();
  }

  int announcementCurrentPage = 0;

  Future<void> updateAnnouncementCurrentPage (int value) async {
    announcementCurrentPage = value;
    notifyListeners();
  }

  final PageController _howToUsePageController = PageController();
  final PageController _announcementController = PageController();
  //final TabController _tabController = TabController(length: 3, vsync: this);

  Widget announcementWidget(BuildContext context, bool isAdBanner, double width,
      double height, Future<void> Function() whichBanner) {

    if (isAdBanner == true) {
      // 항
      return ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5), // 투명도 조절
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: kMainColor,
                    borderRadius: BorderRadius.circular(10.0),
                    // 컨테이너 모서리를 둥글게 만듭니다.
                    // boxShadow: [
                    //   // 그림자 효과를 줍니다.
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.3),
                    //     spreadRadius: 5,
                    //     blurRadius: 7,
                    //     offset: Offset(0, 3), // 그림자의 위치를 조정합니다.
                    //   ),
                    // ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                            controller: _announcementController,
                            itemCount:
                            Provider.of<LoadingUpdate>(context, listen: false)
                                .announcementMapMain
                                .length,
                            onPageChanged: (int) async {
                              await updateAnnouncementCurrentPage(int);
                            },
                            itemBuilder: (context, index){
                            return Scrollbar(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {

                                        await GoogleAnalytics().bannerClickEvent(
                                            context,
                                            'announcement',
                                            index,
                                            Provider.of<LoadingUpdate>(
                                                context,
                                                listen: false).announcementString['$index']!,
                                            Provider.of<LoadingUpdate>(context, listen: false).urlMapAnnouncement[
                                            Provider.of<LoadingUpdate>(
                                                context,
                                                listen: false).announcementString['$index']
                                            ]!);

                                        await LaunchUrl().myLaunchUrl(
                                            "${Provider.of<LoadingUpdate>(context, listen: false).urlMapAnnouncement[
                                            Provider.of<LoadingUpdate>(
                                                context,
                                                listen: false).announcementString['$index']
                                            ]}");
                                      },
                                      child: Container(
                                        width: width,
                                        //double.infinity, // 화면 너비에 맞게 설정
                                        height: height,
                                        //MediaQuery.of(context).size.height,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          image: DecorationImage(
                                            image: MemoryImage(Provider.of<LoadingUpdate>(
                                                        context,
                                                        listen: false)
                                                    .announcementMapMain[
                                            Provider.of<LoadingUpdate>(
                                                context,
                                                listen: false).announcementString['$index']
                                            ] ??
                                                Uint8List(0)),
                                            fit: BoxFit.cover,
                                          ),
                                          // boxShadow: [
                                          //   // 그림자 효과를 줍니다.
                                          //   BoxShadow(
                                          //     color: Colors.black.withOpacity(0.3),
                                          //     spreadRadius: 5,
                                          //     blurRadius: 7,
                                          //     offset: Offset(0, 3), // 그림자의 위치를 조정합니다.
                                          //   ),
                                          // ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        Provider.of<LoadingUpdate>(context, listen: false)
                                                .textMapAnnouncement[
                                        Provider.of<LoadingUpdate>(
                                            context,
                                            listen: false).announcementString['$index']
                                        ] ??
                                            '',
                                        maxLines: null,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: (MediaQuery.of(context).size.width - 60) / 2 -
                                  30, //140,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3), // 반투명한 흰색 배경
                                borderRadius:
                                BorderRadius.circular(8.0), // 버튼의 모서리를 둥글게 만듦
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  //await falseIsAdBannerVisible();
                                  await whichBanner();
                                },
                                child: Text(
                                  '닫기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: (MediaQuery.of(context).size.width - 60) / 2 -
                                  30, //140,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3), // 반투명한 흰색 배경
                                borderRadius:
                                BorderRadius.circular(8.0), // 버튼의 모서리를 둥글게 만듦
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  // await falseIsAdBannerVisible();
                                  await whichBanner();
                                  await ChatBackgroundListen().updateAdBannerVisibleConfirmTime();
                                },
                                child: Text(
                                  '오늘 하루 보지 않음',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ), // 닫기 버튼 2개
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: () async {

                            if (announcementCurrentPage > 0) {
                              _announcementController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                              await updateAnnouncementCurrentPage(announcementCurrentPage - 1);
                            }
                            print('announcementCurrentPage: $announcementCurrentPage');

                          }, icon: Icon(Icons.arrow_left, size: 40,)),
                          Text('${announcementCurrentPage + 1} / ${Provider.of<LoadingUpdate>(context, listen: false)
                              .announcementMapMain
                              .length}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0
                            ),),
                          IconButton(onPressed: () async {

                            if (announcementCurrentPage + 1 < Provider.of<LoadingUpdate>(context, listen: false)
                                .announcementMapMain
                                .length) {
                              _announcementController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                              await updateAnnouncementCurrentPage(announcementCurrentPage + 1);
                            }
                            print('announcementCurrentPage: $announcementCurrentPage');

                          }, icon: Icon(Icons.arrow_right, size: 35)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        ]
      );

    } else {
      // 이용안내
      return ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5), // 투명도 조절
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: kMainColor,
                    borderRadius: BorderRadius.circular(10.0),
                    // 컨테이너 모서리를 둥글게 만듭니다.
                    boxShadow: [
                      // 그림자 효과를 줍니다.
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // 그림자의 위치를 조정합니다.
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await updateHowToUseCurrentPage(0);
                              await whichBanner();
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Expanded(
                        child: PageView.builder(
                            controller: _howToUsePageController,
                            itemCount:
                            Provider.of<LoadingUpdate>(context, listen: false)
                                .howToUseMapMain
                                .length,
                            onPageChanged: (int) async {
                              await updateHowToUseCurrentPage(int);
                            },
                            itemBuilder: (context, index){

                              return Scrollbar(

                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: width,
                                        //double.infinity, // 화면 너비에 맞게 설정
                                        height: height,
                                        //MediaQuery.of(context).size.height,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          image: DecorationImage(
                                            image: MemoryImage(Provider.of<LoadingUpdate>(
                                                context,
                                                listen: false)
                                                .howToUseMapMain['$index'] ??
                                                Uint8List(0)),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          Provider.of<LoadingUpdate>(context, listen: false)
                                              .textMapHowToUse['$index'] ??
                                              '',
                                          maxLines: null,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: () async {

                            if (howToUseCurrentPage > 0) {
                              _howToUsePageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                              await updateHowToUseCurrentPage(howToUseCurrentPage - 1);
                            }
                            print('currentPage: $howToUseCurrentPage');

                          }, icon: Icon(Icons.arrow_left, size: 40,)),
                          Text('${howToUseCurrentPage + 1} / ${Provider.of<LoadingUpdate>(context, listen: false)
                              .howToUseMapMain
                              .length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0
                          ),),
                          IconButton(onPressed: () async {

                            if (howToUseCurrentPage + 1 < Provider.of<LoadingUpdate>(context, listen: false)
                                .howToUseMapMain
                                .length) {
                              _howToUsePageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                              await updateHowToUseCurrentPage(howToUseCurrentPage + 1);
                            }
                            print('currentPage: $howToUseCurrentPage');

                          }, icon: Icon(Icons.arrow_right, size: 35)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        ]
      );
    }
  }
}
