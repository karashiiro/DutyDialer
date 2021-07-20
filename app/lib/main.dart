import 'package:duty_dialer/countdown_page.dart';
import 'package:duty_dialer/se_license.dart';
import 'package:duty_dialer/server_address_entry_view.dart';
import 'package:duty_dialer/web_socket_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

WebSocketStream streamSocket = WebSocketStream();

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  final themePrimaryColor = const Color(0xFFFF9334);
  final themePrimaryColorShade = const Color(0xFFBA9D7E);
  final themePrimaryColorTint = const Color(0xFFF9AE3E);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DutyDialer',
      home: KeyboardVisibilityProvider(
        child: ServerAddressEntryPage(),
      ),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFEEDF),
        backgroundColor: themePrimaryColorShade,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.black),
          backgroundColor: MaterialStateProperty.all(themePrimaryColor),
          shadowColor: MaterialStateProperty.all(
            const Color(0xFFFFEEDF),
          ),
        )),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white70),
          overlayColor: MaterialStateProperty.all(themePrimaryColorTint),
          side: MaterialStateProperty.all(
            BorderSide(
              color: themePrimaryColor,
            ),
          ),
        )),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: themePrimaryColor,
            ),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: themePrimaryColor,
          selectionColor: themePrimaryColorShade,
          selectionHandleColor: themePrimaryColor,
        ),
      ),
    );
  }
}

class ServerAddressEntryPage extends StatefulWidget {
  @override
  _ServerAddressEntryPageState createState() => _ServerAddressEntryPageState();
}

class _ServerAddressEntryPageState extends State<ServerAddressEntryPage> {
  String serverAddress = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          ServerAddressEntryView(
            onAddressChanged: (text) {
              serverAddress = text;
            },
            onConnectActivated: () async {
              streamSocket.connectTo(serverAddress);
              await streamSocket.waitUntilConnected(Duration(seconds: 10));
              if (!streamSocket.isConnected()) {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => CountdownPage(
                      streamSocket: streamSocket,
                    ),
                  ),
                );
              }
            },
          ),
          SquareEnixLicenseInfo(),
        ],
      ),
    );
  }
}
