import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project2/services/finnhub_socket_service.dart';

class LiveStockWidget extends StatefulWidget {
  final String symbol;

  const LiveStockWidget({super.key, required this.symbol});

  @override
  _LiveStockWidgetState createState() => _LiveStockWidgetState();
}

class _LiveStockWidgetState extends State<LiveStockWidget> {
  late FinnhubSocketService _service;

  @override
  void initState() {
    super.initState();
    _service = FinnhubSocketService(widget.symbol);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _service.stream,
      builder: (context, snapshot) {
  print("Snapshot state: ${snapshot.connectionState}");
  print("Snapshot hasData: ${snapshot.hasData}");
  print("Snapshot error: ${snapshot.error}");
  if (snapshot.hasError) {
    return Text("Error: ${snapshot.error}");
  }

  if (snapshot.hasData) {
    final data = snapshot.data;
    print("Raw data: $data");

    final decoded = jsonDecode(data);
    final trades = decoded['data'] ?? [];

    if (trades.isEmpty) {
      return const Center(child: Text('No trades yet...'));
    }

    return ListView.builder(
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return ListTile(
          title: Text('${widget.symbol} @ \$${trade['p']}'),
          subtitle: Text('Volume: ${trade['v']}'),
        );
      },
    );
  }

  return const Center(child: CircularProgressIndicator());
},

    );
  }
}
