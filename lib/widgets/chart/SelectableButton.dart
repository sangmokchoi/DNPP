import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class SelectableButton extends StatelessWidget {
  SelectableButton({
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

  late final MaterialStatesController statesController =
  MaterialStatesController(
      <MaterialState>{if (selected) MaterialState.selected});

  @override
  void didUpdateWidget(SelectableButton oldWidget) {
    //super.didUpdateWidget(oldWidget);
    debugPrint('didUpdateWidget 진입');
    if (selected != oldWidget.selected) {
      statesController.update(MaterialState.selected, selected);
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
        style: ButtonStyle(
          alignment: Alignment.topCenter,
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            kRoundedRectangleBorder.copyWith(
                borderRadius: BorderRadius.circular(20)),
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
          // textStyle: MaterialStateProperty.all<TextStyle>(
          //   TextStyle(
          //     fontSize: 16.0, // Set your desired font size
          //     fontWeight: FontWeight.bold, // Set your desired font weight
          //   ),
          // ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}