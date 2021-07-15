import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:duty_dialer/countdown_view.dart';
import 'package:duty_dialer/ipc_message.dart';
import 'package:duty_dialer/server_address_entry_view.dart';
import 'package:duty_dialer/web_socket_stream.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFEEDF),
        backgroundColor: Color(0xFFBA9D7E),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.black),
          backgroundColor: MaterialStateProperty.all(Color(0xFFFF9334)),
          shadowColor: MaterialStateProperty.all(Color(0xFFFFEEDF)),
        )),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final popSoundPlayer = !Platform.isWindows ? AudioPlayer() : null;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String serverAddress = '';
  String text = 'Waiting for duty pop…';
  String bannerUrl = 'https://xivapi.com/i/100000/100001_hr1.png';
  int queueSeconds = 0;

  late Future? loadSoundFuture =
      widget.popSoundPlayer?.setAsset('assets/sounds/lb_charged.mp3');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 6),
            ),
            Center(
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
                      onConnectButtonPressed: () async {
                        streamSocket.connectTo(serverAddress);
                        await streamSocket
                            .waitUntilConnected(Duration(seconds: 10));
                        setState(() {});
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

                    if (Platform.isWindows) {
                      print("audio is not supported on this platform.");
                    } else {
                      (() async {
                        await loadSoundFuture;
                        widget.popSoundPlayer?.play();
                      })();
                    }
                  }

                  return CountdownView(
                    queueSeconds: queueSeconds,
                    text: text,
                    bannerUrl: bannerUrl,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
