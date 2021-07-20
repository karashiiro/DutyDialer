import 'dart:async';
import 'dart:io';

import 'package:duty_dialer/web_socket_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ServerAddressEntryView extends StatefulWidget {
  const ServerAddressEntryView({Key? key, required this.onConnected})
      : super(key: key);

  final void Function(WebSocketStream) onConnected;

  @override
  _ServerAddressEntryViewState createState() => _ServerAddressEntryViewState();
}

class _ServerAddressEntryViewState extends State<ServerAddressEntryView>
    with RouteAware {
  late RouteObserver routeObserver;
  late WebSocketStream streamSocket;

  QRViewController? controller;
  StreamSubscription? subscription;

  String serverAddress = '';

  @override
  void initState() {
    routeObserver = RouteObserver<PageRoute>();
    streamSocket = WebSocketStream();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void didPopNext() {
    setState(() {});
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    subscription = controller.scannedDataStream.listen((scanData) {
      connect();
    });
  }

  @override
  void dispose() {
    streamSocket.dispose();
    subscription?.cancel();
    controller?.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void connect() async {
    streamSocket.connectTo(serverAddress);
    await streamSocket.waitUntilConnected(Duration(seconds: 10));
    widget.onConnected(streamSocket);
    /*if (!streamSocket.isConnected()) {
      widget.onConnected(streamSocket);
    }*/
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return Container(
      child: Stack(
        children: <Widget>[
          QRView(
            key: GlobalKey(),
            onQRViewCreated: _onQRViewCreated,
            formatsAllowed: const [BarcodeFormat.qrcode],
            overlay: QrScannerOverlayShape(
                borderColor: const Color(0xFFFF9334),
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 20,
                cutOutSize: scanArea),
          ),
          Column(
            children: [
              Expanded(
                flex: KeyboardVisibilityProvider.isKeyboardVisible(context)
                    ? 0
                    : 4,
                child: Container(),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.black45,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 144,
                                child: TextField(
                                  onSubmitted: (_) => connect(),
                                  onChanged: (text) {
                                    serverAddress = text;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Plugin server address',
                                    hintStyle: TextStyle(
                                      color: Colors.white70,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: const Color(0xFFFF9334),
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              Spacer(),
                              OutlinedButton(
                                onPressed: connect,
                                style: OutlinedButton.styleFrom(
                                  fixedSize: Size(120, 45),
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                child: Text('Connect'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
