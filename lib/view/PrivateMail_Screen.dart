import 'package:dnpp/constants.dart';
import 'package:dnpp/models/launchUrl.dart';
import 'package:dnpp/statusUpdate/googleAnalytics.dart';
import 'package:dnpp/view/home_screen.dart';
import 'package:dnpp/viewModel/PrivateMailScreen_ViewModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import '../models/moveToOtherScreen.dart';
import '../repository/firebase_realtime_push.dart';
import '../repository/firebase_realtime_users.dart';
import '../statusUpdate/CurrentPageProvider.dart';

class PrivateMailScreen extends StatelessWidget {
  late Future<List<Map<String, String>>> _future;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {

    _future = RepositoryRealtimePush().getAllPush();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      try {
        await RepositoryRealtimeUsers().getInitializePrivateMailBadge();
      } catch (e) {
        debugPrint('getInitializePrivateMailBadge e: $e');
      }
    });
      // 해당 유저의 privateMailBadge를 0으로 초기화 해버림

    return Consumer<PrivateMailScreenViewModel>(
        builder: (context, privateMailScreenViewModel, child) {
      return PopScope(
        onPopInvoked: (_) async {
          Future.microtask(() async {
            await privateMailScreenViewModel.clear();

            // final previousScreen = Provider.of<CurrentPageProvider>(context, listen: false).currentPage;
            // debugPrint('메일함 previousScreen: $previousScreen'); // PrivateMailScreen으로 나타나고 있음
          });

          // if () {
          //
          // }
          // await MoveToOtherScreen()
          //     .persistentNavPushNewScreen(
          //     context,
          //     HomeScreen(),
          //     false,
          //     PageTransitionAnimation.cupertino)

        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Push 메시지함'),
          ),
          body: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: 0.0, right: 0.0, top: 10.0, bottom: 10.0),
                  child: Container(
                    height: 35.0,
                    alignment: Alignment.centerLeft,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller:
                          privateMailScreenViewModel.horizontalScrollController,
                      shrinkWrap: true,
                      itemCount: privateMailScreenViewModel.menuList.length,
                      itemBuilder: (context, index) {
                        var margin = EdgeInsets.zero;

                        if (index == 0) {
                          margin = EdgeInsets.only(left: 15.0);
                        } else if (index ==
                            privateMailScreenViewModel.menuList.length - 1) {
                          margin = EdgeInsets.only(right: 15.0);
                        }

                        return GestureDetector(
                          onTap: () async {

                            debugPrint('privateMailScreenViewModel. ${privateMailScreenViewModel.clickedMenu}');

                            debugPrint('푸시 메시지함 메뉴 index: $index');

                            if (privateMailScreenViewModel.clickedMenu != index) {

                              await privateMailScreenViewModel
                                  .updateClickedMenu(index).then((value) {

                                switch (index) {
                                  case 0:
                                    _future =
                                        RepositoryRealtimePush().getAllPush();
                                  case 1:
                                    _future = RepositoryRealtimePush()
                                        .getPublicPush();
                                  case 2:
                                    _future = RepositoryRealtimePush()
                                        .getPrivatePush();
                                }
                                privateMailScreenViewModel.notifyListeners();

                              });

                            }

                          },
                          child: Container(
                            margin: margin,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                margin: EdgeInsets.only(right: 7.0),
                                padding: EdgeInsets.only(
                                    left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                                decoration: BoxDecoration(
                                  color: (index ==
                                          privateMailScreenViewModel.clickedMenu)
                                      ? kMainColor
                                      : null,
                                  border: Border.all(color: kMainColor),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  privateMailScreenViewModel.menuList[index],
                                  style: (index ==
                                          privateMailScreenViewModel.clickedMenu)
                                      ? TextStyle(color: Colors.white)
                                      : TextStyle(color: kMainColor),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ), // 메뉴
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    FutureBuilder(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            width: MediaQuery.sizeOf(context).width,
                              height: MediaQuery.sizeOf(context).height/2,
                              child: Center(
                                  child: kCustomCircularProgressIndicator));
                        } else if (snapshot.hasError) {
                          return Center(child: Text('메시지를 불러오는데 에러가 발생했습니다'));
                        } else if (!snapshot.hasData) {
                          return Center(
                              child: Text(
                            '메시지 없음',
                            style: TextStyle(color: Colors.grey),
                          ));
                        } else {
                          final pushData =
                              snapshot.data as List<Map<String, String>>;
                          //height: MediaQuery.sizeOf(context).height,

                          if (pushData == [] || pushData.isEmpty){
                            return Center(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('메시지 없음'),
                            ));
                          } else {
                            return Container(
                              //height: MediaQuery.sizeOf(context).height - 150,
                              padding: EdgeInsets.only(bottom: 15.0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: pushData.length,
                                  itemBuilder: (context, index) {

                                    return ListTile(
                                      title: Text(
                                          '${pushData[index]['title']}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      subtitle: Text(
                                        "${pushData[index]['timeline']}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () async {
                                        Future.wait([
                                          privateMailScreenViewModel
                                              .updateListTileData(
                                            pushData[index]['title']
                                            as String,
                                            pushData[index]['body'] as String,
                                            pushData[index]['timeline']
                                            as String,
                                            pushData[index]['imageUrl']
                                            as String,
                                            pushData[index]['landingUrl']
                                            as String,
                                          ),
                                          privateMailScreenViewModel
                                              .updateIsListTileVisible(),
                                        ]);

                                        if (pushData[index]['landingUrl'] == "*") { // pushData[index]['landingUrl'] == "*" 이면 전체 공지
                                          GoogleAnalytics().openPublicPush(
                                              pushData[index]['title']
                                              as String,
                                              pushData[index]['body'] as String,
                                              pushData[index]['timeline']
                                              as String,
                                          pushData[index]['imageUrl']
                                              as String,
                                          pushData[index]['landingUrl']
                                              as String,
                                          auth.currentUser!.uid.toString()
                                          );
                                        } else {
                                          GoogleAnalytics().openPrivatePush(
                                              pushData[index]['title']
                                              as String,
                                              pushData[index]['body'] as String,
                                              pushData[index]['timeline']
                                              as String,
                                          pushData[index]['imageUrl']
                                              as String,
                                          pushData[index]['landingUrl']
                                              as String,
                                        auth.currentUser!.uid.toString()
                                          );
                                        }


                                      },
                                    );

                                  }),
                            );
                          }


                        }
                      },
                    ),
                    Visibility(
                      visible: privateMailScreenViewModel.isListTileVisible,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: MediaQuery.sizeOf(context).height * 0.8,
                            color: Colors.black.withOpacity(0.5), // 투명도 조절
                          ),
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                height: MediaQuery.sizeOf(context).height * 0.7,
                                width: MediaQuery.sizeOf(context).width * 0.8,
                                padding: EdgeInsets.only(
                                    top: 15.0,
                                    bottom: 25.0,
                                    left: 15.0,
                                    right: 15.0),
                                decoration: BoxDecoration(
                                  color: kMainColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (privateMailScreenViewModel.imageUrl != '')
                                      GestureDetector(
                                        onTap: () async {
                                          if (privateMailScreenViewModel.langingUrl != '') {
                                            LaunchUrl().myLaunchUrl(privateMailScreenViewModel.langingUrl);
                                          }
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,  // 화면 너비에 맞게 설정
                                          height: MediaQuery.of(context).size.width * 3 / 4,  // 비율에 따른 높이 설정
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),  // 테두리 둥글게 설정
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10.0),
                                            child: Image.network(
                                              privateMailScreenViewModel.imageUrl,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                if (loadingProgress == null) return child;  // 이미지가 로드 완료되면 표시
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null ?
                                                    loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                return const Text('Image Loading Error');  // 이미지 로드 실패 시 표시
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 15.0),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 10.0),
                                            Text(
                                                '${privateMailScreenViewModel.title}'),
                                            Text(
                                                '${privateMailScreenViewModel.body}'),
                                            SizedBox(height: 10.0),
                                            Text(
                                                '${privateMailScreenViewModel.timeline}'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    await privateMailScreenViewModel
                                        .updateIsListTileVisible();
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
