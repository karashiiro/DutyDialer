import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:duty_dialer/ipc_message.dart';
import 'package:duty_dialer/timer.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  connectAndListen();
  runApp(App());
}

class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

StreamSocket streamSocket = StreamSocket();

void connectAndListen() {
  final server = 'ws://localhost:3276';

  final channel = IOWebSocketChannel.connect(server);

  channel.stream.listen((message) {
    streamSocket.addResponse(message);
  });
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DutyDialer',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = 'Waiting for duty pop';
  String bannerUrl = 'https://xivapi.com/i/100000/100001_hr1.png';
  int queueSeconds = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: StreamBuilder(
                  stream: streamSocket.getResponse,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      final data =
                          IpcMessage.fromJson(jsonDecode(snapshot.data!));
                      text = 'Duty pop: ${data.contentName}';
                      bannerUrl = data.banner;
                      queueSeconds = max(
                          DateTime.fromMillisecondsSinceEpoch(
                                  data.unixMilliseconds,
                                  isUtc: true)
                              .add(Duration(seconds: 45))
                              .difference(DateTime.now().toUtc())
                              .inSeconds,
                          0);
                    }

                    return Column(
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
                          style: TextStyle(
                              fontSize: 36, fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                        ),
                        Image.network(bannerUrl,
                            height: 200, fit: BoxFit.fitWidth),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
