import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/repository/repository_userData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/customAppointment.dart';
import '../models/pingpongList.dart';
import '../statusUpdate/courtAppointmentUpdate.dart';
import '../statusUpdate/loginStatusUpdate.dart';
import '../statusUpdate/othersPersonalAppointmentUpdate.dart';
import '../statusUpdate/personalAppointmentUpdate.dart';
import '../statusUpdate/profileUpdate.dart';

class RepositoryAppointments {

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> addAppointment(CustomAppointment newCustomAppointment) async {

    try {

      final docRef = db
          .collection("Appointments")
          .withConverter(
        fromFirestore: CustomAppointment.fromFirestore,
        toFirestore:
            (CustomAppointment newCustomAppointment,
            options) =>
            newCustomAppointment.toFirestore(),
      )
          .doc();

      await docRef.set(newCustomAppointment);
      print('docRef.set done');

    } catch (e) {
      print(e);
    }

  }

  Future<void> reAddAppointment(String value, CustomAppointment newCustomAppointment) async {

    try {

      final docRef = db
          .collection("Appointments")
          .withConverter(
        fromFirestore: CustomAppointment.fromFirestore,
        toFirestore: (CustomAppointment newCustomAppointment,
            options) =>
            newCustomAppointment.toFirestore(),
      )
          .doc(value);

      await docRef.set(newCustomAppointment);
      print('docRef.set done');

    } catch (e) {
      print(e);
    }

  }

  Future<void> updateAppointment(String value, CustomAppointment newCustomAppointment) async {

    try {

      // 여기에서 서버에 일정 등록 필요
      final docRef = db
          .collection("Appointments")
          .withConverter(
        fromFirestore: CustomAppointment.fromFirestore,
        toFirestore: (CustomAppointment customAppointment,
            options) =>
            customAppointment.toFirestore(),
      )
          .doc(value);

      final newAppointmentData =
      newCustomAppointment.toFirestore();

      await docRef.update(newAppointmentData);
      print('updateAppointment 완료');

    } catch (e) {
      print(e);
    }

  }

  Future<void> removeAppointment(String value) async {

    try {
      db
          .collection("Appointments")
          .doc(value)
          .delete()
          .then(
            (doc) =>
            print("Document deleted"),
        onError: (e) =>
            print(
                "Error updating document $e"),
      );
    } catch (e) {
      print(e);
    }

  }

