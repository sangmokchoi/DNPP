import 'package:bottom_picker/bottom_picker.dart';
import 'package:dnpp/widgets/chart/chart_repeat_appointment.dart';

import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../constants.dart';
import '../../view/home_screen.dart';
import '../../viewModel/appointmentUpdate.dart';
import '../chart/chart_repeat_times.dart';

class EditAppointment extends StatefulWidget {
  EditAppointment(
      {required this.friendCode,
      required this.userCourt,
      required this.oldMeeting});

  final String friendCode;
  final String userCourt;
  final Appointment oldMeeting;

  @override
  State<EditAppointment> createState() => _EditAppointmentState();
}

class _EditAppointmentState extends State<EditAppointment> {
  String _eventName = '';
  String _memoText = '';

  TextEditingController _eventNametextController = TextEditingController();
  TextEditingController _memoTextController = TextEditingController();

  bool _editAppointment = false;
  bool _onlyThisAppointment = false;

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

        await Provider.of<AppointmentUpdate>(context, listen: false)
            .updateRepeat('매일');
        await Provider.of<AppointmentUpdate>(context, listen: false)
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

        await Provider.of<AppointmentUpdate>(context, listen: false)
            .updateRepeat('매주');
        await Provider.of<AppointmentUpdate>(context, listen: false)
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

        await Provider.of<AppointmentUpdate>(context, listen: false)
            .updateRepeat('매월');
        await Provider.of<AppointmentUpdate>(context, listen: false)
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

