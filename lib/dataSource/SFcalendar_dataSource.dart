import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class SFCalendarDataSource extends CalendarDataSource {

  SFCalendarDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String getId(int index) {
    return appointments![index].id;
  }

  @override
  String getNotes(int index) {
    return appointments![index].notes;
  }

  @override
  String getRecurrenceRule(int index) {
    return appointments![index].recurrenceRule;
  }

  @override
  List<DateTime> getRecurrenceExceptionDates(int index) {
    return appointments![index].exceptionDates;
  }

}

// class Meeting {
//   Meeting(
//       this.friendCode,
//       this.userCourt,
//       this.subject,
//       this.startTime,
//       this.endTime,
//       this.background,
//       //this.isLesson,
//       this.isAllDay,
//       this.notes,
//       this.recurrenceRule
//       );
//
//   String friendCode;
//   String userCourt; // 활동 탁구장
//
//   String subject;
//   DateTime startTime;
//   DateTime endTime;
//   Color background;
//   //bool isLesson;
//   bool isAllDay;
//   String notes;
//   String recurrenceRule;
// }