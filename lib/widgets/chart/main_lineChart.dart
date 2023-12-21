import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../viewModel/courtAppointmentUpdate.dart';
import '../../viewModel/personalAppointmentUpdate.dart';

class MainLineChart extends StatelessWidget {
  MainLineChart({required this.isCourt});

  //final int index; //0이면 나의 훈련시간
  final bool isCourt;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 0)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (isCourt) {

              if (Provider.of<CourtAppointmentUpdate>(context, listen: false)
                  .courtHourlyCounts //personalHourlyCounts
                  .isEmpty) {
                return Center(
                  child: Text(
                    '완료된 일정이 없습니다',
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }

              else {
                return LineChart(mainLineChartDataCourt(context));
              }

            } else {

              if (Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                  .personalHourlyCounts
                  .isEmpty) {
                return Center(
                  child: Text(
                    '완료된 개인 일정이 없습니다',
                    style: TextStyle(color: Colors.black),
                  ),
                );
              } else {
                return LineChart(mainLineChartDataPersonal(context));
              }
            }

          } else {
            // 로딩 상태 등을 표시하거나 다른 처리를 할 수 있습니다.
            return const Center(
                child: CircularProgressIndicator(
                  color: Colors.grey,
                ));
          }
        },
      ),
    ]);
  }

  LineChartData mainLineChartDataCourt(BuildContext context) {
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
      maxY: Provider.of<CourtAppointmentUpdate>(context, listen: false)
                  .calculateAverageY() *
              1.5,
      lineBarsData: [
        LineChartBarData(
          spots: showingGroupsCourt(context),
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

  LineChartData mainLineChartDataPersonal(BuildContext context) {
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
      maxY: Provider.of<PersonalAppointmentUpdate>(context, listen: false)
          .calculateAverageY() *
          1.5,
      lineBarsData: [
        LineChartBarData(
          spots: showingGroupsPersonal(context),
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

  List<FlSpot> showingGroupsPersonal(BuildContext context) => List.generate(
        24,
        (i) {
          return FlSpot(
              i.toDouble(),
              Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                      .personalHourlyCounts[i] ??
                  0.0);
        },
      );

  List<FlSpot> showingGroupsCourt(BuildContext context) => List.generate(
        24,
        (i) {
          return FlSpot(
              i.toDouble(),
              Provider.of<CourtAppointmentUpdate>(context, listen: false)
                      .courtHourlyCounts[i] ??
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
