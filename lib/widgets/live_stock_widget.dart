import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project2/services/favorites_service.dart';

class LiveStockWidget extends StatefulWidget {
  final String symbol;

  const LiveStockWidget({super.key, required this.symbol});

  @override
  _LiveStockWidgetState createState() => _LiveStockWidgetState();
}

class _LiveStockWidgetState extends State<LiveStockWidget> {
  Map<String, dynamic>? _quote;
  bool _isLoading = true;
  Set<String> _favoritedSymbols = {};
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

  Future<void> _loadFavorites() async {
    final symbols = await FavoritesService.getFavorites();
    setState(() {
      _favoritedSymbols = symbols;
    });
  }

  Future<void> _toggleFavorite() async {
    final stockData = {
      'symbol': widget.symbol,
      'description': widget.symbol,
      'type': 'Stock',
    };

    await FavoritesService.toggleFavorite(stockData, _favoritedSymbols);
    setState(() {
      if (_favoritedSymbols.contains(widget.symbol)) {
        _favoritedSymbols.remove(widget.symbol);
      } else {
        _favoritedSymbols.add(widget.symbol);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchQuote();
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Text(_error!);
    if (_quote == null) return const Text("No data");

    final isFavorited = _favoritedSymbols.contains(widget.symbol);

    return ListTile(
      title: Text('${widget.symbol} @ \$${_quote!['c']}'),
      subtitle: Text('Previous Close: \$${_quote!['pc']}'),
      trailing: IconButton(
        icon: Icon(
          isFavorited ? Icons.favorite : Icons.favorite_border,
          color: isFavorited ? Colors.red : null,
        ),
        onPressed: _toggleFavorite,
      ),
    );
  }
}
