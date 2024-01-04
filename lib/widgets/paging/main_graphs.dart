import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../chart/main_barChart.dart';
import '../chart/main_lineChart.dart';

class GraphsWidget extends StatelessWidget {

  GraphsWidget({
    //required this.index, // index 가 0 이면, 나의 훈련 시간을 나타냄
    required this.isCourt,
    required this.isMine,
    required this.titleText,
    required this.backgroundColor,
  });

  //final int index;
  final bool isCourt;
  final bool isMine; // 유저 본인의 데이터인지, 다른 유저의 데이터인지
  final String titleText;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 5.0),
      child: Column(
        children: [
          Stack(
            children: [
              MainBarChart(isCourt: isCourt, backgroundColor: backgroundColor, isMine: isMine),
              Positioned(
                top: 10, // 조절 가능한 값
                left: 15, // 조절 가능한 값
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 5.0,),
                    GestureDetector(
                      onTapUp: (TapUpDetails tap){
                        print('onTapUp');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                              shape: kRoundedRectangleBorder,
                              title: Text('도움말'),
                              content: Text('설정한 기간 동안 등록한 일정의 시간을 총합하여 나타냅니다\n'
                                  '요일을 클릭하면, 해당 요일에 등록된 일정들의 시간을 총합하여 나타냅니다\n'
                                  '요일을 재클릭하면, 전체 기간의 일정들의 시간을 보여줍니다\n'),
                              actions: [
                                Center(
                                  child: Container(
                                    width: 150.0,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('닫기'),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                        child: Icon(
                          size: 20.0,
                          CupertinoIcons.question_circle,
                          color: Colors.white,
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          MainLineChart(isCourt: isCourt, isMine: isMine),
        ],
      ),
    );
  }
}