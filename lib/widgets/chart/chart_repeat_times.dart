import 'package:dnpp/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../statusUpdate/personalAppointmentUpdate.dart';


class RepeatTimes extends StatelessWidget {
  RepeatTimes(this.repeatString);

  String repeatString;
  int _repeatTimes = 0;

  Set<int> selectedButtons = Set<int>();

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
                insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                shape: kRoundedRectangleBorder,
                title: Text(
                  '반복 횟수',
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var n = 2; n < 51; n++)
                        TextButton(
                          onPressed: () async {
                            _repeatTimes = n;

                            if (selectedButtons.length != 0) {
                              selectedButtons.remove(selectedButtons.first);
                              selectedButtons.add(n);
                              print('selectedButtons.length != 0');
                              print(selectedButtons);
                            } else {
                              selectedButtons.add(n);
                              print('selectedButtons.length == 0');
                              print(selectedButtons);
                            }
                            await Provider.of<PersonalAppointmentUpdate>(context,
                                    listen: false)
                                .updateRecurrenceRules(repeatString, n);
                            await Provider.of<PersonalAppointmentUpdate>(context,
                                listen: false)
                                .updateRepeat(repeatString);

                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.grey; // 버튼이 눌렸을 때의 색상
                                }
                                return Colors.transparent; // 일반 상태의 색상
                              },
                            ),
                          ),
                          child: Text(
                            '$n 회',
                            style: kAppointmentTextButtonStyle.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: <Widget>[
                   TextButton(
                       onPressed: () {
                         // Provider.of<AppointmentUpdate>(context, listen: false)
                         //     .updateRecurrenceRules(repeatString, 1);
                         Navigator.pop(context);
                       },
                       child: Text('취소'),
                   ),
                ],
              );
            });
      },
      child: Text(
        '${Provider.of<PersonalAppointmentUpdate>(context, listen: false).repeatTimes} 회',
        style: kAppointmentTextButtonStyle,
      ),
    );
  }
}
