import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StockQuoteWidget extends StatefulWidget {
  final String symbol;
  const StockQuoteWidget({super.key, required this.symbol});

  @override
  State<StockQuoteWidget> createState() => _StockQuoteWidgetState();
}

class _StockQuoteWidgetState extends State<StockQuoteWidget> {
  Map<String, dynamic>? _quote;
  bool _isLoading = true;
  Future<void> fetchQuote() async {
    final url = Uri.parse(
      'https://finnhub.io/api/v1/quote?symbol=${widget.symbol}&token=d0aoti1r01qm3l9mshp0d0aoti1r01qm3l9mshpg',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        _quote = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _quote = null;
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
    if (_isLoading) return CircularProgressIndicator();

    if (_quote == null) return Text("Failed to load quote");

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${widget.symbol}'),
        Text('Current Price: \$${_quote!["c"]}'),
        Text('Open: \$${_quote!["o"]}'),
        Text('High: \$${_quote!["h"]}'),
        Text('Low: \$${_quote!["l"]}'),
        Text('Previous Close: \$${_quote!["pc"]}'),
      ],
    );
  }
}
