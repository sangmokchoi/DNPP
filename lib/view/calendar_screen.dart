import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/view/signup_screen.dart';
import 'package:dnpp/widgets/appointment/add_appointment.dart';
import 'package:dnpp/widgets/calendar/calendar_CustomSFCalendar.dart';
import 'package:dnpp/widgets/appointment/edit_appointment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:dnpp/constants.dart';

import '../models/customAppointment.dart';
import '../viewModel/personalAppointmentUpdate.dart';
import '../viewModel/loginStatusUpdate.dart';

class CalendarScreen extends StatefulWidget {
  static String id = '/StatisticsScreenID';

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  TextEditingController _textFormFieldController = TextEditingController();

  FirebaseFirestore db = FirebaseFirestore.instance;

  bool isChecked = false;

  late Future<void> myFuture;

  void toggleDone() {
    isChecked = !isChecked;
    print(isChecked);
  }

  //final CalendarController _controller = CalendarController();

  // Future<void> fetchAppointmentData() async {
  //   print('fetchAppointmentData 시작');
  //   // 해당 함수는 유저가 로그인한 상태일 때 실행되어야 함
  //
  //   db.collection("Appointments").where(
  //       "userUid",
  //       isEqualTo: Provider.of<LoginStatusUpdate>(context, listen: false).currentUser.uid).get().then(
  //         (querySnapshot) {
  //       print("Successfully completed");
  //       for (var docSnapshot in querySnapshot.docs) {
  //         //final data = docSnapshot.data();
  //         final data = docSnapshot.data() as Map<String, dynamic>;
  //
  //         List<Appointment>? _appointment = (data['appointments'] as List<dynamic>?)
  //             ?.map<Appointment>((dynamic item) {
  //           return Appointment(
  //             startTime: (item['startTime'] as Timestamp).toDate(),
  //             endTime: (item['endTime'] as Timestamp).toDate(),
  //             subject: item['subject'] as String,
  //             isAllDay: item['isAllDay'] as bool,
  //             notes: item['notes'] as String,
  //             recurrenceRule: item['recurrenceRule'] as String,
  //           );
  //         }).toList();
  //
  //
  //         // //Provider.of<AppointmentUpdate>(context, listen: false).meetings.add(_appointment?.first);
  //         if (_appointment != null && _appointment.isNotEmpty) {
  //           print('_appointment: $_appointment');
  //           Provider.of<AppointmentUpdate>(context, listen: false).addMeeting(_appointment.first);
  //         }
  //       }
  //
  //
  //     },
  //     onError: (e) => print("Error completing: $e"),
  //   );
  //
  //   setState(() {
  //
  //   });
  // }

  Future<void> updateProvider(dynamic appointmentDetails) async {
    Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        .updateSubject(appointmentDetails.subject);
    Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        .updateFromDate(appointmentDetails.startTime);
    Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        .updateToDate(appointmentDetails.endTime);
    Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        .changeIsAllDay(appointmentDetails.isAllDay);
    Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        .updateNotes(appointmentDetails.notes);
  }

