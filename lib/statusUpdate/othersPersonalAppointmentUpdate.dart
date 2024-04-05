import 'package:dnpp/models/customAppointment.dart';

import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../constants.dart';

class OthersPersonalAppointmentUpdate extends ChangeNotifier {

  final CalendarController calendarController = CalendarController();

  List<CustomAppointment> customAppointmentMeetings = <CustomAppointment>[];
  List<CustomAppointment> othersCustomAppointmentMeetings = <CustomAppointment>[];
  List<String> extractCustomAppointmentsUserUids = [];

  List<Appointment> newMeetings = [];
  List<Appointment> defaultMeetings = <Appointment>[];

  List<CustomAppointment> extractCustomAppointmentsByCourtAndHour(
      List<CustomAppointment> _appointmentMeetings,
      String title,
      String roadAddress,
      Map<int, Map<int, double>> last28DaysHourlyCountsByDaysOfWeek,
      ) {


    return _appointmentMeetings
        .where((customAppointment) =>
        customAppointment.pingpongCourtName == title &&
        customAppointment.pingpongCourtAddress == roadAddress)

        .where((customAppointment) =>
        customAppointment.appointments.any((appointment) {
          // startTime에서 hour 추출
          int startDayOfWeek = customAppointment.appointments[0].startTime.weekday;
          int startHour = customAppointment.appointments[0].startTime.hour;
          //print('extractCustomAppointmentsByCourtAndHour startDayOfWeek: $startDayOfWeek');
          //print('extractCustomAppointmentsByCourtAndHour startHour: $startHour');
          //last28DaysHourlyCountsByDaysOfWeek {5: {17: 3.0, 20: 1.0}, 3: {17: 9.0, 16: 1.0, 20: 1.0}, 6: {0: 1.0}, 4: {17: 1.0, 0: 1.0}, 2: {15: 1.0}}
          // 시간대 별 구하는 것 뿐만 아니라 요일별로 구해야함

          // last28DaysHourlyCountsByDaysOfWeek의 int값과 동일한 경우만 선택
          // last28DaysHourlyCountsByDaysOfWeek의 요일별로 동일한 시간대를 가지는 경우만 선택
          return initialLast28DaysHourlyCountsByDaysOfWeek.containsKey(startDayOfWeek) &&
              initialLast28DaysHourlyCountsByDaysOfWeek[startDayOfWeek]!.containsKey(startHour);
        }))
        .toList();
  }

  List<Appointment> extractAppointmentsByCourt(
      List<CustomAppointment> _appointmentMeetings,
      String title,
      String roadAddress) {
    return _appointmentMeetings
        .where((customAppointment) =>
        customAppointment.pingpongCourtName == title &&
        customAppointment.pingpongCourtAddress == roadAddress)
        .map((customAppointment) => customAppointment.appointments)
        .expand((appointments) => appointments)
        .toList();
  }

  List<String> pingpongCourtNameList = [];
  List<String> pingpongCourtAddressList = [];

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

  Color color = Color.fromRGBO(33, 150, 243, 1.0);

//Color(0xFF2196F3);
  //Color d = kMainColor;
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
    color = kMainColor;
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

  Future<void> addCustomMeeting(CustomAppointment customMeeting) async {
    customAppointmentMeetings.add(customMeeting);
    
    notifyListeners();
  }

  Future<void> updateDefaultMeetings(List<Appointment> list) async {
    defaultMeetings = list;
    
    notifyListeners();
    //print('defaultMeetings: $defaultMeetings');
  }

  Future<void> addMeeting(Appointment meeting) async {
    defaultMeetings.add(meeting);
    
    notifyListeners();
  }

