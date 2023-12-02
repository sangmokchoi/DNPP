import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AppointmentUpdate extends ChangeNotifier {
  void updateSegmentedButtonTitle(String title) {
    segmentedButtonTitle = title;
    notifyListeners();
  }

  final CalendarController calendarController = CalendarController();
  String segmentedButtonTitle = '월';

  List<Appointment> meetings = <Appointment>[
    Appointment(
        subject: '',
        notes: '',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 1)),
        recurrenceRule: ''),
    Appointment(
        subject: '',
        notes: '',
        startTime: DateTime.now().add(Duration(days: 1)),
        endTime: DateTime.now().add(Duration(days: 1, hours: 1)),
        recurrenceRule: ''),
    Appointment(
        subject: '',
        notes: '',
        startTime: DateTime.now().add(Duration(days: 2)),
        endTime: DateTime.now().add(Duration(days: 2, hours: 1)),
        recurrenceRule: ''),
  ];
  String subject = '';

  var fromDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().hour,
    (DateTime.now().minute / 5).round() * 5,
  );

  var toDate = DateTime(
    DateTime.now().add(Duration(minutes: 20)).year,
    DateTime.now().add(Duration(minutes: 20)).month,
    DateTime.now().add(Duration(minutes: 20)).day,
    DateTime.now().add(Duration(minutes: 20)).hour,
    (DateTime.now().add(Duration(minutes: 20)).minute / 5).round() * 5,
  );

  Color color = Colors.blueAccent;
  bool isOpened = false;
  bool isAllDay = false;

  String notes = '';
  String repeatString = '반복 안 함';
  String recurrenceRule = '';
  bool repeatNo = true;
  bool repeatEveryDay = false;
  bool repeatEveryWeek = false;
  bool repeatEveryMonth = false;
  bool repeatEveryYear = false;

  int repeatTimes = 1;

  void updateCalendarView(String calendarTitle) {
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

  Future<void> clear() async {
    subject = '';
    fromDate = fromDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
      (DateTime.now().minute / 5).round() * 5,
    );
    toDate = DateTime(
      DateTime.now().add(Duration(minutes: 20)).year,
      DateTime.now().add(Duration(minutes: 20)).month,
      DateTime.now().add(Duration(minutes: 20)).day,
      DateTime.now().add(Duration(minutes: 20)).hour,
      (DateTime.now().add(Duration(minutes: 20)).minute / 5).round() * 5,
    );
    color = Colors.blueAccent;
    isOpened = false;
    isAllDay = false;
    notes = '';
    repeatString = '반복 안 함';
    repeatNo = true;
    repeatEveryDay = false;
    repeatEveryWeek = false;
    repeatEveryMonth = false;
    repeatEveryYear = false;
    recurrenceRule = '';

    repeatTimes = 1;

    notifyListeners();
  }

  Future<void> updateSubject(String value) async {
    subject = value;
    notifyListeners();
  }

  void updateFromDate(DateTime value) {
    fromDate = value;
    notifyListeners();
  }

  void updateToDate(DateTime value) {
    toDate = value;
    notifyListeners();
  }

  void updateColor(Color value) {
    color = value;
    notifyListeners();
  }

  void updateNotes(String value) {
    notes = value;
    notifyListeners();
  }

  Future<void> updateRepeat(String value) async {
    if (value == '매일') {
      if (repeatEveryDay == true) {
      } else {
        repeatString = value;

        repeatEveryDay = !repeatEveryDay;
        repeatEveryWeek = false;
        repeatEveryMonth = false;
        repeatEveryYear = false;
        repeatNo = false;
      }
    } else if (value == '매주') {
      if (repeatEveryWeek == true) {
      } else {
        repeatString = value;

        repeatEveryDay = false;
        repeatEveryWeek = !repeatEveryWeek;
        repeatEveryMonth = false;
        repeatEveryYear = false;
        repeatNo = false;
      }
    } else if (value == '매월') {
      if (repeatEveryMonth == true) {
      } else {
        repeatString = value;

        repeatEveryDay = false;
        repeatEveryWeek = false;
        repeatEveryMonth = !repeatEveryMonth;
        repeatEveryYear = false;
        repeatNo = false;
      }
    } else if (value == '매년') {
      if (repeatEveryYear == true) {
      } else {
        repeatString = value;

        repeatEveryDay = false;
        repeatEveryWeek = false;
        repeatEveryMonth = false;
        repeatEveryYear = !repeatEveryYear;
        repeatNo = false;
      }
    } else if (value == '반복 안 함') {
      if (repeatNo == true) {
      } else {
        repeatString = value;

        repeatEveryDay = false;
        repeatEveryWeek = false;
        repeatEveryMonth = false;
        repeatEveryYear = false;
        repeatNo = !repeatNo;
      }
    }
    notifyListeners();
  }

  Future<void> updateRecurrenceRules(String repeatString, int value) async {
    final weekday = DateFormat('EEE').format(fromDate).toUpperCase();
    String twoWeekday = weekday.substring(0, 2);

    if (repeatString == '매일') {
      recurrenceRule = 'FREQ=DAILY;INTERVAL=1;COUNT=$value';
      notifyListeners();
      print('recurrenceRule: $recurrenceRule');
    } else if (repeatString == '매주') {
      recurrenceRule = 'FREQ=WEEKLY;INTERVAL=1;BYDAY=$twoWeekday;COUNT=$value';
      notifyListeners();
      print('recurrenceRule: $recurrenceRule');
    } else if (repeatString == '매월') {
      recurrenceRule =
      'FREQ=MONTHLY;BYMONTHDAY=${fromDate.day};INTERVAL=1;COUNT=$value';
      notifyListeners();
      print('recurrenceRule: $recurrenceRule');
    } else if (repeatString == '매년') {
      recurrenceRule =
      'FREQ=YEARLY;BYMONTHDAY=${fromDate.day};BYMONTH=${fromDate.month};INTERVAL=1;COUNT=$value';
      notifyListeners();
      print('recurrenceRule: $recurrenceRule');
    } else if (repeatString == '반복 안 함') {
      recurrenceRule = '';
    }
    repeatTimes = value;
    notifyListeners();

    print(repeatTimes);
  }

  void updateIsOpened() {
    isOpened = !isOpened;
    notifyListeners();
  }

  void updateIsAllDay() {
    isAllDay = !isAllDay;
    notifyListeners();
  }

  void changeIsOpened(bool value) {
    isOpened = value;
    notifyListeners();
  }

  void changeIsAllDay(bool value) {
    isAllDay = value;
    notifyListeners();
  }

  Future<void> addMeeting(Appointment meeting) async {
    meetings.add(meeting);
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> addRecurrenceExceptionDates(Appointment oldMeeting,
      Appointment newMeeting, bool onlyThisAppointment, bool isDeletion) async {
    Appointment? existingAppointment =
    meetings.firstWhere((element) => element.id == oldMeeting.id);

    final DateTime exceptionDate =
    DateTime(fromDate.year, fromDate.month, fromDate.day);

    if (existingAppointment != null) {
      print(11111);
      if (newMeeting.recurrenceRule != '') {
        // 반복되는 일정으로 변경하고자 함
        print(22222);
        if (onlyThisAppointment != true) {
          // 전체 반복일정을 변경하는 경우
          print(33333);
          existingAppointment.startTime = DateTime(
            newMeeting.startTime.year,
            newMeeting.startTime.month,
            newMeeting.startTime.day,
            newMeeting.startTime.hour,
            newMeeting.startTime.minute,
          );

          existingAppointment.endTime = DateTime(
            newMeeting.endTime.year,
            newMeeting.endTime.month,
            newMeeting.endTime.day,
            newMeeting.endTime.hour,
            newMeeting.endTime.minute,
          );
          existingAppointment.subject = newMeeting.subject;
          existingAppointment.color = newMeeting.color;
          existingAppointment.isAllDay = newMeeting.isAllDay;
          existingAppointment.notes = newMeeting.notes;
          existingAppointment.recurrenceRule = newMeeting.recurrenceRule;

          // meetings.removeWhere((element) => element.id == oldMeeting.id);
          // meetings.add(newMeeting);
        } else {
          // 해당 반복일정만 변경하는 경우 // onlyThisAppointment == true
          print(44444);
          if (existingAppointment.recurrenceExceptionDates == null) {
            // recurrenceExceptionDates가 이전에 설정된 적 없음
            existingAppointment.recurrenceExceptionDates = [exceptionDate];
          } else {
            // recurrenceExceptionDates가 이전에 설정된 적 있음
            existingAppointment.recurrenceExceptionDates?.add(exceptionDate);
          }

          newMeeting.recurrenceRule = '';
          newMeeting.recurrenceId = existingAppointment.id;

          if (isDeletion == true) {
            // 삭제하려는 경우
          } else {
            // 변경만 하는 경우
            //meetings.removeWhere((element) => element.id == oldMeeting.id);
            meetings.add(newMeeting);
          }
        }
      } else {
        // 반복되지 않는 일정으로 저장
        print(55555);
        existingAppointment.startTime = DateTime(
          newMeeting.startTime.year,
          newMeeting.startTime.month,
          newMeeting.startTime.day,
          newMeeting.startTime.hour,
          newMeeting.startTime.minute,
        );

        existingAppointment.endTime = DateTime(
          newMeeting.endTime.year,
          newMeeting.endTime.month,
          newMeeting.endTime.day,
          newMeeting.endTime.hour,
          newMeeting.endTime.minute,
        );

        existingAppointment.subject = newMeeting.subject;
        existingAppointment.color = newMeeting.color;
        existingAppointment.isAllDay = newMeeting.isAllDay;
        existingAppointment.notes = newMeeting.notes;

        existingAppointment.recurrenceExceptionDates?.clear();
        existingAppointment.recurrenceRule = '';

        //meetings.add(newMeeting);
      }

      newMeeting.color = Colors.pinkAccent;

      await Future.delayed(Duration.zero);
      notifyListeners();
    }
  }

  Future<void> removeMeeting(Appointment oldMeeting) async {
    meetings.removeWhere((element) => element.id == oldMeeting.id);
    //meetings.remove(oldMeeting);
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> updateMeeting(
      Appointment oldMeeting, Appointment newMeeting) async {
    meetings.removeWhere((element) => element.id == oldMeeting.id);
    await Future.delayed(Duration.zero); // 비동기적으로 처리하도록 함
    meetings.add(newMeeting);
    notifyListeners();
  }

  // 각 요일별로 기간을 저장할 Map
  Map<String, double> daywiseDurations = {};
  Map<String, double> last7DaysDurations = {};
  Map<String, double> last28DaysDurations = {};
  Map<String, double> last3MonthsDurations = {};

  Map<int, double> hourlyCounts = {};
  Map<int, double> last7DaysHourlyCounts = {};
  Map<int, Map<int, double>> last7DaysHourlyCountsByDaysOfWeek = {};

  Map<int, double> last28DaysHourlyCounts = {};
  Map<int, Map<int, double>> last28DaysHourlyCountsByDaysOfWeek = {};

  Map<int, double> last3MonthsHourlyCounts = {};
  Map<int, Map<int, double>> last3MonthsHourlyCountsByDaysOfWeek = {};

  Future<void> countHours(bool isInitial) async {
    // hourlyCounts.clear();
    // last7DaysHourlyCounts.clear();
    // last7DaysHourlyCountsByDaysOfWeek.clear();
    // last28DaysHourlyCounts.clear();
    // last28DaysHourlyCountsByDaysOfWeek.clear();
    // last3MonthsHourlyCounts.clear();
    // last3MonthsHourlyCountsByDaysOfWeek.clear();

    // 모든 시간대의 카운트를 저장할 맵
    DateTime currentDate = DateTime.now();

    // 각 약속에서 startTime부터 endTime까지의 모든 시간을 추출하고 카운트
    for (var appointment in meetings) {
      if (appointment.startTime
          .isAfter(currentDate.subtract(Duration(days: 7))) &&
          appointment.endTime.isBefore(currentDate)) {
        DateTime startTime = appointment.startTime;
        DateTime endTime = appointment.endTime;

        while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) { //(startTime.hour <= endTime.hour)
          int hour = startTime.hour;
          int dayOfWeek = startTime.weekday;
          last7DaysHourlyCounts[hour] = (last7DaysHourlyCounts[hour] ?? 0) + 1;

          last7DaysHourlyCountsByDaysOfWeek[dayOfWeek] =
          (last7DaysHourlyCountsByDaysOfWeek[dayOfWeek] ?? {})
            ..update(
              hour,
                  (value) => value + 1,
              ifAbsent: () => 1.0, // 여기를 1로 해서 double 타입으로 변경
            );
          //print('dayOfWeek: ${dayOfWeek}');
          //print('last7DaysHourlyCountsByDaysOfWeek[dayOfWeek]: ${last7DaysHourlyCountsByDaysOfWeek[dayOfWeek]}');

          startTime = startTime.add(Duration(hours: 1));

        }

        if (isInitial == true) {
          hourlyCounts = last7DaysHourlyCounts;
        }
      }

      if (appointment.startTime
          .isAfter(currentDate.subtract(Duration(days: 28))) &&
          appointment.endTime.isBefore(currentDate)) {
        DateTime startTime = appointment.startTime;
        DateTime endTime = appointment.endTime;

        while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) { //(startTime.hour <= endTime.hour)
          int hour = startTime.hour;
          int dayOfWeek = startTime.weekday;
          last28DaysHourlyCounts[hour] =
              (last28DaysHourlyCounts[hour] ?? 0) + 1;

          last28DaysHourlyCountsByDaysOfWeek[dayOfWeek] =
          (last28DaysHourlyCountsByDaysOfWeek[dayOfWeek] ?? {})
            ..update(
              hour,
                  (value) => value + 1,
              ifAbsent: () => 1.0, // 여기를 1로 해서 double 타입으로 변경
            );

          startTime = startTime.add(Duration(hours: 1));

        }

        // if (isInitial == true) {
        //   hourlyCounts = last28DaysHourlyCounts;
        // }
      }

      if (appointment.startTime
          .isAfter(currentDate.subtract(Duration(days: 90))) &&
          appointment.endTime.isBefore(currentDate)) {
        DateTime startTime = appointment.startTime;
        DateTime endTime = appointment.endTime;

        while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) { //(startTime.hour <= endTime.hour)
          int hour = startTime.hour;
          int dayOfWeek = startTime.weekday;
          last3MonthsHourlyCounts[hour] =
              (last3MonthsHourlyCounts[hour] ?? 0) + 1;

          last3MonthsHourlyCountsByDaysOfWeek[dayOfWeek] =
          (last3MonthsHourlyCountsByDaysOfWeek[dayOfWeek] ?? {})
            ..update(
              hour,
                  (value) => value + 1,
              ifAbsent: () => 1.0, // 여기를 1로 해서 double 타입으로 변경
            );

          startTime = startTime.add(Duration(hours: 1));

        }
      }

      // if (isInitial == true) {
      //   hourlyCounts = last3MonthsHourlyCounts;
      // }
    }

    notifyListeners();
  }

  int recentDays = -1;
  void updateRecentDays(int index){
    recentDays = index;
    notifyListeners();
  }

  final isSelected = <bool>[true, false, false];

  Future<void> updateLast7DaysHourlyCounts() async {
    hourlyCounts = last7DaysHourlyCounts;
    print('hourlyCounts: $hourlyCounts');
    notifyListeners();
  }

  Future<void> updateLast28DaysHourlyCounts() async {
    hourlyCounts = last28DaysHourlyCounts;
    print('hourlyCounts: $hourlyCounts');
    notifyListeners();
  }

  Future<void> updateLast3MonthsHourlyCounts() async {
    hourlyCounts = last3MonthsHourlyCounts;
    print('hourlyCounts: $hourlyCounts');
    notifyListeners();
  }
  void updateMainLineChart() {
    notifyListeners();
  }

  Future<void> updateLast7DaysHourlyCountsByDaysOfWeek(int value) async {
    hourlyCounts = last7DaysHourlyCountsByDaysOfWeek[value] ?? {};
    print('updateLast7DaysHourlyCountsByDaysOfWeek hourlyCounts: $hourlyCounts');
    notifyListeners();
  }

  Future<void> updateLast28DaysHourlyCountsByDaysOfWeek(int value) async {
    hourlyCounts = last28DaysHourlyCountsByDaysOfWeek[value] ?? {};
    print('updateLast28DaysHourlyCountsByDaysOfWeek hourlyCounts: $hourlyCounts');
    notifyListeners();
  }

  Future<void> updateLast3MonthsHourlyCountsByDaysOfWeek(int value) async {
    hourlyCounts = last3MonthsHourlyCountsByDaysOfWeek[value] ?? {};
    print('updateLast3MonthsHourlyCountsByDaysOfWeek hourlyCounts: $hourlyCounts');
    notifyListeners();
  }

  double calculateAverageY() {
    if (daywiseDurations.isEmpty) {
      return 0.0; // Return 0 if the map is empty to avoid division by zero.
    }

    double sum = 0.0;
    double max = 0.0;

    hourlyCounts.forEach((hour, counts) {
      sum += counts;
      if (counts >= max) {
        max = counts;
      }
    });

    return max; //sum / daywiseDurations.length;
  }

  Future<void> updateLast7DaysDurations() async {
    daywiseDurations = last7DaysDurations;
    notifyListeners();
  }

  Future<void> updateLast28DaysDurations() async {
    daywiseDurations = last28DaysDurations;
    notifyListeners();
  }

  Future<void> updateLast3MonthsDurations() async {
    daywiseDurations = last3MonthsDurations;
    notifyListeners();
  }

  Future<void> updateChart(int index) async {

    if (index == 0){
      isSelected[0] = true;
      isSelected[1] = false;
      isSelected[2] = false;

      updateLast7DaysDurations();
      updateLast7DaysHourlyCounts();
      updateRecentDays(index);

    } else if (index == 1) {
      isSelected[0] = false;
      isSelected[1] = true;
      isSelected[2] = false;

      updateLast28DaysDurations();
      updateLast28DaysHourlyCounts();
      updateRecentDays(index);
    } else if (index == 2) {
      isSelected[0] = false;
      isSelected[1] = false;
      isSelected[2] = true;

      updateLast3MonthsDurations();
      updateLast3MonthsHourlyCounts();
      updateRecentDays(index);
    }

  }

  Future<void> daywiseDurationsCalculate(bool isInitial) async {
    print('daywiseDurationsCalculate');

    DateTime currentDate = DateTime.now();

    // meetings 리스트의 각 Appointment 객체에 대해 endTime - startTime의 합산 수행
    for (Appointment appointment in meetings) {
      // 해당 Appointment의 시작일의 요일을 구함 (예: "Monday", "Tuesday", 등)
      String dayOfWeek = DateFormat('EEE', 'ko').format(appointment.startTime);

      if (appointment.startTime
          .isAfter(currentDate.subtract(Duration(days: 7))) &&
          appointment.endTime.isBefore(currentDate)) {
// Map에 이미 해당 요일이 있는지 확인하고 없으면 추가, 있으면 누적
        if (last7DaysDurations.containsKey(dayOfWeek)) {
          final double previousDuration = last7DaysDurations[dayOfWeek] ?? 0.0;
          final double timeDifference = previousDuration +
              appointment.endTime
                  .difference(appointment.startTime)
                  .inMilliseconds
                  .toDouble() /
                  1000000;

          last7DaysDurations[dayOfWeek] = timeDifference;
        } else {
          final timeDifference =
          appointment.endTime.difference(appointment.startTime);
          last7DaysDurations[dayOfWeek] =
              timeDifference.inMilliseconds.toDouble() / 1000000;
        }

        if (isInitial == true) {
          daywiseDurations = last7DaysDurations;
        }
      }

      if (appointment.startTime
          .isAfter(currentDate.subtract(Duration(days: 27))) &&
          appointment.endTime.isBefore(currentDate)) {
        if (last28DaysDurations.containsKey(dayOfWeek)) {
          final double previousDuration = last28DaysDurations[dayOfWeek] ?? 0.0;
          final double timeDifference = previousDuration +
              appointment.endTime
                  .difference(appointment.startTime)
                  .inMilliseconds
                  .toDouble() /
                  1000000;

          last28DaysDurations[dayOfWeek] = timeDifference;
        } else {
          final timeDifference =
          appointment.endTime.difference(appointment.startTime);
          last28DaysDurations[dayOfWeek] =
              timeDifference.inMilliseconds.toDouble() / 1000000;
        }

        // if (isInitial == true) {
        //   daywiseDurations = last28DaysDurations;
        // }
      }

      if (appointment.startTime
          .isAfter(currentDate.subtract(Duration(days: 90))) &&
          appointment.endTime.isBefore(currentDate)) {
        if (last3MonthsDurations.containsKey(dayOfWeek)) {
          final double previousDuration =
              last3MonthsDurations[dayOfWeek] ?? 0.0;
          final double timeDifference = previousDuration +
              appointment.endTime
                  .difference(appointment.startTime)
                  .inMilliseconds
                  .toDouble() /
                  1000000;

          last3MonthsDurations[dayOfWeek] = timeDifference;
        } else {
          final timeDifference =
          appointment.endTime.difference(appointment.startTime);
          last3MonthsDurations[dayOfWeek] =
              timeDifference.inMilliseconds.toDouble() / 1000000;
        }

        // if (isInitial == true) {
        //   daywiseDurations = last3MonthsDurations;
        // }
      }

      // // Map에 이미 해당 요일이 있는지 확인하고 없으면 추가, 있으면 누적
      // if (daywiseDurations.containsKey(dayOfWeek)) {
      //   // daywiseDurations[dayOfWeek] += appointment.endTime.difference(appointment.startTime);
      //
      //   final double previousDuration = daywiseDurations[dayOfWeek] ?? 0.0;
      //   final double timeDifference = previousDuration +
      //       appointment.endTime.difference(appointment.startTime).inMilliseconds.toDouble() / 1000000;
      //
      //   // final Duration timeDifference = (daywiseDurations[dayOfWeek] ?? Duration.zero) +
      //   //     appointment.endTime.difference(appointment.startTime);
      //
      //   daywiseDurations[dayOfWeek] = timeDifference;
      //
      // } else {
      //   final timeDifference = appointment.endTime.difference(appointment.startTime);
      //   daywiseDurations[dayOfWeek] = timeDifference.inMilliseconds.toDouble() / 1000000;
      // }
    }

    print("daywiseDurations: $daywiseDurations");
    print("last7DaysDurations: $last7DaysDurations");
    print("last28DaysDurations: $last28DaysDurations");
    print("last3MonthsDurations: $last3MonthsDurations");
    notifyListeners();
  }

  double calculateAverage() {
    if (daywiseDurations.isEmpty) {
      return 0.0; // Return 0 if the map is empty to avoid division by zero.
    }

    double sum = 0.0;
    double max = 0.0;

    daywiseDurations.forEach((day, duration) {
      sum += duration;
      if (duration >= max) {
        max = duration;
      }
    });

    return max; //sum / daywiseDurations.length;
  }
}