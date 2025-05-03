import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesService {
  static final _collection = FirebaseFirestore.instance.collection('favorites');

  static Future<Set<String>> getFavorites() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  
  static Future<void> addFavorite(Map<String, dynamic> stock) async {
    final profileUrl = Uri.parse(
      'https://finnhub.io/api/v1/stock/profile2?symbol=${stock['symbol']}&token=d0aoti1r01qm3l9mshp0d0aoti1r01qm3l9mshpg',
    );

    final response = await http.get(profileUrl);
    String sector = 'Unknown';

    if (response.statusCode == 200) {
      final profile = jsonDecode(response.body);
      sector = profile['finnhubIndustry'] ?? 'Unknown';
    }

    await _collection.doc(stock['symbol']).set({
      'symbol': stock['symbol'],
      'description': stock['description'],
      'type': stock['type'],
      'sector': sector,
    });
  }


  
  static Future<void> removeFavorite(String symbol) async {
    await _collection.doc(symbol).delete();
  }

  static Future<void> toggleFavorite(Map<String, dynamic> stock, Set<String> currentFavorites) async {
    final symbol = stock['symbol'];
    final doc = FirebaseFirestore.instance.collection('favorites').doc(symbol);

    if (currentFavorites.contains(symbol)) {
      await doc.delete();
    } else {
      await addFavorite(stock);
    }
  }



  static Stream<QuerySnapshot<Map<String, dynamic>>> streamFavorites() {
    return _collection.snapshots();
  }
}
