import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../viewModel/appointmentUpdate.dart';

class MainLineChart extends StatefulWidget {

  MainLineChart({required this.index});

  final int index;

  @override
  State<MainLineChart> createState() => _MainLineChartState();
}

class _MainLineChartState extends State<MainLineChart> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 0)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // 1초 뒤에 실행되는 조건문
            if (Provider.of<AppointmentUpdate>(context, listen: false)
                .hourlyCounts
                .isEmpty) {
              return const Center(
                child: Text(
                  '완료된 일정이 없습니다',
                  style: TextStyle(color: Colors.black),
                ),
              );
            } else {
              return Consumer<AppointmentUpdate>(
                builder: (context, taskData, child) {
                  return LineChart(
                    mainLineChartData(),
                  );
                },
              );
            }
          } else {
            // 로딩 상태 등을 표시하거나 다른 처리를 할 수 있습니다.
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            );
          }
        },
      ),
    ]);
  }

  LineChartData mainLineChartData() {
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
      lineTouchData: const LineTouchData(
          enabled: false
      ),
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
      maxY: Provider.of<AppointmentUpdate>(context, listen: false)
              .calculateAverageY() *
          1.5,
      lineBarsData: [
        LineChartBarData(
          spots: showingGroups(),
          isCurved: true,
          barWidth: 2,
          curveSmoothness: 0.1,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                color: Colors.blueAccent,
                radius: 3.0,
                strokeWidth: 1.0,
                strokeColor: Colors.transparent,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
          ),
        ),
      ],
    );
  }

  List<FlSpot> showingGroups() => List.generate(24, (i) {
        return FlSpot(
            i.toDouble(),
            Provider.of<AppointmentUpdate>(context, listen: false)
                    .hourlyCounts[i] ??
                0.0);
      });

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
    );

    Widget defaultWidget = Text('${value.toInt()}', style: style);
    Widget text;
    switch (value.toInt()) {
      case 23:
        text = const Text('', style: style);
      default:
        text = defaultWidget;
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text, //text,
    );
  }
}
