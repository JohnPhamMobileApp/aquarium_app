import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:math';

// Global database helper
final dbHelper = DatabaseHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aquarium App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Fish> _fishList = [];

  @override
  void initState() {
    super.initState();
    _loadFishFromDatabase();
  }

  void _loadFishFromDatabase() async {
    final allFish = await dbHelper.queryAllFish();
    setState(() {
      _fishList = allFish.map((fish) => Fish(
        speed: fish[DatabaseHelper.columnSpeed],
        color: Color(int.parse(fish[DatabaseHelper.columnColor], radix: 16)),
      )).toList();
    });
  }

  void _addFish() async {
    // Create random fish data
    final random = Random();
    int speed = random.nextInt(5) + 1; // Speed between 1 and 5
    String colorHex = (random.nextInt(0xFFFFFF)).toRadixString(16).padLeft(6, '0'); // Random color

    Map<String, dynamic> row = {
      DatabaseHelper.columnSpeed: speed,
      DatabaseHelper.columnColor: '0xFF$colorHex', // Store color in hex
    };

    await dbHelper.insertFish(row);
    _loadFishFromDatabase(); // Reload after adding new fish
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Aquarium'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Stack(
                children: _fishList.map((fish) => fish.buildFish()).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFish,
              child: const Text('Add Fish'),
            ),
          ],
        ),
      ),
    );
  }
}

// Fish class for representing fish data
class Fish {
  final double speed;
  final Color color;

  Fish({required this.speed, required this.color});

  Widget buildFish() {
    return AnimatedAlign(
      alignment: Alignment(
        Random().nextDouble() * 2 - 1, // Random x position
        Random().nextDouble() * 2 - 1, // Random y position
      ),
      duration: Duration(seconds: speed.toInt()),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
