import 'package:duty_dialer/timer.dart';
import 'package:flutter/material.dart';

class CountdownView extends StatelessWidget {
  const CountdownView(
      {Key? key,
      required this.queueSeconds,
      required this.text,
      required this.bannerUrl})
      : super(key: key);

  final int queueSeconds;
  final String text;
  final String bannerUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Timer(
            seconds: queueSeconds,
            maxSeconds: 45,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40),
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
          ),
          Image.network(bannerUrl, height: 200, fit: BoxFit.fitWidth),
        ],
      ),
    );
  }
}
