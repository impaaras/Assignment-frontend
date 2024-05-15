import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart'; // Use IOWebSocketChannel for non-web platforms

class WebSocketManager {
  WebSocketChannel? channel;

  void connect(String url) {
    channel = IOWebSocketChannel.connect(url);
  }

  void sendMessage(String message) {
    if (channel != null && channel!.sink != null) {
      channel!.sink.add(message);
    }
  }

  void close() {
    if (channel != null && channel!.sink != null) {
      channel!.sink.close();
    }
  }

  Stream<dynamic> getStream() {
    if (channel != null && channel!.stream != null) {
      return channel!.stream;
    } else {
      throw Exception('WebSocket channel is not initialized.');
    }
  }
}
