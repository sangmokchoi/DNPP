import 'package:dnpp/widgets/appointment/add_appointment.dart';
import 'package:dnpp/widgets/calendar/calendar_CustomSFCalendar.dart';
import 'package:dnpp/widgets/appointment/edit_appointment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:dnpp/constants.dart';

import '../viewModel/appointmentUpdate.dart';

class CalendarScreen extends StatefulWidget {
  static String id = '/StatisticsScreenID';

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  TextEditingController _textFormFieldController = TextEditingController();

  bool isChecked = false;

  void toggleDone() {
    isChecked = !isChecked;
    print(isChecked);
  }

  //final CalendarController _controller = CalendarController();

  Future<void> updateProvider(dynamic appointmentDetails) async {
    Provider.of<AppointmentUpdate>(context, listen: false)
        .updateSubject(appointmentDetails.subject);
    Provider.of<AppointmentUpdate>(context, listen: false)
        .updateFromDate(appointmentDetails.startTime);
    Provider.of<AppointmentUpdate>(context, listen: false)
        .updateToDate(appointmentDetails.endTime);
    Provider.of<AppointmentUpdate>(context, listen: false)
        .changeIsAllDay(appointmentDetails.isAllDay);
    Provider.of<AppointmentUpdate>(context, listen: false)
        .updateNotes(appointmentDetails.notes);
  }

  void openModalBottomSheet(BuildContext context, dynamic appointmentDetails){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ListView(children: [
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Consumer<AppointmentUpdate>(
              builder: (context, taskData, child) {
                return EditAppointment(
                  friendCode: '',
                  userCourt: '',
                  oldMeeting: appointmentDetails,
                );
              },
            ),
          ),
        ]);
      },
    );
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    if (Provider.of<AppointmentUpdate>(context, listen: false).calendarController.view ==
        CalendarView.month) {
      if (calendarTapDetails.targetElement == CalendarElement.resourceHeader) {

        print('111');
      } else if (calendarTapDetails.targetElement ==
          CalendarElement.appointment) {
        print('222');

        final appointmentDetails = calendarTapDetails.appointments?.first;
        print("appointmentDetails: $appointmentDetails");

        //print(appointmentDetails); // color 가 MaterialAccentColor(primary value: Color(0xff448aff)
        // 이면, 일반 일정이고, 다른 색상이면 공유되는 일정으로 표시해야함

        //Appointment? existingAppointment = meetings.firstWhere((element) => element.id == oldMeeting.id);

        if (appointmentDetails.recurrenceRule != '' || appointmentDetails.recurrenceRule != null) {
          print('appointmentDetails.recurrenceRule != '', 반복 일정 O'); // 반복 일정 O

          await updateProvider(appointmentDetails);
          openModalBottomSheet(context, appointmentDetails);

        } else {
          print('appointmentDetails.recurrenceRule == '', 반복 일정 X'); // 반복 일정 X
          await updateProvider(appointmentDetails);
          openModalBottomSheet(context, appointmentDetails);

        }

      } else if (calendarTapDetails.targetElement ==
          CalendarElement.calendarCell){

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
        Provider.of<AppointmentUpdate>(context, listen: false)
            .updateFromDate(fromDate);
        Provider.of<AppointmentUpdate>(context, listen: false)
            .updateToDate(toDate);
      } else {
        print('333-2');
      }

    } else if (Provider.of<AppointmentUpdate>(context, listen: false).calendarController.view ==
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
        Provider.of<AppointmentUpdate>(context, listen: false)
            .updateFromDate(fromDate);
        Provider.of<AppointmentUpdate>(context, listen: false)
            .updateToDate(toDate);
      } else {
        print('666 - 3');
      }
    } else if (Provider.of<AppointmentUpdate>(context, listen: false).calendarController.view ==
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
      Provider.of<AppointmentUpdate>(context, listen: false)
          .updateFromDate(fromDate);
      Provider.of<AppointmentUpdate>(context, listen: false)
          .updateToDate(toDate);

      String _segmentedButtonTitle =
          Provider.of<AppointmentUpdate>(context, listen: false)
              .segmentedButtonTitle;
      Provider.of<AppointmentUpdate>(context, listen: false)
          .updateCalendarView(_segmentedButtonTitle);

      if (calendarTapDetails.targetElement == CalendarElement.viewHeader) {
        print('777-1');
        print(fromDate);
        print(toDate);
        Provider.of<AppointmentUpdate>(context, listen: false)
            .calendarController
            .view = CalendarView.day;
        setState(() {
          Provider.of<AppointmentUpdate>(context, listen: false)
              .updateSegmentedButtonTitle('일');
          Provider.of<AppointmentUpdate>(context, listen: false)
              .updateCalendarView(
                  Provider.of<AppointmentUpdate>(context, listen: false)
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
        Provider.of<AppointmentUpdate>(context, listen: false)
            .updateFromDate(fromDate);
        Provider.of<AppointmentUpdate>(context, listen: false)
            .updateToDate(toDate);
      } else {
        print('888 - 2');
      }

    } else if (Provider.of<AppointmentUpdate>(context, listen: false)
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
          title: Text('Calendar'),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12.0, right: 2.0),
          child: FloatingActionButton(
            child: Icon(Icons.edit_calendar),
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return ListView(children: [
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Consumer<AppointmentUpdate>(
                            builder: (context, taskData, child) {
                          return AddAppointment(
                            friendCode: '',
                            userCourt: '',
                          );
                        }),
                      ),
                    ]);
                  });
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
                    child: SingleChoice(),
                  )),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.0),
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

class SingleChoice extends StatefulWidget {
  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {

  final List<String> _list = ['전체', '월', '주', '일'];

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: <ButtonSegment<String>>[
        ButtonSegment<String>(
            value: _list[0], label: Text(_list[0]), icon: Icon(Icons.schedule)),
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
      selected: <String>{
        Provider.of<AppointmentUpdate>(context, listen: false)
            .segmentedButtonTitle
      }, //<String>{_selected},
      onSelectionChanged: (newSelection) {
        setState(() {
          print(newSelection);
          // _selected = newSelection.first;
          // print(_selected);
          Provider.of<AppointmentUpdate>(context, listen: false)
              .updateSegmentedButtonTitle(newSelection.first);
          Provider.of<AppointmentUpdate>(context, listen: false)
              .updateCalendarView(
                  Provider.of<AppointmentUpdate>(context, listen: false)
                      .segmentedButtonTitle);
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey),
      ),
    );
  }
}
