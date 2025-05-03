import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  List<double> _priceHistory = [];
  Set<String> _favoritedSymbols = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchQuote();
    fetchPriceHistory();
    _loadFavorites();
  }

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
          _error = 'Quote failed (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Quote error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> fetchPriceHistory() async {
    final url = Uri.parse(
      'https://finnhub.io/api/v1/stock/candle?symbol=${widget.symbol}&resolution=D&count=10&token=d0aoti1r01qm3l9mshp0d0aoti1r01qm3l9mshpg',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prices = List<double>.from(data['c'] ?? []);
        setState(() => _priceHistory = prices);
      }
    } catch (e) {
      print("Error fetching price history: $e");
    }
  }

  Future<void> _loadFavorites() async {
    final symbols = await FavoritesService.getFavorites();
    setState(() => _favoritedSymbols = symbols);
  }

  Future<void> _toggleFavorite() async {
    final stockData = {
      'symbol': widget.symbol,
      'description': widget.symbol,
      'type': 'Stock',
    };

    await FavoritesService.toggleFavorite(stockData, _favoritedSymbols);
    if (!mounted) return;
    setState(() {
      if (_favoritedSymbols.contains(widget.symbol)) {
        _favoritedSymbols.remove(widget.symbol);
      } else {
        _favoritedSymbols.add(widget.symbol);
      }
    });
  }

  void _showDetailsDialog() {
    final isFavorited = _favoritedSymbols.contains(widget.symbol);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.symbol),
            IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : null,
              ),
              onPressed: () {
                Navigator.of(context).pop(); 
                _toggleFavorite();
              },
            )
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Price: \$${_quote?['c']}'),
            Text('High: \$${_quote?['h']}'),
            Text('Low: \$${_quote?['l']}'),
            Text('Previous Close: \$${_quote?['pc']}'),
          ],
        ),
      ),
    );
  }

  //I dont have access to candle from finnhub
  //below is the code for the chart if you have access to the candle data
  

  Widget _buildChart() {
    if (_priceHistory.isEmpty) {
      return const SizedBox(width: 100, height: 50, child: Center(child: Text("No chart")));
    }

    return SizedBox(
      width: 100,
      height: 50,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _priceHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: false),
            )
          ],
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Text(_error!);
    if (_quote == null) return const Text("No data");

    return ListTile(
      title: Text('${widget.symbol} @ \$${_quote!['c']}'),
      subtitle: Text('Previous Close: \$${_quote!['pc']}'),
      trailing: _buildChart(),
      onTap: _showDetailsDialog,
    );
  }
}
