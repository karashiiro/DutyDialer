import 'package:duty_dialer/web_socket_stream.dart';
import 'package:flutter/material.dart';

class ServerAddressEntryView extends StatelessWidget {
  const ServerAddressEntryView(
      {Key? key,
      required this.streamSocket,
      required this.onAddressFieldChanged,
      required this.onConnectButtonPressed})
      : super(key: key);

  final WebSocketStream streamSocket;
  final void Function(String) onAddressFieldChanged;
  final void Function() onConnectButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Plugin server address',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          TextField(
            onChanged: onAddressFieldChanged,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
          ),
          ElevatedButton(
            onPressed: onConnectButtonPressed,
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(Size(120, 45)),
              textStyle: MaterialStateProperty.all(TextStyle(
                fontSize: 18,
              )),
            ),
            child: Text('Connect'),
          )
        ],
      ),
    );
  }
}