  Future<void> deleteUserAppointment(String uid) async {
    try {
      final querySnapshot = await db
          .collection("Appointments")
          .where("userUid", isEqualTo: uid).get();

      // userUid 필드가 일치하는 문서가 있는지 확인
      if (querySnapshot.docs.isNotEmpty) {
        // 검색된 모든 문서를 반복하여 삭제
        for (final doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
        // 문서 삭제 성공
        print("해당 userUid를 가진 문서를 삭제했습니다.");
      } else {
        // 해당 userUid를 가진 문서가 없음
        print("해당 userUid를 가진 문서가 없습니다.");
      }
    } catch (e) {
      print('deleteUserAppointment e: $e');
      //LaunchUrl().alertFunc(context, '알림', '유저 정보 삭제 중 에러가 발생했습니다', '확인', () { });
    }
  }

  // currnet 유저 일정 불러오기
  Future<void> fetchCurrentUserAppointmentData(BuildContext context, User currentUser) async {
    print('fetchCurrentUserAppointmentData 시작');

    PersonalAppointmentUpdate personalAppointmentUpdate = Provider.of<PersonalAppointmentUpdate>(context, listen: false);

    try {
      db
          .collection("Appointments")
          .where("userUid",
          isEqualTo: currentUser.uid)
          .get()
          .then(
            (querySnapshot) async {
          print("Successfully completed");

          for (var docSnapshot in querySnapshot.docs) {
            //final data = docSnapshot.data();
            //print("Document ID: ${docSnapshot.id}");
            final data = docSnapshot.data() as Map<String, dynamic>;

            List<Appointment>? _appointment;

            _appointment = (data['appointments'] as List<dynamic>?)
                ?.expand<Appointment>((dynamic item) {

              List<Timestamp>? recurrenceExceptionDatesRaw =
              (item['recurrenceExceptionDates'] as List<dynamic>?)
                  ?.cast<Timestamp>();
              //print('fetchCurrentUserAppointmentData recurrenceExceptionDatesRaw: $recurrenceExceptionDatesRaw');
              List<DateTime>? recurrenceExceptionDates =
              recurrenceExceptionDatesRaw?.map((timestamp) => timestamp.toDate()).toList() ?? [];
              //print('recurrenceExceptionDates: $recurrenceExceptionDates');

              final recurrenceId = item['recurrenceId'] as String? ?? '';
              final recurrenceRule = item['recurrenceRule'] as String? ?? '';

              List<Appointment> appointments = [];

              // 반복 일정
              if (recurrenceRule != null && recurrenceRule != '') {

                appointments.add(Appointment(
                  startTime: (item['startTime'] as Timestamp).toDate(),
                  endTime: (item['endTime'] as Timestamp).toDate(),
                  subject: item['subject'] as String,
                  isAllDay: item['isAllDay'] as bool,
                  id: item['id'] as Object?,
                  color: Color(item['color']).withOpacity(1),
                  notes: item['notes'] as String,
                  recurrenceRule: item['recurrenceRule'] as String? ?? '',
                  recurrenceId: item['recurrenceId'] as String? ?? '',
                  recurrenceExceptionDates: recurrenceExceptionDates,
                ));

                int exceptionCount = 0;

                // 예외 일정 있음
                if (recurrenceExceptionDates != null && recurrenceExceptionDates != []) {
                  // 반복 일정 중 예외 처리된 일자
                }

                if (recurrenceRule.contains('DAILY')) {
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('DAILY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                      DateTime currentStartDate = startDate.add(Duration(days: i));
                      DateTime currentEndDate = endDate.add(Duration(days: i));

                      if (!recurrenceExceptionDates.contains(currentStartDate)) {
                        appointments.add(Appointment(
                          startTime: currentStartDate,
                          endTime: currentEndDate,
                          subject: item['subject'] as String,
                          isAllDay: item['isAllDay'] as bool,
                          id: item['id'] as Object?,
                          color: Color(item['color']).withOpacity(1),
                          notes: item['notes'] as String,
                          recurrenceRule: null,
                          recurrenceId: null,
                          recurrenceExceptionDates: [],
                        ));
                      }

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }

                } else if (recurrenceRule.contains('WEEKLY')) {
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('WEEKLY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                      DateTime currentStartDate = startDate.add(Duration(days: 7 * i));
                      DateTime currentEndDate = endDate.add(Duration(days: 7 * i));

                      appointments.add(Appointment(
                        startTime: currentStartDate,
                        endTime: currentEndDate,
                        subject: item['subject'] as String,
                        isAllDay: item['isAllDay'] as bool,
                        id: item['id'] as Object?,
                        color: Color(item['color']).withOpacity(1),
                        notes: item['notes'] as String,
                        recurrenceRule: null,
                        recurrenceId: null,
                        recurrenceExceptionDates: [],
                      ));

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }
                } else if (recurrenceRule.contains('MONTHLY')) {
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('MONTHLY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                    DateTime currentStartDate = DateTime(startDate.year, startDate.month + i, startDate.day, startDate.hour, startDate.minute);
                    DateTime currentEndDate = DateTime(endDate.year, endDate.month + i, endDate.day, endDate.hour, endDate.minute);

                    appointments.add(Appointment(
                              startTime: currentStartDate,
                              endTime: currentEndDate,
                              subject: item['subject'] as String,
                              isAllDay: item['isAllDay'] as bool,
                              id: item['id'] as Object?,
                              color: Color(item['color']).withOpacity(1),
                              notes: item['notes'] as String,
                              recurrenceRule: null,
                              recurrenceId: null,
                              recurrenceExceptionDates: [],
                            ));

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }

                } else if (recurrenceRule.contains('YEARLY')){
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('YEARLY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                      DateTime currentStartDate = DateTime(startDate.year + i, startDate.month, startDate.day, startDate.hour, startDate.minute);
                      DateTime currentEndDate = DateTime(endDate.year + i, endDate.month, endDate.day, endDate.hour, endDate.minute);

                      appointments.add(Appointment(
                        startTime: currentStartDate,
                        endTime: currentEndDate,
                        subject: item['subject'] as String,
                        isAllDay: item['isAllDay'] as bool,
                        id: item['id'] as Object?,
                        color: Color(item['color']).withOpacity(1),
                        notes: item['notes'] as String,
                        recurrenceRule: null,
                        recurrenceId: null,
                        recurrenceExceptionDates: [],
                      ));

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }

                }

              } else {

                // 예외 일정임
                if (recurrenceId != null && recurrenceId != '') {
                  // 반복 일정 중에서 예외 처리된 일정
                  appointments?.add(Appointment(
                    startTime: (item['startTime'] as Timestamp).toDate(),
                    endTime: (item['endTime'] as Timestamp).toDate(),
                    subject: item['subject'] as String,
                    isAllDay: item['isAllDay'] as bool,
                    id: item['id'] as Object?,
                    color: Color(item['color']).withOpacity(1),
                    notes: item['notes'] as String,
                    recurrenceRule: null,
                    recurrenceId: recurrenceId,
                    recurrenceExceptionDates: [],
                  ));
                } else {
                  // 일반 일정
                  appointments.add(Appointment(
                    startTime: (item['startTime'] as Timestamp).toDate(),
                    endTime: (item['endTime'] as Timestamp).toDate(),
                    subject: item['subject'] as String,
                    isAllDay: item['isAllDay'] as bool,
                    id: item['id'] as Object?,
                    color: Color(item['color']).withOpacity(1),
                    notes: item['notes'] as String,
                    recurrenceRule: null,
                    recurrenceId: null,
                    recurrenceExceptionDates: [],
                  ));
                }
              }

              return appointments;
              // return Appointment(
              //   startTime: (item['startTime'] as Timestamp).toDate(),
              //   endTime: (item['endTime'] as Timestamp).toDate(),
              //   subject: item['subject'] as String,
              //   isAllDay: item['isAllDay'] as bool,
              //   id: item['id'] as Object?,
              //   color: Color(item['color']).withOpacity(1),
              //   notes: item['notes'] as String,
              //   recurrenceRule: item['recurrenceRule'] as String? ?? '',
              //   recurrenceId: item['recurrenceId'] as String? ?? '',
              //   recurrenceExceptionDates: recurrenceExceptionDates,
              // );
            }).toList();

            CustomAppointment _customAppointment = CustomAppointment(
              appointments: _appointment!,
              pingpongCourtName: data['pingpongCourtName'],
              pingpongCourtAddress: data['pingpongCourtAddress'],
              userUid: data['userUid'],
            );
            _customAppointment.id = docSnapshot.id;

            //print('_customAppointment: ${_customAppointment}');
            // //Provider.of<AppointmentUpdate>(context, listen: false).meetings.add(_appointment?.first);

            if (_appointment != null || _appointment.isNotEmpty) {
              personalAppointmentUpdate.addCustomMeeting(_customAppointment);
              for (int i = 0; i < _appointment.length; i++) {
                personalAppointmentUpdate.addMeeting(_appointment[i]);
              }
            }
          }

          await personalAppointmentUpdate.daywiseDurationsCalculate(
              true, true, 'title', 'roadAddress',
          );
          await personalAppointmentUpdate.personalCountHours(
            true, true, 'title', 'roadAddress',
          );

        },
        onError: (e) =>
            print("fetchCurrentUserAppointmentData Error completing: $e"),
      );
    } catch (e) {
      print(e);
    }

  }
  // 다른 유저 일정 불러오기
  Future<void> fetchOtherUsersAppointmentData(BuildContext context, User currentUser) async {
    print('fetchOtherUsersAppointmentData 시작');

    OthersPersonalAppointmentUpdate othersPersonalAppointmentUpdate = Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false);

    try {
      db
          .collection("Appointments")
          .where("userUid",
          isNotEqualTo: currentUser.uid)
          .get()
          .then(
            (querySnapshot) async {
          print("Successfully completed");

          for (var docSnapshot in querySnapshot.docs) {
            //final data = docSnapshot.data();
            //print("Document ID: ${docSnapshot.id}");
            final data = docSnapshot.data() as Map<String, dynamic>;

            List<Appointment>? _appointment;

            _appointment = (data['appointments'] as List<dynamic>?)
                ?.expand<Appointment>((dynamic item) {

              List<Timestamp>? recurrenceExceptionDatesRaw =
              (item['recurrenceExceptionDates'] as List<dynamic>?)
                  ?.cast<Timestamp>();
              //print('fetchCurrentUserAppointmentData recurrenceExceptionDatesRaw: $recurrenceExceptionDatesRaw');
              List<DateTime>? recurrenceExceptionDates =
                  recurrenceExceptionDatesRaw?.map((timestamp) => timestamp.toDate()).toList() ?? [];
              //print('recurrenceExceptionDates: $recurrenceExceptionDates');

              final recurrenceId = item['recurrenceId'] as String? ?? '';
              final recurrenceRule = item['recurrenceRule'] as String? ?? '';

              List<Appointment> appointments = [];

              // 반복 일정
              if (recurrenceRule != null && recurrenceRule != '') {

                appointments.add(Appointment(
                  startTime: (item['startTime'] as Timestamp).toDate(),
                  endTime: (item['endTime'] as Timestamp).toDate(),
                  subject: item['subject'] as String,
                  isAllDay: item['isAllDay'] as bool,
                  id: item['id'] as Object?,
                  color: Color(item['color']).withOpacity(1),
                  notes: item['notes'] as String,
                  recurrenceRule: item['recurrenceRule'] as String? ?? '',
                  recurrenceId: item['recurrenceId'] as String? ?? '',
                  recurrenceExceptionDates: recurrenceExceptionDates,
                ));

                int exceptionCount = 0;

                // 예외 일정 있음
                if (recurrenceExceptionDates != null && recurrenceExceptionDates != []) {
                  // 반복 일정 중 예외 처리된 일자
                }

                if (recurrenceRule.contains('DAILY')) {
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('DAILY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                      DateTime currentStartDate = startDate.add(Duration(days: i));
                      DateTime currentEndDate = endDate.add(Duration(days: i));

                      if (!recurrenceExceptionDates.contains(currentStartDate)) {
                        appointments.add(Appointment(
                          startTime: currentStartDate,
                          endTime: currentEndDate,
                          subject: item['subject'] as String,
                          isAllDay: item['isAllDay'] as bool,
                          id: item['id'] as Object?,
                          color: Color(item['color']).withOpacity(1),
                          notes: item['notes'] as String,
                          recurrenceRule: null,
                          recurrenceId: null,
                          recurrenceExceptionDates: [],
                        ));
                      }

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }

                } else if (recurrenceRule.contains('WEEKLY')) {
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('WEEKLY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                      DateTime currentStartDate = startDate.add(Duration(days: 7 * i));
                      DateTime currentEndDate = endDate.add(Duration(days: 7 * i));

                      appointments.add(Appointment(
                        startTime: currentStartDate,
                        endTime: currentEndDate,
                        subject: item['subject'] as String,
                        isAllDay: item['isAllDay'] as bool,
                        id: item['id'] as Object?,
                        color: Color(item['color']).withOpacity(1),
                        notes: item['notes'] as String,
                        recurrenceRule: null,
                        recurrenceId: null,
                        recurrenceExceptionDates: [],
                      ));

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }
                } else if (recurrenceRule.contains('MONTHLY')) {
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('MONTHLY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                      DateTime currentStartDate = DateTime(startDate.year, startDate.month + i, startDate.day, startDate.hour, startDate.minute);
                      DateTime currentEndDate = DateTime(endDate.year, endDate.month + i, endDate.day, endDate.hour, endDate.minute);

                      appointments.add(Appointment(
                        startTime: currentStartDate,
                        endTime: currentEndDate,
                        subject: item['subject'] as String,
                        isAllDay: item['isAllDay'] as bool,
                        id: item['id'] as Object?,
                        color: Color(item['color']).withOpacity(1),
                        notes: item['notes'] as String,
                        recurrenceRule: null,
                        recurrenceId: null,
                        recurrenceExceptionDates: [],
                      ));

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }

                } else if (recurrenceRule.contains('YEARLY')){
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('YEARLY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                      DateTime currentStartDate = DateTime(startDate.year + i, startDate.month, startDate.day, startDate.hour, startDate.minute);
                      DateTime currentEndDate = DateTime(endDate.year + i, endDate.month, endDate.day, endDate.hour, endDate.minute);

                      appointments.add(Appointment(
                        startTime: currentStartDate,
                        endTime: currentEndDate,
                        subject: item['subject'] as String,
                        isAllDay: item['isAllDay'] as bool,
                        id: item['id'] as Object?,
                        color: Color(item['color']).withOpacity(1),
                        notes: item['notes'] as String,
                        recurrenceRule: null,
                        recurrenceId: null,
                        recurrenceExceptionDates: [],
                      ));

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }

                }

              } else {

                // 예외 일정임
                if (recurrenceId != null && recurrenceId != '') {
                  // 반복 일정 중에서 예외 처리된 일정
                  appointments?.add(Appointment(
                    startTime: (item['startTime'] as Timestamp).toDate(),
                    endTime: (item['endTime'] as Timestamp).toDate(),
                    subject: item['subject'] as String,
                    isAllDay: item['isAllDay'] as bool,
                    id: item['id'] as Object?,
                    color: Color(item['color']).withOpacity(1),
                    notes: item['notes'] as String,
                    recurrenceRule: null,
                    recurrenceId: recurrenceId,
                    recurrenceExceptionDates: [],
                  ));
                } else {
                  // 일반 일정
                  appointments.add(Appointment(
                    startTime: (item['startTime'] as Timestamp).toDate(),
                    endTime: (item['endTime'] as Timestamp).toDate(),
                    subject: item['subject'] as String,
                    isAllDay: item['isAllDay'] as bool,
                    id: item['id'] as Object?,
                    color: Color(item['color']).withOpacity(1),
                    notes: item['notes'] as String,
                    recurrenceRule: null,
                    recurrenceId: null,
                    recurrenceExceptionDates: [],
                  ));
                }
              }

              return appointments;
              // return Appointment(
              //   startTime: (item['startTime'] as Timestamp).toDate(),
              //   endTime: (item['endTime'] as Timestamp).toDate(),
              //   subject: item['subject'] as String,
              //   isAllDay: item['isAllDay'] as bool,
              //   id: item['id'] as Object?,
              //   color: Color(item['color']).withOpacity(1),
              //   notes: item['notes'] as String,
              //   recurrenceRule: item['recurrenceRule'] as String? ?? '',
              //   recurrenceId: item['recurrenceId'] as String? ?? '',
              //   recurrenceExceptionDates: recurrenceExceptionDates,
              // );
            }).toList();

            CustomAppointment _customAppointment = CustomAppointment(
              appointments: _appointment!,
              pingpongCourtName: data['pingpongCourtName'],
              pingpongCourtAddress: data['pingpongCourtAddress'],
              userUid: data['userUid'],
            );
            _customAppointment.id = docSnapshot.id;

            print('fetchOtherUsersAppointmentData _customAppointment: ${_customAppointment.userUid}');
            // // //Provider.of<AppointmentUpdate>(context, listen: false).meetings.add(_appointment?.first);
            print('_appointment: ${_appointment}');
            print('_appointment.isempty: ${_appointment.isEmpty}');
            print('_appointment.length: ${_appointment.length}');

            if (_appointment != null || _appointment.isNotEmpty) {
              othersPersonalAppointmentUpdate.addCustomMeeting(_customAppointment);
              print('_customAppointment add 함');
              for (int i = 0; i < _appointment.length; i++) {
                othersPersonalAppointmentUpdate.addMeeting(_appointment[i]);
              }
            }
          }

          await othersPersonalAppointmentUpdate.daywiseDurationsCalculate(
              true, true, 'title', 'roadAddress',
          );
          await othersPersonalAppointmentUpdate.personalCountHours(
              true, true, 'title', 'roadAddress',
          );

        },
        onError: (e) =>
            print("fetchOtherUsersAppointmentData Error completing: $e"),
      );
    } catch (e) {
      print(e);
    }

  }
  // 탁구장별 유저 일정 불러오기
  Future<void> fetchAppointmentDataForCalculatingByCourt(
      BuildContext context) async {

    print('fetchAppointmentDataForCalculatingByCourt 시작');

    CourtAppointmentUpdate courtAppointmentUpdate = Provider.of<CourtAppointmentUpdate>(context, listen: false);
    OthersPersonalAppointmentUpdate othersPersonalAppointmentUpdate = Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false);

