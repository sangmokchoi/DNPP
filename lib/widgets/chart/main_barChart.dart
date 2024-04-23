import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../statusUpdate/courtAppointmentUpdate.dart';
import '../../statusUpdate/othersPersonalAppointmentUpdate.dart';
import '../../statusUpdate/personalAppointmentUpdate.dart';
import 'SelectableButton.dart';

class MainBarChart extends StatelessWidget {
  MainBarChart({required this.backgroundColor, required this.number});

  Color backgroundColor;
  int number;

  final Color barBackgroundColor = Colors.white.withOpacity(0.3);
  final Color barColor = Colors.white;

  late BuildContext buildcontext;

  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex = -1;
  bool isPlaying = false;
  bool isSelected = false;

  int pressedInt = -1;

  late dynamic basicData;

  late PersonalAppointmentUpdate personalData; // CurrentUser 데이터
  late CourtAppointmentUpdate courtData; // 탁구장 별 데이터
  late OthersPersonalAppointmentUpdate othersPersonalData; // 다른 유저의 데이터

  @override
  Widget build(BuildContext context) {
    buildcontext = context;

    if (number == 1) {
      basicData =
          Provider.of<CourtAppointmentUpdate>(buildcontext, listen: false);
    } else if (number == 2) {
      basicData = Provider.of<OthersPersonalAppointmentUpdate>(
          buildcontext,
          listen: false);
    } else {
      basicData =
          Provider.of<PersonalAppointmentUpdate>(buildcontext, listen: false);
    }

    // print('bar number: $number');
    // print('bar basicData.daywiseDurations: ${basicData.daywiseDurations}');

    return Container(
      height: 250,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              //spreadRadius: 5,
              blurRadius: 5,
              offset: Offset(0, 0.5),
            ),
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          color: backgroundColor),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 45.0, 5.0, 10.0),
          child: (basicData.daywiseDurations.isEmpty)
              ? Center(
                  child: Text(
                  '등록된 일정이 없습니다',
                  style: TextStyle(color: Colors.white),
                ))
              : BarChart(individualBarData())),
    );
  }

  BarChartData individualBarData() {
    // 유저 본인인지, 다른 유저인지 구분 필요
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay;
            switch (group.x) {
              case 0:
                weekDay = '월';
                break;
              case 1:
                weekDay = '화';
                break;
              case 2:
                weekDay = '수';
                break;
              case 3:
                weekDay = '목';
                break;
              case 4:
                weekDay = '금';
                break;
              case 5:
                weekDay = '토';
                break;
              case 6:
                weekDay = '일';
                break;
              default:
                throw Error();
            }
            return BarTooltipItem(
              '$weekDay요일\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: <TextSpan>[
                if ((rod.toY.toInt() ~/ 60) != 0)
                  TextSpan(
                    text: '${(rod.toY.toInt() ~/ 60)} 시간 ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if ((rod.toY.toInt() % 60) != 0)
                  TextSpan(
                    text: '${(rod.toY.toInt() % 60)} 분',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          //   setState(() {
          //     if (!event.isInterestedForInteractions ||
          //         barTouchResponse == null ||
          //         barTouchResponse.spot == null) {
          //       touchedIndex = -1;
          //       print('if touchedIndex: $touchedIndex');
          //       return;
          //     }
          //     touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          //     print('touchedIndex: $touchedIndex');
          //
          //     //buildLineChart(widget.meetings);
          //   });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 45,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;

    switch (value.toInt()) {
      case 0:
        text = Text('월', style: style,);
        break;
      case 1:
        text = Text('화', style: style);
        break;
      case 2:
        text = Text('수', style: style);
        break;
      case 3:
        text = Text('목', style: style);
        break;
      case 4:
        text = Text('금', style: style);
        break;
      case 5:
        text = Text('토', style: style);
        break;
      case 6:
        text = Text('일', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 40.0, height: 40.0),
        child: SelectableButton(
            onPressed: () async {
              //isSelected = !isSelected;
              // 해당 버튼을 클릭하면 다른 버튼들의 선택을 해제하고 현재 버튼을 선택
              print('basicData.selectedList[value.toInt()]: ${basicData.selectedList[value.toInt()]}');

              if (basicData.selectedList[value.toInt()] != true) {
                // 클릭되지 않은 요일 클릭
                basicData.selectedList =
                    List.filled(basicData.selectedList.length, false);
                basicData.selectedList[value.toInt()] =
                    !basicData.selectedList[value.toInt()];
                pressedInt = value.toInt();
                print('basicData.recentDays: ${basicData.recentDays}');

                if (basicData.recentDays == 0) {
                  // 최근 7일 클릭시 recentDays
                  basicData.updateLast7DaysHourlyCountsByDaysOfWeek(pressedInt);
                } else if (basicData.recentDays == 1) {
                  basicData.updateLast28DaysHourlyCountsByDaysOfWeek(pressedInt);
                } else if (basicData.recentDays == 2) {
                  basicData
                      .updateLast3MonthsHourlyCountsByDaysOfWeek(pressedInt);
                } else if (basicData.recentDays == 3) {
                  basicData.updateNext28daysHourlyCountsByDaysOfWeek(pressedInt);
                }
              } else {
                // 요일이 한 번 클릭된 상태에서 클릭된 요일 클릭
                basicData.selectedList[value.toInt()] =
                    !basicData.selectedList[value.toInt()];
                int indexOfTrue = basicData.isSelected.indexOf(true);
                print('indexOfTrue: $indexOfTrue');

                // 요일 해제 시, 전체의 시간대로 보이게끔 초기화
                if (indexOfTrue == 0) {
                  basicData.updateLast7DaysHourlyCounts();
                } else if (indexOfTrue == 1) {
                  basicData.updateLast28DaysHourlyCounts();
                } else if (indexOfTrue == 2) {
                  basicData.updateLast3MonthsHourlyCounts();
                } else if (indexOfTrue == 3) {
                  basicData.updateNext28daysHourlyCounts();
                }
              }
            },
            selected: basicData.selectedList[value.toInt()],
            child: text,
          ),
      ),
    );
  } // 월, 화, 수, ... 타이틀 관련

  ButtonStyle getButtonStyleBasedOnCondition(dynamic basicData) {
    // 여기에 basicData 또는 다른 조건을 기반으로 한 스타일 결정 로직 추가
    return ButtonStyle(
      // 버튼 스타일 설정
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    barColor ??= barColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: Colors.white,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.white)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: basicData.calculateAverage() * 1.5,
            color: barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, basicData.daywiseDurations['월'] ?? 0.0,
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, basicData.daywiseDurations['화'] ?? 0.0,
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, basicData.daywiseDurations['수'] ?? 0.0,
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, basicData.daywiseDurations['목'] ?? 0.0,
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, basicData.daywiseDurations['금'] ?? 0.0,
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, basicData.daywiseDurations['토'] ?? 0.0,
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, basicData.daywiseDurations['일'] ?? 0.0,
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });
}
