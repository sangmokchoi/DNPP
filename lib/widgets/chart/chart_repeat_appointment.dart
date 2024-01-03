import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../viewModel/appointmentUpdate.dart';

class RepeatAppointment extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        alignment: Alignment.centerRight,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  '반복',
                ),
                content: Container(
                  height: 200,
                  child: Consumer<AppointmentUpdate>(
                    builder: (context, taskData, child) {
                      return Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text('반복 안 함'),
                                  Checkbox(
                                    value: Provider.of<AppointmentUpdate>(context, listen: false).repeatNo,
                                    onChanged: (value) {
                                      Provider.of<AppointmentUpdate>(context, listen: false).updateRepeat('반복 안 함');
                                      Provider.of<AppointmentUpdate>(context, listen: false).updateRecurrenceRules('반복 안 함', 0);
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('매일'),
                                  Checkbox(
                                    value: Provider.of<AppointmentUpdate>(context, listen: false).repeatEveryDay,
                                    onChanged: (value) {
                                      Provider.of<AppointmentUpdate>(context, listen: false).updateRepeat('매일');
                                      Provider.of<AppointmentUpdate>(context, listen: false).updateRecurrenceRules('매일', 1);
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('매주'),
                                  Checkbox(
                                    value: Provider.of<AppointmentUpdate>(context, listen: false).repeatEveryWeek,
                                    onChanged: (value) {
                                      Provider.of<AppointmentUpdate>(context, listen: false).updateRepeat('매주');
                                      Provider.of<AppointmentUpdate>(context, listen: false).updateRecurrenceRules('매주', 1);
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('매월'),
                                  Checkbox(
                                    value: Provider.of<AppointmentUpdate>(context, listen: false).repeatEveryMonth,
                                    onChanged: (value) {
                                      Provider.of<AppointmentUpdate>(context, listen: false).updateRepeat('매월');
                                      Provider.of<AppointmentUpdate>(context, listen: false).updateRecurrenceRules('매월', 1);
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('매년'),
                                  Checkbox(
                                    value: Provider.of<AppointmentUpdate>(context, listen: false).repeatEveryYear,
                                    onChanged: (value) {
                                      Provider.of<AppointmentUpdate>(context, listen: false).updateRepeat('매년');
                                      Provider.of<AppointmentUpdate>(context, listen: false).updateRecurrenceRules('매년', 1);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('취소')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('저장')),
                ],
              );
            });
      },
      child: Text(
        Provider.of<AppointmentUpdate>(context, listen: false)
            .repeatString,
        style: kAppointmentTextButtonStyle,
      ),
    );
  }
}