    final pingpongCourt = Provider.of<ProfileUpdate>(context, listen: false)
        .userProfile
        .pingpongCourt;

    print('fetchAppointmentData pingpongCourt: ${pingpongCourt}');

    if (pingpongCourt != null) {

      try {

        await Future.forEach(pingpongCourt, (PingpongList pingpong) async {
          print('forEach pingpongCourtAddress: ${pingpong.roadAddress}');

          final querySnapshot = await db
              .collection("Appointments")
              .where("pingpongCourtAddress", isEqualTo: pingpong.roadAddress)
              .get();

          print("fetchAppointmentData Successfully completed");

          for (var docSnapshot in querySnapshot.docs) {
            final data = docSnapshot.data() as Map<String, dynamic>;
            //print('fetchAppointmentData data:\n $data');

            final String pingpongCourtName = data['pingpongCourtName'];
            final String pingpongCourtAddress = data['pingpongCourtAddress'];

            courtAppointmentUpdate.addPingpongCourtNameList(pingpongCourtName);
            courtAppointmentUpdate.addPingpongCourtAddressList(pingpongCourtAddress);

            List<Appointment>? _appointment;

            _appointment = (data['appointments'] as List<dynamic>?)
                ?.expand<Appointment>((dynamic item) {

              List<Timestamp>? recurrenceExceptionDatesRaw =
              (item['recurrenceExceptionDates'] as List<dynamic>?)
                  ?.cast<Timestamp>();
              //print('fetchCurrentUserAppointmentData recurrenceExceptionDatesRaw: $recurrenceExceptionDatesRaw');
              List<DateTime>? recurrenceExceptionDates =
                  recurrenceExceptionDatesRaw?.map((timestamp) => timestamp.toDate()).toList() ?? [];
              //print('recurrenceExceptionDates: $recurrenceExceptionDates');

              final recurrenceId = item['recurrenceId'] as String? ?? '';
              final recurrenceRule = item['recurrenceRule'] as String? ?? '';

              List<Appointment> appointments = [];

              // 반복 일정
              if (recurrenceRule != null && recurrenceRule != '') {

                appointments.add(Appointment(
                  startTime: (item['startTime'] as Timestamp).toDate(),
                  endTime: (item['endTime'] as Timestamp).toDate(),
                  subject: item['subject'] as String,
                  isAllDay: item['isAllDay'] as bool,
                  id: item['id'] as Object?,
                  color: Color(item['color']).withOpacity(1),
                  notes: item['notes'] as String,
                  recurrenceRule: item['recurrenceRule'] as String? ?? '',
                  recurrenceId: item['recurrenceId'] as String? ?? '',
                  recurrenceExceptionDates: recurrenceExceptionDates,
                ));

                int exceptionCount = 0;

                // 예외 일정 있음
                if (recurrenceExceptionDates != null && recurrenceExceptionDates != []) {
                  // 반복 일정 중 예외 처리된 일자
                }

                if (recurrenceRule.contains('DAILY')) {
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('DAILY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                      DateTime currentStartDate = startDate.add(Duration(days: i));
                      DateTime currentEndDate = endDate.add(Duration(days: i));

                      if (!recurrenceExceptionDates.contains(currentStartDate)) {
                        appointments.add(Appointment(
                          startTime: currentStartDate,
                          endTime: currentEndDate,
                          subject: item['subject'] as String,
                          isAllDay: item['isAllDay'] as bool,
                          id: item['id'] as Object?,
                          color: Color(item['color']).withOpacity(1),
                          notes: item['notes'] as String,
                          recurrenceRule: null,
                          recurrenceId: null,
                          recurrenceExceptionDates: [],
                        ));
                      }

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }

                } else if (recurrenceRule.contains('WEEKLY')) {
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('WEEKLY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                      DateTime currentStartDate = startDate.add(Duration(days: 7 * i));
                      DateTime currentEndDate = endDate.add(Duration(days: 7 * i));

                      appointments.add(Appointment(
                        startTime: currentStartDate,
                        endTime: currentEndDate,
                        subject: item['subject'] as String,
                        isAllDay: item['isAllDay'] as bool,
                        id: item['id'] as Object?,
                        color: Color(item['color']).withOpacity(1),
                        notes: item['notes'] as String,
                        recurrenceRule: null,
                        recurrenceId: null,
                        recurrenceExceptionDates: [],
                      ));

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }
                } else if (recurrenceRule.contains('MONTHLY')) {
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('MONTHLY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                      DateTime currentStartDate = DateTime(startDate.year, startDate.month + i, startDate.day, startDate.hour, startDate.minute);
                      DateTime currentEndDate = DateTime(endDate.year, endDate.month + i, endDate.day, endDate.hour, endDate.minute);

                      appointments.add(Appointment(
                        startTime: currentStartDate,
                        endTime: currentEndDate,
                        subject: item['subject'] as String,
                        isAllDay: item['isAllDay'] as bool,
                        id: item['id'] as Object?,
                        color: Color(item['color']).withOpacity(1),
                        notes: item['notes'] as String,
                        recurrenceRule: null,
                        recurrenceId: null,
                        recurrenceExceptionDates: [],
                      ));

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }

                } else if (recurrenceRule.contains('YEARLY')){
                  int countIndex = recurrenceRule.indexOf('COUNT=');

                  if (countIndex != -1) {
                    // COUNT= 뒤의 숫자를 추출합니다.
                    String countString = recurrenceRule.substring(countIndex + 'COUNT='.length);
                    int count = int.tryParse(countString) ?? 0; // 숫자로 변환합니다.
                    print('YEARLY COUNT 값: $count');

                    // 시작 일자
                    DateTime startDate = (item['startTime'] as Timestamp).toDate();
                    DateTime endDate = (item['endTime'] as Timestamp).toDate();

                    // COUNT 값 만큼 _appointment에 Appointment를 추가합니다.
                    for (int i = 1; i < count; i++) {

                      DateTime currentStartDate = DateTime(startDate.year + i, startDate.month, startDate.day, startDate.hour, startDate.minute);
                      DateTime currentEndDate = DateTime(endDate.year + i, endDate.month, endDate.day, endDate.hour, endDate.minute);

                      appointments.add(Appointment(
                        startTime: currentStartDate,
                        endTime: currentEndDate,
                        subject: item['subject'] as String,
                        isAllDay: item['isAllDay'] as bool,
                        id: item['id'] as Object?,
                        color: Color(item['color']).withOpacity(1),
                        notes: item['notes'] as String,
                        recurrenceRule: null,
                        recurrenceId: null,
                        recurrenceExceptionDates: [],
                      ));

                    }

                  } else {
                    print('COUNT 값이 없습니다.');
                  }

                }

              } else {

                // 예외 일정임
                if (recurrenceId != null && recurrenceId != '') {
                  // 반복 일정 중에서 예외 처리된 일정
                  appointments?.add(Appointment(
                    startTime: (item['startTime'] as Timestamp).toDate(),
                    endTime: (item['endTime'] as Timestamp).toDate(),
                    subject: item['subject'] as String,
                    isAllDay: item['isAllDay'] as bool,
                    id: item['id'] as Object?,
                    color: Color(item['color']).withOpacity(1),
                    notes: item['notes'] as String,
                    recurrenceRule: null,
                    recurrenceId: recurrenceId,
                    recurrenceExceptionDates: [],
                  ));
                } else {
                  // 일반 일정
                  appointments.add(Appointment(
                    startTime: (item['startTime'] as Timestamp).toDate(),
                    endTime: (item['endTime'] as Timestamp).toDate(),
                    subject: item['subject'] as String,
                    isAllDay: item['isAllDay'] as bool,
                    id: item['id'] as Object?,
                    color: Color(item['color']).withOpacity(1),
                    notes: item['notes'] as String,
                    recurrenceRule: null,
                    recurrenceId: null,
                    recurrenceExceptionDates: [],
                  ));
                }
              }

              return appointments;
              // return Appointment(
              //   startTime: (item['startTime'] as Timestamp).toDate(),
              //   endTime: (item['endTime'] as Timestamp).toDate(),
              //   subject: item['subject'] as String,
              //   isAllDay: item['isAllDay'] as bool,
              //   id: item['id'] as Object?,
              //   color: Color(item['color']).withOpacity(1),
              //   notes: item['notes'] as String,
              //   recurrenceRule: item['recurrenceRule'] as String? ?? '',
              //   recurrenceId: item['recurrenceId'] as String? ?? '',
              //   recurrenceExceptionDates: recurrenceExceptionDates,
              // );
            }).toList();

            CustomAppointment _customAppointment = CustomAppointment(
              appointments: _appointment!,
              pingpongCourtName: data['pingpongCourtName'],
              pingpongCourtAddress: data['pingpongCourtAddress'],
              userUid: data['userUid'],
            );
            _customAppointment.id = docSnapshot.id;

            courtAppointmentUpdate.addCustomMeeting(_customAppointment);
            for (int i = 0; i < _appointment.length; i++) {
              courtAppointmentUpdate.addMeeting(_appointment[i]);
            }

          }

          // courtAppointmentUpdate.extractPingpongCourtAddressList();
        });

        await courtAppointmentUpdate.daywiseDurationsCalculate(
            true,
            false,
            courtAppointmentUpdate.pingpongCourtNameList.first,
            courtAppointmentUpdate.pingpongCourtAddressList.first,
        );

        await courtAppointmentUpdate.courtCountHours(
            true,
            false,
            courtAppointmentUpdate.pingpongCourtNameList.first,
            courtAppointmentUpdate.pingpongCourtAddressList.first,
        );

        // await othersPersonalAppointmentUpdate.extractCustomAppointments(
        //     courtAppointmentUpdate.pingpongCourtNameList.first,
        //     courtAppointmentUpdate.pingpongCourtAddressList.first,
        //   true
        // );
        // 여기서 탁구장별 유저 본인과 비슷한 시간대 찾음

      } catch (e) {
        print("fetchAppointmentData Error completing: $e");
      }
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> allAppointments() {

    print('allAppointments 시작됨');

    final today = DateTime.now();
    final limitDate = today.add(Duration(days: -100));

    final snapshots = db.collection("Appointments").
    // where("userUid",
    //     isNotEqualTo: auth.currentUser?.uid ?? '').
        //where(field).
    snapshots();

    return snapshots;
  }

  // List<Apppointment> calendarAppointments(BuildContext context) {
  //
  //   db.collection("Appointments")
  //       .where("userUid",
  //       isEqualTo: Provider.of<LoginStatusUpdate>(context, listen: false)
  //           .currentUser
  //           .uid)
  //       .snapshots()
  //       .listen((event) {
  //     final list = [];
  //     for (var doc in event.docs) {
  //       list.add(doc.data()["name"]);
  //     }
  //     print("list : ${list.join(", ")}");
  //   });
  //
  //   return list;
  // }

}
