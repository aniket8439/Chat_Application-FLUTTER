import 'package:web_socket_channel/io.dart';

class WebSocketService {
  final IOWebSocketChannel _channel;

  WebSocketService() : _channel = IOWebSocketChannel.connect('ws://10.0.2.2:7777');

  Stream get stream => _channel.stream;

  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  void dispose() {
    _channel.sink.close();
  }
}
