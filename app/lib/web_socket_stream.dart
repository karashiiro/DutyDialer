import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketStream {
  final _socketResponse = StreamController<String>();
  IOWebSocketChannel? _channel;

  Stream<String> get getResponse => _socketResponse.stream;

  bool isConnected() {
    return _channel != null;
  }

  void connectTo(String server) {
    _channel?.sink.close(status.goingAway);

    try {
      _channel = IOWebSocketChannel.connect(server);
    } catch (error) {
      print(error);
      return;
    }

    _channel!.stream.listen(
      (message) {
        _socketResponse.sink.add(message);
      },
      onError: (error) {
        print(error);
        _channel = null;
      },
    );
  }

  void dispose() {
    _socketResponse.close();
  }
}
