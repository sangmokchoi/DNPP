import 'package:bottom_picker/bottom_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/models/pingpongList.dart';
import 'package:dnpp/widgets/chart/chart_repeat_appointment.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/customAppointment.dart';
import '../../models/userProfile.dart';
import '../../repository/repository_loadData.dart';
import '../../viewModel/courtAppointmentUpdate.dart';
import '../../viewModel/personalAppointmentUpdate.dart';
import '../../viewModel/loginStatusUpdate.dart';
import '../../viewModel/profileUpdate.dart';
import '../chart/chart_repeat_times.dart';

class AddAppointment extends StatefulWidget {
  AddAppointment({required this.userCourt, required this.context});

  final BuildContext context;
  final String userCourt;

  @override
  State<AddAppointment> createState() => _AddAppointmentState();
}

class _AddAppointmentState extends State<AddAppointment> {
  TextEditingController _eventNametextController = TextEditingController();
  TextEditingController _memoTextController = TextEditingController();

  String _eventName = '';
  String _memoText = '';

  String chosenCourtRoadAddress = '';

  PingpongList? foundCourt;

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
    _eventNametextController.addListener(() {});
    _memoTextController.addListener(() {});

    setState(() {
      if (Provider.of<ProfileUpdate>(context, listen: false)
          .userProfile
          .pingpongCourt!
          .isNotEmpty) {
        print('pingpongCourt isNotEmpty');

        foundCourt = Provider.of<ProfileUpdate>(context, listen: false)
            .userProfile
            .pingpongCourt!
            .first;

        chosenCourtRoadAddress =
            Provider.of<ProfileUpdate>(context, listen: false)
                .userProfile
                .pingpongCourt![0]
                .roadAddress;
      } else {
        print('pingpongCourt isEmpty');
        print('여기에서 유저 프로필 생성으로 안내 필요');

        chosenCourtRoadAddress = '없음';
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _eventNametextController.dispose();
    _memoTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext defaultContext) {
    final User _currentUser =
        Provider.of<LoginStatusUpdate>(defaultContext, listen: false).currentUser;
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Padding(
            padding:
                EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              alignment: Alignment.centerLeft,
                            ),
                            onPressed: () async {
                              await Provider.of<PersonalAppointmentUpdate>(defaultContext,
                                      listen: false)
                                  .clear();
                              Navigator.pop(defaultContext);
                            },
                            child: Text(
                              '취소',
                              style: kElevationButtonStyle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '일정 추가',
                              style: kAppointmentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TextButton(
                            child: Text(
                              '저장',
                              style: kElevationButtonStyle,
                              textAlign: TextAlign.end,
                            ),
                            style: ButtonStyle(
                              alignment: Alignment.centerRight,
                            ),
                            onPressed: () async {
                              await toggleLoading(true, defaultContext);

                              Appointment meeting = Appointment(
                                startTime: Provider.of<PersonalAppointmentUpdate>(
                                        defaultContext,
                                        listen: false)
                                    .fromDate,
                                endTime: Provider.of<PersonalAppointmentUpdate>(
                                        defaultContext,
                                        listen: false)
                                    .toDate,
                                subject: _eventName,
                                //Provider.of<AppointmentUpdate>(context, listen: false).subject,//

                                // color: Provider.of<AppointmentUpdate>(context,
                                //         listen: false)
                                //     .color,

                                //Provider.of<AppointmentUpdate>(context, listen: false).isLesson,
                                isAllDay: Provider.of<PersonalAppointmentUpdate>(
                                        defaultContext,
                                        listen: false)
                                    .isAllDay,
                                notes: _memoText,
                                //Provider.of<AppointmentUpdate>(context, listen: false).notes,//
                                recurrenceRule:
                                    Provider.of<PersonalAppointmentUpdate>(defaultContext,
                                            listen: false)
                                        .recurrenceRule,
                              );

                              await Provider.of<PersonalAppointmentUpdate>(defaultContext,
                                      listen: false)
                                  .addMeeting(meeting);

                              // 여기에서 서버에 일정 등록 필요
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

                              final newCustomAppointment = CustomAppointment(
                                  appointments: [meeting],
                                  pingpongCourtName: foundCourt?.title ?? '',
                                  pingpongCourtAddress:
                                      foundCourt?.roadAddress ?? '',
                                  userUid: _currentUser.uid);

                              await docRef.set(newCustomAppointment);
                              print('docRef.set done');

                              // await Provider.of<AppointmentUpdate>(context,
                              //         listen: false)
                              //     .daywiseDurationsCalculate(false);
                              // await Provider.of<AppointmentUpdate>(context,
                              //         listen: false)
                              //    .countHours(false);

                              await Provider.of<PersonalAppointmentUpdate>(defaultContext,
                                      listen: false)
                                  .clear();

                              print('await LoadData().refreshData(context);');
                              //await LoadData().refreshData(context);
                              await refreshData(defaultContext);
                              print('await LoadData().refreshData(context);');
                              await toggleLoading(false, defaultContext);

                              Navigator.pop(defaultContext);
                            },
                          ),
                        ],
                      ),
                      TextFormField(
                        //controller: _eventNametextController,
                        decoration:
                            InputDecoration(labelText: '일정 제목', hintText: '예) 레슨'),
                        style: kAppointmentDateTextStyle,
                        onChanged: (value) {
                          _eventName = value;
                          //Provider.of<AppointmentUpdate>(context, listen: false).updateSubject(value);
                        },
                      ),
                      TextFormField(
                        //controller: _memoTextController,
                        decoration: InputDecoration(labelText: '메모'),
                        style: kAppointmentDateTextStyle,
                        onChanged: (value) {
                          _memoText = value;
                          //Provider.of<AppointmentUpdate>(context, listen: false).updateNotes(value);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      Visibility(
                        visible:
                            Provider.of<PersonalAppointmentUpdate>(defaultContext).isAllDay
                                ? false
                                : true,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    DateFormat('yyyy. MM. dd. (E) HH:mm', 'ko')
                                        .format(
                                            Provider.of<PersonalAppointmentUpdate>(
                                                    defaultContext,
                                                    listen: false)
                                                .fromDate),
                                    style: kAppointmentDateTextStyle,
                                  ),
                                  Text(
                                    DateFormat('yyyy. MM. dd. (E) HH:mm', 'ko')
                                        .format(
                                            Provider.of<PersonalAppointmentUpdate>(
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
                                        Provider.of<PersonalAppointmentUpdate>(
                                                defaultContext,
                                                listen: false)
                                            .fromDate,
                                    startFirstDate: DateTime(2000),
                                    startLastDate: DateTime.now().add(
                                      const Duration(days: 10956),
                                    ),
                                    endInitialDate:
                                        Provider.of<PersonalAppointmentUpdate>(
                                                defaultContext,
                                                listen: false)
                                            .toDate,
                                    endFirstDate: DateTime(2000),
                                    endLastDate: DateTime.now().add(
                                      const Duration(days: 10956),
                                    ),
                                    is24HourMode: false,
                                    isShowSeconds: false,
                                    minutesInterval: 5,
                                    secondsInterval: 1,
                                    borderRadius:
                                        const BorderRadius.all(Radius.circular(16)),
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
                                    print(dateTimeList); // 여기에 시작 시간과 종료시간이 담김

                                    if (dateTimeList.first
                                        .isAfter(dateTimeList.last)) {
                                      // 시작일이 종료일보다 느린 상태이므로 에러임.
                                      print('시작일이 종료일보다 느린 상태이므로 에러임');

                                      showDialog(
                                          context: defaultContext,
                                          builder: (context) {
                                            return AlertDialog(
                                              insetPadding: EdgeInsets.only(
                                                  left: 10.0, right: 10.0),
                                              shape: kRoundedRectangleBorder,
                                              content: Text('시작일은 종료일보다 늦어야 합니다'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
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
                                          .updateFromDate(dateTimeList.first);
                                      Provider.of<PersonalAppointmentUpdate>(
                                              defaultContext,
                                              listen: false)
                                          .updateToDate(dateTimeList.last);
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
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       '다른 사람에게 일정 보이기',
                      //       style: kAppointmentTextStyle,
                      //     ),
                      //     Checkbox(
                      //       value: Provider.of<AppointmentUpdate>(context,
                      //               listen: false)
                      //           .isOpened,
                      //       onChanged: (value) {
                      //         Provider.of<AppointmentUpdate>(context, listen: false)
                      //             .updateIsOpened();
                      //       },
                      //     ),
                      //   ],
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '탁구장',
                            style: kAppointmentTextStyle,
                          ),
                          DropdownButton(
                            value: chosenCourtRoadAddress,
                            items: (chosenCourtRoadAddress != '없음')
                                ? Provider.of<ProfileUpdate>(defaultContext, listen: false)
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
                                                style: kAppointmentTextButtonStyle,
                                              ),
                                              Text(
                                                element.roadAddress,
                                                style: kAppointmentTextButtonStyle
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
                                      child: Text(
                                        chosenCourtRoadAddress,
                                        style: kAppointmentTextButtonStyle,
                                      ),
                                    ),
                                  ],
                            onChanged: (value) {
                              setState(() {
                                print(value);
                                chosenCourtRoadAddress =
                                    value.toString(); // 사용자가 선택한 값을 저장

                                foundCourt = Provider.of<ProfileUpdate>(defaultContext,
                                        listen: false)
                                    .userProfile
                                    .pingpongCourt
                                    ?.firstWhere((element) =>
                                        element.roadAddress ==
                                        chosenCourtRoadAddress);
                              });
                            },
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
                            value: Provider.of<PersonalAppointmentUpdate>(defaultContext,
                                    listen: false)
                                .isAllDay,
                            onChanged: (value) {
                              Provider.of<PersonalAppointmentUpdate>(defaultContext,
                                      listen: false)
                                  .updateIsAllDay();
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Provider.of<PersonalAppointmentUpdate>(defaultContext).repeatNo
                                ? false
                                : true,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '반복 횟수',
                              style: kAppointmentTextStyle,
                            ),
                            RepeatTimes(
                                Provider.of<PersonalAppointmentUpdate>(defaultContext)
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
        ),
      ),
    );
  }
}
