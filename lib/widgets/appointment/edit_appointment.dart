import 'package:bottom_picker/bottom_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/view/calendar_screen.dart';
import 'package:dnpp/widgets/chart/chart_repeat_appointment.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../constants.dart';
import '../../models/customAppointment.dart';
import '../../models/pingpongList.dart';
import '../../models/userProfile.dart';
import '../../repository/repository_loadData.dart';
import '../../view/home_screen.dart';
import '../../viewModel/courtAppointmentUpdate.dart';
import '../../viewModel/loginStatusUpdate.dart';
import '../../viewModel/personalAppointmentUpdate.dart';
import '../../viewModel/profileUpdate.dart';
import '../chart/chart_repeat_times.dart';

class EditAppointment extends StatefulWidget {
  EditAppointment(
      {required this.context,
      required this.userCourt,
      required this.oldMeeting});

  final String userCourt;
  final dynamic oldMeeting;
  final BuildContext context;

  @override
  State<EditAppointment> createState() => _EditAppointmentState();
}

class _EditAppointmentState extends State<EditAppointment> {
  String _eventName = '';
  String _memoText = '';

  //PingpongList? foundCourt;
  bool iscourtAddressNotEmpty = false; //
  String chosenCourtName = '없음';
  String chosenCourtRoadAddress = '없음';

  CustomAppointment? oldmeetingAppointments;
  String customAppointmentID = '';

  TextEditingController _eventNametextController = TextEditingController();
  TextEditingController _memoTextController = TextEditingController();

