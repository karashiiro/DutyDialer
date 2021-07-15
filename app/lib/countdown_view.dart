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
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
          ),
          Container(
            height: 150,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            height: 150,
            child: Image.network(
              bannerUrl,
              fit: BoxFit.fitWidth,
            ),
          ),
        ],
      ),
    );
  }
}
