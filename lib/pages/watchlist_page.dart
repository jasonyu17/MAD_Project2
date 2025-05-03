import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project2/widgets/live_stock_widget.dart';
import 'package:project2/services/favorites_service.dart';

class WatchlistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FavoritesService.streamFavorites(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error: ${snapshot.error}");
        if (!snapshot.hasData) return CircularProgressIndicator();

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Center(child: Text("No favorites yet."));

        
        final Map<String, List<Map<String, dynamic>>> sectorMap = {};
        for (var doc in docs) {
          final data = doc.data();
          final sector = data['sector'] ?? 'Unknown';
          sectorMap.putIfAbsent(sector, () => []).add(data);
        }

        return ListView(
          children: sectorMap.entries.expand((entry) {
            final sector = entry.key;
            final stocks = entry.value;

            return [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Text(sector, style: Theme.of(context).textTheme.titleMedium),
              ),
              ...stocks.map((stock) => LiveStockWidget(symbol: stock['symbol'])),
            ];
          }).toList(),
        );
      },
    );
  }
}
