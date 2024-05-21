import 'package:dnpp/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../statusUpdate/profileUpdate.dart';
import '../view/chatList_Screen.dart';
import '../view/chat_screen.dart';
import 'moveToOtherScreen.dart';

class LaunchUrl {
  Future<void> myLaunchUrl(String _url) async {
    debugPrint('myLaunchUrl 진입');
    final Uri _newUrl = Uri.parse(_url);
    if (!await launchUrl(_newUrl)) {
      throw Exception('Could not launch $_newUrl');
    }
  }

  void alertFunc(BuildContext context, String titleText, String contentText,
      String okText, VoidCallback? onOkPressed) {
    showDialog(
        context: context,
        //barrierDismissible: false,
        builder: (builder) {
          return AlertDialog(
            insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
            shape: kRoundedRectangleBorder,
            title: Text(
              titleText,
              textAlign: TextAlign.center,
            ),
            content: Text(
              contentText,
              style: TextStyle(
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Center(
                    child: Text(
                  okText,
                )),
                onPressed: () {
                  if (onOkPressed != null) {
                    onOkPressed(); // 콜백 함수 실행
                  }
                },
              ),
            ],
          );
        });
  }

  void alertFuncFalseBarrierDismissible(BuildContext context, String titleText,
      String contentText, String okText, VoidCallback? onOkPressed) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (builder) {
          return AlertDialog(
            insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
            shape: kRoundedRectangleBorder,
            title: Text(
              titleText,
              textAlign: TextAlign.center,
            ),
            content: Text(
              contentText,
              style: TextStyle(
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Center(
                    child: Text(
                  okText,
                )),
                onPressed: () {
                  if (onOkPressed != null) {
                    onOkPressed(); // 콜백 함수 실행
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> alertOkAndCancelFunc(
    BuildContext context,
    String titleText,
    String contentText,
    String cancelText,
    String okText,
    Color cancelColor,
    Color okColor,
    VoidCallback? onCancelPressed,
    VoidCallback? onOkPressed,
  ) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (builder) {
          return AlertDialog(
            insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
            shape: kRoundedRectangleBorder,
            title: Text(
              titleText,
              style: kAppointmentDateTextStyle,
              textAlign: TextAlign.center,
            ),
            content: Text(
              contentText,
              style: TextStyle(
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: Center(
                        child: Text(
                      cancelText,
                      style: kAppointmentTextButtonStyle.copyWith(
                          color: cancelColor),
                    )),
                    onPressed: () {
                      if (onCancelPressed != null) {
                        onCancelPressed();
                      }
                      //Navigator.pop(context);

                      // 다이얼로그 닫기는 여기서 호출
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: Center(
                        child: Text(okText,
                            style: kAppointmentTextButtonStyle.copyWith(
                                color: okColor))),
                    onPressed: () {
                      debugPrint('onOkPressed: ${onOkPressed}');
                      if (onOkPressed != null) {
                        onOkPressed(); // 콜백 함수 실행
                        Navigator.pop(context); // 다이얼로그 닫기는 여기서 호출
                      } else {
                        Navigator.pop(context); // 다이얼로그 닫기는 여기서 호출
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future<void> alertOkAndCancelFuncNoPop(
    BuildContext context,
    String titleText,
    String contentText,
    String cancelText,
    String okText,
    Color cancelColor,
    Color okColor,
    VoidCallback? onCancelPressed,
    VoidCallback? onOkPressed,
  ) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (builder) {
          return AlertDialog(
            insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
            shape: kRoundedRectangleBorder,
            title: Text(
              titleText,
              style: kAppointmentDateTextStyle,
              textAlign: TextAlign.center,
            ),
            content: Text(
              contentText,
              style: TextStyle(
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: Center(
                        child: Text(
                      cancelText,
                      style: kAppointmentTextButtonStyle.copyWith(
                          color: cancelColor),
                    )),
                    onPressed: () {
                      if (onCancelPressed != null) {
                        onCancelPressed();
                      }
                      //Navigator.pop(context);

                      // 다이얼로그 닫기는 여기서 호출
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: Center(
                        child: Text(okText,
                            style: kAppointmentTextButtonStyle.copyWith(
                                color: okColor))),
                    onPressed: () {
                      if (onOkPressed != null) {
                        onOkPressed(); // 콜백 함수 실행
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }

  void openBottomSheetMoveToChat(BuildContext context, var user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        debugPrint('openBottomSheetMoveToChat user: ${user}');
        debugPrint(
            'user[pingpongCourt].length: ${user['pingpongCourt'].length}');
        return Container(
          height: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                topLeft: Radius.circular(10.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (user['selfIntroduction'] != '' &&
                    user['selfIntroduction'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(children: [
                        TextSpan(
                          text: '자기소개\n',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${user['selfIntroduction']}',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ])),
                    ],
                  ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '활동 탁구장:',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: 35,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 5.0, bottom: 0.0),
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (user['pingpongCourt'].length != 0)
                              ? user['pingpongCourt'].length
                              : 1,
                          itemBuilder: (itemBuilder, index) {
                            var padding = EdgeInsets.zero;

                            if (index == 0) {
                              padding = EdgeInsets.only(left: 0.0);
                            } else if (index ==
                                Provider.of<ProfileUpdate>(context,
                                            listen: false)
                                        .userProfile
                                        .pingpongCourt!
                                        .length -
                                    1) {
                              padding = EdgeInsets.only(right: 0.0);
                            }

                            if (user['pingpongCourt'].length != 0) {
                              // 활동 탁구장이 있는 경우,
                              return Padding(
                                padding: padding,
                                child: Container(
                                    margin: EdgeInsets.only(right: 7.0),
                                    padding: EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                        top: 5.0,
                                        bottom: 5.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: kMainColor),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Text(
                                      '${user['pingpongCourt'][index]['title']}',
                                      style: TextStyle(color: kMainColor),
                                    )),
                              );
                            } else {
                              //활동 탁구장이 없는 경우,
                              return Center(
                                child: Text(
                                  '활동 탁구장이 아직 없습니다',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }
                          }),
                    ),
                  ],
                ), // 활동 탁구장 리스트
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Text(
                    '${user['nickName']}님에게\n함께 탁구를 쳐보자는 메시지를 보낼까요?',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        //style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey),),
                        style: ElevatedButton.styleFrom(
                          elevation: 3, // 그림자 깊이 조정
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          '취소',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        //style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey),),
                        style: ElevatedButton.styleFrom(
                          elevation: 3, // 그림자 깊이 조정
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          //Navigator.push(context, createRouteChatView(user));

                          await MoveToOtherScreen()
                              .initializeGASetting(context, 'ChatScreen')
                              .then((value) async {

                            await MoveToOtherScreen()
                                .persistentNavPushNewScreen(
                                    context,
                                    ChatScreen(receivedData: user),
                                    false,
                                    PageTransitionAnimation.cupertino).then((value) async {
                              await MoveToOtherScreen()
                                  .initializeGASetting(context, 'MatchingScreen');

                            });
                          });
                        },
                        child: Text(
                          '확인',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: kMainColor),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
