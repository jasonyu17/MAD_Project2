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

final subMsg = jsonEncode({
  'type': 'subscribe',
  'symbol': _symbol,
});

print("Subscribing with message: $subMsg");
_channel.sink.add(subMsg);

    _channel.sink.add(jsonEncode({
      'type': 'subscribe',
      'symbol': _symbol,
    }));
    
  }
  
  bool useMockData = true; 

Stream<dynamic> get stream {
  if (useMockData) {
    return Stream.periodic(
      const Duration(seconds: 1),
      (i) => jsonEncode({
        "data": [
          {
            "p": 150.0 + i,
            "v": 100 + i,
            "t": DateTime.now().millisecondsSinceEpoch
          }
        ]
      }),
    );
  } else {
    return _channel.stream.asBroadcastStream();
  }
}

  
  void dispose() {
    _channel.sink.add(jsonEncode({
      'type': 'unsubscribe',
      'symbol': _symbol,
    }));
    _channel.sink.close();
  }
}
