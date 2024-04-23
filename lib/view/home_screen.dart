import 'package:dnpp/view/main_screen.dart';
import 'package:dnpp/view/matching_screen.dart';
import 'package:dnpp/view/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import '../statusUpdate/profileUpdate.dart';
import 'calendar_screen.dart';

// GlobalKey<_HomeScreenState> homePageKey = GlobalKey<_HomeScreenState>();

class HomeScreen extends StatefulWidget {
  static String id = '/HomeScreenID';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  late bool _hideNavBar;

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
        icon: Icon(
          CupertinoIcons.home,//CupertinoIcons.chart_bar_circle,
          size: 30,
        ),
        title: ("Home"),
        textStyle: TextStyle(fontSize: 15.0),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          CupertinoIcons.calendar_today,
          size: 30,
        ),
        title: ("캘린더"),
        textStyle: TextStyle(fontSize: 15.0),
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
        icon: Icon(
          CupertinoIcons.person_2_fill,//Icons.people,//CupertinoIcons.group,
          size: 30,
        ),
        title: ("매칭"),
        textStyle: TextStyle(
          fontSize: 15.0,
        ),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          CupertinoIcons.ellipsis,
          size: 30,
        ),
        title: ("설정"),
        textStyle: TextStyle(fontSize: 15.0),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white,
      ),
    ];
  }

  // @override
  void onItemSelected(int index) {
    _controller.jumpToTab(index);
    // 추가로 수행해야 할 로직이 있다면 여기에 추가
    print('onItemSelected pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileUpdate>(
        builder: (context, currentUserUpdate, child) {
          return PersistentTabView(
            //key: homePageKey,
            context,
            controller: _controller,
            onItemSelected: (int) {
              setState(() {
                switch (int) {
                  case 0:
                    return print('$int');
                  case 1:
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
            //confineInSafeArea: true,
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            //Colors.white70, // Default is Colors.white.
            handleAndroidBackButtonPress: true,
            // Default is true.
            resizeToAvoidBottomInset: true,
            // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
            stateManagement: true,
            // Default is true.
            hideNavigationBarWhenKeyboardShows: true,
            // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
            decoration: NavBarDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
              colorBehindNavBar: Colors.transparent,
            ),
            popAllScreensOnTapOfSelectedTab: true,
            popActionScreens: PopActionScreensType.all,
            itemAnimationProperties: ItemAnimationProperties(
              // Navigation Bar's items animation properties.
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
            ),
            screenTransitionAnimation: ScreenTransitionAnimation(
              // Screen transition animation on change of selected tab.
              animateTabTransition: true,
              curve: Curves.ease,
              duration: Duration(milliseconds: 200),
            ),
            navBarStyle:
            NavBarStyle.style1, // Choose the nav bar style with this property.
          );
        });
  }
}
