// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:rubber_lk/services/firebase_services.dart';

class MeterDashboardScreen extends StatefulWidget {
  const MeterDashboardScreen({super.key});

  @override
  _MeterDashboardScreenState createState() => _MeterDashboardScreenState();
}

class _MeterDashboardScreenState extends State<MeterDashboardScreen> {
  FirebaseService firebaseService = FirebaseService();

  String temperature = '...';
  String humidity = '...';
  double soilMoisture = 0.00;
  String message = 'Loading...';
  double rainLevel = 0.0;

  @override
  void initState() {
    super.initState();

    // Listen to the latest data entry in the Monitoring_System/data path
    firebaseService.database
        .ref('Monitoring_System/data')
        .limitToLast(1)
        .onValue
        .listen(
          (event) {
            if (event.snapshot.value != null) {
              // Extract the last data point (most recent)
              Map<dynamic, dynamic> dataMap = event.snapshot.value as Map;

              // Get the key of the latest entry
              String latestKey = dataMap.keys.first;
              Map<dynamic, dynamic> latestData = dataMap[latestKey];

              setState(() {
                // Update sensor values from the latest data point
                temperature = latestData['temperature']?.toString() ?? 'N/A';
                humidity = latestData['humidity']?.toString() ?? 'N/A';
                soilMoisture = latestData['soil_moisture']?.toDouble() ?? 0.0;
                rainLevel = latestData['rain_level']?.toDouble() ?? 0.0;

                // Set message based on rain_level
                message = rainLevel > 10 ? 'Raining!' : 'Not Raining!';
              });
            }
          },
          onError: (error) {
            print('Firebase Error: $error');
            setState(() {
              message = 'Connection Error!';
            });
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text(
          'Sensor Dashboard',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MeterCard(
                title: 'Temperature',
                value: temperature,
                icon: Icons.thermostat_outlined,
                icolor: Colors.redAccent,
              ),
              MeterCard(
                title: 'Humidity',
                value: humidity,
                icon: Icons.water_damage,
                icolor: Colors.blueAccent,
              ),
              MeterCard(
                title: 'Soil Moisture',
                value: soilMoisture.toString(),
                icon: Icons.waves,
                icolor: Colors.brown,
              ),
            ],
          ),
          const SizedBox(height: 40),

          showImage(),
          const SizedBox(height: 10),
          showImagerain(),
          Text(
            message,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget showImage() {
    if (message == 'Not Raining!') {
      if (soilMoisture < 45) {
        return Column(
          children: [
            Image.asset('assets/images/shovel.png', width: 150, height: 150),
            const SizedBox(height: 10),
            const Text(
              'Need to fertilize',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Image.asset('assets/images/tree.png', width: 200, height: 200),
            const Text(
              'No need to fertilize',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        );
      }
    } else {
      return Column(
        children: [
          Image.asset('assets/images/tree.png', width: 200, height: 200),
          const Text(
            'No need to fertilize',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      );
    }
  }

  Widget showImagerain() {
    if (message == 'Not Raining!') {
      return Image.asset('assets/icons/03d.png', width: 200, height: 200);
    } else {
      return Image.asset('assets/icons/09n.png', width: 200, height: 200);
    }
  }
}

class MeterCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color icolor;

  const MeterCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.icolor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: icolor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
