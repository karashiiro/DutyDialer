import 'package:duty_dialer/web_socket_stream.dart';
import 'package:flutter/material.dart';

class ServerAddressEntryView extends StatefulWidget {
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
  _ServerAddressEntryViewState createState() => _ServerAddressEntryViewState();
}

class _ServerAddressEntryViewState extends State<ServerAddressEntryView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'DutyDialer',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 6),
          ),
          Center(
            child: Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 168,
                  child: TextField(
                    onChanged: widget.onAddressFieldChanged,
                    decoration:
                        InputDecoration(hintText: 'Plugin server address'),
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: widget.onConnectButtonPressed,
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size(120, 45)),
                    textStyle: MaterialStateProperty.all(TextStyle(
                      fontSize: 18,
                    )),
                  ),
                  child: Text('Connect'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
