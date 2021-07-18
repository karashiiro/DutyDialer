import 'dart:io';
import 'package:flutter/material.dart';

class Timer extends StatefulWidget {
  const Timer(
      {Key? key,
      required this.seconds,
      required this.maxSeconds,
      this.size,
      this.strokeWidth,
      this.startColor,
      this.endColor,
      this.backgroundColor})
      : super(key: key);

  final Color? startColor;
  final Color? endColor;
  final Color? backgroundColor;
  final int seconds;
  final int maxSeconds;
  final double? size;
  final double? strokeWidth;

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
      begin: widget.endColor ?? Colors.red,
      end: widget.startColor ?? Colors.yellow,
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
                backgroundColor: widget.backgroundColor ?? Colors.grey,
                strokeWidth: widget.strokeWidth ?? 8,
                semanticsLabel: 'Circular progress indicator',
              ),
            ),
            height: widget.size ?? 200,
            width: widget.size ?? 200,
          ),
        ),
        Center(
          heightFactor:
              _getPlatformCountdownHeight() * ((widget.size ?? 200) / 200),
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