  void openModalBottomSheet(BuildContext context, dynamic appointmentDetails) {
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   builder: (BuildContext context) {
    //     return ListView(children: [
    //       Padding(
    //         padding: EdgeInsets.only(
    //             bottom: MediaQuery.of(context).viewInsets.bottom),
    //         child: Consumer<PersonalAppointmentUpdate>(
    //           builder: (context, taskData, child) {
    //             return EditAppointment(
    //               context: context,
    //               userCourt: '',
    //               oldMeeting: appointmentDetails,
    //             );
    //           },
    //         ),
    //       ),
    //     ]);
    //   },
    // );
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: EditAppointment(
          context: context, userCourt: '', oldMeeting: appointmentDetails),
      withNavBar: true,
      // OPTIONAL VALUE. True by default.
      pageTransitionAnimation: PageTransitionAnimation.slideUp,
    );
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    if (Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .calendarController
            .view ==
        CalendarView.month) {
      if (calendarTapDetails.targetElement == CalendarElement.resourceHeader) {
        print('111');
      } else if (calendarTapDetails.targetElement ==
          CalendarElement.appointment) {
        print('222');

        final appointmentDetails = calendarTapDetails.appointments?.first;
        print("appointmentDetails: ${appointmentDetails}");

        print("appointmentDetails recurrenceRule: ${appointmentDetails.recurrenceRule}");

        //print(appointmentDetails); // color 가 MaterialAccentColor(primary value: Color(0xff448aff)
        // 이면, 일반 일정이고, 다른 색상이면 공유되는 일정으로 표시해야함

        //Appointment? existingAppointment = meetings.firstWhere((element) => element.id == oldMeeting.id);

    // class CalendarAppointment {
    // /// Constructor to creates an appointment data for [SfCalendar].
    // CalendarAppointment({
    // this.startTimeZone,
    // this.endTimeZone,
    // this.recurrenceRule,
    // this.isAllDay = false,
    // this.notes,
    // this.location,
    // this.resourceIds,
    // this.recurrenceId,
    // this.id,
    // required this.startTime,
    // required this.endTime,
    // this.subject = '',
    // this.color = Colors.lightBlue,
    // this.isSpanned = false,
    // this.recurrenceExceptionDates,
    // })  : actualStartTime = startTime,
    // actualEndTime = endTime;

        if (appointmentDetails.recurrenceRule != null) {
          print('appointmentDetails.recurrenceRule != null, 반복 일정 O'); // 반복 일정 O

          await updateProvider(appointmentDetails);
          openModalBottomSheet(context, appointmentDetails);
        } else {
          print('appointmentDetails.recurrenceRule == null, 반복 일정 X'); // 반복 일정 X
          await updateProvider(appointmentDetails);
          openModalBottomSheet(context, appointmentDetails);
        }
      } else if (calendarTapDetails.targetElement ==
          CalendarElement.calendarCell) {
        print('333-1');
        final year = calendarTapDetails.date?.year;
        final month = calendarTapDetails.date?.month;
        final day = calendarTapDetails.date?.day;
        final day2 = calendarTapDetails.date?.weekday;
        // 일 - 7, 토 - 6

        var fromDate = DateTime(
          year!,
          month!,
          day!,
          DateTime.now().hour,
          (DateTime.now().minute / 5).round() * 5,
        );

        var toDate = DateTime(
          year,
          month,
          day,
          DateTime.now().add(Duration(minutes: 20)).hour,
          (DateTime.now().add(Duration(minutes: 20)).minute / 5).round() * 5,
        );
        Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateFromDate(fromDate);
        Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateToDate(toDate);
      } else {
        print('333-2');
      }
    } else if (Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .calendarController
            .view ==
        CalendarView.week) {
      print('444');
      if (calendarTapDetails.targetElement == CalendarElement.viewHeader) {
        //Provider.of<MapWidgetUpdate>(context, listen: false).calendarController.view = CalendarView.day;
        print('일 캘린더가 나타나야함');
        print('555');
      } else if (calendarTapDetails.targetElement == CalendarElement.agenda) {
        print('666 - 0');
      } else if (calendarTapDetails.targetElement ==
          CalendarElement.appointment) {
        print('666 - 1'); // 주 에서 약속 클릭
        final appointmentDetails = calendarTapDetails.appointments![0];

        await updateProvider(appointmentDetails);
        openModalBottomSheet(context, appointmentDetails);
      } else if (calendarTapDetails.targetElement ==
          CalendarElement.calendarCell) {
        print('666 - 2');
        final year = calendarTapDetails.date?.year;
        final month = calendarTapDetails.date?.month;
        final day = calendarTapDetails.date?.day;
        final hour = calendarTapDetails.date?.hour;
        final minute = calendarTapDetails.date?.minute;
        // 일 - 7, 토 - 6

        var fromDate = DateTime(
          year!,
          month!,
          day!,
          hour!,
          (minute! / 5).round() * 5,
        );

        var toDate = DateTime(
          year,
          month,
          day,
          fromDate.add(Duration(minutes: 20)).hour,
          (fromDate.add(Duration(minutes: 20)).minute / 5).round() * 5,
        );
        Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateFromDate(fromDate);
        Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateToDate(toDate);
      } else {
        print('666 - 3');
      }
    } else if (Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .calendarController
            .view ==
        CalendarView.day) {
      print('777');

      final year = calendarTapDetails.date?.year;
      final month = calendarTapDetails.date?.month;
      final day = calendarTapDetails.date?.day;
      final day2 = calendarTapDetails.date?.weekday;
      // 일 - 7, 토 - 6

      var fromDate = DateTime(
        year!,
        month!,
        day!,
        DateTime.now().hour,
        (DateTime.now().minute / 5).round() * 5,
      );

      var toDate = DateTime(
        year,
        month,
        day,
        DateTime.now().add(Duration(minutes: 20)).hour,
        (DateTime.now().add(Duration(minutes: 20)).minute / 5).round() * 5,
      );
      Provider.of<PersonalAppointmentUpdate>(context, listen: false)
          .updateFromDate(fromDate);
      Provider.of<PersonalAppointmentUpdate>(context, listen: false)
          .updateToDate(toDate);

      String _segmentedButtonTitle =
          Provider.of<PersonalAppointmentUpdate>(context, listen: false)
              .segmentedButtonTitle;
      Provider.of<PersonalAppointmentUpdate>(context, listen: false)
          .updateCalendarView(_segmentedButtonTitle);

      if (calendarTapDetails.targetElement == CalendarElement.viewHeader) {
        print('777-1');
        print(fromDate);
        print(toDate);
        Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .calendarController
            .view = CalendarView.day;
        setState(() {
          Provider.of<PersonalAppointmentUpdate>(context, listen: false)
              .updateSegmentedButtonTitle('일');
          Provider.of<PersonalAppointmentUpdate>(context, listen: false)
              .updateCalendarView(
                  Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                      .segmentedButtonTitle);
        }); // 이유는 모르겠으나 여기서 week 캘린더의 viewHeader를 클릭해야 day 캘린더로 넘어감
      } else if (calendarTapDetails.targetElement ==
          CalendarElement.appointment) {
        print('888');
        final appointmentDetails = calendarTapDetails.appointments![0];

        await updateProvider(appointmentDetails);
        openModalBottomSheet(context, appointmentDetails);
      } else if (calendarTapDetails.targetElement ==
          CalendarElement.calendarCell) {
        print('888 - 1');

        final year = calendarTapDetails.date?.year;
        final month = calendarTapDetails.date?.month;
        final day = calendarTapDetails.date?.day;
        final hour = calendarTapDetails.date?.hour;
        final minute = calendarTapDetails.date?.minute;

        var fromDate = DateTime(
          year!,
          month!,
          day!,
          hour!,
          (minute! / 5).round() * 5,
        );

        var toDate = DateTime(
          year,
          month,
          day,
          fromDate.add(Duration(minutes: 20)).hour,
          (fromDate.add(Duration(minutes: 20)).minute / 5).round() * 5,
        );
        Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateFromDate(fromDate);
        Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateToDate(toDate);
      } else {
        print('888 - 2');
      }
    } else if (Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .calendarController
            .view ==
        CalendarView.schedule) {
      print('999');
      print(calendarTapDetails.targetElement);

      if (calendarTapDetails.targetElement == CalendarElement.appointment) {
        final appointmentDetails = calendarTapDetails.appointments![0];

        await updateProvider(appointmentDetails);
        openModalBottomSheet(context, appointmentDetails);
      }
    } else {
      print('1000');
    }
  }

