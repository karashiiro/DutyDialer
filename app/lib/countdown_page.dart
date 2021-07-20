import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:duty_dialer/countdown_view.dart';
import 'package:duty_dialer/ipc_message.dart';
import 'package:duty_dialer/web_socket_stream.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class CountdownPage extends StatefulWidget {
  CountdownPage({Key? key, required this.streamSocket}) : super(key: key);

  final WebSocketStream streamSocket;

  final popSoundPlayer = !Platform.isWindows ? AudioPlayer() : null;

  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  String text = 'Waiting for duty pop…';
  String bannerUrl = 'https://xivapi.com/i/100000/100001_hr1.png';
  int queueSeconds = 0;

  late Future? loadSoundFuture =
      widget.popSoundPlayer?.setAsset('assets/sounds/lb_charged.mp3');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 6),
                  ),
                  Center(
                    child: StreamBuilder(
                      stream: widget.streamSocket.getResponse,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
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
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30),
              ),
              RawMaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                elevation: 2.0,
                fillColor: const Color(0xFFFF9334),
                child: Icon(
                  Icons.arrow_back,
                  size: 35.0,
                ),
                padding: const EdgeInsets.all(10.0),
                shape: CircleBorder(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
