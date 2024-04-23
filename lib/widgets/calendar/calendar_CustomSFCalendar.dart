import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/repository/moveToOtherScreen.dart';
import 'package:dnpp/repository/repsitory_appointments.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../constants.dart';
import '../../dataSource/SFcalendar_dataSource.dart';
import '../../statusUpdate/loginStatusUpdate.dart';
import '../../viewModel/CalendarScreen_ViewModel.dart';
import '../../statusUpdate/personalAppointmentUpdate.dart';
import '../appointment/edit_appointment.dart';

// class CustomSFCalendar extends StatefulWidget {
//   CustomSFCalendar({required this.context});
//
//   final BuildContext context;
//
//   @override
//   State<CustomSFCalendar> createState() => _CustomSFCalendarState();
// }
//
// class _CustomSFCalendarState extends State<CustomSFCalendar> {
//
//   // List<Appointment> _getDataSource() =>
//   //     Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//   //         .defaultMeetings;
//
//   //List<Appointment> _getDataSource = [];
//   late List<Appointment> _getDataSource;
//   late CalendarScreenViewModel viewModel;
//
//   //FirebaseFirestore db = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     viewModel = Provider.of<CalendarScreenViewModel>(context, listen: false);
//     _getDataSource = viewModel.calendarListener(context);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return SfCalendar(
//       view: CalendarView.month,
//       selectionDecoration: BoxDecoration(
//         color: Colors.transparent,
//         border: Border.all(color: kMainColor, width: 2),
//         borderRadius: const BorderRadius.all(Radius.circular(3)),
//         shape: BoxShape.rectangle,
//       ),
//       todayHighlightColor: kMainColor,
//       viewHeaderStyle: const ViewHeaderStyle(
//         dayTextStyle: TextStyle(
//           fontSize: 14,
//         ),
//       ),
//       headerHeight: 45,
//       headerStyle: const CalendarHeaderStyle(
//           textAlign: TextAlign.left,
//           textStyle: TextStyle(
//             fontSize: 24,
//             fontStyle: FontStyle.normal,
//             fontWeight: FontWeight.w500,
//           )),
//       controller:
//           Provider.of<CalendarScreenViewModel>(context).calendarController,
//       initialDisplayDate: DateTime.now(),
//       initialSelectedDate: DateTime.now(),
//       onTap: calendarTapped,
//       dataSource: SFCalendarDataSource(_getDataSource),
//       timeSlotViewSettings: const TimeSlotViewSettings(
//         timeTextStyle: TextStyle(
//           fontWeight: FontWeight.w500,
//           fontStyle: FontStyle.normal,
//           fontSize: 16,
//         ),
//         timeFormat: 'a h:mm',
//         timeRulerSize: 65,
//         dayFormat: 'EEE',
//         timeInterval: Duration(minutes: 30),
//         timeIntervalHeight: 70,
//       ),
//
//       scheduleViewSettings: ScheduleViewSettings(
//         hideEmptyScheduleWeek: true,
//         appointmentItemHeight: 60,
//         appointmentTextStyle: TextStyle(
//           fontSize: 16,
//         ),
//         dayHeaderSettings: DayHeaderSettings(
//           dayFormat: 'EEEE',
//           width: 60,
//           dayTextStyle: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w300,
//           ),
//           dateTextStyle: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w300,
//           ),
//         ),
//         weekHeaderSettings: WeekHeaderSettings(
//           startDateFormat: 'yyyy년 MMM d일',
//           endDateFormat: 'MMM d일',
//           height: 35,
//           textAlign: TextAlign.left,
//           weekTextStyle: TextStyle(
//             fontWeight: FontWeight.w400,
//             fontSize: 15,
//           ),
//         ),
//         monthHeaderSettings: MonthHeaderSettings(
//           monthFormat: 'MMMM, yyyy',
//           height: 0,
//           textAlign: TextAlign.justify,
//           backgroundColor: Colors.lightBlueAccent,
//           monthTextStyle: TextStyle(
//             fontSize: 25,
//           ),
//         ),
//       ),
//
//       // monthCellBuilder:
//       //     (BuildContext buildContext, MonthCellDetails details) {
//       //   final Color defaultColor = Colors.transparent;
//       //   return Container(
//       //     decoration: BoxDecoration(
//       //         color: defaultColor,
//       //         border: Border.all(color: Colors.grey, width: 0.1),
//       //
//       //     ),
//       //     child: Align(
//       //       alignment: Alignment.topLeft,
//       //       child: Padding(
//       //         padding: const EdgeInsets.all(5.0),
//       //         child: Text(
//       //           details.date.day.toString(),
//       //           style: TextStyle(color: Colors.black),
//       //         ),
//       //       ),
//       //     ),
//       //   );
//       // },
//
//       monthViewSettings: MonthViewSettings(
//         showTrailingAndLeadingDates: true,
//         dayFormat: 'EEE',
//         showAgenda: true,
//         appointmentDisplayCount: 5,
//         numberOfWeeksInView: 6,
//         agendaItemHeight: 60,
//         agendaViewHeight: 180,
//         monthCellStyle: MonthCellStyle(
//           trailingDatesBackgroundColor: kMainColor.withOpacity(0.15),
//           leadingDatesBackgroundColor: kMainColor.withOpacity(0.15),
//           textStyle: TextStyle(
//             fontSize: 15,
//           ),
//           trailingDatesTextStyle: TextStyle(
//             fontStyle: FontStyle.normal,
//             fontSize: 14,
//           ),
//           leadingDatesTextStyle: TextStyle(
//             fontStyle: FontStyle.normal,
//             fontSize: 14,
//           ),
//         ),
//         agendaStyle: AgendaStyle(
//           //backgroundColor: Colors.white,
//           appointmentTextStyle: TextStyle(
//             fontSize: 18,
//             fontStyle: FontStyle.normal,
//           ), //Color(0xFF0ffcc00)),
//           dateTextStyle: TextStyle(
//             fontStyle: FontStyle.normal,
//             fontSize: 18,
//             fontWeight: FontWeight.w300,
//           ),
//           dayTextStyle: TextStyle(
//             fontStyle: FontStyle.normal,
//             fontSize: 25,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//
//       headerDateFormat: 'MMM yyy',
//       appointmentTimeTextFormat: 'HH:mm',
//       appointmentTextStyle: TextStyle(
//           fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),
//       onViewChanged: (ViewChangedDetails details) {
//         List dates = details.visibleDates;
//       },
//       showDatePickerButton: true,
//       showCurrentTimeIndicator: true,
//       //allowViewNavigation: true,
//       showTodayButton: true,
//     );
//   }
//
//   void calendarTapped(CalendarTapDetails calendarTapDetails) async {
//     if (Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
//         .calendarController
//         .view ==
//         CalendarView.month) {
//       if (calendarTapDetails.targetElement == CalendarElement.resourceHeader) {
//         print('111');
//       } else if (calendarTapDetails.targetElement ==
//           CalendarElement.appointment) {
//         print('222');
//
//         final appointmentDetails = calendarTapDetails.appointments?.first;
//         print("appointmentDetails: ${appointmentDetails}");
//
//         print("appointmentDetails recurrenceRule: ${appointmentDetails.recurrenceRule}");
//
//         //print(appointmentDetails); // color 가 MaterialAccentColor(primary value: Color(0xff448aff)
//         // 이면, 일반 일정이고, 다른 색상이면 공유되는 일정으로 표시해야함
//
//         //Appointment? existingAppointment = meetings.firstWhere((element) => element.id == oldMeeting.id);
//
//         if (appointmentDetails.recurrenceRule != null) {
//           print('appointmentDetails.recurrenceRule != null, 반복 일정 O'); // 반복 일정 O
//
//           await updateProvider(appointmentDetails);
//           openModalBottomSheet(widgetContext, appointmentDetails);
//         } else {
//           print('appointmentDetails.recurrenceRule == null, 반복 일정 X'); // 반복 일정 X
//           await updateProvider(appointmentDetails);
//           openModalBottomSheet(widgetContext, appointmentDetails);
//         }
//       } else if (calendarTapDetails.targetElement ==
//           CalendarElement.calendarCell) {
//         print('333-1');
//         final year = calendarTapDetails.date?.year;
//         final month = calendarTapDetails.date?.month;
//         final day = calendarTapDetails.date?.day;
//         final day2 = calendarTapDetails.date?.weekday;
//         // 일 - 7, 토 - 6
//
//         var fromDate = DateTime(
//           year!,
//           month!,
//           day!,
//           DateTime.now().hour,
//           (DateTime.now().minute / 5).round() * 5,
//         );
//
//         var toDate = DateTime(
//           year,
//           month,
//           day,
//           DateTime.now().add(Duration(minutes: 20)).hour,
//           (DateTime.now().add(Duration(minutes: 20)).minute / 5).round() * 5,
//         );
//         Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//             .updateFromDate(fromDate);
//         Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//             .updateToDate(toDate);
//       } else {
//         print('333-2');
//       }
//     } else if (Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
//         .calendarController
//         .view ==
//         CalendarView.week) {
//       print('444');
//       if (calendarTapDetails.targetElement == CalendarElement.viewHeader) {
//         //Provider.of<MapWidgetUpdate>(context, listen: false).calendarController.view = CalendarView.day;
//         print('일 캘린더가 나타나야함');
//         print('555');
//       } else if (calendarTapDetails.targetElement == CalendarElement.agenda) {
//         print('666 - 0');
//       } else if (calendarTapDetails.targetElement == CalendarElement.appointment) {
//         print('666 - 1'); // 주 에서 약속 클릭
//         final appointmentDetails = calendarTapDetails.appointments![0];
//
//         await updateProvider(appointmentDetails);
//         openModalBottomSheet(widgetContext, appointmentDetails);
//       } else if (calendarTapDetails.targetElement ==
//           CalendarElement.calendarCell) {
//         print('666 - 2');
//         final year = calendarTapDetails.date?.year;
//         final month = calendarTapDetails.date?.month;
//         final day = calendarTapDetails.date?.day;
//         final hour = calendarTapDetails.date?.hour;
//         final minute = calendarTapDetails.date?.minute;
//         // 일 - 7, 토 - 6
//
//         var fromDate = DateTime(
//           year!,
//           month!,
//           day!,
//           hour!,
//           (minute! / 5).round() * 5,
//         );
//
//         var toDate = DateTime(
//           year,
//           month,
//           day,
//           fromDate.add(Duration(minutes: 20)).hour,
//           (fromDate.add(Duration(minutes: 20)).minute / 5).round() * 5,
//         );
//         Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//             .updateFromDate(fromDate);
//         Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//             .updateToDate(toDate);
//       } else {
//         print('666 - 3');
//       }
//     } else if (Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
//         .calendarController
//         .view ==
//         CalendarView.day) {
//       print('777');
//
//       final year = calendarTapDetails.date?.year;
//       final month = calendarTapDetails.date?.month;
//       final day = calendarTapDetails.date?.day;
//       final day2 = calendarTapDetails.date?.weekday;
//       // 일 - 7, 토 - 6
//
//       var fromDate = DateTime(
//         year!,
//         month!,
//         day!,
//         DateTime.now().hour,
//         (DateTime.now().minute / 5).round() * 5,
//       );
//
//       var toDate = DateTime(
//         year,
//         month,
//         day,
//         DateTime.now().add(Duration(minutes: 20)).hour,
//         (DateTime.now().add(Duration(minutes: 20)).minute / 5).round() * 5,
//       );
//       Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//           .updateFromDate(fromDate);
//       Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//           .updateToDate(toDate);
//
//       String _segmentedButtonTitle =
//           Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
//               .segmentedButtonTitle;
//       Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
//           .updateCalendarView(_segmentedButtonTitle);
//
//       if (calendarTapDetails.targetElement == CalendarElement.viewHeader) {
//         print('777-1');
//         print(fromDate);
//         print(toDate);
//         Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
//             .calendarController
//             .view = CalendarView.day;
//
//         Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
//             .updateSegmentedButtonTitle('일');
//         Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
//             .updateCalendarView(
//             Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
//                 .segmentedButtonTitle);
//
//       } else if (calendarTapDetails.targetElement ==
//           CalendarElement.appointment) {
//         print('888');
//         final appointmentDetails = calendarTapDetails.appointments![0];
//
//         await updateProvider(appointmentDetails);
//         openModalBottomSheet(widgetContext, appointmentDetails);
//       } else if (calendarTapDetails.targetElement ==
//           CalendarElement.calendarCell) {
//         print('888 - 1');
//
//         final year = calendarTapDetails.date?.year;
//         final month = calendarTapDetails.date?.month;
//         final day = calendarTapDetails.date?.day;
//         final hour = calendarTapDetails.date?.hour;
//         final minute = calendarTapDetails.date?.minute;
//
//         var fromDate = DateTime(
//           year!,
//           month!,
//           day!,
//           hour!,
//           (minute! / 5).round() * 5,
//         );
//
//         var toDate = DateTime(
//           year,
//           month,
//           day,
//           fromDate.add(Duration(minutes: 20)).hour,
//           (fromDate.add(Duration(minutes: 20)).minute / 5).round() * 5,
//         );
//         Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//             .updateFromDate(fromDate);
//         Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//             .updateToDate(toDate);
//       } else {
//         print('888 - 2');
//       }
//     } else if (Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
//         .calendarController
//         .view ==
//         CalendarView.schedule) {
//       print('999');
//       print(calendarTapDetails.targetElement);
//
//       if (calendarTapDetails.targetElement == CalendarElement.appointment) {
//         final appointmentDetails = calendarTapDetails.appointments![0];
//
//         await updateProvider(appointmentDetails);
//         openModalBottomSheet(widgetContext, appointmentDetails);
//       }
//     } else {
//       print('1000');
//     }
//   }
//
//   Future<void> updateProvider(dynamic appointmentDetails) async {
//     Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//         .updateSubject(appointmentDetails.subject);
//     Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//         .updateFromDate(appointmentDetails.startTime);
//     Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//         .updateToDate(appointmentDetails.endTime);
//     Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//         .changeIsAllDay(appointmentDetails.isAllDay);
//     Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
//         .updateNotes(appointmentDetails.notes);
//   }
//
//   void openModalBottomSheet(BuildContext context, dynamic appointmentDetails) {
//     MoveToOtherScreen().persistentNavPushNewScreen(context, EditAppointment(
//         context: context, userCourt: '', oldMeeting: appointmentDetails), true, PageTransitionAnimation.slideUp,);
//   }
// }

