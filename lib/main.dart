import 'package:flutter/material.dart';
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Color> fishColors = []; // List to store fish colors

  void _addFish() {
    // Add a random color for the fish
    setState(() {
      fishColors.add(Colors.primaries[fishColors.length % Colors.primaries.length]); // Cycle through available colors
    });
  }

  void _removeFish() {
    // Remove the last fish if there are any
    setState(() {
      if (fishColors.isNotEmpty) {
        fishColors.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIRTUAL AQUARIUM'),
        backgroundColor: Colors.blue, // Set the AppBar color to blue
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                ),
                itemCount: fishColors.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 10, // Smaller width for the fish
                    height: 10, // Smaller height for the fish
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: fishColors[index],
                    ),
                    margin: const EdgeInsets.all(5),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
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
          ],
        ),
      ),
    );
  }
}
