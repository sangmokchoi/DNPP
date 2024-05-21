import 'dart:core';
import 'package:dnpp/models/moveToOtherScreen.dart';
import 'package:dnpp/view/main_screen.dart';
import 'package:dnpp/view/matching_screen.dart';
import 'package:dnpp/view/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../statusUpdate/CurrentPageProvider.dart';
import '../statusUpdate/googleAnalytics.dart';
import 'calendar_screen.dart';


class HomeScreen extends StatefulWidget {
  static String id = '/HomeScreenID';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  PersistentTabController _persistentTabController =
      PersistentTabController(initialIndex: 0);

  //Timer? _timer; // 타이머를 저장할 변수

  List<Widget> _buildScreens() {
    return [
      MainScreen(),
      //ProfileScreen(),
      //SignupScreen(),
      CalendarScreen(),
      MatchingScreen(),
      SettingScreen(),
      //MapScreen()
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(
          CupertinoIcons.home, //CupertinoIcons.chart_bar_circle,
          size: 30,
        ),
        title: ("Home"),
        textStyle: const TextStyle(fontSize: 15.0),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          CupertinoIcons.calendar_today,
          size: 30,
        ),
        title: ("Calendar"),
        textStyle: const TextStyle(fontSize: 15.0),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white,
      ),
      // PersistentBottomNavBarItem(
      //   icon: Icon(CupertinoIcons.settings),
      //   title: ("설정"),
      //   activeColorPrimary: CupertinoColors.activeBlue,
      //   inactiveColorPrimary: CupertinoColors.systemGrey,
      // ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          CupertinoIcons.person_2_fill, //Icons.people,//CupertinoIcons.group,
          size: 30,
        ),
        title: ("Matching"),
        textStyle: const TextStyle(
          fontSize: 15.0,
        ),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          CupertinoIcons.ellipsis,
          size: 30,
        ),
        title: ("Setting"),
        textStyle: const TextStyle(fontSize: 15.0),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white,
      ),
    ];
  }

  // @override
  void onItemSelected(int index) {
    _persistentTabController.jumpToTab(index);
    // 추가로 수행해야 할 로직이 있다면 여기에 추가
    debugPrint('onItemSelected pressed');
  }

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    debugPrint('홈스크린 이닛!');
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // navigator key의 현재 라우트 수 확인
      if (navigatorKey.currentState?.canPop() ?? false) {
        debugPrint('불필요한 라우트가 있는 경우 pop');
        // 불필요한 라우트가 있는 경우 pop
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    });

    super.initState();

    _persistentTabController = PersistentTabController(initialIndex: 0);

    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    controller.forward(); // 애니메이션 시작

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
          .startTimer('MainScreen');
    });
  }

  @override
  void dispose() {
    controller.dispose();
    debugPrint('homeScreen dispose!!!');
    //_timer?.cancel(); // 위젯이 제거되면 타이머도 취소
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FadeTransition(
      opacity: animation,
      child: GestureDetector(
        onTap: (){
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: PersistentTabView(
            //key: homePageKey,
            context,
            controller: _persistentTabController,
            onItemSelected: (itemInt) async {

              String screenName = '';
              // 맨 처음 진입시에 곧장 매칭 스크린, 채팅 리스트, 채팅 뷰로 넘어가면 매칭 스크린이 ga에서 추적이 안됨

                switch (itemInt) {
                  case 0:
                    screenName = 'MainScreen';
                  case 1:
                    screenName = 'CalendarScreen';
                  case 2:
                    screenName = 'MatchingScreen';
                  case 3:
                    screenName = 'SettingScreen';
                }
              debugPrint('홈스크린 itemInt: $itemInt');
                debugPrint('홈스크린 screenName: $screenName');

                await MoveToOtherScreen().initializeGASetting(context, screenName);

              setState(() {
                return debugPrint('$itemInt');
              }); // This is required to update the nav bar if Android back button is pressed
            },
            screens: _buildScreens(),
            items: _navBarsItems(),
            navBarHeight: 65,
            //confineInSafeArea: true,
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            //Colors.white70, // Default is Colors.white.
            handleAndroidBackButtonPress: true,
            // Default is true.
            resizeToAvoidBottomInset: false,
            // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
            stateManagement: true,
            // Default is true.
            hideNavigationBarWhenKeyboardShows: false,
            // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
            decoration: const NavBarDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
              colorBehindNavBar: Colors.transparent,
            ),
            popAllScreensOnTapOfSelectedTab: true,
            popActionScreens: PopActionScreensType.all,
            itemAnimationProperties: const ItemAnimationProperties(
              // Navigation Bar's items animation properties.
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
            ),
            screenTransitionAnimation: const ScreenTransitionAnimation(
              // Screen transition animation on change of selected tab.
              animateTabTransition: true,
              curve: Curves.ease,
              duration: Duration(milliseconds: 200),
            ),
            navBarStyle:
                NavBarStyle.style1, // Choose the nav bar style with this property.
          ),
        ),
      ),
    );
  }
}
