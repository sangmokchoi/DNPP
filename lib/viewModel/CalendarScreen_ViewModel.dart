
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../constants.dart';
import '../models/customAppointment.dart';
import '../statusUpdate/loginStatusUpdate.dart';

class CalendarScreenViewModel extends ChangeNotifier {

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  List<Appointment> appointments = [];

  final List<String> _list = ['전체', '월', '주', '일'];

  Widget SingleChoice(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary,
            //spreadRadius: 5,
            blurRadius: 1,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: SegmentedButton<String>(
        segments: <ButtonSegment<String>>[
          ButtonSegment<String>(
              value: _list[0],
              label: Text(_list[0]),
              icon: Icon(Icons.calendar_today_rounded)),// icon: Icon(Icons.schedule)),
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
          segmentedButtonTitle
        }, //<String>{_selected},
        onSelectionChanged: (newSelection) async {
          debugPrint("$newSelection");

          await updateSegmentedButtonTitle(newSelection.first);
          await updateCalendarView(newSelection.first);
          //notifyListeners();
        },
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(
              fontSize: 16,
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
                return Theme.of(context).colorScheme.secondary;
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

  final CalendarController calendarController = CalendarController();
  String segmentedButtonTitle = '월';

  Future<void> updateSegmentedButtonTitle(String title) async {
    segmentedButtonTitle = title;
    notifyListeners();
    debugPrint('segmentedButtonTitle: $segmentedButtonTitle');
  }

  Future<void> updateCalendarView(String calendarTitle) async {
    if (calendarTitle == '월') {
      calendarController.view = CalendarView.month;
      segmentedButtonTitle = calendarTitle;
      debugPrint(calendarTitle);
    } else if (calendarTitle == '주') {
      calendarController.view = CalendarView.week;
      segmentedButtonTitle = calendarTitle;
      debugPrint(calendarTitle);
    } else if (calendarTitle == '일') {
      calendarController.view = CalendarView.day;
      segmentedButtonTitle = calendarTitle;
      debugPrint(calendarTitle);
    } else if ((calendarTitle == '전체')) {
      calendarController.view = CalendarView.schedule;
      segmentedButtonTitle = calendarTitle;
      debugPrint(calendarTitle);
    } else {
      debugPrint('calendarController.view else');
    }
    notifyListeners();
  }

  Future<void> notify() async {
    notifyListeners();
    debugPrint('notify');
  }

  Future<void> resetAppointments() async {
    appointments.clear();
    notifyListeners();
  }

  Stream<List<Appointment>> calendarListener(BuildContext context) {

    debugPrint('calendarListener 진입');

    final currentUser = auth.currentUser;

    if (currentUser != null) {
    // if (Provider
    //     .of<LoginStatusUpdate>(context, listen: false)
    //     .currentUser != null) {
      final docRef = db.collection("Appointments").where("userUid",
          isEqualTo: currentUser.uid);

      return docRef.snapshots().map((snapshot) {

        // List<Appointment>
        appointments = [];

        snapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // 예약된 모든 약속을 가져와서 리스트에 추가합니다.
          List<dynamic> appointmentsData = data['appointments'];

          appointmentsData.forEach((appointmentData) {

            List<DateTime> recurrenceExceptionDates = (appointmentData['recurrenceExceptionDates'] as List<dynamic>?)
                ?.cast<Timestamp>()
                ?.map((timestamp) => timestamp.toDate())
                ?.toList() ?? [];

            Appointment appointment = Appointment(
              startTime: appointmentData['startTime'].toDate(),
              endTime: appointmentData['endTime'].toDate(),
              isAllDay: appointmentData['isAllDay'] as bool,
              id: appointmentData['id'] as Object?,
              color: Color(appointmentData['color']).withOpacity(1),
              notes: appointmentData['notes'] as String,
              recurrenceId: appointmentData['recurrenceId'] as String?,
              recurrenceRule: appointmentData['recurrenceRule'] as String?,
              subject: appointmentData['subject'] as String,
              recurrenceExceptionDates: recurrenceExceptionDates,//appointmentData['recurrenceExceptionDates'] as List<DateTime>?,
            );
            appointments.add(appointment);
          });

        });
        return appointments;
      });
    } else {
      return Stream.empty();
    }
  }

}