  @override
  void initState() {
    //myFuture = fetchAppointmentData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          titleTextStyle: kAppbarTextStyle,
          title: Text(
              'Calendar',
            style: Theme.of(context).brightness == Brightness.light ?
            TextStyle(color: Colors.black) :
            TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
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

                // showModalBottomSheet(
                //   isScrollControlled: true,
                //   context: context,
                //   builder: (BuildContext context) {
                //     return ListView(children: [
                //       Padding(
                //         padding: EdgeInsets.only(
                //             bottom: MediaQuery.of(context).viewInsets.bottom),
                //         child: Consumer<PersonalAppointmentUpdate>(
                //             builder: (context, taskData, child) {
                //           return AddAppointment(
                //             userCourt: '',
                //             context: context,
                //           );
                //         }),
                //       ),
                //     ]);
                //   },
                // );

                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AddAppointment(
                      context: context, userCourt: ''),
                  withNavBar: true,
                  // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.slideUp,
                );

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
                              // 로그인 페이지로 이
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: SignupScreen(),
                                withNavBar: false,
                                // OPTIONAL VALUE. True by default.
                                pageTransitionAnimation:
                                    PageTransitionAnimation.fade,
                              );

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
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              //EdgeInsets.only(top: 8.0, bottom: 8.0, left: 25.0, right: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: Padding(
                    padding:
                        EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0),
                    child: Consumer<PersonalAppointmentUpdate>(
                        builder: (context, taskData, child) {
                      return SingleChoice();
                    }),
                  )),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: CustomSFCalendar(
                  calendarTapped: calendarTapped,
                  context: context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SingleChoice extends StatelessWidget {
  final List<String> _list = ['전체', '월', '주', '일'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            //spreadRadius: 5,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: SegmentedButton<String>(
        segments: <ButtonSegment<String>>[
          ButtonSegment<String>(
              value: _list[0],
              label: Text(_list[0]),
              icon: Icon(Icons.schedule)),
          ButtonSegment<String>(
              value: _list[1],
              label: Text(_list[1]),
              icon: Icon(Icons.calendar_view_month)),
          ButtonSegment<String>(
              value: _list[2],
              label: Text(_list[2]),
              icon: Icon(Icons.calendar_view_week)),
          ButtonSegment<String>(
              value: _list[3],
              label: Text(_list[3]),
              icon: Icon(Icons.calendar_view_day))
        ],
        selected: {
          Provider.of<PersonalAppointmentUpdate>(context, listen: false)
              .segmentedButtonTitle
        }, //<String>{_selected},
        onSelectionChanged: (newSelection) async {
          print(newSelection);

          await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
              .updateSegmentedButtonTitle(newSelection.first);
          await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
              .updateCalendarView(newSelection.first);
        },
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(
              fontSize: 16, // Adjust the font size as needed
              // Other text style properties...
            ),
          ),
          //backgroundColor: MaterialStateProperty.all(Colors.blue),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              // If the button is selected (clicked), set text color to black
              return kMainColor;
            }
            // Default text color for unselected state
            return Colors.grey;
          }),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          elevation: MaterialStateProperty.all(8),
          side: MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> states) {
              // Set the border color based on the states (e.g., pressed)
              return BorderSide(color: Colors.white, width: 0.5);
            },
          ),
        ),
      ),
    );
  }
}
