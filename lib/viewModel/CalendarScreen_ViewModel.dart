
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../constants.dart';
import '../models/customAppointment.dart';

class CalendarScreenViewModel extends ChangeNotifier {

  final List<String> _list = ['전체', '월', '주', '일'];

  Widget SingleChoice(BuildContext context) {
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
          segmentedButtonTitle
        }, //<String>{_selected},
        onSelectionChanged: (newSelection) async {
          print(newSelection);

          await updateSegmentedButtonTitle(newSelection.first);
          await updateCalendarView(newSelection.first);
          notifyListeners();
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

  final CalendarController calendarController = CalendarController();
  String segmentedButtonTitle = '월';

  Future<void> updateSegmentedButtonTitle(String title) async {
    segmentedButtonTitle = title;
    notifyListeners();
    print('segmentedButtonTitle: $segmentedButtonTitle');
  }

  Future<void> updateCalendarView(String calendarTitle) async {
    if (calendarTitle == '월') {
      calendarController.view = CalendarView.month;
      segmentedButtonTitle = calendarTitle;
      print(calendarTitle);
    } else if (calendarTitle == '주') {
      calendarController.view = CalendarView.week;
      segmentedButtonTitle = calendarTitle;
      print(calendarTitle);
    } else if (calendarTitle == '일') {
      calendarController.view = CalendarView.day;
      segmentedButtonTitle = calendarTitle;
      print(calendarTitle);
    } else if ((calendarTitle == '전체')) {
      calendarController.view = CalendarView.schedule;
      segmentedButtonTitle = calendarTitle;
      print(calendarTitle);
    } else {
      print('calendarController.view else');
    }
    notifyListeners();
  }
}
