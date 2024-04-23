import 'package:dnpp/repository/moveToOtherScreen.dart';
import 'package:dnpp/view/signup_screen.dart';
import 'package:dnpp/viewModel/CalendarScreen_ViewModel.dart';
import 'package:dnpp/widgets/appointment/add_appointment.dart';
import 'package:dnpp/widgets/calendar/calendar_CustomSFCalendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:dnpp/constants.dart';
import '../statusUpdate/loginStatusUpdate.dart';

class CalendarScreen extends StatelessWidget {
  static String id = '/StatisticsScreenID';
  late CalendarScreenViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<CalendarScreenViewModel>(context, listen: false);
    return Consumer<CalendarScreenViewModel>(
        builder: (context, currentUserUpdate, child) {
      return SafeArea(
          child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          titleTextStyle: kAppbarTextStyle,
          title: Text(
            'Calendar',
            style: Theme.of(context).brightness == Brightness.light
                ? TextStyle(color: Colors.black)
                : TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 15.0, right: 2.0),
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: Icon(Icons.edit_calendar),
            onPressed: () {
              if (Provider.of<LoginStatusUpdate>(context, listen: false)
                  .isLoggedIn) {
                MoveToOtherScreen().persistentNavPushNewScreen(
                    context,
                    AddAppointment(userCourt: ''),
                    false,
                    PageTransitionAnimation.slideUp);
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                      shape: kRoundedRectangleBorder,
                      title: Center(child: Text('알림')),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('로그인이 필요한 화면입니다\n로그인 화면으로 이동합니다'),
                        ],
                      ),
                      actions: [
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              MoveToOtherScreen().persistentNavPushNewScreen(
                                  context,
                                  SignupScreen(),
                                  false,
                                  PageTransitionAnimation.fade);
                            },
                            child: Text('확인'),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0),//EdgeInsets.all(10.0),
              //EdgeInsets.only(top: 8.0, bottom: 8.0, left: 25.0, right: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0, bottom: 10.0),
                    // child: Consumer<CalendarScreenProvider>(
                    //     builder: (context, taskData, child) {
                    //   return CalendarScreenViewModel().SingleChoice(context);
                    // }),
                    child: viewModel.SingleChoice(context),
                  )),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: CustomSFCalendar(
                  widgetContext: context,
                ),
              ),
            ),
            // SizedBox(
            //   height: 700,
            //   child: Padding(
            //     padding: EdgeInsets.only(bottom: 5.0),
            //     child: CustomSFCalendar(
            //       widgetContext: context,
            //     ),
            //   ),
            // ),
          ],
        ),
      ));
    });
  }
}
