import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../viewModel/appointmentUpdate.dart';

class MainBarChart extends StatefulWidget {
  MainBarChart({required this.index});

  final int index;

  List<Color> get availableColors => const <Color>[
        Colors.purple,
        Colors.yellow,
        Colors.blue,
        Colors.orange,
        Colors.pink,
        Colors.red,
      ];

  final Color barBackgroundColor = Colors.white.withOpacity(0.3);
  final Color barColor = Colors.white;
  final Color touchedBarColor = Colors.green;

  @override
  State<MainBarChart> createState() => _MainBarChartState();
}

class _MainBarChartState extends State<MainBarChart> {
  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex = -1;
  bool isPlaying = false;

  int pressedInt = -1;

  List<bool> selectedList = List.generate(7, (index) => false);

  @override
  void initState() {
    // calculate(widget.meetings);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: 0)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // 1초 뒤에 실행되는 조건문
          if (Provider.of<AppointmentUpdate>(context, listen: false)
              .daywiseDurations
              .isEmpty) {
            return const Center(
              child: Text(
                '완료된 일정이 없습니다',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return Consumer<AppointmentUpdate>(
              builder: (context, taskData, child) {
                if (widget.index == 0) {
                  return BarChart(individualBarData());
                } else {
                  return BarChart(individualBarData());
                }
              },
            );
          }
        } else {
          // 로딩 상태 등을 표시하거나 다른 처리를 할 수 있습니다.
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.grey,
          ));
        }
      },
    );
  }

  BarChartData individualBarData() {
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
                weekDay = 'Monday';
                break;
              case 1:
                weekDay = 'Tuesday';
                break;
              case 2:
                weekDay = 'Wednesday';
                break;
              case 3:
                weekDay = 'Thursday';
                break;
              case 4:
                weekDay = 'Friday';
                break;
              case 5:
                weekDay = 'Saturday';
                break;
              case 6:
                weekDay = 'Sunday';
                break;
              default:
                throw Error();
            }
            return BarTooltipItem(
              '$weekDay\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY - 1).toInt().toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              print('if touchedIndex: $touchedIndex');
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            print('touchedIndex: $touchedIndex');

            //buildLineChart(widget.meetings);
          });
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
            reservedSize: 38,
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
        text = Text('일', style: style);
        break;
      case 1:
        text = Text('월', style: style);
        break;
      case 2:
        text = Text('화', style: style);
        break;
      case 3:
        text = Text('수', style: style);
        break;
      case 4:
        text = Text('목', style: style);
        break;
      case 5:
        text = Text('금', style: style);
        break;
      case 6:
        text = Text('토', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 35.0),
        child: SelectableButton(
          onPressed: () async {
            setState(() {
              // 해당 버튼을 클릭하면 다른 버튼들의 선택을 해제하고 현재 버튼을 선택

              if (selectedList[value.toInt()] != true) {
                // 클릭되지 않는 요일 클릭
                selectedList = List.filled(selectedList.length, false);
                selectedList[value.toInt()] = !selectedList[value.toInt()];

                pressedInt = value.toInt();
                print('pressedInt: $pressedInt');

                Provider.of<AppointmentUpdate>(context, listen: false)
                    .updateLast7DaysHourlyCountsByDaysOfWeek(pressedInt);
                Provider.of<AppointmentUpdate>(context, listen: false)
                    .updateLast28DaysHourlyCountsByDaysOfWeek(pressedInt);
                Provider.of<AppointmentUpdate>(context, listen: false)
                    .updateLast3MonthsHourlyCountsByDaysOfWeek(pressedInt);
              } else {
                // 요일이 한 번 클릭된 상태에서 클릭된 요일 클릭
                selectedList[value.toInt()] = !selectedList[value.toInt()];
                int indexOfTrue =
                    Provider.of<AppointmentUpdate>(context, listen: false)
                        .isSelected
                        .indexOf(true);
                print('indexOfTrue: $indexOfTrue');

                // 요일 해제 시, 전체의 시간대로 보이게끔 초기화
                if (indexOfTrue == 0) {
                  Provider.of<AppointmentUpdate>(context, listen: false)
                      .updateLast7DaysHourlyCounts();
                } else if (indexOfTrue == 1) {
                  Provider.of<AppointmentUpdate>(context, listen: false)
                      .updateLast28DaysHourlyCounts();
                } else if (indexOfTrue == 2) {
                  Provider.of<AppointmentUpdate>(context, listen: false)
                      .updateLast3MonthsHourlyCounts();
                }
              }
            });
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // 원하는 반지름 설정
              ),
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.red;
                }
                return null; // defer to the defaults
              },
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                // 현재 버튼이 선택된 경우 배경색 지정, 아니면 null
                if (states.contains(MaterialState.selected)) {
                  return Colors.indigo;
                }
                return null;
              },
            ),
          ),
          selected: selectedList[value.toInt()],
          child: text,
        ),
      ),
    );
  } // 월, 화, 수, ... 타이틀 관련

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    barColor ??= widget.barColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? widget.touchedBarColor : barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: widget.touchedBarColor)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: Provider.of<AppointmentUpdate>(context, listen: false)
                    .calculateAverage() *
                1.5,
            color: widget.barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(
                0,
                Provider.of<AppointmentUpdate>(context, listen: false)
                        .daywiseDurations['일'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(
                1,
                Provider.of<AppointmentUpdate>(context, listen: false)
                        .daywiseDurations['월'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(
                2,
                Provider.of<AppointmentUpdate>(context, listen: false)
                        .daywiseDurations['화'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(
                3,
                Provider.of<AppointmentUpdate>(context, listen: false)
                        .daywiseDurations['수'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(
                4,
                Provider.of<AppointmentUpdate>(context, listen: false)
                        .daywiseDurations['목'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(
                5,
                Provider.of<AppointmentUpdate>(context, listen: false)
                        .daywiseDurations['금'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(
                6,
                Provider.of<AppointmentUpdate>(context, listen: false)
                        .daywiseDurations['토'] ??
                    0.0,
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });
}



class SelectableButton extends StatefulWidget {
  const SelectableButton({
    super.key,
    required this.selected,
    this.style,
    required this.onPressed,
    required this.child,
  });

  final bool selected;
  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<SelectableButton> createState() => _SelectableButtonState();
}

class _SelectableButtonState extends State<SelectableButton> {
  late final MaterialStatesController statesController;

  @override
  void initState() {
    super.initState();
    statesController = MaterialStatesController(
        <MaterialState>{if (widget.selected) MaterialState.selected});
  }

  @override
  void didUpdateWidget(SelectableButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      statesController.update(MaterialState.selected, widget.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(1000)
      // ),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: TextButton(
        statesController: statesController,
        style: widget.style,
        onPressed: widget.onPressed,
        child: widget.child,
      ),
    );
  }
}
