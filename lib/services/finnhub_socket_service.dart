import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class FinnhubSocketService {
  final String _apiKey = 'd0aoti1r01qm3l9mshp0d0aoti1r01qm3l9mshpg'; 
  final String _symbol;
  late WebSocketChannel _channel;

  FinnhubSocketService(this._symbol) {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.finnhub.io?token=$_apiKey'),
    );

    _channel.sink.add(jsonEncode({
      'type': 'subscribe',
      'symbol': _symbol,
    }));
  }

  Stream<dynamic> get stream => _channel.stream;

  void dispose() {
    _channel.sink.add(jsonEncode({
      'type': 'unsubscribe',
      'symbol': _symbol,
    }));
    _channel.sink.close();
  }
}
