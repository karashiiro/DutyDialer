import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketStream {
  final _socketResponse = StreamController<String>();
  IOWebSocketChannel? _channel;

  Stream<String> get getResponse => _socketResponse.stream;

  void connectTo(String server) {
    _channel?.sink.close(status.goingAway);
    _channel = IOWebSocketChannel.connect(server);
    _channel!.stream.listen((message) {
      _socketResponse.sink.add(message);
    });
  }

  void dispose() {
    _socketResponse.close();
  }
}
