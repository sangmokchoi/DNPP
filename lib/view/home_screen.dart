import 'dart:core';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:dnpp/models/launchUrl.dart';
import 'package:dnpp/models/moveToOtherScreen.dart';
import 'package:dnpp/view/main_screen.dart';
import 'package:dnpp/view/matching_screen.dart';
import 'package:dnpp/view/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../notification.dart';
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
      CalendarScreen(),
      MatchingScreen(),
      SettingScreen(),
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await homeScreenInitPlugin();

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

  int _navBarInt = -1;

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

              _navBarInt = itemInt;

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

                if (_navBarInt != itemInt) {
                  setState(() {
                    return debugPrint('$itemInt');
                  }); // This is required to update the nav bar if Android back button is pressed
                }

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

  Future<void> homeScreenInitPlugin() async {

    final TrackingStatus status =
    await AppTrackingTransparency.trackingAuthorizationStatus;
    debugPrint('status 1: $status');

    if (status == TrackingStatus.notDetermined) {
      await showCustomTrackingDialog(context);
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");

  }

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      LaunchUrl().alertFuncFalseBarrierDismissible(
          context,
          '추적 요청',
          "핑퐁플러스는 광고를 통해 앱을 무료로 운영하고 있습니다. 광고 맞춤화를 위해 데이터를 사용할 수 있게끔 추적 권한을 요청드립니다.\n\n추적을 허용하게 되면, 광고 파트너들은 디바이스의 고유 식별자를 사용하여 맞춤화된 광고를 보여주게 됩니다.\n\n앱 설정에서 언제든지 추적 허용에 대한 권한을 변경할 수 있습니다.",
          '다음',
              () async {
            Navigator.pop(context);
            // Wait for dialog popping animation
            await Future.delayed(const Duration(milliseconds: 200));
            // Request system's tracking authorization dialog
            final TrackingStatus status =
            await AppTrackingTransparency.requestTrackingAuthorization();
            debugPrint('status 2: $status');
          });

}
