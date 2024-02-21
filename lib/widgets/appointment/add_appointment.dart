import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/models/pingpongList.dart';
import 'package:dnpp/repository/launchUrl.dart';
import 'package:dnpp/widgets/chart/chart_repeat_appointment.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/customAppointment.dart';

import '../../repository/repository_userData.dart';
import '../../statusUpdate/courtAppointmentUpdate.dart';
import '../../statusUpdate/personalAppointmentUpdate.dart';
import '../../statusUpdate/loginStatusUpdate.dart';
import '../../statusUpdate/profileUpdate.dart';
import '../chart/chart_repeat_times.dart';

class AddAppointment extends StatefulWidget {
  AddAppointment({required this.userCourt});

  final String userCourt;

  @override
  State<AddAppointment> createState() => _AddAppointmentState();
}

class _AddAppointmentState extends State<AddAppointment> {
  TextEditingController _eventNametextController = TextEditingController();
  TextEditingController _memoTextController = TextEditingController();

  String chosenCourtRoadAddress = '';

  PingpongList? foundCourt;

  FirebaseFirestore db = FirebaseFirestore.instance;

  void toggleLoading(bool isLoading, BuildContext context) {
    //setState(() {
      if (isLoading) {
        // 로딩 바를 화면에 표시
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
    //});
  }

  Future<void> refreshData(BuildContext context) async {

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

        chosenCourtRoadAddress = '';
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
                              toggleLoading(true, defaultContext);

                              Appointment meeting = Appointment(
                                startTime: Provider.of<PersonalAppointmentUpdate>(
                                        defaultContext,
                                        listen: false)
                                    .fromDate,
                                endTime: Provider.of<PersonalAppointmentUpdate>(
                                        defaultContext,
                                        listen: false)
                                    .toDate,
                                subject: _eventNametextController.text,
                                //Provider.of<AppointmentUpdate>(context, listen: false).subject,//

                                // color: Provider.of<AppointmentUpdate>(context,
                                //         listen: false)
                                //     .color,

                                //Provider.of<AppointmentUpdate>(context, listen: false).isLesson,
                                isAllDay: Provider.of<PersonalAppointmentUpdate>(
                                        defaultContext,
                                        listen: false)
                                    .isAllDay,
                                notes: _memoTextController.text,
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

                              await Provider.of<PersonalAppointmentUpdate>(defaultContext,
                                      listen: false)
                                  .clear();

                              await refreshData(defaultContext).then((value) async {
                                print('await LoadData().refreshData(context);');
                                //await LoadData().fetchUserData(context);
                                await RepositoryUserData().fetchUserData(context).then((value) {
                                  toggleLoading(false, defaultContext);

                                  setState(() {
                                    LaunchUrl().alertFunc(context, '알림', '일정이 등록되었습니다', '확인', () {
                                      Navigator.pop(defaultContext);
                                    });
                                  });

                                });
                              });

                            },
                          ),
                        ],
                      ),
                      TextField(
                        controller: _eventNametextController,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration:
                            InputDecoration(
                                labelText: '일정 제목',
                                hintText: '예) 레슨',
                            ),
                        style: kAppointmentDateTextStyle,
                        // onChanged: (value) {
                        //   _eventName = value;
                        //   //Provider.of<AppointmentUpdate>(context, listen: false).updateSubject(value);
                        // },
                      ),
                      Container(
                        height: 120,
                        margin: EdgeInsets.only(top: 15.0),
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(15)),
                          border: Border.all(
                              color: Colors.grey, width: 0.3),
                        ),
                        child: TextField(
                          controller: _memoTextController,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            labelText: '메모'
                          ),
                          maxLines: null,
                          style: kAppointmentDateTextStyle,
                          // onChanged: (value) {
                          //   _memoText = value;
                          //   //Provider.of<AppointmentUpdate>(context, listen: false).updateNotes(value);
                          // },
                        ),
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
                      SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '탁구장',
                            style: kAppointmentTextStyle,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: (chosenCourtRoadAddress != '') ? chosenCourtRoadAddress : null,
                              items: (chosenCourtRoadAddress != '')
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
                                                  style: kAppointmentCourtTextButtonStyle,
                                                ),
                                                Text(
                                                  element.roadAddress,
                                                  style: kAppointmentCourtTextButtonStyle
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
