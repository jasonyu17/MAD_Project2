import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }



  Future<void> fetchNews() async {
    final url = Uri.parse(
      'https://finnhub.io/api/v1/news?category=general&token=d0aoti1r01qm3l9mshp0d0aoti1r01qm3l9mshpg',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _articles = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("Failed to load news: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching news: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: article['image'] != null && article['image'] != ""
                ? Image.network(article['image'], width: 60, fit: BoxFit.cover)
                : null,
            title: Text(article['headline'] ?? 'No title'),
            subtitle: Text(
              article['summary'] ?? 'No summary',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _launchURL(article['url']),
          ),
        );
      },
    );
  }
}
