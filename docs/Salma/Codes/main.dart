cd C:\Users\qaise\my_auc\lib\main.dart

  import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyAUC Navigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? selectedDestination;
  String serverStatusText = "No data yet";

  final List<String> destinations = [
    'Electronics Lab 1',
    'Embedded Systems Lab',
    'Microprocessors Lab',
    'Professor Office 101',
    'Department Head Office',
  ];

  Future<void> fetchMapData() async {
    if (selectedDestination == null) {
      setState(() {
        serverStatusText = "Please select a destination first!";
      });
      return;
    }

    setState(() {
      serverStatusText = "Calculating route to $selectedDestination...";
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.8.160:8080/map?destination=$selectedDestination'),
      );

      if (response.statusCode == 200) {
        setState(() {
          serverStatusText = response.body; 
        });
      } else {
        setState(() {
          serverStatusText = "Server Error: Status ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        serverStatusText = "Failed to connect to Server.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          'MyAUC Indoor Navigation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Prevents layout clipping on smaller phone screens
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ NEW: Blueprint Map Display Card positioned directly at the top
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    'http://192.168.8.160:8080/getmapimage',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.map_outlined, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30), // Gap below the map visual
              
              // Destination Dropdown Picker
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Destination',
                  labelStyle: TextStyle(color: Colors.blue[800]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!, width: 2.0),
                  ),
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue[800]),
                ),
                value: selectedDestination,
                items: destinations.map((String room) {
                  return DropdownMenuItem<String>(value: room, child: Text(room));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedDestination = newValue;
                  });
                },
              ),
              const SizedBox(height: 30),
              
              // Navigation Instructions Display Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    serverStatusText,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              
              // Action Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: fetchMapData,
                child: const Text(
                  'Fetch Map from Server',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
