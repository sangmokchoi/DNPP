import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    if (selected != oldWidget.selected) {
      statesController.update(MaterialState.selected, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print("object");
      },
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: TextButton(
          statesController: statesController,
          style: style,
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}