        await Provider.of<AppointmentUpdate>(context, listen: false)
            .updateRepeat('매년');
        await Provider.of<AppointmentUpdate>(context, listen: false)
            .updateRecurrenceRules('매년', count);
        print('YEARLY');
      } else {
        await Provider.of<AppointmentUpdate>(context, listen: false)
            .updateRepeat('반복 안 함');
        await Provider.of<AppointmentUpdate>(context, listen: false)
            .updateRecurrenceRules('반복 안 함', 1);
        print('반복 안 함');
      }
    } else {
      // recurrenceRule == null 이므로 반복 일정이 아님
      await Provider.of<AppointmentUpdate>(context, listen: false)
          .updateRepeat('반복 안 함');
      await Provider.of<AppointmentUpdate>(context, listen: false)
          .updateRecurrenceRules('반복 안 함', 1);
      print('반복 안 함');
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
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
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
                              Navigator.pop(context);
                              await Provider.of<AppointmentUpdate>(context,
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
                                    // final DateTime exceptionDate = DateTime(
                                    //     Provider.of<AppointmentUpdate>(context, listen: false).fromDate.year,
                                    //     Provider.of<AppointmentUpdate>(context, listen: false).fromDate.month,
                                    //     Provider.of<AppointmentUpdate>(context, listen: false).fromDate.day
                                    //   //   widget.oldMeeting.startTime.year,
                                    //   // widget.oldMeeting.startTime.month,
                                    //   // widget.oldMeeting.startTime.day,
                                    // );
                                    //
                                    // widget.oldMeeting.recurrenceExceptionDates =
                                    // [exceptionDate];

                                    //print("oldMeeting.id: ${widget.oldMeeting.id}");
                                    //print("widget.oldMeeting.recurrenceExceptionDates: ${widget.oldMeeting.recurrenceExceptionDates}");
                                    //Provider.of<AppointmentUpdate>(context, listen: false).removeMeeting(widget.oldMeeting);
                                    //Provider.of<AppointmentUpdate>(context, listen: false).addMeeting(widget.oldMeeting);

                                    final _newMeeting = Appointment(
                                      startTime: Provider.of<AppointmentUpdate>(context, listen: false).fromDate,
                                      endTime: Provider.of<AppointmentUpdate>(context, listen: false).toDate,
                                      subject: _eventNametextController.text,
                                      color: Provider.of<AppointmentUpdate>(context, listen: false).color,
                                      //Provider.of<AppointmentUpdate>(context, listen: false).isLesson,
                                      isAllDay: Provider.of<AppointmentUpdate>(context, listen: false).isAllDay,
                                      notes: _memoTextController.text,
                                      recurrenceRule: Provider.of<AppointmentUpdate>(context, listen: false).recurrenceRule,
                                    );

                                    // if (widget.oldMeeting.recurrenceRule == ''){ // 해당 일정만 변경
                                    //   _onlyThisAppointment = true;
                                    // } else {
                                    //   _onlyThisAppointment = false;
                                    // }

                                    await Provider.of<AppointmentUpdate>(context, listen: false).addRecurrenceExceptionDates(widget.oldMeeting, _newMeeting, _onlyThisAppointment, false);
                                    // await Provider.of<AppointmentUpdate>(context,
                                    //         listen: false)
                                    //     .updateMeeting(widget.oldMeeting, _newMeeting);
                                    await Provider.of<AppointmentUpdate>(context,
                                        listen: false)
                                        .daywiseDurationsCalculate(false);
                                    await Provider.of<AppointmentUpdate>(context, listen: false)
                                        .countHours(false);
                                    await Provider.of<AppointmentUpdate>(context, listen: false).clear();
                                    Navigator.pop(context);
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
                              visible: Provider.of<AppointmentUpdate>(context)
                                      .isAllDay
                                  ? false
                                  : true,
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
                                        DateFormat('yyyy. MM. dd. (E) HH:mm', 'ko').format(
                                            Provider.of<AppointmentUpdate>(context, listen: false).fromDate
                                        ),
                                        style: kAppointmentDateTextStyle,
                                      ),
                                      Text(
                                        DateFormat('yyyy. MM. dd. (E) HH:mm', 'ko').format(
                                            Provider.of<AppointmentUpdate>(context, listen: false).toDate
                                        ),
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
                                        context: context,
                                        startInitialDate:
                                            widget.oldMeeting.startTime,
                                        startFirstDate: DateTime(2000),
                                        startLastDate: DateTime.now().add(const Duration(days: 10956),),
                                        endInitialDate:
                                            widget.oldMeeting.endTime,
                                        endFirstDate: DateTime(2000),
                                        endLastDate: DateTime.now().add(const Duration(days: 10956),),
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
                                        transitionDuration: const Duration(milliseconds: 200),
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
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  content: Text(
                                                      '시작일은 종료일보다 늦어야 합니다'),
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
                                          Provider.of<AppointmentUpdate>(context, listen: false).updateFromDate(dateTimeList.first);
                                          Provider.of<AppointmentUpdate>(context, listen: false).updateToDate(dateTimeList.last);
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '다른 사람에게 일정 보이기',
                                  style: kAppointmentTextStyle,
                                ),
                                Checkbox(
                                  value: Provider.of<AppointmentUpdate>(context, listen: false).isOpened,
                                  onChanged: (value) {
                                    Provider.of<AppointmentUpdate>(context, listen: false).updateIsOpened();
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
                                  value: Provider.of<AppointmentUpdate>(context, listen: false).isAllDay,
                                  onChanged: (value) {
                                    Provider.of<AppointmentUpdate>(context, listen: false).updateIsAllDay();
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
                                        Provider.of<AppointmentUpdate>(context).repeatNo ? false : true,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '반복 횟수',
                                          style: kAppointmentTextStyle,
                                        ),
                                        RepeatTimes(Provider.of<AppointmentUpdate>(context).repeatString),
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
                        child: ElevatedButton(
                          style: kElevationButtonDeletionStyle.copyWith(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.blueAccent)),
                          child: Text(
                            '수정',
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
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        actionsAlignment: MainAxisAlignment.spaceEvenly,
                                        actions: <Widget>[
                                          Column(
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  _onlyThisAppointment = true;
                                                  _editAppointment = !_editAppointment;
                                                  Navigator.pop(context);
                                                },
                                                child: Text('이 일정만', style: kAppointmentTextButtonStyle,),
                                              ),
                                              Divider(
                                                thickness: 1.0,
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _onlyThisAppointment = false;
                                                  _editAppointment = !_editAppointment;
                                                  Navigator.pop(context);
                                                },
                                                child: Text('전체 일정 수정', style: kAppointmentTextButtonStyle,),
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
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    '정말 일정을 삭제하시겠습니까?',
                                    style: kAppointmentDateTextStyle,
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

                                        if (widget.oldMeeting.recurrenceRule == '') { // 일반 일정 삭제
                                          await Provider.of<AppointmentUpdate>(context, listen: false).removeMeeting(widget.oldMeeting);
                                        } else { // 반복 일정 삭제
                                          if (_onlyThisAppointment != true){ // 전체 일정 삭제
                                            await Provider.of<AppointmentUpdate>(context, listen: false).removeMeeting(widget.oldMeeting);
                                          } else {
                                            final _newMeeting = Appointment(
                                              startTime: Provider
                                                  .of<AppointmentUpdate>(
                                                  context, listen: false)
                                                  .fromDate,
                                              endTime: Provider
                                                  .of<AppointmentUpdate>(
                                                  context, listen: false)
                                                  .toDate,
                                              subject: _eventNametextController
                                                  .text,
                                              color: Provider
                                                  .of<AppointmentUpdate>(
                                                  context, listen: false)
                                                  .color,
                                              //Provider.of<AppointmentUpdate>(context, listen: false).isLesson,
                                              isAllDay: Provider
                                                  .of<AppointmentUpdate>(
                                                  context, listen: false)
                                                  .isAllDay,
                                              notes: _memoTextController.text,
                                              recurrenceRule: Provider
                                                  .of<AppointmentUpdate>(
                                                  context, listen: false)
                                                  .recurrenceRule,
                                            );

                                            await Provider.of<
                                                AppointmentUpdate>(
                                                context, listen: false)
                                                .addRecurrenceExceptionDates(
                                                widget.oldMeeting, _newMeeting,
                                                _onlyThisAppointment,
                                            true); // true 는 isDeletion으로 true 이면 삭제를 의미
                                          }
                                          }

                                        await Provider.of<AppointmentUpdate>(context, listen: false).clear();
                                        await Provider.of<AppointmentUpdate>(context,
                                            listen: false)
                                            .daywiseDurationsCalculate(false);
                                        await Provider.of<AppointmentUpdate>(context, listen: false)
                                            .countHours(false);
                                        Navigator.pop(context);
                                        Navigator.pushNamed(context, HomeScreen.id);
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
    );
  }
}
