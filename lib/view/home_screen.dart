import 'package:dnpp/view/main_screen.dart';
import 'package:dnpp/view/profile_screen.dart';
import 'package:dnpp/view/setting_screen.dart';
import 'package:dnpp/view/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import '../models/search.dart';
import '../viewModel/personalAppointmentUpdate.dart';
import 'map_screen.dart';
import 'calendar_screen.dart';

import 'package:firebase_storage/firebase_storage.dart';

GlobalKey<_HomeScreenState> homePageKey = GlobalKey<_HomeScreenState>();

class HomeScreen extends StatefulWidget {
  static String id = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0;

  PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  late bool _hideNavBar;

  List<Widget> _buildScreens() {
    return [
      MainScreen(),
      //ProfileScreen(),
      CalendarScreen(),
      //SignupScreen(),
      CalendarScreen(),
      SignupScreen(),
      SettingScreen(),
      //MapScreen()
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.chart_bar_circle),
        title: ("캘린더"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.settings),
        title: ("설정"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.chat_bubble_2),
        title: ("매칭"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.ellipsis),
        title: ("더보기"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  // static const TextStyle optionStyle =
  // TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  //
  // static const List<Widget> _widgetOptions = <Widget>[
  //   Text(
  //     'Index 0: Home',
  //     style: optionStyle,
  //   ),
  //   Text(
  //     'Index 1: Business',
  //     style: optionStyle,
  //   ),
  //   Text(
  //     'Index 2: School',
  //     style: optionStyle,
  //   ),
  // ];

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController();
    _hideNavBar = false;
  }

  void onItemSelected(int index) {
    _controller.jumpToTab(index);
    // 추가로 수행해야 할 로직이 있다면 여기에 추가
    print('onItemSelected pressed');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PersistentTabView(
        key: homePageKey,
        context,
        controller: _controller,
        onItemSelected: (int) {
          setState(() {

            switch (int) {
              case 0:
              // WidgetsBinding.instance?.addPostFrameCallback((_) {
              //   try {
              //     Provider.of<AppointmentUpdate>(context, listen: false)
              //         .daywiseDurationsCalculate(false);
              //     Provider.of<AppointmentUpdate>(context, listen: false)
              //         .countHours(true);
              //     Provider.of<AppointmentUpdate>(context, listen: false).updateRecentDays(0);
              //     setState(() {});
              //   } catch (e) {
              //     print(e);
              //   }
              //
              // });
                return print('$int');
              case 1:
                // WidgetsBinding.instance?.addPostFrameCallback((_) {
                //   try {
                //     Provider.of<AppointmentUpdate>(context, listen: false)
                //         .daywiseDurationsCalculate(true);
                //     Provider.of<AppointmentUpdate>(context, listen: false)
                //         .countHours(true);
                //     Provider.of<AppointmentUpdate>(context, listen: false).updateRecentDays(0);
                //     setState(() {});
                //   } catch (e) {
                //     print(e);
                //   }
                //
                // });
                return print('$int');
              case 2:
                return print('$int');
              case 3:
                return print('$int');
              case 4:
                return print('$int');
              case 5:
                return print('$int');
              default:
                return print('$int');
            }
          }); // This is required to update the nav bar if Android back button is pressed
        },
        screens: _buildScreens(),
        items: _navBarsItems(),
        navBarHeight: 65,
        confineInSafeArea: true,
        backgroundColor: Colors.white70, // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties( // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.style1, // Choose the nav bar style with this property.
      ),
    );

  }
}

