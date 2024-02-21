
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

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
      withNavBar: withNavBar,
      // OPTIONAL VALUE. True by default.
      pageTransitionAnimation: animation,
    );
  }

}