import 'package:bottom_picker/bottom_picker.dart';
import 'package:dnpp/constants.dart';
import 'package:dnpp/widgets/chart/chart_repeat_appointment.dart';

import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../viewModel/appointmentUpdate.dart';
import '../chart/chart_repeat_times.dart';

class AddAppointment extends StatefulWidget {
  AddAppointment({required this.friendCode, required this.userCourt});

  final String friendCode;
  final String userCourt;

  @override
  State<AddAppointment> createState() => _AddAppointmentState();
}

class _AddAppointmentState extends State<AddAppointment> {
  TextEditingController _eventNametextController = TextEditingController();
  TextEditingController _memoTextController = TextEditingController();

  String _eventName = '';
  String _memoText = '';

  @override
  void initState() {
    _eventNametextController.addListener(() {});
    _memoTextController.addListener(() {});
    super.initState();
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
      color: Colors.white54,
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
                          await Provider.of<AppointmentUpdate>(context,
                                  listen: false)
                              .clear();
                          Navigator.pop(context);
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
                        style: ButtonStyle(alignment: Alignment.centerRight),
                        onPressed: () async {

                          Appointment meeting = Appointment(
                            startTime: Provider.of<AppointmentUpdate>(context,
                                    listen: false)
                                .fromDate,
                            endTime: Provider.of<AppointmentUpdate>(context,
                                    listen: false)
                                .toDate,
                            subject: _eventName,
                            //Provider.of<AppointmentUpdate>(context, listen: false).subject,//
                            color: Provider.of<AppointmentUpdate>(context,
                                    listen: false)
                                .color,
                            //Provider.of<AppointmentUpdate>(context, listen: false).isLesson,
                            isAllDay: Provider.of<AppointmentUpdate>(context,
                                    listen: false)
                                .isAllDay,
                            notes: _memoText,
                            //Provider.of<AppointmentUpdate>(context, listen: false).notes,//
                            recurrenceRule: Provider.of<AppointmentUpdate>(
                                    context,
                                    listen: false).recurrenceRule,
                          );

                          await Provider.of<AppointmentUpdate>(context,
                                  listen: false)
                              .addMeeting(meeting);
                          await Provider.of<AppointmentUpdate>(context,
                              listen: false)
                              .daywiseDurationsCalculate(false);

                          await Provider.of<AppointmentUpdate>(context,
                              listen: false).countHours(false);

                          await Provider.of<AppointmentUpdate>(context,
                                  listen: false)
                              .clear();

                          Navigator.pop(context);
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
                    visible: Provider.of<AppointmentUpdate>(context).isAllDay
                        ? false
                        : true,
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
                                  .format(Provider.of<AppointmentUpdate>(
                                          context,
                                          listen: false)
                                      .fromDate),
                              style: kAppointmentDateTextStyle,
                            ),
                            Text(
                              DateFormat('yyyy. MM. dd. (E) HH:mm', 'ko')
                                  .format(Provider.of<AppointmentUpdate>(
                                          context,
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
                              context: context,
                              startInitialDate: Provider.of<AppointmentUpdate>(
                                      context,
                                      listen: false)
                                  .fromDate,
                              startFirstDate: DateTime(2000),
                              startLastDate: DateTime.now().add(
                                const Duration(days: 10956),
                              ),
                              endInitialDate: Provider.of<AppointmentUpdate>(
                                      context,
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
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
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
                                Provider.of<AppointmentUpdate>(context,
                                        listen: false)
                                    .updateFromDate(dateTimeList.first);
                                Provider.of<AppointmentUpdate>(context,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '다른 사람에게 일정 보이기',
                        style: kAppointmentTextStyle,
                      ),
                      Checkbox(
                        value: Provider.of<AppointmentUpdate>(context,
                                listen: false)
                            .isOpened,
                        onChanged: (value) {
                          Provider.of<AppointmentUpdate>(context, listen: false)
                              .updateIsOpened();
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
                        value: Provider.of<AppointmentUpdate>(context,
                                listen: false)
                            .isAllDay,
                        onChanged: (value) {
                          Provider.of<AppointmentUpdate>(context, listen: false)
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
                    visible: Provider.of<AppointmentUpdate>(context).repeatNo
                        ? false
                        : true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }
}
