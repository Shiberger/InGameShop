import 'package:flutter/material.dart';
import 'package:app/app/services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In-Game Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(), // เราจะสร้าง HomeScreen ต่อไป
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  String _welcomeMessage = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchMessage();
  }

  void _fetchMessage() async {
    final message = await _apiService.getWelcomeMessage();
    setState(() {
      _welcomeMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In-Game Shop'),
      ),
      body: Center(
        child: Text(_welcomeMessage),
      ),
    );
  }
}