class CustomSFCalendar extends StatelessWidget {
  CustomSFCalendar({required this.widgetContext});

  final BuildContext widgetContext;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Appointment>>(
      stream: Provider.of<CalendarScreenViewModel>(context).calendarListener(context),
      builder: (BuildContext context, AsyncSnapshot<List<Appointment>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: kCustomCircularProgressIndicator,
          ); // 데이터 로딩 중일 때 보여줄 위젯
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // 데이터 로딩 중 오류가 발생했을 때 보여줄 위젯
        } else {
          // 데이터가 성공적으로 로드되었을 때 보여줄 위젯
          List<Appointment> appointments = snapshot.data ?? [];
          return SfCalendar(
            view: CalendarView.month,
            selectionDecoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: kMainColor, width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(3)),
              shape: BoxShape.rectangle,
            ),
            todayHighlightColor: kMainColor,
            viewHeaderStyle: const ViewHeaderStyle(
              dayTextStyle: TextStyle(
                fontSize: 14,
              ),
            ),
            headerHeight: 45,
            headerStyle: const CalendarHeaderStyle(
                textAlign: TextAlign.left,
                textStyle: TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w500,
                ),
            ),
            controller:
            Provider.of<CalendarScreenViewModel>(context).calendarController,
            initialDisplayDate: DateTime.now(),
            initialSelectedDate: DateTime.now(),
            onTap: calendarTapped,
            dataSource: SFCalendarDataSource(appointments),
            timeSlotViewSettings: const TimeSlotViewSettings(
              timeTextStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                fontSize: 16,
              ),
              timeFormat: 'a h:mm',
              timeRulerSize: 65,
              dayFormat: 'EEE',
              timeInterval: Duration(minutes: 30),
              timeIntervalHeight: 70,
            ),

            scheduleViewSettings: const ScheduleViewSettings(
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
                  fontSize: 18,
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
                height: 0,
                textAlign: TextAlign.justify,
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
              agendaViewHeight: MediaQuery.of(context).size.height * 0.2, //180,
              monthCellStyle: MonthCellStyle(
                trailingDatesBackgroundColor: kMainColor.withOpacity(0.15),
                leadingDatesBackgroundColor: kMainColor.withOpacity(0.15),
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
                //backgroundColor: Colors.white,
                appointmentTextStyle: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.normal,
                ), //Color(0xFF0ffcc00)),
                dateTextStyle: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
                dayTextStyle: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            headerDateFormat: 'MMM yyy',
            appointmentTimeTextFormat: 'HH:mm',
            appointmentTextStyle: TextStyle(
                fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),
            onViewChanged: (ViewChangedDetails details) {
              List dates = details.visibleDates;
            },
            showDatePickerButton: true,
            showCurrentTimeIndicator: true,
            //allowViewNavigation: true,
            showTodayButton: true,
          );
        }
      },
    );
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    if (Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
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
        print("appointmentDetails recurrenceExceptionDates: ${appointmentDetails.recurrenceExceptionDates}");

        //print(appointmentDetails); // color 가 MaterialAccentColor(primary value: Color(0xff448aff)
        // 이면, 일반 일정이고, 다른 색상이면 공유되는 일정으로 표시해야함

        //Appointment? existingAppointment = meetings.firstWhere((element) => element.id == oldMeeting.id);

        if (appointmentDetails.recurrenceRule != null) {
          print('appointmentDetails.recurrenceRule != null, 반복 일정 O'); // 반복 일정 O

          await updateProvider(appointmentDetails);
          openModalBottomSheet(widgetContext, appointmentDetails);
        } else {
          print('appointmentDetails.recurrenceRule == null, 반복 일정 X'); // 반복 일정 X
          await updateProvider(appointmentDetails);
          openModalBottomSheet(widgetContext, appointmentDetails);
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
        Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
            .updateFromDate(fromDate);
        Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
            .updateToDate(toDate);
      } else {
        print('333-2');
      }
    } else if (Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
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
      } else if (calendarTapDetails.targetElement == CalendarElement.appointment) {
        print('666 - 1'); // 주 에서 약속 클릭
        final appointmentDetails = calendarTapDetails.appointments![0];

        await updateProvider(appointmentDetails);
        openModalBottomSheet(widgetContext, appointmentDetails);
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
        Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
            .updateFromDate(fromDate);
        Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
            .updateToDate(toDate);
      } else {
        print('666 - 3');
      }
    } else if (Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
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
      Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
          .updateFromDate(fromDate);
      Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
          .updateToDate(toDate);

      String _segmentedButtonTitle =
          Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
              .segmentedButtonTitle;
      Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
          .updateCalendarView(_segmentedButtonTitle);

      if (calendarTapDetails.targetElement == CalendarElement.viewHeader) {
        print('777-1');
        print(fromDate);
        print(toDate);
        Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
            .calendarController
            .view = CalendarView.day;

        Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
            .updateSegmentedButtonTitle('일');
        Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
            .updateCalendarView(
            Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
                .segmentedButtonTitle);

      } else if (calendarTapDetails.targetElement ==
          CalendarElement.appointment) {
        print('888');
        final appointmentDetails = calendarTapDetails.appointments![0];

        await updateProvider(appointmentDetails);
        openModalBottomSheet(widgetContext, appointmentDetails);
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
        Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
            .updateFromDate(fromDate);
        Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
            .updateToDate(toDate);
      } else {
        print('888 - 2');
      }
    } else if (Provider.of<CalendarScreenViewModel>(widgetContext, listen: false)
        .calendarController
        .view ==
        CalendarView.schedule) {
      print('999');
      print(calendarTapDetails.targetElement);

      if (calendarTapDetails.targetElement == CalendarElement.appointment) {
        final appointmentDetails = calendarTapDetails.appointments![0];

        await updateProvider(appointmentDetails);
        openModalBottomSheet(widgetContext, appointmentDetails);
      }
    } else {
      print('1000');
    }
  }

  Future<void> updateProvider(dynamic appointmentDetails) async {
    await Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
        .updateSubject(appointmentDetails.subject);
    await Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
        .updateFromDate(appointmentDetails.startTime);
    await Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
        .updateToDate(appointmentDetails.endTime);
    await Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
        .updateId(appointmentDetails.id);
    await Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
        .updateColor(appointmentDetails.color);
    await Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
        .changeIsAllDay(appointmentDetails.isAllDay);
    await Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
        .updateNotes(appointmentDetails.notes);
    await Provider.of<PersonalAppointmentUpdate>(widgetContext, listen: false)
        .updateRecurrenceExceptionDate(appointmentDetails.recurrenceExceptionDates);
  }

  void openModalBottomSheet(BuildContext context, dynamic appointmentDetails) {
    MoveToOtherScreen().persistentNavPushNewScreen(context, EditAppointment(
        context: context, userCourt: '', oldMeeting: appointmentDetails), true, PageTransitionAnimation.slideUp,);
  }

}
