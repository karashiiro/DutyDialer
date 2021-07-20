import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ServerAddressEntryView extends StatefulWidget {
  const ServerAddressEntryView(
      {Key? key,
      required this.onAddressChanged,
      required this.onConnectActivated})
      : super(key: key);

  final void Function(String) onAddressChanged;
  final void Function() onConnectActivated;

  @override
  _ServerAddressEntryViewState createState() => _ServerAddressEntryViewState();
}

class _ServerAddressEntryViewState extends State<ServerAddressEntryView>
    with RouteAware {
  late RouteObserver routeObserver;

  QRViewController? controller;
  StreamSubscription? subscription;

  @override
  void initState() {
    routeObserver = RouteObserver<PageRoute>();
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
      widget.onAddressChanged(scanData.code);
      widget.onConnectActivated();
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    controller?.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
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
            formatsAllowed: [BarcodeFormat.qrcode],
            overlay: QrScannerOverlayShape(
                borderColor: const Color(0xFFFF9334),
                borderRadius: 10,
                borderLength: 50,
                borderWidth: 10,
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
                                  onSubmitted: (_) =>
                                      widget.onConnectActivated(),
                                  onChanged: widget.onAddressChanged,
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
                                onPressed: widget.onConnectActivated,
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
