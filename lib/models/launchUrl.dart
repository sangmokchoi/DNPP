import 'dart:ui';

import 'package:dnpp/constants.dart';
import 'package:dnpp/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../repository/firebase_realtime_blockedList.dart';
import '../statusUpdate/profileUpdate.dart';
import '../statusUpdate/reportUpdate.dart';
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

  final List<String> buttonLabels = [
    '스팸, 광고',
    '부적절한 프로필',
    '폭언, 비속어, 혐오 발언',
    '불쾌감을 주는 발언',
    '기타',
  ];

  Future<void> openBottomSheetToReport(
      BuildContext context, double containerHeight, String messageText, Future<bool?> Function() reportFunc) async {

    showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (context) {

          return Consumer<ReportUpdate>(
              builder: (context, reportUpdate, child) {
            return Container(
              height: containerHeight,
              width: double.infinity,
              padding: EdgeInsets.only(left: 25.0, right: 25.0, bottom: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  topLeft: Radius.circular(10.0),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 5.0,
                  ),
                  SizedBox(
                    width: 50.0,
                    child: Container(
                      height: 3.0,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '신고하기',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await reportUpdate.clearReportReasonList();
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '신고사유를 선택해주세요 (중복 가능)',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        Text(
                          '누적 신고 횟수가 5회 이상인 유저는 채팅 기능이 이용 불가합니다.',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('신고할 채팅: $messageText', style: TextStyle(
                                decoration: TextDecoration.underline,
                              ), maxLines: 1, overflow: TextOverflow.ellipsis,)
                            ],
                          ),
                        ),
                        Center(
                            child: Wrap(
                          spacing: 7.0, // 각 버튼 사이의 가로 간격
                          runSpacing: 4.0, // 각 버튼 사이의 세로 간격
                          children: buttonLabels.map((label) {
                            bool isSelected =
                                reportUpdate.reportReasonList.contains(label);
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    isSelected ? Colors.white : kMainColor,
                                backgroundColor: isSelected
                                    ? kMainColor
                                    : (Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : Colors.transparent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? kMainColor
                                      : (Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.blue
                                          : Colors.grey),
                                ),
                              ),
                              onPressed: () {
                                if (isSelected) {
                                  reportUpdate.removeReportReasonList(label);
                                } else {
                                  reportUpdate.addReportReasonList(label);
                                }
                              },
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList(),
                        )),
                        Container(
                          height: containerHeight * 0.15,
                          margin: EdgeInsets.only(top: 10.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 0.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            border: Border.all(color: Colors.grey, width: 0.3),
                          ),
                          child: TextField(
                            controller: reportUpdate.reportTextEditingController,
                            //autofocus: true,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                                labelText: '추가 사항'),
                            maxLines: 1,
                            style: kAppointmentDateTextStyle,
                            onChanged: (text){
                              if (!reportUpdate.reportReasonList.contains('기타')) {
                                reportUpdate.addReportReasonList('기타');
                              }
                              if (text == '') {
                                reportUpdate.removeReportReasonList('기타');
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: kCancelButtonStyle,
                                  child: Text(
                                    '취소',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                  onPressed: () async {

                                    if (reportUpdate.reportReasonList.isEmpty) {
                                      alertFunc(context, '알림', '신고 사유를 선택해주세요', '확인', () {
                                        Navigator.pop(context);
                                      });
                                    } else {

                                      await alertOkAndCancelFuncNoPop(
                                          context,
                                          '알림',
                                          '이 유저를 정말 신고하시겠습니까?\n신고 완료 후 이 유저는 자동으로 차단됩니다',
                                          '취소',
                                          '확인',
                                          Colors.red,
                                          kMainColor,
                                              () {
                                            Navigator.pop(context);
                                          },
                                              () async {
                                            Navigator.pop(context);


                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) {
                                                return Center(
                                                  child: CircularProgressIndicator(), // 로딩 바 표시
                                                );
                                              },
                                            );

                                            await reportFunc().then((value) {

                                              debugPrint(
                                                'reportFunc().then((value): $value'
                                              );

                                              Navigator.pop(context);

                                              if (value == false) {
                                                alertFunc(
                                                    context,
                                                    '알림',
                                                    '이미 신고되었습니다\n채팅방 목록으로 돌아갑니다',
                                                    '확인', () async {

                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);

                                                });
                                              }

                                              if (value == null || value == true) {
                                                alertFunc(
                                                    context,
                                                    '알림',
                                                    '신고가 완료되었습니다.\n검토까지는 최대 24시간이 소요됩니다.\n\n채팅방 목록으로 돌아갑니다',
                                                    '확인', () async {

                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);

                                                });
                                              }

                                            });

                                          });
                                    }

                                  },
                                  style: kConfirmButtonStyle.copyWith(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.red),
                                  ),
                                  child: Text(
                                    '신고',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  void openBottomSheetMoveToChat(BuildContext context, var user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // debugPrint('openBottomSheetMoveToChat user: ${user}');
        // debugPrint(
        //     'user[pingpongCourt].length: ${user['pingpongCourt'].length}');
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
                          debugPrint('user: ${user}');
                          debugPrint('user[uid]: ${user['uid']}');
                          // 차단한 유저인지 확인 필요
                          RepositoryRealtimeBlockedList().getCheckIsOpponentBlocked(user['uid']).then((boolValue) async {

                            if (boolValue == true) {
                              LaunchUrl().alertFunc(navigatorKey.currentContext!, '알림', '차단 목록에 있는 유저입니다.\n차단을 먼저 해제해주세요.', '확인', () {
                                Navigator.of(navigatorKey.currentContext!, rootNavigator: false).pop();
                              });
                            } else {

                              await MoveToOtherScreen()
                                  .initializeGASetting(context, 'ChatScreen')
                                  .then((value) async {
                                debugPrint('여기서 에러 발생2');
                                await MoveToOtherScreen()
                                    .persistentNavPushNewScreen(
                                    context,
                                    ChatScreen(receivedData: user),
                                    false,
                                    PageTransitionAnimation.cupertino)
                                    .then((value) async {
                                  debugPrint('여기서 에러 발생3');
                                  await MoveToOtherScreen().initializeGASetting(
                                      context, 'MatchingScreen');
                                });
                              });
                            }

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
