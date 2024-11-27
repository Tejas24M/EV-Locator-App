import 'package:flutter/material.dart';
import 'pages/map_page.dart';
import 'slide.dart'; // Import the SlideDrawer file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}

class GlobalConfig {
  static final GlobalConfig _instance = GlobalConfig._internal();

  // final String _url = "192.168.1.101:3000"; // Fixed URL
  final String _url = "13.126.188.82:3000"; // Fixed URL
  final String _googleKey = "AIzaSyDz8CKcfCnCtvkbjwK-tTcZtc96ku8JUJ0";
  String token = "";
  String username = "";

  factory GlobalConfig() {
    return _instance;
  }

  GlobalConfig._internal();

  // Getter for url
  String get url => _url;

  // Getter for googleKey
  String get googleKey => _googleKey;
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IITB EV LOCATOR'),
        backgroundColor: Colors.orange,
      ),
      drawer: SlideDrawer(), // Use SlideDrawer from slide.dart
      body: Column(
        children: [
          Expanded(
            child: MapPage(), // MapPage will be the main content in the expanded section
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            color: Colors.red.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'E-Buggies',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for calling buggy
                  },
                  child: Row(
                    children: [
                      Text('Call Buggy'),
                      SizedBox(width: 8),
                      Icon(Icons.qr_code),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
