import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project2/widgets/live_stock_widget.dart';

class WatchlistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favs = FirebaseFirestore.instance.collection('favorites');

    return StreamBuilder(
      stream: favs.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error: ${snapshot.error}");
        if (!snapshot.hasData) return CircularProgressIndicator();

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Center(child: Text("No favorites yet."));

        return ListView(
          children: docs.map((doc) {
            final data = doc.data();
            return LiveStockWidget(symbol: data['symbol']);
          }).toList(),
        );
      },
    );
  }
}
