import 'package:flutter/material.dart';
import 'dart:math'; 
import 'database_helper.dart';

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
      title: 'VIRTUAL AQUARIUM',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

// Define the Fish class
class Fish {
  Color color;
  double speed; 
  
  Fish({required this.color, required this.speed});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Fish> fishList = []; // List of fish objects
  List<Offset> fishPositions = []; // Current positions of fish
  final double aquariumWidth = 300; // Width of the aquarium
  final double aquariumHeight = 300; // Height of the aquarium

  // Variables for controlling fish speed and color
  double selectedSpeed = 1.0; // Default speed
  Color selectedColor = Colors.blue; // Default color

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100), // Faster animation
      vsync: this,
    )..addListener(() {
        // Update fish positions based on animation progress
        _updateFishPositions();
      });
  }

  void _updateFishPositions() {
    setState(() {
      for (int i = 0; i < fishList.length; i++) {
        // Update position based on fish speed and animation value
        double deltaX = fishList[i].speed * (1 + Random().nextDouble()); // Randomize movement
        double deltaY = fishList[i].speed * (1 + Random().nextDouble()); // Randomize movement
        fishPositions[i] = Offset(
          (fishPositions[i].dx + deltaX) % aquariumWidth,
          (fishPositions[i].dy + deltaY) % aquariumHeight,
        );
      }
    });
  }

  void _addFish() {
    if (fishList.length < 10) { // Limiting to 10 fish
      setState(() {
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
        fishPositions.add(Offset(Random().nextDouble() * aquariumWidth, Random().nextDouble() * aquariumHeight)); // Random position
        if (fishList.length == 1) {
          _controller.repeat(); // Start animation when first fish is added
        }
      });
    }
  }

  void _removeFish() {
    setState(() {
      if (fishList.isNotEmpty) {
        fishList.removeLast();
        fishPositions.removeLast();
      }
      if (fishList.isEmpty) {
        _controller.stop(); // Stop animation if no fish are left
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIRTUAL AQUARIUM'),
        backgroundColor: Colors.blue,
      ),
      body: Center( // Center the aquarium in the middle of the screen
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: aquariumWidth,
              height: aquariumHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
              ),
            ),
            ...List.generate(fishList.length, (index) {
              return Positioned(
                left: fishPositions[index].dx,
                top: fishPositions[index].dy,
                child: Container(
                  width: 20, // Size of the fish
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fishList[index].color,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _addFish,
                child: const Text('Add Fish'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _removeFish,
                child: const Text('Delete Fish'),
              ),
            ],
          ),
          // Slider for adjusting speed
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Speed:'),
              Slider(
                value: selectedSpeed,
                min: 0.5,
                max: 5.0,
                divisions: 10,
                label: selectedSpeed.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    selectedSpeed = value;
                  });
                },
              ),
            ],
          ),
          // Dropdown for selecting color
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Select Color:'),
              DropdownButton<Color>(
                value: selectedColor,
                items: Colors.primaries.map((Color color) {
                  return DropdownMenuItem<Color>(
                    value: color,
                    child: Container(
                      width: 50,
                      height: 20,
                      color: color,
                    ),
                  );
                }).toList(),
                onChanged: (Color? newValue) {
                  setState(() {
                    if (newValue != null) {
                      selectedColor = newValue;
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
