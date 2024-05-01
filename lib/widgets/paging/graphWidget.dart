import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../chart/main_barChart.dart';
import '../chart/main_lineChart.dart';

class GraphsWidget extends StatelessWidget {

  GraphsWidget({
    required this.titleText,
    required this.backgroundColor,
    required this.number, // 0은 currentuser, 1은 탁구장별 데이터, 2은 다른 유저의 데이터
  });

  final String titleText;
  final Color backgroundColor;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 5.0),
      child: Column(
        children: [
          Stack(
            children: [
              MainBarChart(backgroundColor: backgroundColor, number: number,),
              Positioned(
                top: 10, // 조절 가능한 값
                left: 15, // 조절 가능한 값
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.7,
                      ),
                      child: Text(
                        titleText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 5.0,),
                    Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: GestureDetector(
                        onTapUp: (TapUpDetails tap){
                          if (number == 0) {
                            currentText(context);
                          } else if (number == 1) {
                            courtText(context);
                          } else { // number == 2
                            othersText(context);
                          }

                        },
                          child: Icon(
                            size: 20.0,
                            CupertinoIcons.question_circle,
                            color: Colors.white,
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          MainLineChart(number: number,),
        ],
      ),
    );
  }


  Future currentText(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          shape: kRoundedRectangleBorder,
          title: Text('도움말', style: kAlertDialogTitleTextStyle,),
          content: SizedBox(
            height: 250,
            child: Scrollbar(
              thumbVisibility: true,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SingleChildScrollView(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: '이용자가 직접 등록한 일정을 보여주는 차트입니다\n\n',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          // TextSpan(
                          //   text: '원하는 기간에 맞춰 한 눈에 일정을 살펴보세요.\n'
                          // '("최근 7일", "최근 28일", "최근 3개월", "앞으로 1개월"으로 구분되어 있습니다)\n\n',
                          //   //style: TextStyle(fontWeight: FontWeight.bold),
                          // ),
                          TextSpan(
                            text: '1. 막대 차트는 기간별로 등록한 일정들의 시간을 모두 더하여 요일별로 나타냅니다.\n\n'
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '2. 직선 차트는 기간별로 등록한 일정들을 시간대별로 구분해서 나타냅니다\n\n'
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '3. 각 요일을 클릭하면, 요일별로 등록된 일정들의 시간만을 나타냅니다\n\n',
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '4. 요일을 재클릭하면, 선택한 요일이 해제되며, 모든 요일의 일정을 보여줍니다\n\n',
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                        style: kAlertDialogContentTextStyle,
                      ),
                      maxLines: null,
                    )
                ),
              ),
            ),
          ),
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
  }

  Future courtText(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          shape: kRoundedRectangleBorder,
          title: Text('도움말', style: kAlertDialogTitleTextStyle,),
          content: SizedBox(
            height: 250,
            child: Scrollbar(
              thumbVisibility: true,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SingleChildScrollView(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '탁구장별 이용자들이 등록한 일정을 차트로 보여주는 위젯입니다\n\n',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text: '1. 막대 차트는 기간별로 등록한 일정들의 시간을 모두 더하여 요일별로 나타냅니다.\n\n'
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text: '2. 직선 차트는 기간별로 등록한 일정들을 시간대별로 구분해서 나타냅니다\n\n'
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '3. 각 요일을 클릭하면, 요일별로 등록된 일정들의 시간만을 나타냅니다\n\n',
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '4. 요일을 재클릭하면, 선택한 요일이 해제되며, 모든 요일의 일정을 보여줍니다\n\n',
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                        style: kAlertDialogContentTextStyle,
                      ),
                      maxLines: null,
                    )
                ),
              ),
            ),
          ),
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
  }

  Future othersText(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          shape: kRoundedRectangleBorder,
          title: Text('도움말', style: kAlertDialogTitleTextStyle,),
          content: SizedBox(
            height: 250,
            child: Scrollbar(
              thumbVisibility: true,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SingleChildScrollView(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '다른 이용자가 등록한 일정을 차트로 보여주는 위젯입니다\n',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '(최근 28일 동안 등록한 일정만을 차트로 나타내줍니다)\n\n',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                              text: '1. 막대 차트는 기간별로 등록한 일정들의 시간을 모두 더하여 요일별로 나타냅니다.\n\n'
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text: '2. 직선 차트는 기간별로 등록한 일정들을 시간대별로 구분해서 나타냅니다\n\n'
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '3. 각 요일을 클릭하면, 요일별로 등록된 일정들의 시간만을 나타냅니다\n\n',
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '4. 요일을 재클릭하면, 선택한 요일이 해제되며, 모든 요일의 일정을 보여줍니다\n\n',
                            //style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                        style: kAlertDialogContentTextStyle,
                      ),
                      maxLines: null,
                    )
                ),
              ),
            ),
          ),
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
  }
}