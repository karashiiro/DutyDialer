import 'package:flutter/material.dart';

class Timer extends StatefulWidget {
  const Timer({Key? key}) : super(key: key);

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Color?> colorTween;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      value: 1.0,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {});
      });
    colorTween = controller.drive(ColorTween(
      begin: Colors.red,
      end: Colors.green,
    ));
    controller.reverse();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SizedBox(
            child: RotatedBox(
              quarterTurns: 2,
              child: CircularProgressIndicator(
                value: controller.value,
                valueColor: colorTween,
                backgroundColor: Colors.grey,
                strokeWidth: 8,
                semanticsLabel: 'Circular progress indicator',
              ),
            ),
            height: 200,
            width: 200,
          ),
        ),
        Center(
          heightFactor: 2.71,
          child: Text('${(controller.value * 30).floor()}',
              style: TextStyle(fontSize: 64)),
        ),
      ],
    );
  }
}