  bool _editAppointment = false;
  bool _onlyThisAppointment = false;

  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> toggleLoading(bool isLoading, BuildContext context) async {
    setState(() {
      if (isLoading) {
        // 로딩 바를 화면에 표시
        print('profileScreen 로딩 바를 화면에 표시');
        showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: CircularProgressIndicator(), // 로딩 바 표시
            );
          },
        );
      } else {
        print('로딩 바 제거');
        //Navigator.pop(context);
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  void checkOldMeeting() async {
    String? recurrenceRule = widget.oldMeeting.recurrenceRule;
    print('checkOldMeeting recurrenceRule: $recurrenceRule');
    // recurrenceRule 문자열을 세미콜론(;)으로 분할
    List<String>? parts = recurrenceRule?.split(';');

    if (recurrenceRule != null) {
      if (recurrenceRule.contains('DAILY')) {
        var byDay;
        var count;

        for (String part in parts!) {
          if (part.startsWith('BYDAY=')) {
            byDay = part.substring(6);
            print('byDay');
            print(byDay);
          } else if (part.startsWith('COUNT=')) {
            count = int.parse(part.substring(6));
            print('count');
            print(count);
          }
        }

        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateRepeat('매일');
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateRecurrenceRules('매일', count);
        print('DAILY');
      } else if (recurrenceRule.contains('WEEKLY')) {
        var byDay;
        var count;

        for (String part in parts!) {
          if (part.startsWith('BYDAY=')) {
            byDay = part.substring(6);
            print('byDay');
            print(byDay);
          } else if (part.startsWith('COUNT=')) {
            count = int.parse(part.substring(6));
            print('count');
            print(count);
          }
        }

        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateRepeat('매주');
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateRecurrenceRules('매주', count);
        print('WEEKLY');
      } else if (recurrenceRule.contains('MONTHLY')) {
        var byDay;
        var count;

        for (String part in parts!) {
          if (part.startsWith('BYDAY=')) {
            byDay = part.substring(6);
            print('byDay');
            print(byDay);
          } else if (part.startsWith('COUNT=')) {
            count = int.parse(part.substring(6));
            print('count');
            print(count);
          }
        }

        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateRepeat('매월');
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateRecurrenceRules('매월', count);
        print('MONTHLY');
      } else if (recurrenceRule.contains('YEARLY')) {
        var byDay;
        var count;

        for (String part in parts!) {
          if (part.startsWith('BYDAY=')) {
            byDay = part.substring(6);
            print('byDay');
            print(byDay);
          } else if (part.startsWith('COUNT=')) {
            count = int.parse(part.substring(6));
            print('count');
            print(count);
          }
        }

        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateRepeat('매년');
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateRecurrenceRules('매년', count);
        print('YEARLY');
      } else {
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateRepeat('반복 안 함');
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .updateRecurrenceRules('반복 안 함', 1);
        print('반복 안 함');
      }
    } else {
      // recurrenceRule == null 이므로 반복 일정이 아님
      await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
          .updateRepeat('반복 안 함');
      await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
          .updateRecurrenceRules('반복 안 함', 1);
      print('반복 안 함');
    }
  }

  Future<void> refreshData(BuildContext context) async {

    try {

      await Future.delayed(Duration(seconds: 1)).then((value) {
        print('refreshData done');
      });

      await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
          .resetMeetings();
      await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
          .resetDaywiseDurations();
      await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
          .resetHourlyCounts();

      await Provider.of<CourtAppointmentUpdate>(context, listen: false)
          .resetMeetings();
      await Provider.of<CourtAppointmentUpdate>(context, listen: false)
          .resetDaywiseDurations();
      await Provider.of<CourtAppointmentUpdate>(context, listen: false)
          .resetHourlyCounts();

      //await LoadData().fetchUserData(context);
      await LoadData().fetchUserData(context);
      //setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _eventNametextController.addListener(() {
      //print(_eventNametextController.text);
    });
    _memoTextController.addListener(() {
      //print(_memoTextController.text);
    });
    _eventNametextController.text = widget.oldMeeting.subject;
    //Provider.of<AppointmentUpdate>(context, listen: false).eventName;;
    _memoTextController.text = widget.oldMeeting.notes!;

    setState(() {
      if (Provider.of<PersonalAppointmentUpdate>(context, listen: false)
          .customAppointmentMeetings
          .isNotEmpty) {
        print('customAppointmentMeetings isNotEmpty');

        // final docRef = db.collection("Appointments").where("userUid",
        //           isEqualTo: Provider.of<LoginStatusUpdate>(context, listen: false)
        //               .currentUser
        //               .uid).withConverter(
        //   fromFirestore: CustomAppointment.fromFirestore,
        //   toFirestore: (CustomAppointment customAppointment, _) => customAppointment.toFirestore(),
        // );

        // docRef.snapshots().listen(
        //       (event) => print("current data: ${event.docs}"),
        //   onError: (error) => print("Listen failed: $error"),
        // );

        try {
          oldmeetingAppointments = Provider.of<PersonalAppointmentUpdate>(
            context,
            listen: false,
          ).customAppointmentMeetings.firstWhere((customAppointment) =>
              customAppointment.appointments.contains(widget.oldMeeting));

          customAppointmentID = oldmeetingAppointments!.id!;
          print('oldmeetingAppointments: ${oldmeetingAppointments?.appointments.first}');

        } catch (e) {
          print('customAppointmentID = oldmeetingAppointments!.id; 실패 $e');
        }

        if (oldmeetingAppointments!.pingpongCourtAddress.isNotEmpty) {
          chosenCourtRoadAddress = oldmeetingAppointments!.pingpongCourtAddress;
          chosenCourtName = oldmeetingAppointments!.pingpongCourtName;
          print('chosenCourtRoadAddress: ${chosenCourtRoadAddress}');
          print('chosenCourtName: ${chosenCourtName}');

          // foundCourt = Provider.of<ProfileUpdate>(context, listen: false)
          //     .userProfile
          //     .pingpongCourt
          //     ?.firstWhere(
          //         (element) => element.roadAddress == chosenCourtRoadAddress);

          iscourtAddressNotEmpty = true;

          print('1 1 1 1');
        } else {
          print('2 2 2 2');
        }

      } else {
        print('customAppointmentMeetings isEmpty');
        print('여기에서 유저 프로필 생성으로 안내 필요');
      }
    });

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 상태 변경 작업을 여기에 넣습니다.
      checkOldMeeting();
    });
  }

  @override
  void dispose() {
    _eventNametextController.dispose();
    _memoTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext defaultContext) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Padding(
            padding:
                EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 10.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              style: ButtonStyle(
                                alignment: Alignment.centerLeft,
                              ),
                              onPressed: () async {
                                Navigator.pop(defaultContext);
                                await Provider.of<PersonalAppointmentUpdate>(
                                        defaultContext,
                                        listen: false)
                                    .clear();
                              },
                              child: Text(
                                _editAppointment ? '취소' : '뒤로',
                                style: kElevationButtonStyle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _editAppointment ? '일정 수정' : '일정',
                                style: kAppointmentTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                alignment: Alignment.centerRight,
                              ),
                              child: Text(
                                '저장',
                                style: _editAppointment
                                    ? kElevationButtonStyle
                                    : kElevationButtonStyle.copyWith(
                                        color: Colors.transparent),
                              ),
                              onPressed: _editAppointment
                                  ? () async {

                                      await toggleLoading(true, defaultContext);

                                      final _newMeeting = Appointment(
                                        startTime: Provider.of<
                                                    PersonalAppointmentUpdate>(
                                                defaultContext,
                                                listen: false)
                                            .fromDate,
                                        endTime: Provider.of<
                                                    PersonalAppointmentUpdate>(
                                                defaultContext,
                                                listen: false)
                                            .toDate,
                                        subject: _eventNametextController.text,
                                        isAllDay: Provider.of<
                                                    PersonalAppointmentUpdate>(
                                                defaultContext,
                                                listen: false)
                                            .isAllDay,
                                        notes: _memoTextController.text,
                                        recurrenceRule: Provider.of<
                                                    PersonalAppointmentUpdate>(
                                                defaultContext,
                                                listen: false)
                                            .recurrenceRule,
                                      );

                                      await Provider.of<
                                                  PersonalAppointmentUpdate>(
                                              defaultContext,
                                              listen: false)
                                          .addRecurrenceExceptionDates(
                                              widget.oldMeeting,
                                              _newMeeting,
                                              _onlyThisAppointment,
                                              false);

                                      widget.oldMeeting.startTime =
                                          Provider.of<PersonalAppointmentUpdate>(
                                                  defaultContext,
                                                  listen: false)
                                              .fromDate;
                                      widget.oldMeeting.endTime =
                                          Provider.of<PersonalAppointmentUpdate>(
                                                  defaultContext,
                                                  listen: false)
                                              .toDate;
                                      widget.oldMeeting.subject =
                                          _eventNametextController.text;
                                      widget.oldMeeting.isAllDay =
                                          Provider.of<PersonalAppointmentUpdate>(
                                                  defaultContext,
                                                  listen: false)
                                              .isAllDay;
                                      widget.oldMeeting.notes =
                                          _memoTextController.text;
                                      widget.oldMeeting.recurrenceRule =
                                          Provider.of<PersonalAppointmentUpdate>(
                                                  defaultContext,
                                                  listen: false)
                                              .recurrenceRule;

                                      await Provider.of<
                                                  PersonalAppointmentUpdate>(
                                              defaultContext,
                                              listen: false)
                                          .updateMeeting(
                                              widget.oldMeeting, _newMeeting);

                                      // 여기에서 서버에 일정 등록 필요
                                      final docRef = db
                                          .collection("Appointments")
                                          .withConverter(
                                            fromFirestore:
                                                CustomAppointment.fromFirestore,
                                            toFirestore: (CustomAppointment
                                                        customAppointment,
                                                    options) =>
                                                customAppointment.toFirestore(),
                                          )
                                          .doc(oldmeetingAppointments?.id);

                                      final newCustomAppointment =
                                          CustomAppointment(
                                        appointments: [widget.oldMeeting],
                                        //[_newMeeting],
                                        pingpongCourtName:
                                        chosenCourtName,
                                        pingpongCourtAddress:
                                        chosenCourtRoadAddress,
                                        userUid: Provider.of<LoginStatusUpdate>(
                                                defaultContext,
                                                listen: false)
                                            .currentUser
                                            .uid,
                                      );

                                      final newAppointmentData =
                                          newCustomAppointment.toFirestore();

                                      await docRef.update(newAppointmentData);

                                      await Provider.of<
                                                  PersonalAppointmentUpdate>(
                                              defaultContext,
                                              listen: false)
                                          .personalDaywiseDurationsCalculate(
                                              false,
                                              true,
                                          chosenCourtName,
                                              chosenCourtRoadAddress);
                                      await Provider.of<
                                                  PersonalAppointmentUpdate>(
                                              defaultContext,
                                              listen: false)
                                          .personalCountHours(
                                              false,
                                              true,
                                          chosenCourtName,
                                          chosenCourtRoadAddress);

                                      await Provider.of<
                                                  PersonalAppointmentUpdate>(
                                              defaultContext,
                                              listen: false)
                                          .clear();


                                      //await LoadData().refreshData(context);
                                      await refreshData(defaultContext);

                                      await toggleLoading(false, defaultContext);

                                      Navigator.pop(defaultContext);
                                    }
                                  : () {},
                            ),
                          ],
                        ), // 일정 수정을 수락한 경우 (저장 활성화)
                        IgnorePointer(
                          ignoring: _editAppointment ? false : true,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _eventNametextController,
                                decoration: InputDecoration(
                                    labelText: '일정 제목', hintText: '예) 레슨'),
                                style: kAppointmentDateTextStyle,
                                onChanged: (value) {
                                  _eventName = value;
                                },
                              ),
                              TextFormField(
                                controller: _memoTextController,
                                decoration: InputDecoration(labelText: '메모'),
                                style: kAppointmentDateTextStyle,
                                onChanged: (value) {
                                  _memoText = value;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: [
                        IgnorePointer(
                          ignoring: _editAppointment ? false : true,
                          child: Column(
                            children: [
                              Visibility(
                                visible: Provider.of<PersonalAppointmentUpdate>(
                                            defaultContext)
                                        .isAllDay
                                    ? false
                                    : true,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5.0, bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            '시작 시간',
                                            style: kAppointmentTextStyle,
                                          ),
                                          Text(
                                            '종료 시간',
                                            style: kAppointmentTextStyle,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            DateFormat('yyyy. MM. dd. (E) HH:mm',
                                                    'ko')
                                                .format(Provider.of<
                                                            PersonalAppointmentUpdate>(
                                                        defaultContext,
                                                        listen: false)
                                                    .fromDate),
                                            style: kAppointmentDateTextStyle,
                                          ),
                                          Text(
                                            DateFormat('yyyy. MM. dd. (E) HH:mm',
                                                    'ko')
                                                .format(Provider.of<
                                                            PersonalAppointmentUpdate>(
                                                        defaultContext,
                                                        listen: false)
                                                    .toDate),
                                            style: kAppointmentDateTextStyle,
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        style: ButtonStyle(
                                          alignment: Alignment.centerRight,
                                        ),
                                        onPressed: () async {
                                          List<DateTime>? dateTimeList =
                                              await showOmniDateTimeRangePicker(
                                            context: defaultContext,
                                            startInitialDate:
                                                widget.oldMeeting.startTime,
                                            startFirstDate: DateTime(2000),
                                            startLastDate: DateTime.now().add(
                                              const Duration(days: 10956),
                                            ),
                                            endInitialDate:
                                                widget.oldMeeting.endTime,
                                            endFirstDate: DateTime(2000),
                                            endLastDate: DateTime.now().add(
                                              const Duration(days: 10956),
                                            ),
                                            is24HourMode: false,
                                            isShowSeconds: false,
                                            minutesInterval: 5,
                                            secondsInterval: 1,
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(16)),
                                            constraints: const BoxConstraints(
                                              maxWidth: 350,
                                              maxHeight: 650,
                                            ),
                                            transitionBuilder:
                                                (context, anim1, anim2, child) {
                                              return FadeTransition(
                                                opacity: anim1.drive(
                                                  Tween(
                                                    begin: 0,
                                                    end: 1,
                                                  ),
                                                ),
                                                child: child,
                                              );
                                            },
                                            transitionDuration:
                                                const Duration(milliseconds: 200),
                                            barrierDismissible: true,
                                          );

                                          if (dateTimeList != null) {
                                            print(
                                                dateTimeList); // 여기에 시작 시간과 종료시간이 담김

                                            if (dateTimeList.first
                                                .isAfter(dateTimeList.last)) {
                                              // 시작일이 종료일보다 느린 상태이므로 에러임.
                                              print('시작일이 종료일보다 느린 상태이므로 에러임');

                                              showDialog(
                                                  context: defaultContext,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      insetPadding:
                                                          EdgeInsets.only(
                                                              left: 10.0,
                                                              right: 10.0),
                                                      shape:
                                                          kRoundedRectangleBorder,
                                                      content: Text(
                                                          '시작일은 종료일보다 늦어야 합니다'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('확인'),
                                                        )
                                                      ],
                                                    );
                                                  });
                                            } else {
                                              print('시작일이 종료일보다 빠린 상태이므로 에러 아님');
                                              Provider.of<PersonalAppointmentUpdate>(
                                                      defaultContext,
                                                      listen: false)
                                                  .updateFromDate(
                                                      dateTimeList.first);
                                              Provider.of<PersonalAppointmentUpdate>(
                                                      defaultContext,
                                                      listen: false)
                                                  .updateToDate(
                                                      dateTimeList.last);
                                            }
                                          } else {
                                            // dateTimeList가 null인 경우에 대한 오류 처리
                                            print('No date/time selected.');
                                          }
                                        },
                                        child: Text(
                                          '변경',
                                          style: kAppointmentTextButtonStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '탁구장',
                                    style: kAppointmentTextStyle,
                                  ),

                                  // Provider.of<ProfileUpdate>(context, listen: false)
                                  //     .userProfile
                                  //     .pingpongCourt![0]
                                  //     .roadAddress
                                  //
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      value: Provider.of<ProfileUpdate>(defaultContext,
                                                      listen: false)
                                                  .userProfile
                                                  .pingpongCourt
                                                  ?.map((element) =>
                                                      element.roadAddress)
                                                  ?.contains(
                                                      chosenCourtRoadAddress) ??
                                              false
                                          ? chosenCourtRoadAddress
                                          : null,
                                      //iscourtAddressNotEmpty ? √ : '없음',
                                      items: Provider.of<ProfileUpdate>(defaultContext,
                                                      listen: false)
                                                  .userProfile
                                                  .pingpongCourt
                                                  !.map((element) =>
                                                      element.roadAddress ==
                                                      chosenCourtRoadAddress).isNotEmpty
                                          ? Provider.of<ProfileUpdate>(defaultContext,
                                                  listen: false)
                                              .userProfile
                                              .pingpongCourt
                                              ?.map((element) => DropdownMenuItem(
                                                    value: element.roadAddress,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          element.title,
                                                          style:
                                                              kAppointmentCourtTextButtonStyle,
                                                        ),
                                                        Text(
                                                          element.roadAddress,
                                                          style:
                                                              kAppointmentCourtTextButtonStyle
                                                                  .copyWith(
                                                            fontSize: 10.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList()
                                          : [
                                              DropdownMenuItem(
                                                value: chosenCourtRoadAddress,
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      chosenCourtName,
                                                      style:
                                                      kAppointmentTextButtonStyle,
                                                    ),
                                                    Text(
                                                      chosenCourtRoadAddress,
                                                      style:
                                                      kAppointmentTextButtonStyle
                                                          .copyWith(
                                                        fontSize: 10.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                      onChanged: (value) {
                                        setState(() {
                                          chosenCourtRoadAddress =
                                              value.toString(); // 사용자가 선택한 값을 저장

                                          // foundCourt = Provider.of<ProfileUpdate>(
                                          //         defaultContext,
                                          //         listen: false)
                                          //     .userProfile
                                          //     .pingpongCourt
                                          //     ?.firstWhere((element) =>
                                          //         element.roadAddress ==
                                          //         chosenCourtRoadAddress);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '하루 종일',
                                    style: kAppointmentTextStyle,
                                  ),
                                  Checkbox(
                                    value: Provider.of<PersonalAppointmentUpdate>(
                                            defaultContext,
                                            listen: false)
                                        .isAllDay,
                                    onChanged: (value) {
                                      Provider.of<PersonalAppointmentUpdate>(
                                              defaultContext,
                                              listen: false)
                                          .updateIsAllDay();
                                    },
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: _onlyThisAppointment ? false : true,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '반복',
                                          style: kAppointmentTextStyle,
                                        ),
                                        RepeatAppointment(),
                                      ],
                                    ),
                                    Visibility(
                                      visible:
                                          Provider.of<PersonalAppointmentUpdate>(
                                                      defaultContext)
                                                  .repeatNo
                                              ? false
                                              : true,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '반복 횟수',
                                            style: kAppointmentTextStyle,
                                          ),
                                          RepeatTimes(Provider.of<
                                                      PersonalAppointmentUpdate>(
                                                  defaultContext)
                                              .repeatString),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: _editAppointment ? false : true,
                          // _editAppointment이 false 일때 보여야함
                          child: TextButton(
                            style: kElevationButtonDeletionStyle.copyWith(
                                backgroundColor:
                                    MaterialStatePropertyAll(kMainColor)),
                            child: Text(
                              '편집',
                              style: kAppointmentTextButtonStyle.copyWith(
                                  color: Colors.white),
                            ),
                            onPressed: () {
                              setState(() {
                                if (widget.oldMeeting.recurrenceRule == '') {
                                  // 단일 일정인 경우,
                                  _editAppointment = !_editAppointment;
                                } else {
                                  // 반복 일정인 경우
                                  showDialog(
                                      context: defaultContext,
                                      builder: (context) {
                                        return AlertDialog(
                                          insetPadding: EdgeInsets.only(
                                              left: 10.0, right: 10.0),
                                          shape: kRoundedRectangleBorder,
                                          actionsAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          actions: <Widget>[
                                            Column(
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    _onlyThisAppointment = true;
                                                    _editAppointment =
                                                        !_editAppointment;
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    '이 일정만',
                                                    style:
                                                        kAppointmentTextButtonStyle,
                                                  ),
                                                ),
                                                Divider(
                                                  thickness: 1.0,
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _onlyThisAppointment = false;
                                                    _editAppointment =
                                                        !_editAppointment;
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    '전체 일정 수정',
                                                    style:
                                                        kAppointmentTextButtonStyle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      });
                                }
                              });
                            },
                          ),
                        ), // 수정
                        Visibility(
                          visible: _editAppointment ? true : false,
                          //_editAppointment이 true 일때 보여야함
                          child: ElevatedButton(
                            style: kElevationButtonDeletionStyle,
                            child: Text(
                              '삭제',
                              style: kAppointmentTextButtonStyle.copyWith(
                                  color: Colors.white),
                            ),
                            onPressed: () {
                              showDialog(
                                context: defaultContext,
                                builder: (context) {
                                  return AlertDialog(
                                    insetPadding:
                                        EdgeInsets.only(left: 10.0, right: 10.0),
                                    shape: kRoundedRectangleBorder,
                                    title: Center(
                                      child: Text(
                                        '정말 일정을 삭제하시겠습니까?',
                                        style: kAppointmentDateTextStyle,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          '취소',
                                          style: kAppointmentTextButtonStyle,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {

                                          await toggleLoading(true, defaultContext);

                                          if (widget.oldMeeting.recurrenceRule ==
                                              '') {
                                            // 일반 일정 삭제
                                            await Provider.of<
                                                        PersonalAppointmentUpdate>(
                                                    defaultContext,
                                                    listen: false)
                                                .removeMeeting(widget.oldMeeting);

                                            db
                                                .collection("Appointments")
                                                .doc(oldmeetingAppointments?.id)
                                                .delete()
                                                .then(
                                                  (doc) =>
                                                      print("Document deleted"),
                                                  onError: (e) => print(
                                                      "Error updating document $e"),
                                                );
                                          } else {
                                            // 반복 일정 삭제
                                            if (_onlyThisAppointment != true) {
                                              // 전체 일정 삭제
                                              await Provider.of<
                                                          PersonalAppointmentUpdate>(
                                                  defaultContext,
                                                      listen: false)
                                                  .removeMeeting(
                                                      widget.oldMeeting);

                                              db
                                                  .collection("Appointments")
                                                  .doc(oldmeetingAppointments?.id)
                                                  .delete()
                                                  .then(
                                                    (doc) =>
                                                        print("Document deleted"),
                                                    onError: (e) => print(
                                                        "Error updating document $e"),
                                                  );
                                            } else {
                                              final _newMeeting = Appointment(
                                                startTime: Provider.of<
                                                            PersonalAppointmentUpdate>(
                                                    defaultContext,
                                                        listen: false)
                                                    .fromDate,
                                                endTime: Provider.of<
                                                            PersonalAppointmentUpdate>(
                                                    defaultContext,
                                                        listen: false)
                                                    .toDate,
                                                subject:
                                                    _eventNametextController.text,
                                                // color: Provider.of<
                                                //             PersonalAppointmentUpdate>(
                                                //         defaultContext,
                                                //         listen: false)
                                                //     .color,
                                                //Provider.of<AppointmentUpdate>(context, listen: false).isLesson,
                                                isAllDay: Provider.of<
                                                            PersonalAppointmentUpdate>(
                                                    defaultContext,
                                                        listen: false)
                                                    .isAllDay,
                                                notes: _memoTextController.text,
                                                recurrenceRule: Provider.of<
                                                            PersonalAppointmentUpdate>(
                                                    defaultContext,
                                                        listen: false)
                                                    .recurrenceRule,
                                              );

                                              await Provider.of<
                                                          PersonalAppointmentUpdate>(
                                                  defaultContext,
                                                      listen: false)
                                                  .addRecurrenceExceptionDates(
                                                      widget.oldMeeting,
                                                      _newMeeting,
                                                      _onlyThisAppointment,
                                                      true); // true 는 isDeletion으로 true 이면 삭제를 의미

                                              final docRef = db
                                                  .collection("Appointments")
                                                  .withConverter(
                                                    fromFirestore:
                                                        CustomAppointment
                                                            .fromFirestore,
                                                    toFirestore: (CustomAppointment
                                                                customAppointment,
                                                            options) =>
                                                        customAppointment
                                                            .toFirestore(),
                                                  )
                                                  .doc(
                                                      oldmeetingAppointments?.id);

                                              final newCustomAppointment =
                                                  CustomAppointment(
                                                      appointments: [_newMeeting],
                                                      pingpongCourtName:
                                                      chosenCourtName,
                                                      pingpongCourtAddress:
                                                          chosenCourtRoadAddress,
                                                      userUid: Provider.of<
                                                                  LoginStatusUpdate>(
                                                          defaultContext,
                                                              listen: false)
                                                          .currentUser
                                                          .uid);

                                              await docRef
                                                  .set(newCustomAppointment);
                                            }
                                          }

                                          await Provider.of<
                                                      PersonalAppointmentUpdate>(
                                              defaultContext,
                                                  listen: false)
                                              .personalDaywiseDurationsCalculate(
                                                  false,
                                                  true,
                                              chosenCourtName,
                                                  chosenCourtRoadAddress);
                                          await Provider.of<
                                                      PersonalAppointmentUpdate>(
                                              defaultContext,
                                                  listen: false)
                                              .personalCountHours(
                                                  false,
                                                  true,
                                              chosenCourtName,
                                              chosenCourtRoadAddress);

                                          await Provider.of<
                                                      PersonalAppointmentUpdate>(
                                              defaultContext,
                                                  listen: false)
                                              .clear();

                                          //await LoadData().refreshData(defaultContext);
                                          await refreshData(context);

                                          await toggleLoading(false, defaultContext);

                                          Navigator.of(context).pop();
                                          print('취소 완료');
                                          Navigator.of(widget.context).pop();
                                          print('showBottom 창 내리기 완료');
                                        },
                                        child: Text(
                                          '확인',
                                          style: kAppointmentTextButtonStyle
                                              .copyWith(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ), // 삭제
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
