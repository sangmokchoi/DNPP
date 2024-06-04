
import 'dart:ffi';

import 'package:dnpp/main.dart';
import 'package:dnpp/models/userProfile.dart';
import 'package:dnpp/LocalDataSource/firebase_fireStore/DS_Local_userData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../statusUpdate/CurrentPageProvider.dart';
import '../statusUpdate/googleAnalytics.dart';
import '../view/chatList_Screen.dart';
import '../view/chat_screen.dart';

class MoveToOtherScreen {

  static Route createRouteChatView(var receivedData) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(receivedData: receivedData,),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route createRouteChatListView() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ChatListView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future persistentNavPushNewScreen(BuildContext context, Widget screen, bool withNavBar, PageTransitionAnimation animation) {
    return PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: screen,
      withNavBar: withNavBar,    // OPTIONAL VALUE. True by default.
      pageTransitionAnimation: animation,
    );
  }

  void bottomProfileUp(BuildContext context, String uid) {
    // data = types.User

    debugPrint('bottomProfileUp data: $uid');
    //getOneUserData

    showModalBottomSheet<void>(
      enableDrag: false,
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder(
            stream: LocalDSUserData().oneUserData(uid),//FirebaseFirestore.instance.collection('users').doc(data['id']).snapshots(),
          builder: (context, snapshot) {
              debugPrint('bottomProfileUp snapshot.data?.docs: ${snapshot.data?.docs}');
              debugPrint('bottomProfileUp snapshot.hasData: ${snapshot.hasData}');
              var docs = snapshot.data?.docs;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: kCustomCircularProgressIndicator); // 데이터 로딩 중에는 로딩 스피너 표시
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // 에러가 있는 경우 에러 메시지 표시
            } else if (docs!.isEmpty) {
              return Center(child: Text('User not found')); // 데이터가 없는 경우 메시지 표시
            } else {

              final snapshotData = docs?.first.data();
              debugPrint('snapshotData: ${snapshotData}');

              return Stack(
                children: [
                  Container(
                    height: 275,
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 35.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(50.0)),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        snapshotData?['photoUrl']) as ImageProvider<Object>,// ['imageUrl']) as ImageProvider<Object>,
                                  ), //가져온 이미지를 화면에 띄워주는 코드
                                ),
                              ),
                            ),
                            SizedBox(width: 10.0,),
                            Flexible(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      snapshotData?['nickName'],
                                      style: TextStyle(
                                          fontSize: 20.0, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      snapshotData?['selfIntroduction'],
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 12.0, fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),
                                    ),

                                    // SizedBox(
                                    //   height: 5.0,
                                    // ),
                                    // Column(
                                    //   mainAxisAlignment: MainAxisAlignment.start,
                                    //   crossAxisAlignment: CrossAxisAlignment.start,
                                    //   children: [
                                    //     Text(
                                    //       '연령대: ${snapshotData?['ageRange']}',
                                    //       style: TextStyle(
                                    //           fontSize: 14.0, fontWeight: FontWeight.normal),
                                    //     ),
                                    //     //SizedBox(width: 5.0,),
                                    //     Text(
                                    //       '성별: ${snapshotData?['gender']}',
                                    //       style: TextStyle(
                                    //           fontSize: 14.0, fontWeight: FontWeight.normal),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('특징', style: TextStyle(fontSize: 14.0),),
                                SizedBox(
                                  height: 3.0,
                                ),
                                SizedBox(
                                  height: 35.0,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 4,
                                    itemBuilder: (context, index) {
                                      final features = [
                                        '플레이스타일: ${snapshotData?['playStyle']}',
                                        '경력: ${snapshotData?['playedYears']}',
                                        '라켓: ${snapshotData?['racket']}',
                                        '러버: ${snapshotData?['rubber']}',
                                      ];

                                      return Container(
                                        height: 30,
                                        margin: EdgeInsets.only(right: 7.0),
                                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: kMainColor),
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: Text(
                                          features[index],
                                          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.primary),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '활동 지역', style: TextStyle(fontSize: 14.0),
                                ),
                                SizedBox(
                                  height: 3.0,
                                ),
                                SizedBox(
                                  height: 35,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: snapshotData?['address'].length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        height: 30,
                                        margin: EdgeInsets.only(right: 7.0),
                                        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                                        decoration: BoxDecoration(
                                          border:
                                          Border.all(color: Theme.of(context).colorScheme.primary),
                                          borderRadius:
                                          BorderRadius.circular(20.0),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              snapshotData?['address'][index],
                                              style:
                                              TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.primary),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 5.0,
                      right: 1.0,
                      child: IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close, color: Colors.grey,),),),
                ],
              );
            }
          }
        );
      },
    );
  }

  Future<void> initializeGASetting(BuildContext defaultContext, String screenName) async {

    try {

      final previousScreen = Provider.of<CurrentPageProvider>(defaultContext, listen: false).currentPage;
      debugPrint('previousScreen: $previousScreen');
      await Provider.of<GoogleAnalyticsNotifier>(defaultContext, listen: false)
          .startTimer(previousScreen);

      await GoogleAnalytics().trackScreen(defaultContext, screenName);
      await Provider.of<CurrentPageProvider>(defaultContext, listen: false)
          .setCurrentPage(screenName);

    } catch (e) {
      debugPrint('initializeGASetting e: $e');
      final previousScreen = Provider.of<CurrentPageProvider>(navigatorKey.currentContext!, listen: false).currentPage;
      debugPrint('previousScreen: $previousScreen');
      await Provider.of<GoogleAnalyticsNotifier>(navigatorKey.currentContext!, listen: false)
          .startTimer(previousScreen);

      await GoogleAnalytics().trackScreen(navigatorKey.currentContext!, screenName);
      await Provider.of<CurrentPageProvider>(navigatorKey.currentContext!, listen: false)
          .setCurrentPage(screenName);
    }



  }

}