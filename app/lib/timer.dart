import 'dart:io';
import 'package:flutter/material.dart';

class Timer extends StatefulWidget {
  const Timer({Key? key, required this.seconds, required this.maxSeconds})
      : super(key: key);

  final int seconds;
  final int maxSeconds;

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Color?> colorTween;

  void createController() {
    controller = AnimationController(
      vsync: this,
      value: widget.seconds * 1.0 / widget.maxSeconds,
      duration: Duration(seconds: widget.maxSeconds),
    )..addListener(() {
        setState(() {});
      });
    colorTween = controller.drive(ColorTween(
      // These get reversed, so it becomes from yellow to red
      begin: Colors.red,
      end: Colors.yellow,
    ));
    controller.reverse();
  }

  @override
  void initState() {
    createController();
    super.initState();
  }

  @override
  void didUpdateWidget(Timer oldWidget) {
    controller.dispose();
    createController();
    super.didUpdateWidget(oldWidget);
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
                strokeWidth: 12,
                semanticsLabel: 'Circular progress indicator',
              ),
            ),
            height: 200,
            width: 200,
          ),
        ),
        Center(
          heightFactor: _getPlatformCountdownHeight(),
          child: Text('${(controller.value * widget.maxSeconds).ceil()}',
              style: TextStyle(fontSize: 64)),
        ),
      ],
    );
  }
}

double _getPlatformCountdownHeight() {
  if (Platform.isAndroid) {
    return 2.7;
  } else if (Platform.isWindows) {
    return 2.3;
  } else {
    return 2.5;
  }
}
