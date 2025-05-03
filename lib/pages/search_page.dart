import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project2/services/favorites_service.dart';
import '../utils/debouncer.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 400);

  List<Map<String, dynamic>> _results = [];
  Set<String> _favoritedSymbols = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final symbols = await FavoritesService.getFavorites();
    setState(() {
      _favoritedSymbols = symbols;
    });
  }

  Future<void> _searchStocks(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://finnhub.io/api/v1/search?q=$trimmed&token=d0aoti1r01qm3l9mshp0d0aoti1r01qm3l9mshpg',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = List<Map<String, dynamic>>.from(data['result']);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } else {
      setState(() {
        _results = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> stock) async {
  await FavoritesService.toggleFavorite(stock, _favoritedSymbols);
  setState(() {
    final symbol = stock['symbol'];
    if (_favoritedSymbols.contains(symbol)) {
      _favoritedSymbols.remove(symbol);
    } else {
      _favoritedSymbols.add(symbol);
    }
  });
}


  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Search stock (e.g. Apple, AAPL)",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (text) => _debouncer.run(() => _searchStocks(text)),
          ),
        ),
        _isLoading
            ? CircularProgressIndicator()
            : Expanded(
                child: _results.isEmpty
                    ? Center(child: Text("No results"))
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final stock = _results[index];
                          final isFavorited = _favoritedSymbols.contains(stock['symbol']);

                          return ListTile(
                            title: Text(stock['description']),
                            subtitle: Text(stock['symbol']),
                            trailing: IconButton(
                              icon: Icon(
                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: isFavorited ? Colors.amber : null,
                              ),
                              onPressed: () => _toggleFavorite(stock),

                            ),
                          );
                        },
                      ),
              ),
      ],
    );
  }
}
