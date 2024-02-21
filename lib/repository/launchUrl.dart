import 'package:dnpp/constants.dart';
import 'package:dnpp/repository/moveToOtherScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../view/chatList_Screen.dart';
import '../view/chat_screen.dart';

class LaunchUrl {

  Future<void> myLaunchUrl(String _url) async {
    print('myLaunchUrl 진입');
    final Uri _newUrl = Uri.parse(_url);
    if (!await launchUrl(_newUrl)) {
      throw Exception('Could not launch $_newUrl');
    }
  }

  void alertFunc(BuildContext context, String titleText, String contentText,
      String okText, VoidCallback? onOkPressed) {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
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
                  Navigator.pop(context); // 다이얼로그 닫기는 여기서 호출

                },
              ),
            ],
          );
        });
  }

  void openBottomSheetMoveToChat(BuildContext context, var user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                topLeft: Radius.circular(10.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '이 유저에게 함께 탁구를 쳐보자는 메시지를 보낼까요?',
                  style: TextStyle(
                    fontSize: 16.0,
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
                          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.red),
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
                        onPressed: () {
                          Navigator.pop(context);
                          //Navigator.push(context, createRouteChatView(user));

                          MoveToOtherScreen().persistentNavPushNewScreen(context, ChatScreen(receivedData: user), false, PageTransitionAnimation.cupertino);
                        },
                        child: Text(
                          '확인',
                          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: kMainColor),
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
