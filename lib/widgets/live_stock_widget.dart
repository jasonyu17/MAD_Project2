import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project2/services/finnhub_socket_service.dart';
import 'package:http/http.dart' as http;

class LiveStockWidget extends StatefulWidget {
  final String symbol;

  const LiveStockWidget({super.key, required this.symbol});

  @override
  _LiveStockWidgetState createState() => _LiveStockWidgetState();
}

class _LiveStockWidgetState extends State<LiveStockWidget> {
  Map<String, dynamic>? _quote;
  bool _isLoading = true;
  String? _error;

  Future<void> fetchQuote() async {
    final url = Uri.parse(
      'https://finnhub.io/api/v1/quote?symbol=${widget.symbol}&token=d0aoti1r01qm3l9mshp0d0aoti1r01qm3l9mshpg',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _quote = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch quote (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Text(_error!);
    if (_quote == null) return const Text("No data");

    return ListTile(
      title: Text('${widget.symbol} @ \$${_quote!['c']}'),
      subtitle: Text('Previous Close: \$${_quote!['pc']}'),
      trailing: Text('Vol: N/A'),
    );
  }
}