  Future<void> addRecurrenceExceptionDates(Appointment oldMeeting,
      Appointment newMeeting, bool onlyThisAppointment, bool isDeletion) async {
    Appointment? existingAppointment =
    defaultMeetings.firstWhere((element) => element.id == oldMeeting.id);

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
            defaultMeetings.add(newMeeting);
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

      
      notifyListeners();
    }
  }

  Future<void> removeMeeting(Appointment oldMeeting) async {
    defaultMeetings.removeWhere((element) => element.id == oldMeeting.id);
    //meetings.remove(oldMeeting);
    
    notifyListeners();
  }

  Future<void> updateMeeting(Appointment oldMeeting, Appointment newMeeting) async {

    final index = defaultMeetings.indexWhere((element) => element.id == oldMeeting.id);
    if (index != -1) {
      // If the oldMeeting is found in the list
      defaultMeetings[index] = oldMeeting;
      print('defaultMeetings[index]: ${defaultMeetings[index].id}');
      notifyListeners();
    } else {
      // Handle the case where the oldMeeting is not found
      print("Error: oldMeeting not found in the list.");
    }
  }


  // 각 요일별로 기간을 저장할 Map
  Map<String, double> daywiseDurations = {};
  Map<String, double> last28DaysDurations = {};

  Map<int, double> hourlyCounts = {};
  Map<int, double> last28DaysHourlyCounts = {};
  Map<int, Map<int, double>> initialLast28DaysHourlyCountsByDaysOfWeek = {};
  Map<int, Map<int, double>> last28DaysHourlyCountsByDaysOfWeek = {};

  final isSelected = <bool>[false, true, false, false];
  final isSelectedString = <String>['최근 7일', '최근 28일', '최근 90일', '앞으로 1개월'];

  Future<void> updateLast28DaysHourlyCounts() async {
    hourlyCounts = last28DaysHourlyCounts;
    //print('last28DaysHourlyCounts hourlyCounts: $hourlyCounts');
    notifyListeners();
  }

  Future<void> updateLast28DaysHourlyCountsByDaysOfWeek(int value) async {
    int newValue = value + 1;
    hourlyCounts = last28DaysHourlyCountsByDaysOfWeek[newValue] ?? {};
     print(
        '다른 유저 updateLast28DaysHourlyCountsByDaysOfWeek hourlyCounts: $hourlyCounts');
    notifyListeners();
  }

  double calculateAverageY() {
    if (daywiseDurations.isEmpty) {
      return 0.0; // Return 0 if the map is empty to avoid division by zero.
    }

    double sum = 0.0;
    double max = 0.0;

    // print('calculateAverageY hourlyCounts: $hourlyCounts');

    hourlyCounts.forEach((hour, counts) {
      sum += counts;
      if (counts >= max) {
        max = counts;
      }
    });

    return max; //sum / daywiseDurations.length;
  }

  Future<void> updateLast28DaysDurations() async {
    daywiseDurations = last28DaysDurations;
    notifyListeners();
  }

  int recentDays = 1; // 최근 28일로 기본 설정

  Future<void> resetMeetings() async {
    customAppointmentMeetings.clear();
    newMeetings.clear();
    defaultMeetings.clear();
  }

  Future<void> resetDaywiseDurations() async {
    daywiseDurations.clear();
    last28DaysDurations.clear();
  }

  Future<void> resetHourlyCounts() async {

    hourlyCounts.clear();
    last28DaysHourlyCounts.clear();

    last28DaysHourlyCountsByDaysOfWeek.clear();
  }

  Future<void> daywiseDurationsCalculate(
      bool isInitial, bool isPersonal, String title, String roadAddress) async {
    //print('others personalDaywiseDurationsCalculate 시작');
    print(title);
    print(roadAddress);

    if (isPersonal != true) {

      List<Appointment> extractedAppointments = extractAppointmentsByCourt(
          customAppointmentMeetings, title, roadAddress);

      newMeetings = extractedAppointments;
      //print('others isPersonal false');
      //print('others daywiseDurationsCalculate isMyTime false');

    } else {
      // isPersonal == true 이면, 개인별 차트
      newMeetings = defaultMeetings;
      //print('others isPersonal true');
      //print('others daywiseDurationsCalculate isMyTime true');

    }
    print('others personl daywiseDurationsCalculate 이제 시작');
    print('newMeetings: $newMeetings');

    resetDaywiseDurations();

    DateTime currentDate = DateTime.now();

    // meetings 리스트의 각 Appointment 객체에 대해 endTime - startTime의 합산 수행
    for (Appointment appointment in newMeetings) {
      // 해당 Appointment의 시작일의 요일을 구함 (예: "Monday", "Tuesday", 등)
      String dayOfWeek = DateFormat('EEE', 'ko').format(appointment.startTime);

      if (appointment.startTime
          .isAfter(currentDate.subtract(Duration(days: 28))) &&
          appointment.startTime.isBefore(currentDate)) {

        if (last28DaysDurations.containsKey(dayOfWeek)) {
          final double previousDuration = last28DaysDurations[dayOfWeek] ?? 0.0;
          final double timeDifference = previousDuration +
              appointment.endTime
                  .difference(appointment.startTime)
                  .inMinutes
                  .toDouble();

          last28DaysDurations[dayOfWeek] = timeDifference;
        } else {
          final timeDifference =
          appointment.endTime.difference(appointment.startTime);
          last28DaysDurations[dayOfWeek] =
              timeDifference.inMinutes.toDouble(); // 1000000;
        }

        daywiseDurations = last28DaysDurations;

      }

      // print('last28DaysHourlyCountsByDaysOfWeek: $last28DaysHourlyCountsByDaysOfWeek');
      //
      // var extractCustomA0 =
      // extractCustomAppointmentsByCourtAndHour0(customAppointmentMeetings, title, roadAddress, last28DaysHourlyCountsByDaysOfWeek);
      //
      // print('extractCustomA0: $extractCustomA0');

    }


    // extractCustomAppointments(title, roadAddress, true);

    notifyListeners();

  }

  Future<List<String>> extractCustomAppointments(String title, String roadAddress, bool isUserTapped) async {

    print('customAppointmentMeetings.length: ${customAppointmentMeetings.length}');
    var extractedResult =
    extractCustomAppointmentsByCourtAndHour(customAppointmentMeetings, title, roadAddress, last28DaysHourlyCountsByDaysOfWeek);
    print('extractedResult: $extractedResult');
    print('extractedResult.length: ${extractedResult.length}');
    othersCustomAppointmentMeetings = extractedResult;
    print('OthersCustomAppointmentMeetings: $othersCustomAppointmentMeetings');


    if (isUserTapped) { // 특정 유저 클릭시
      extractCustomAppointmentsUserUids = extractedResult.map((customAppointment) => customAppointment.userUid).toSet().toList();
      print('특정 유저 클릭시 extractCustomAppointmentsUserUids: $extractCustomAppointmentsUserUids');
    } else { // 매칭 스크린에 맨 처음 진입시
      print('매칭 스크린에 맨 처음 진입시 extractCustomAppointmentsUserUids: $extractCustomAppointmentsUserUids');
      extractCustomAppointmentsUserUids = othersCustomAppointmentMeetings.map((customAppointment) => customAppointment.userUid).toSet().toList();
    }

    return extractCustomAppointmentsUserUids;

  }

  Future<void> personalCountHours(bool isInitial, bool isMyTime, String title, String roadAddress) async {

    print('others personal countHours 시작');

    if (isMyTime != true) {
      // isMyTime == true 이면, 첫번째 바 차트
      List<Appointment> extractedAppointments = extractAppointmentsByCourt(
          customAppointmentMeetings, title, roadAddress);

      newMeetings = extractedAppointments;
      //print('others countHours isMyTime false');
      //print('countHours newMeetings: $newMeetings');

    } else {
      //print('others countHours isMyTime true');
      newMeetings = defaultMeetings;
      //print('countHours newMeetings: $newMeetings');
    }

    resetHourlyCounts();

    // 모든 시간대의 카운트를 저장할 맵
    DateTime currentDate = DateTime.now();

    // 각 약속에서 startTime부터 endTime까지의 모든 시간을 추출하고 카운트
    for (var appointment in newMeetings) {

      if (appointment.startTime
          .isAfter(currentDate.subtract(Duration(days: 28))) &&
          appointment.startTime.isBefore(currentDate)) {

        DateTime startTime = appointment.startTime;
        DateTime endTime = appointment.endTime;

        while (startTime.isBefore(endTime) ||
            startTime.isAtSameMomentAs(endTime)) {

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

          hourlyCounts = last28DaysHourlyCounts;
          startTime = startTime.add(Duration(hours: 1));
        }

        hourlyCounts = last28DaysHourlyCounts;
      }
    }

    print('isInitial: $isInitial');
    if (isInitial == true) {
      print('isInitial == true');
      initialLast28DaysHourlyCountsByDaysOfWeek = Map.from(last28DaysHourlyCountsByDaysOfWeek);//last28DaysHourlyCountsByDaysOfWeek;
      print('initialLast28DaysHourlyCountsByDaysOfWeek: ${initialLast28DaysHourlyCountsByDaysOfWeek}');
      print('last28DaysHourlyCountsByDaysOfWeek: ${last28DaysHourlyCountsByDaysOfWeek}');
      notifyListeners();
    } else {
      print('isInitial == false');
      //last28DaysHourlyCountsByDaysOfWeek = last28DaysHourlyCountsByDaysOfWeek;
      print('initialLast28DaysHourlyCountsByDaysOfWeek: ${initialLast28DaysHourlyCountsByDaysOfWeek}');
      print('last28DaysHourlyCountsByDaysOfWeek: ${last28DaysHourlyCountsByDaysOfWeek}');
    }

  }

  List<bool> defaultSelectedList = List.generate(7, (index) => false);
  List<bool> selectedList = List.generate(7, (index) => false);
  List<bool> falseSelectedList = [false, false, false, false, false, false, false, ];

  Future<void> resetSelectedList() async {
    selectedList = defaultSelectedList;
    notifyListeners();
  }

  double calculateAverage() {
    if (daywiseDurations.isEmpty) {
      return 0.0; // Return 0 if the map is empty to avoid division by zero.
    }

    //print('personal daywiseDurations: ${daywiseDurations}');

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
