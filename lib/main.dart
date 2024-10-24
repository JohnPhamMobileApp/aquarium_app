import 'package:flutter/material.dart';
import 'dart:math'; // Import for random positioning
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
  double speed; // Speed can be used for movement logic
  Offset direction; // Direction of movement
  
  Fish({required this.color, required this.speed, required this.direction});
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 16), // Short duration for fast updates (approx. 60 FPS)
      vsync: this,
    )..addListener(() {
        // Update fish positions based on animation progress
        _updateFishPositions();
      });
  }

  void _updateFishPositions() {
    setState(() {
      for (int i = 0; i < fishList.length; i++) {
        // Update position based on fish speed and direction
        fishPositions[i] = Offset(
          (fishPositions[i].dx + fishList[i].speed * fishList[i].direction.dx) % aquariumWidth,
          (fishPositions[i].dy + fishList[i].speed * fishList[i].direction.dy) % aquariumHeight,
        );

        // Handle wrapping around the aquarium edges
        if (fishPositions[i].dx < 0) {
          fishPositions[i] = Offset(aquariumWidth + fishPositions[i].dx, fishPositions[i].dy);
        }
        if (fishPositions[i].dy < 0) {
          fishPositions[i] = Offset(fishPositions[i].dx, aquariumHeight + fishPositions[i].dy);
        }
      }
    });
  }

  void _addFish() {
    if (fishList.length < 10) { // Limiting to 10 fish
      Color selectedColor = Colors.primaries[fishList.length % Colors.primaries.length]; // Choose color
      double selectedSpeed = 2.0 + (fishList.length % 5); // Example speed logic

      // Set random direction
      double randomDirectionX = (Random().nextDouble() - 0.5) * 2; // Random direction between -1 and 1
      double randomDirectionY = (Random().nextDouble() - 0.5) * 2; // Random direction between -1 and 1
      double length = sqrt(randomDirectionX * randomDirectionX + randomDirectionY * randomDirectionY); // Calculate the length
      // Normalize direction manually
      Offset randomDirection = Offset(
        randomDirectionX / length, 
        randomDirectionY / length
      );

      setState(() {
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed, direction: randomDirection));
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
      body: Center( 
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
      bottomNavigationBar: Row(
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
    );
  }
}
