import 'package:flutter/material.dart';
import 'package:project2/pages/home_page.dart';
import 'package:project2/pages/search_page.dart';
import 'package:project2/pages/watchlist_page.dart';
import 'package:project2/pages/news_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Tracking App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StockTracking(),
    );
  }
}

class StockTracking extends StatefulWidget {
  @override
  _StockTrackingState createState() => _StockTrackingState();
  
}

class _StockTrackingState extends State<StockTracking> {
  int selectedIndex = 0;
  
  
  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    WatchlistPage(),
    NewsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Tracking App')),
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white, 
      selectedItemColor: Colors.blue, 
      unselectedItemColor: Colors.black54, 
      currentIndex: selectedIndex,
      onTap: _onItemTapped,
      items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: "Search",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.tv),
      label: "Watchlist",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.newspaper),
      label: "News",
    ),
  ],
),

      
    );
  }
}
