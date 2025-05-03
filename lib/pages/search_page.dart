import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project2/utils/debouncer.dart'; 

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 400);

  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

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
              hintText: "Search stock",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (text) {
              _debouncer.run(() => _searchStocks(text));
            },
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
                          return ListTile(
                            title: Text(stock['description']),
                            subtitle: Text(stock['symbol']),
                            trailing: Text(stock['type']),
                          );
                        },
                      ),
              ),
      ],
    );
  }
}
