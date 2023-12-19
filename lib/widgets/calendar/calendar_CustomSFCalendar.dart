import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../dataSource/SFcalendar_dataSource.dart';
import '../../models/customAppointment.dart';
import '../../viewModel/loginStatusUpdate.dart';
import '../../viewModel/personalAppointmentUpdate.dart';

class CustomSFCalendar extends StatelessWidget {
  CustomSFCalendar({required this.calendarTapped, required this.context});

  final Function(CalendarTapDetails) calendarTapped;
  final BuildContext context;

  List<Appointment> _getDataSource() =>
      Provider.of<PersonalAppointmentUpdate>(context, listen: false).defaultMeetings;

  FirebaseFirestore db = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    // final docRef = db.collection("Appointments").where("userUid",
    //     isEqualTo: Provider.of<LoginStatusUpdate>(context, listen: false)
    //         .currentUser
    //         .uid).withConverter(
    //   fromFirestore: CustomAppointment.fromFirestore,
    //   toFirestore: (CustomAppointment customAppointment, _) => customAppointment.toFirestore(),
    // );


    return SfCalendar(
      view: CalendarView.month,
      viewHeaderStyle: const ViewHeaderStyle(
        dayTextStyle: TextStyle(
          fontSize: 14,
        ),
      ),
      headerHeight: 35,
      headerStyle: const CalendarHeaderStyle(
          textAlign: TextAlign.left,
          textStyle: TextStyle(
            fontSize: 24,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w500,
          )),
      controller: Provider.of<PersonalAppointmentUpdate>(context).calendarController,
      initialDisplayDate: DateTime.now(),
      initialSelectedDate: DateTime.now(),
      onTap: calendarTapped,
      dataSource: SFCalendarDataSource(_getDataSource()),
      timeSlotViewSettings: const TimeSlotViewSettings(
        timeTextStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.normal,
          fontSize: 16,
          color: Colors.black54,
        ),
        timeFormat: 'a h:mm',
        timeRulerSize: 65,
        dayFormat: 'EEE',
        timeInterval: Duration(minutes: 30),
        timeIntervalHeight: 70,
      ),

      scheduleViewSettings: ScheduleViewSettings(
        hideEmptyScheduleWeek: true,
        appointmentItemHeight: 60,
        appointmentTextStyle: TextStyle(
          fontSize: 16,
        ),
        dayHeaderSettings: DayHeaderSettings(
          dayFormat: 'EEEE',
          width: 60,
          dayTextStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
          dateTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
        weekHeaderSettings: WeekHeaderSettings(
          startDateFormat: 'yyyy년 MMM d일',
          endDateFormat: 'MMM d일',
          height: 35,
          textAlign: TextAlign.left,
          weekTextStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
        monthHeaderSettings: MonthHeaderSettings(
          monthFormat: 'MMMM, yyyy',
          height: 70,
          textAlign: TextAlign.left,
          backgroundColor: Colors.lightBlueAccent,
          monthTextStyle: TextStyle(
            fontSize: 25,
          ),
        ),
      ),

      // monthCellBuilder:
      //     (BuildContext buildContext, MonthCellDetails details) {
      //   final Color defaultColor = Colors.transparent;
      //   return Container(
      //     decoration: BoxDecoration(
      //         color: defaultColor,
      //         border: Border.all(color: Colors.grey, width: 0.1),
      //
      //     ),
      //     child: Align(
      //       alignment: Alignment.topLeft,
      //       child: Padding(
      //         padding: const EdgeInsets.all(5.0),
      //         child: Text(
      //           details.date.day.toString(),
      //           style: TextStyle(color: Colors.black),
      //         ),
      //       ),
      //     ),
      //   );
      // },

      monthViewSettings: MonthViewSettings(
        showTrailingAndLeadingDates: true,
        dayFormat: 'EEE',
        showAgenda: true,
        appointmentDisplayCount: 5,
        numberOfWeeksInView: 6,
        agendaItemHeight: 60,
        agendaViewHeight: 170,
        monthCellStyle: MonthCellStyle(
          trailingDatesBackgroundColor: Colors.blue.withOpacity(0.15),
          leadingDatesBackgroundColor: Colors.blue.withOpacity(0.15),
          textStyle: TextStyle(
            fontSize: 15,
          ),
          trailingDatesTextStyle: TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: 14,
          ),
          leadingDatesTextStyle: TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: 14,
          ),
        ),

        agendaStyle: AgendaStyle(
          backgroundColor: Colors.white54,
          appointmentTextStyle: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.normal,
              color: Colors.white), //Color(0xFF0ffcc00)),
          dateTextStyle: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: Colors.black),
          dayTextStyle: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Colors.black),
        ),
      ),

      headerDateFormat: 'MMM yyy',
      appointmentTimeTextFormat: 'HH:mm',
      appointmentTextStyle: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.normal
      ),
      onViewChanged: (ViewChangedDetails details) {
        List dates = details.visibleDates;
      },
      showDatePickerButton: true,
      showCurrentTimeIndicator: true,
      allowViewNavigation: true,
      showTodayButton: true,
    );
  }
}
