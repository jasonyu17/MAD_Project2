import 'package:flutter/material.dart';
import 'package:project2/services/finnhub_socket_service.dart';
import 'package:project2/widgets/live_stock_widget.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
    children: const [
      Expanded(child: LiveStockWidget(symbol: 'AAPL')),
    ],
  );
  }
}
