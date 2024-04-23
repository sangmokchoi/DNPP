import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/models/colorType.dart';
import 'package:dnpp/repository/firebase_firestore_appointments.dart';
import 'package:dnpp/repository/firebase_firestore_userData.dart';

import 'package:dnpp/viewModel/CalendarScreen_ViewModel.dart';
import 'package:dnpp/widgets/chart/chart_repeat_appointment.dart';

import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../LocalDataSource/firebase_fireStore/DS_Local_appointments.dart';
import '../../constants.dart';
import '../../models/customAppointment.dart';
import '../../models/launchUrl.dart';
import '../../statusUpdate/googleAnalytics.dart';
import '../../LocalDataSource/firebase_fireStore/DS_Local_userData.dart';
import '../../statusUpdate/courtAppointmentUpdate.dart';
import '../../statusUpdate/loginStatusUpdate.dart';
import '../../statusUpdate/personalAppointmentUpdate.dart';
import '../../statusUpdate/profileUpdate.dart';
import '../chart/chart_repeat_times.dart';
import 'package:uuid/uuid.dart';

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
  String oldCourtName = '';
  String oldCourtRoadAddress = '';
  String chosenCourtName = '없음';
  String chosenCourtRoadAddress = '없음';

  CustomAppointment? oldMeetingAppointment;
  String customAppointmentID = '';

  TextEditingController _eventNametextController = TextEditingController();
  TextEditingController _memoTextController = TextEditingController();

  bool _editAppointment = false;
  bool _onlyThisAppointment = false;

  FirebaseFirestore db = FirebaseFirestore.instance;

  int colorNum = 5;
  bool colorShows = false;

  late PersonalAppointmentUpdate personalAppointmentUpdate;

  @override
  void initState() {

    personalAppointmentUpdate = Provider.of<PersonalAppointmentUpdate>(context, listen: false);

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
      if (personalAppointmentUpdate
          .customAppointmentMeetings
          .isNotEmpty) {
        print('customAppointmentMeetings isNotEmpty');
        print(
            'widget.oldMeeting: ${personalAppointmentUpdate.customAppointmentMeetings}');
        print('widget.oldMeeting: ${widget.oldMeeting}');
        print('oldmeetingAppointments: ${oldMeetingAppointment?.appointments}');

        print(
            "oldmeetingAppointments: ${personalAppointmentUpdate.customAppointmentMeetings.where((customAppointment) {
          return customAppointment.appointments
              .any((appointment) => appointment.id == widget.oldMeeting.id);
        })}");

        print(
            'oldmeetingAppointments: ${oldMeetingAppointment?.appointments.length}');
        print(
            'oldmeetingAppointments: ${oldMeetingAppointment?.appointments.first}');
        //customAppointmentID = oldMeetingAppointment!.id!;

        try {
          Color color = widget.oldMeeting.color;
          colorNum = findMatchingIndex(color);
          // oldMeetingAppointments = Provider.of<PersonalAppointmentUpdate>(
          //   context,
          //   listen: false,
          // ).customAppointmentMeetings.firstWhere((customAppointment) =>
          //     customAppointment.appointments.contains(widget.oldMeeting));
          oldMeetingAppointment = Provider.of<PersonalAppointmentUpdate>(
            context,
            listen: false,
          )
              .customAppointmentMeetings
              .where((customAppointment) => customAppointment.appointments
                  .any((appointment) => appointment.id == widget.oldMeeting.id))
              .first;

          //customAppointmentID = oldMeetingAppointment!.id!;
          print(
              'oldmeetingAppointments: ${oldMeetingAppointment?.appointments.length}');
          print(
              'oldmeetingAppointments: ${oldMeetingAppointment?.appointments.first}');
        } catch (e) {
          print('customAppointmentID = oldmeetingAppointments!.id; 실패 $e');
        }

        if (oldMeetingAppointment != null) {
          if (oldMeetingAppointment!.pingpongCourtAddress.isNotEmpty) {
            chosenCourtRoadAddress =
                oldMeetingAppointment!.pingpongCourtAddress;
            chosenCourtName = oldMeetingAppointment!.pingpongCourtName;
            print('chosenCourtRoadAddress: ${chosenCourtRoadAddress}');
            print('chosenCourtName: ${chosenCourtName}');

            iscourtAddressNotEmpty = true;

            print('1 1 1 1');
          } else {
            print('2 2 2 2');
          }
        }
      } else {
        print('customAppointmentMeetings isEmpty');
        print('여기에서 유저 프로필 생성으로 안내 필요');
      }
    });

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 상태 변경 작업을 여기에 넣습니다.
      checkOldMeeting();
      await GoogleAnalytics().trackScreen(context, 'EditAppointment');
      Provider.of<GoogleAnalyticsNotifier>(context, listen: false).startTimer('CalendarScreen');
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    // Future.microtask(() {
    //   //if (mounted) {
    //     Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
    //         .startTimer('EditAppointment');
    //   //}
    // });
  }

  @override
  void dispose() {
    _eventNametextController.dispose();
    _memoTextController.dispose();

    colorNum = 5;

    super.dispose();
  }

  @override
  Widget build(BuildContext defaultContext) {
    return Consumer<PersonalAppointmentUpdate>(
      builder: (context, personalAppointmentUpdate, child) {
        return SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 5.0, bottom: 10.0),
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
                                    Future.microtask(() async {
                                      await personalAppointmentUpdate.clear();
                                      await Provider.of<GoogleAnalyticsNotifier>(context, listen: false)
                                          .startTimer('EditAppointment');
                                    }).then((value) {
                                      Navigator.pop(defaultContext);
                                    });

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
                                  child: _editAppointment
                                      ? Text(
                                          '저장',
                                          style: kElevationButtonStyle,
                                        )
                                      : Text(
                                          '편집',
                                          style: kElevationButtonStyle,
                                        ),
                                  onPressed: _editAppointment
                                      ? () async {
                                          await toggleLoading(true, defaultContext);

                                          var _newMeeting = Appointment(
                                            startTime: personalAppointmentUpdate
                                                .fromDate,
                                            endTime: personalAppointmentUpdate
                                                .toDate,
                                            // id: Provider.of<
                                            //     PersonalAppointmentUpdate>(
                                            //     defaultContext,
                                            //     listen: false).id,
                                            subject: _eventNametextController.text,
                                            color: Provider.of<
                                                        PersonalAppointmentUpdate>(
                                                    context,
                                                    listen: false)
                                                .color,
                                            isAllDay: personalAppointmentUpdate
                                                .isAllDay,
                                            notes: _memoTextController.text,
                                            // recurrenceRule: Provider.of<
                                            //             PersonalAppointmentUpdate>(
                                            //         defaultContext,
                                            //         listen: false)
                                            //     .recurrenceRule,
                                          );

                                          var _oldMeeting = oldMeetingAppointment!
                                              .appointments.first;
                                          print('before old: $_oldMeeting');
                                          print('before old: ${widget.oldMeeting}');

                                          if (widget.oldMeeting.recurrenceRule ==
                                                  null ||
                                              widget.oldMeeting.recurrenceRule!
                                                  .isEmpty) {
                                            print('일반 일');
                                            //
                                            // 일반 일정
                                            //
                                            //if (_oldMeeting.recurrenceExceptionDates == null || _oldMeeting.recurrenceExceptionDates!.isEmpty) {
                                            // 일반 일정 편집하는 상황
                                            _newMeeting.id = personalAppointmentUpdate
                                                .id;

                                            _newMeeting.recurrenceRule = Provider
                                                    .of<PersonalAppointmentUpdate>(
                                                        defaultContext,
                                                        listen: false)
                                                .recurrenceRule;

                                            // if (widget.oldMeeting.recurrenceId != null) {
                                            //   // 이미 한 번 수정된 반복 일정이므로, 기존의 전체 일정을 수정하게끔해서는 안됨
                                            //   //recurrenceId 는 기존대로 가져감
                                            //   _newMeeting.recurrenceId = widget.oldMeeting.recurrenceId;
                                            // } else {
                                            //   _newMeeting.recurrenceId = null;
                                            // }
                                            _newMeeting.recurrenceId = null;

                                            print('last _newMeeting: $_newMeeting');

                                            final newCustomAppointment =
                                                CustomAppointment(
                                              appointments: [_newMeeting], //[old],
                                              pingpongCourtName: chosenCourtName,
                                              pingpongCourtAddress:
                                                  chosenCourtRoadAddress,
                                              userUid:
                                                  Provider.of<LoginStatusUpdate>(
                                                          defaultContext,
                                                          listen: false)
                                                      .currentUser
                                                      .uid,
                                            );

                                            await RepositoryFirestoreAppointments()
                                                .getUpdateAppointment(
                                                    oldMeetingAppointment!.id!,
                                                    newCustomAppointment);
                                            //}
                                          } else {
                                            print('반복 일정');
                                            //
                                            // 반복 일정
                                            //
                                            if (_onlyThisAppointment == true) {
                                              // 이 일정만 수정
                                              print('이 일정만 수정');

                                              final exceptedNewMeeting =
                                                  _newMeeting; // 예외 일정 등록을 위해 _newMeeting을 복사해놓은 변수

                                              //_oldMeeting.startTime = widget.oldMeeting.startTime;
                                              //_oldMeeting.endTime = widget.oldMeeting.endTime;

                                              exceptedNewMeeting.id =
                                                  const Uuid().v4();
                                              exceptedNewMeeting
                                                  .recurrenceId = Provider.of<
                                                          PersonalAppointmentUpdate>(
                                                      defaultContext,
                                                      listen: false)
                                                  .id;
                                              exceptedNewMeeting
                                                  .recurrenceExceptionDates = [];
                                              exceptedNewMeeting.recurrenceRule =
                                                  null;

                                              final exceptedNewCustomAppointment =
                                                  CustomAppointment(
                                                appointments: [exceptedNewMeeting],
                                                pingpongCourtName: chosenCourtName,
                                                pingpongCourtAddress:
                                                    chosenCourtRoadAddress,
                                                userUid:
                                                    Provider.of<LoginStatusUpdate>(
                                                            defaultContext,
                                                            listen: false)
                                                        .currentUser
                                                        .uid,
                                              );

                                              await RepositoryFirestoreAppointments()
                                                  .getAddAppointment(
                                                      exceptedNewCustomAppointment);

                                              // 기존 일정에서 recurrenceExceptionDate만 추가

                                              // _oldMeeting.id = Provider
                                              //     .of<
                                              //     PersonalAppointmentUpdate>(
                                              //     defaultContext,
                                              //     listen: false)
                                              //     .id;
                                              _oldMeeting.id = widget.oldMeeting.id;

                                              _oldMeeting.recurrenceRule = Provider
                                                      .of<PersonalAppointmentUpdate>(
                                                          defaultContext,
                                                          listen: false)
                                                  .recurrenceRule;
                                              _oldMeeting.recurrenceId = null;

                                              if (_oldMeeting
                                                      .recurrenceExceptionDates !=
                                                  null) {
                                                _oldMeeting
                                                    .recurrenceExceptionDates!
                                                    .add(widget
                                                        .oldMeeting.startTime);
                                              } else {
                                                _oldMeeting
                                                    .recurrenceExceptionDates = [
                                                  widget.oldMeeting.startTime
                                                ];
                                              }

                                              final oldCustomAppointment =
                                                  CustomAppointment(
                                                appointments: [_oldMeeting],
                                                pingpongCourtName: oldCourtName,
                                                pingpongCourtAddress:
                                                    oldCourtRoadAddress,
                                                userUid:
                                                    Provider.of<LoginStatusUpdate>(
                                                            defaultContext,
                                                            listen: false)
                                                        .currentUser
                                                        .uid,
                                              );

                                              await RepositoryFirestoreAppointments()
                                                  .getUpdateAppointment(
                                                      oldMeetingAppointment!.id!,
                                                      oldCustomAppointment);
                                            } else {
                                              // 전체 일정 수정
                                              print('전체 일정 수정');
                                              // _newMeeting.id = Provider
                                              //     .of<
                                              //     PersonalAppointmentUpdate>(
                                              //     defaultContext,
                                              //     listen: false)
                                              //     .id;

                                              _newMeeting.id = widget.oldMeeting.id;
                                              _newMeeting.recurrenceRule = Provider
                                                      .of<PersonalAppointmentUpdate>(
                                                          defaultContext,
                                                          listen: false)
                                                  .recurrenceRule;

                                              // if (widget.oldMeeting.recurrenceId != null) {
                                              //   // 이미 한 번 수정된 반복 일정이므로, 기존의 전체 일정을 수정하게끔해서는 안됨
                                              //   //recurrenceId 는 기존대로 가져감
                                              //   _newMeeting.recurrenceId = widget.oldMeeting.recurrenceId;
                                              // } else {
                                              //   _newMeeting.recurrenceId = null;
                                              // }
                                              _newMeeting.recurrenceId = null;
                                              _newMeeting.recurrenceExceptionDates =
                                                  widget.oldMeeting
                                                      .recurrenceExceptionDates;

                                              print(
                                                  'last _newMeeting: $_newMeeting');

                                              final newCustomAppointment =
                                                  CustomAppointment(
                                                appointments: [
                                                  _newMeeting
                                                ], //[old],
                                                pingpongCourtName: chosenCourtName,
                                                pingpongCourtAddress:
                                                    chosenCourtRoadAddress,
                                                userUid:
                                                    Provider.of<LoginStatusUpdate>(
                                                            defaultContext,
                                                            listen: false)
                                                        .currentUser
                                                        .uid,
                                              );

                                              await RepositoryFirestoreAppointments()
                                                  .getUpdateAppointment(
                                                      oldMeetingAppointment!.id!,
                                                      newCustomAppointment);
                                            }
                                          }

                                          await Provider.of<
                                                      PersonalAppointmentUpdate>(
                                                  defaultContext,
                                                  listen: false)
                                              .daywiseDurationsCalculate(
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

                                          await RepositoryFirestoreUserData()
                                              .getFetchUserData(context)
                                              .then((value) async {
                                            // await MainScreenViewModel().jumpToChartPageZero();

                                            await toggleLoading(
                                                false, defaultContext);
                                          });

                                          Navigator.pop(defaultContext, () async {
                                            await Provider.of<
                                                        CalendarScreenViewModel>(
                                                    context,
                                                    listen: false)
                                                .notify();
                                          });
                                        }
                                      : () {
                                          setState(
                                            () {
                                              if (widget
                                                      .oldMeeting.recurrenceRule ==
                                                  '') {
                                                // 단일 일정인 경우,
                                                _editAppointment =
                                                    !_editAppointment;
                                              } else if (widget
                                                      .oldMeeting.recurrenceId !=
                                                  null) {
                                                // 이미 한 번 수정된 반복일정임
                                                _editAppointment =
                                                    !_editAppointment;
                                              } else {
                                                // 반복 일정인 경우
                                                showDialog(
                                                  context: defaultContext,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      insetPadding: EdgeInsets.only(
                                                          left: 10.0, right: 10.0),
                                                      shape:
                                                          kRoundedRectangleBorder,
                                                      // actionsAlignment:
                                                      //     MainAxisAlignment.spaceEvenly,
                                                      actions: <Widget>[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  top: 20.0),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                child: TextButton(
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      _onlyThisAppointment =
                                                                          true;
                                                                      _editAppointment =
                                                                          !_editAppointment;
                                                                      Navigator.pop(
                                                                          context);
                                                                    });
                                                                  },
                                                                  child: Text(
                                                                    '이 일정만 수정',
                                                                    style:
                                                                        kAppointmentTextButtonStyle,
                                                                  ),
                                                                ),
                                                              ),
                                                              Divider(
                                                                thickness: 1.0,
                                                              ),
                                                              Container(
                                                                height: 50,
                                                                child: TextButton(
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      _onlyThisAppointment =
                                                                          false;
                                                                      _editAppointment =
                                                                          !_editAppointment;
                                                                      Navigator.pop(
                                                                          context);
                                                                    });
                                                                  },
                                                                  child: Text(
                                                                    '전체 일정 수정',
                                                                    style:
                                                                        kAppointmentTextButtonStyle,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          );
                                        },
                                ),
                              ],
                            ), // 일정 수정을 수락한 경우 (저장 활성화)
                            IgnorePointer(
                              ignoring: _editAppointment ? false : true,
                              child: Column(
                                children: [
                                  TextField(
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    controller: _eventNametextController,
                                    decoration: InputDecoration(
                                        labelText: '일정 제목', hintText: '예) 레슨'),
                                    style: kAppointmentDateTextStyle,
                                    onChanged: (value) {
                                      _eventName = value;
                                    },
                                  ),
                                  Container(
                                    height: 120,
                                    margin: EdgeInsets.only(top: 15.0),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 0.0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      border: Border.all(
                                          color: Colors.grey, width: 0.3),
                                    ),
                                    child: TextField(
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      controller: _memoTextController,
                                      decoration: InputDecoration(
                                        focusedBorder: InputBorder.none,
                                        border: InputBorder.none,
                                        labelText: '메모',
                                      ),
                                      maxLines: null,
                                      style: kAppointmentDateTextStyle,
                                      onChanged: (value) {
                                        _memoText = value;
                                      },
                                    ),
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '색상',
                                        style: kAppointmentTextStyle,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 1,
                                              offset: Offset(0,
                                                  2), // changes position of shadow
                                            ),
                                          ],
                                          shape: BoxShape.circle,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              colorShows = !colorShows;
                                            });
                                          },
                                          child: CircleAvatar(
                                            backgroundColor:
                                                ColorType().colorList[colorNum],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 250),
                                    // Adjust the duration as needed
                                    height: colorShows ? 50 : 0,
                                    child: SingleChildScrollView(
                                        child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent.withOpacity(0.05),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                      ),
                                      child: Center(
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: ColorType().colorList.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, int index) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 3.0),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    colorNum = index;
                                                  });

                                                  await Provider.of<
                                                              PersonalAppointmentUpdate>(
                                                          context,
                                                          listen: false)
                                                      .updateColor(ColorType()
                                                          .colorList[colorNum])
                                                      .then((value) => {});
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                        offset: Offset(0,
                                                            2), // changes position of shadow
                                                      ),
                                                    ],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: CircleAvatar(
                                                    backgroundColor: ColorType()
                                                        .colorList[index],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )),
                                  ),
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
                                                DateFormat(
                                                        'yyyy. MM. dd. (E) HH:mm',
                                                        'ko')
                                                    .format(Provider.of<
                                                                PersonalAppointmentUpdate>(
                                                            defaultContext,
                                                            listen: false)
                                                        .fromDate),
                                                style: kAppointmentDateTextStyle,
                                              ),
                                              Text(
                                                DateFormat(
                                                        'yyyy. MM. dd. (E) HH:mm',
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
                                                borderRadius:
                                                    const BorderRadius.all(
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
                                                transitionDuration: const Duration(
                                                    milliseconds: 200),
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
                                                          content: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '시작일은 종료일보다 늦어야 합니다',
                                                                style:
                                                                    kAppointmentCourtAlertTextStyle,
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Center(
                                                                  child:
                                                                      Text('확인')),
                                                            )
                                                          ],
                                                        );
                                                      });
                                                } else {
                                                  print(
                                                      '시작일이 종료일보다 빠린 상태이므로 에러 아님');
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
                                              style: _editAppointment ? kAppointmentTextButtonStyle : kAppointmentTextButtonStyle.copyWith(color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '탁구장',
                                        style: kAppointmentTextStyle,
                                      ),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          padding:
                                              EdgeInsets.symmetric(horizontal: 8.0),
                                          value: Provider.of<ProfileUpdate>(
                                                          defaultContext,
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
                                          items: Provider.of<ProfileUpdate>(
                                                      defaultContext,
                                                      listen: false)
                                                  .userProfile
                                                  .pingpongCourt!
                                                  .map((element) =>
                                                      element.roadAddress ==
                                                      chosenCourtRoadAddress)
                                                  .isNotEmpty
                                              ? Provider.of<ProfileUpdate>(
                                                      defaultContext,
                                                      listen: false)
                                                  .userProfile
                                                  .pingpongCourt
                                                  ?.map((element) =>
                                                      DropdownMenuItem(
                                                        value: element.roadAddress,
                                                        child: ConstrainedBox(
                                                          constraints: BoxConstraints(
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.6),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                element.title,
                                                                style:
                                                                    kAppointmentCourtTextButtonStyle,
                                                              ),
                                                              Text(
                                                                element.roadAddress,
                                                                maxLines: 1,
                                                                style: kAppointmentCourtTextButtonStyle
                                                                    .copyWith(
                                                                        fontSize:
                                                                            8.0,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .fade),

                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ))
                                                  .toList()
                                              : [
                                                  DropdownMenuItem(
                                                    value: chosenCourtRoadAddress,
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          maxWidth:
                                                              MediaQuery.of(context)
                                                                      .size
                                                                      .width *
                                                                  0.7),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            chosenCourtName,
                                                            style:
                                                                kAppointmentTextButtonStyle,
                                                          ),
                                                          Text(
                                                            chosenCourtRoadAddress,
                                                            style: kAppointmentTextButtonStyle
                                                                .copyWith(
                                                                fontSize:
                                                                8.0,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .fade),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                          onChanged: (value) {
                                            setState(() {
                                              chosenCourtRoadAddress = value
                                                  .toString(); // 사용자가 선택한 값을 저장
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '하루 종일',
                                        style: kAppointmentTextStyle,
                                      ),
                                      Checkbox(
                                        value:
                                            Provider.of<PersonalAppointmentUpdate>(
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
                                    visible: _onlyThisAppointment ||
                                            (widget.oldMeeting.recurrenceId != null)
                                        ? false
                                        : true,
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
                                            RepeatAppointment(editAppointment: _editAppointment,),
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
                                  LaunchUrl().alertOkAndCancelFunc(
                                      defaultContext,
                                      '정말 일정을 삭제하시겠습니까?',
                                      '일정 삭제 시, 복구가 되지 않습니다',
                                      '취소',
                                      '삭제',
                                      kMainColor,
                                      Colors.red, () {
                                    // 취소 시 함수
                                    Navigator.of(defaultContext,
                                            rootNavigator: true)
                                        .pop();
                                  }, () async {
                                    // 확인 시 함수
                                    Navigator.of(defaultContext,
                                            rootNavigator: true)
                                        .pop();

                                    await toggleLoading(true, context);

                                    if (widget.oldMeeting.recurrenceRule == null ||
                                        widget.oldMeeting.recurrenceRule == '') {
                                      // 일반 일정
                                      if (widget.oldMeeting.recurrenceId != null) {
                                        // 이미 한 번 수정된 반복 일정
                                        await personalAppointmentUpdate
                                            .removeMeeting(widget.oldMeeting);

                                        await RepositoryFirestoreAppointments()
                                            .getRemoveAppointment(
                                                oldMeetingAppointment!.id!);
                                      } else {
                                        // 일반 일정 삭제
                                        await personalAppointmentUpdate
                                            .removeMeeting(widget.oldMeeting);

                                        await RepositoryFirestoreAppointments()
                                            .getRemoveAppointment(
                                                oldMeetingAppointment!.id!);
                                      }
                                    } else {
                                      // 반복 일정
                                      if (_onlyThisAppointment != true) {
                                        // 전체 일정 삭제
                                        await personalAppointmentUpdate
                                            .removeMeeting(widget.oldMeeting);

                                        await RepositoryFirestoreAppointments()
                                            .getRemoveAppointment(
                                                oldMeetingAppointment!.id!);
                                      } else {
                                        // 이 일정만 삭제
                                        // 이 일정만 삭제

                                        // final _newMeeting = Appointment(
                                        //   startTime: Provider.of<
                                        //               PersonalAppointmentUpdate>(
                                        //           defaultContext,
                                        //           listen: false)
                                        //       .fromDate,
                                        //   endTime: Provider.of<
                                        //               PersonalAppointmentUpdate>(
                                        //           defaultContext,
                                        //           listen: false)
                                        //       .toDate,
                                        //   subject: _eventNametextController.text,
                                        //   color: (Provider.of<PersonalAppointmentUpdate>(context,
                                        //       listen: false)
                                        //       .color),
                                        //   isAllDay: Provider.of<
                                        //               PersonalAppointmentUpdate>(
                                        //           defaultContext,
                                        //           listen: false)
                                        //       .isAllDay,
                                        //   notes: _memoTextController.text,
                                        //   recurrenceRule: Provider.of<
                                        //               PersonalAppointmentUpdate>(
                                        //           defaultContext,
                                        //           listen: false)
                                        //       .recurrenceRule,
                                        //   // recurrenceId: Provider.of<
                                        //   //     PersonalAppointmentUpdate>(
                                        //   //     defaultContext,
                                        //   //     listen: false).id,
                                        // );
                                        //
                                        // // await Provider.of<
                                        // //             PersonalAppointmentUpdate>(
                                        // //         defaultContext,
                                        // //         listen: false)
                                        // //     .addRecurrenceExceptionDates(
                                        // //         widget.oldMeeting,
                                        // //         _newMeeting,
                                        // //         _onlyThisAppointment,
                                        // //         true); // true 는 isDeletion으로 true 이면 삭제를 의미
                                        //
                                        //
                                        //
                                        // final newCustomAppointment =
                                        //     CustomAppointment(
                                        //         appointments: [_newMeeting],
                                        //         pingpongCourtName: chosenCourtName,
                                        //         pingpongCourtAddress:
                                        //             chosenCourtRoadAddress,
                                        //         userUid:
                                        //             Provider.of<LoginStatusUpdate>(
                                        //                     defaultContext,
                                        //                     listen: false)
                                        //                 .currentUser
                                        //                 .uid);
                                        //
                                        // RepositoryAppointments().reAddAppointment(
                                        //     oldMeetingAppointment!.id!,
                                        //     newCustomAppointment);

                                        await personalAppointmentUpdate
                                            .removeMeeting(widget.oldMeeting);

                                        await RepositoryFirestoreAppointments()
                                            .getRemoveAppointment(
                                                oldMeetingAppointment!.id!);

                                        var _oldMeeting = oldMeetingAppointment!
                                            .appointments.first;

                                        _oldMeeting.recurrenceExceptionDates
                                            ?.remove(personalAppointmentUpdate
                                                .fromDate);

                                        final oldCustomAppointment =
                                            CustomAppointment(
                                          appointments: [_oldMeeting],
                                          pingpongCourtName: oldCourtName,
                                          pingpongCourtAddress: oldCourtRoadAddress,
                                          userUid: Provider.of<LoginStatusUpdate>(
                                                  defaultContext,
                                                  listen: false)
                                              .currentUser
                                              .uid,
                                        );

                                        await RepositoryFirestoreAppointments()
                                            .getUpdateAppointment(
                                                oldMeetingAppointment!.id!,
                                                oldCustomAppointment);
                                      }
                                    }

                                    await personalAppointmentUpdate
                                        .daywiseDurationsCalculate(
                                            false,
                                            true,
                                            chosenCourtName,
                                            chosenCourtRoadAddress);
                                    await personalAppointmentUpdate
                                        .personalCountHours(
                                            false,
                                            true,
                                            chosenCourtName,
                                            chosenCourtRoadAddress);

                                    await RepositoryFirestoreUserData()
                                        .getFetchUserData(defaultContext)
                                        .then((value) {
                                      toggleLoading(false, defaultContext);
                                    });
                                  });
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
    );
  }

  Future<void> toggleLoading(bool isLoading, BuildContext context) async {
    //setState(() {
    if (isLoading) {
      // 로딩 바를 화면에 표시
      print('profileScreen 로딩 바를 화면에 표시');
      Future.delayed(Duration(seconds: 3));
      showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  '데이터를 업로드하는 중입니다',
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ],
            ), // 로딩 바 표시
          );
        },
      );
    } else {
      print('로딩 바 제거');
      //Navigator.pop(context);
      Navigator.of(context, rootNavigator: true).pop();
    }
    return;
    //});
  }

  void checkOldMeeting() async {
    String? recurrenceRule = widget.oldMeeting.recurrenceRule;
    print('checkOldMeeting recurrenceRule: $recurrenceRule');
    print('checkOldMeeting startTime: ${widget.oldMeeting.startTime}');
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

        await personalAppointmentUpdate
            .updateRepeat('매일');
        await personalAppointmentUpdate
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

        await personalAppointmentUpdate
            .updateRepeat('매주');
        await personalAppointmentUpdate
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

        await personalAppointmentUpdate
            .updateRepeat('매월');
        await personalAppointmentUpdate
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

        await personalAppointmentUpdate
            .updateRepeat('매년');
        await personalAppointmentUpdate
            .updateRecurrenceRules('매년', count);
        print('YEARLY');
      } else {
        await personalAppointmentUpdate
            .updateRepeat('반복 안 함');
        await personalAppointmentUpdate
            .updateRecurrenceRules('반복 안 함', 1);
        print('반복 안 함');
      }
    } else {
      // recurrenceRule == null 이므로 반복 일정이 아님
      await personalAppointmentUpdate
          .updateRepeat('반복 안 함');
      await personalAppointmentUpdate
          .updateRecurrenceRules('반복 안 함', 1);
      print('반복 안 함');
    }
  }

  int findMatchingIndex(Color color) {
    int index = -1;
    for (int i = 0; i < ColorType().colorList.length; i++) {
      if (color.value == ColorType().colorList[i].value) {
        index = i;
        break;
      }
    }
    return index;
  }
}
