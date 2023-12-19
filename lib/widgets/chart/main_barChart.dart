import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../viewModel/courtAppointmentUpdate.dart';
import '../../viewModel/personalAppointmentUpdate.dart';

class MainBarChart extends StatefulWidget {
  MainBarChart({required this.isCourt});

  final bool isCourt;

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
  bool isSelected = false;

  int pressedInt = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: 0)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (widget.isCourt) {
//daywiseDurations
            if (Provider.of<CourtAppointmentUpdate>(context, listen: false)
                  .daywiseDurations
                  .isEmpty) {
              return Center(
                child: Text(
                  '완료된 일정이 없습니다',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            else {
              return BarChart(individualBarDataCourt());
            }

          } else {

            if (Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                .daywiseDurations
                .isEmpty) {
              return Center(
                child: Text(
                  '완료된 개인 일정이 없습니다',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            else {
              return BarChart(individualBarDataPersonal());
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
    );
  }

  BarChartData individualBarDataPersonal() {
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
            getTitlesWidget: getTitlesPersonal,
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
      barGroups: showingGroupsPersonal(),
      gridData: const FlGridData(show: false),
    );
  }

  BarChartData individualBarDataCourt() {
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
            getTitlesWidget: getTitlesCourt,
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
      barGroups: showingGroupsCourt(),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getTitlesPersonal(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;

    switch (value.toInt()) {
      case 0:
        text = Text('월', style: style);
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
        constraints: BoxConstraints.tightFor(width: 35.0),
        child: SelectableButton(
          onPressed: () async {
            setState(() {
              //isSelected = !isSelected;
              // 해당 버튼을 클릭하면 다른 버튼들의 선택을 해제하고 현재 버튼을 선택

              if (Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                      .selectedList[value.toInt()] !=
                  true) {
                // 클릭되지 않은 요일 클릭
                Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                        .selectedList =
                    List.filled(
                        Provider.of<PersonalAppointmentUpdate>(context,
                                listen: false)
                            .selectedList
                            .length,
                        false);
                Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                        .selectedList[value.toInt()] =
                    !Provider.of<PersonalAppointmentUpdate>(context,
                            listen: false)
                        .selectedList[value.toInt()];
                pressedInt = value.toInt();
                print('pressedInt: $pressedInt');
                print(
                    'recentDays: ${Provider.of<PersonalAppointmentUpdate>(context, listen: false).recentDays}');

                if (Provider.of<PersonalAppointmentUpdate>(context,
                            listen: false)
                        .recentDays ==
                    0) {
                  // 최근 7일 클릭시 recentDays
                  Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                      .updateLast7DaysHourlyCountsByDaysOfWeek(pressedInt);

                } else if (Provider.of<PersonalAppointmentUpdate>(context,
                            listen: false)
                        .recentDays ==
                    1) {
                  Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                      .updateLast28DaysHourlyCountsByDaysOfWeek(pressedInt);

                } else if (Provider.of<PersonalAppointmentUpdate>(context,
                            listen: false)
                        .recentDays ==
                    2) {
                  Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                      .updateLast3MonthsHourlyCountsByDaysOfWeek(pressedInt);

                } else if (Provider.of<PersonalAppointmentUpdate>(context,
                            listen: false)
                        .recentDays ==
                    3) {
                  Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                      .updateNext28daysHourlyCountsByDaysOfWeek(pressedInt);

                }
              } else {
                // 요일이 한 번 클릭된 상태에서 클릭된 요일 클릭
                Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                        .selectedList[value.toInt()] =
                    !Provider.of<PersonalAppointmentUpdate>(context,
                            listen: false)
                        .selectedList[value.toInt()];
                int indexOfTrue = Provider.of<PersonalAppointmentUpdate>(
                        context,
                        listen: false)
                    .isSelected
                    .indexOf(true);
                print('indexOfTrue: $indexOfTrue');

                // 요일 해제 시, 전체의 시간대로 보이게끔 초기화
                if (indexOfTrue == 0) {
                  Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                      .updateLast7DaysHourlyCounts();

                } else if (indexOfTrue == 1) {
                  Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                      .updateLast28DaysHourlyCounts();

                } else if (indexOfTrue == 2) {
                  Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                      .updateLast3MonthsHourlyCounts();

                } else if (indexOfTrue == 3) {
                  Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                      .updateNext28daysHourlyCounts();
                }
              }
            });
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              kRoundedRectangleBorder,
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
          selected:
              Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                  .selectedList[value.toInt()], // Provider.of<PersonalAppointmentUpdate>(context, listen: false).falseSelectedList
          child: text,
        ),
      ),
    );
  } // 월, 화, 수, ... 타이틀 관련

  Widget getTitlesCourt(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;

    switch (value.toInt()) {
      case 0:
        text = Text('월', style: style);
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
        constraints: BoxConstraints.tightFor(width: 35.0),
        child: SelectableButton(
          onPressed: () async {
            setState(() {
              // 해당 버튼을 클릭하면 다른 버튼들의 선택을 해제하고 현재 버튼을 선택
              if (Provider.of<CourtAppointmentUpdate>(context, listen: false)
                      .selectedList[value.toInt()] !=
                  true) {
                // 클릭되지 않는 요일 클릭
                Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .selectedList =
                    List.filled(
                        Provider.of<CourtAppointmentUpdate>(context,
                                listen: false)
                            .selectedList
                            .length,
                        false);
                Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .selectedList[value.toInt()] =
                    !Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .selectedList[value.toInt()];
                pressedInt = value.toInt();
                print('pressedInt: $pressedInt');
                print(
                    'recentDays: ${Provider.of<CourtAppointmentUpdate>(context, listen: false).recentDays}');

                if (Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .recentDays ==
                    0) {
                  // 최근 7일 클릭시 recentDays
                  Provider.of<CourtAppointmentUpdate>(context, listen: false)
                      .updateLast7DaysHourlyCountsByDaysOfWeek(pressedInt);

                } else if (Provider.of<CourtAppointmentUpdate>(context,
                            listen: false)
                        .recentDays ==
                    1) {
                  Provider.of<CourtAppointmentUpdate>(context, listen: false)
                      .updateLast28DaysHourlyCountsByDaysOfWeek(pressedInt);

                } else if (Provider.of<CourtAppointmentUpdate>(context,
                            listen: false)
                        .recentDays ==
                    2) {
                  Provider.of<CourtAppointmentUpdate>(context, listen: false)
                      .updateLast3MonthsHourlyCountsByDaysOfWeek(pressedInt);

                } else if (Provider.of<CourtAppointmentUpdate>(context,
                            listen: false)
                        .recentDays ==
                    3) {
                  Provider.of<CourtAppointmentUpdate>(context, listen: false)
                      .updateNext28daysHourlyCountsByDaysOfWeek(pressedInt);

                }

              } else {
                // 요일이 한 번 클릭된 상태에서 클릭된 요일 클릭
                Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .selectedList[value.toInt()] =
                    !Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .selectedList[value.toInt()];
                int indexOfTrue =
                    Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .isSelected
                        .indexOf(true);
                print('indexOfTrue: $indexOfTrue');

                // 요일 해제 시, 전체의 시간대로 보이게끔 초기화
                if (indexOfTrue == 0) {
                  Provider.of<CourtAppointmentUpdate>(context, listen: false)
                      .updateLast7DaysHourlyCounts();
                } else if (indexOfTrue == 1) {
                  Provider.of<CourtAppointmentUpdate>(context, listen: false)
                      .updateLast28DaysHourlyCounts();
                } else if (indexOfTrue == 2) {
                  Provider.of<CourtAppointmentUpdate>(context, listen: false)
                      .updateLast3MonthsHourlyCounts();
                } else if (indexOfTrue == 3) {
                  Provider.of<CourtAppointmentUpdate>(context, listen: false)
                      .updateNext28daysHourlyCounts();
                }
              }
            });
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              kRoundedRectangleBorder,
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
          selected: Provider.of<CourtAppointmentUpdate>(context, listen: false)
              .selectedList[value.toInt()],
          child: text,
        ),
      ),
    );
  } // 월, 화, 수, ... 타이틀 관련

  BarChartGroupData makeGroupDataPersonal(
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
            toY: Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                    .calculateAverage() *
                1.5,
            color: widget.barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  BarChartGroupData makeGroupDataCourt(
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
            toY: Provider.of<CourtAppointmentUpdate>(context, listen: false)
                    .calculateAverage() *
                1.5,
            color: widget.barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroupsPersonal() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupDataPersonal(
                0,
                Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['월'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupDataPersonal(
                1,
                Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['화'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupDataPersonal(
                2,
                Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['수'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupDataPersonal(
                3,
                Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['목'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupDataPersonal(
                4,
                Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['금'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupDataPersonal(
                5,
                Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['토'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupDataPersonal(
                6,
                Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['일'] ??
                    0.0,
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  List<BarChartGroupData> showingGroupsCourt() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupDataCourt(
                0,
                Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['월'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupDataCourt(
                1,
                Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['화'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupDataCourt(
                2,
                Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['수'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupDataCourt(
                3,
                Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['목'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupDataCourt(
                4,
                Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['금'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupDataCourt(
                5,
                Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['토'] ??
                    0.0,
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupDataCourt(
                6,
                Provider.of<CourtAppointmentUpdate>(context, listen: false)
                        .daywiseDurations['일'] ??
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
