import 'dart:convert';
import 'dart:math';

import 'package:duty_dialer/countdown_view.dart';
import 'package:duty_dialer/ipc_message.dart';
import 'package:duty_dialer/server_address_entry_view.dart';
import 'package:duty_dialer/web_socket_stream.dart';
import 'package:flutter/material.dart';

WebSocketStream streamSocket = WebSocketStream();

void main() {
  runApp(App());
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
  String serverAddress = '';
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
                    if (!streamSocket.isConnected()) {
                      return ServerAddressEntryView(
                        streamSocket: streamSocket,
                        onAddressFieldChanged: (text) {
                          serverAddress = text;
                        },
                        onConnectButtonPressed: () {
                          streamSocket.connectTo(serverAddress);
                        },
                      );
                    }

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

                    return CountdownView(
                      queueSeconds: queueSeconds,
                      text: text,
                      bannerUrl: bannerUrl,
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
