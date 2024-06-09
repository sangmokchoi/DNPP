import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../statusUpdate/courtAppointmentUpdate.dart';
import '../../statusUpdate/othersPersonalAppointmentUpdate.dart';
import '../../statusUpdate/personalAppointmentUpdate.dart';

class MainLineChart extends StatelessWidget {

  MainLineChart({required this.number});

  final int number;

  late dynamic basicData;

  late PersonalAppointmentUpdate personalData; // CurrentUser 데이터
  late CourtAppointmentUpdate courtData; // 탁구장 별 데이터
  late OthersPersonalAppointmentUpdate othersPersonalData; // 다른 유저의 데이터

  @override
  Widget build(BuildContext context) {

    basicData = null;

    if (number == 1) {
      basicData = Provider.of<CourtAppointmentUpdate>(context, listen: false);
    } else if (number == 2) {
      basicData =
          Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false);
    } else {
      basicData = Provider.of<PersonalAppointmentUpdate>(context, listen: false);
    }
    // debugPrint('line number: $number');
    // debugPrint('line basicData.hourlyCounts: ${basicData.hourlyCounts}');

    return Padding(
      padding:
          const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 5.0, right: 5.0),
      child: Container(
        height: 100,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: (basicData.hourlyCounts.isEmpty)
                ? Center(
                    child: Text(
                      '등록된 일정이 없습니다',
                      //style: TextStyle(color: Colors.black),
                    ),
                  )
                : LineChart(mainLineChartData(context))),
      ),
    );
  }

  LineChartData mainLineChartData(BuildContext context) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.transparent,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.transparent,
            strokeWidth: 1,
          );
        },
      ),
      lineTouchData: const LineTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: const AxisTitles(
            sideTitles: SideTitles(reservedSize: 44, showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(reservedSize: 44, showTitles: false)),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(reservedSize: 44, showTitles: false)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                reservedSize: 25,
                showTitles: true,
                getTitlesWidget: bottomTitleWidgets)),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: 23,
      minY: 0,
      maxY: basicData.calculateAverageY() * 1.5,
      lineBarsData: [
        LineChartBarData(
          spots: showingGroups(context),
          isCurved: true,
          barWidth: 2,
          curveSmoothness: 0.1,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                color: kMainColor,
                radius: 2.5,
                strokeWidth: 3.0,
                strokeColor: Colors.transparent,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                kMainColor.withOpacity(0.5),
                kMainColor.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> showingGroups(BuildContext context) => List.generate(
        24,
        (i) {
          return FlSpot(
              i.toDouble(),
              basicData.hourlyCounts[i] ??
                  0.0);
        },
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 12,
    );

    Widget defaultWidget = Text('${value.toInt()}시', style: style);
    Widget text;
    switch (value.toInt()) {
      case 23:
        text = const Text('', style: style);
        break;
      default:
        text = defaultWidget;
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text, //text,
      space: 5.0,
    );
  }
}
