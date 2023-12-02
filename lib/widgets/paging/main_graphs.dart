import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../chart/main_barChart.dart';
import '../chart/main_lineChart.dart';

class GraphsWidget extends StatelessWidget {

  GraphsWidget({
    required this.index,
    required this.titleText,
    required this.backgroundColor,
  });

  final int index;
  final String titleText;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                    color: backgroundColor),
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(5.0, 45.0, 5.0, 10.0),
                  child: MainBarChart(index: index),
                ),
              ),
              Positioned(
                top: 10, // 조절 가능한 값
                left: 15, // 조절 가능한 값
                child: Column(
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
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 4.0, bottom: 4.0, left: 5.0, right: 5.0),
            child: Container(
              height: 100,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: MainLineChart(index: index)),
            ),
          ),
        ],
      ),
    );
  }
}