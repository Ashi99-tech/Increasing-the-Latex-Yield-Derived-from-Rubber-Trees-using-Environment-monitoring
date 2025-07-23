// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rubber_lk/weather_dashboard.dart';

class Prediction {
  final DateTime date;
  final List<dynamic> times;
  final double humidity;
  final String rainfall;
  final double temperature;

  Prediction({
    required this.date,
    required this.times,
    required this.humidity,
    required this.rainfall,
    required this.temperature,
  });
}

class IdealTimes extends StatefulWidget {
  final String documentId;

  const IdealTimes({super.key, required this.documentId});

  @override
  _IdealTimesState createState() => _IdealTimesState();
}

class _IdealTimesState extends State<IdealTimes> {
  bool isLoading = true;
  List<Prediction> predictionItem = [];
  final firestoreInstance = FirebaseFirestore.instance;

  void fetchModulesData(String documentId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await firestoreInstance
              .collection('prediction')
              .doc(documentId)
              .get();

      if (documentSnapshot.exists) {
        List<dynamic> dataArray = documentSnapshot.get("time_tap_rubber");

        Prediction prediction = Prediction(
          date: documentSnapshot.get("date").toDate(),
          times: dataArray,
          temperature: documentSnapshot.get("temperature"),
          rainfall: documentSnapshot.get("rainfall"),
          humidity: documentSnapshot.get("humidity"),
        );

        setState(() {
          isLoading = false;
          predictionItem.add(prediction);
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Document does not exist');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchModulesData(widget.documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text('PREDICTIONS', style: TextStyle(color: Colors.white)),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: predictionItem.length,
                itemBuilder: (context, index) {
                  String formattedDate = DateFormat(
                    'yyyy-MM-dd',
                  ).format(predictionItem[index].date);
                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      const SizedBox(height: 10),
                      Text(
                        'Predicted Date: $formattedDate',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OtherDetailsCard(
                            title: 'Humidity',
                            value: predictionItem[index].humidity.toString(),
                            icon: Icons.water_damage,
                            icolor: Colors.blueAccent,
                          ),
                          OtherDetailsCard(
                            title: 'Temperature',
                            value: predictionItem[index].temperature.toString(),
                            icon: Icons.compress,
                            icolor: Colors.amber,
                          ),
                          OtherDetailsCard(
                            title: 'Rainfall',
                            value: predictionItem[index].rainfall,
                            icon: Icons.wind_power,
                            icolor: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Ideal time for tap rubber'.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: Colors.white.withOpacity(0.2),
                          child: ListTile(
                            subtitle: Column(
                              children:
                                  predictionItem[index].times
                                      .map(
                                        (item) => Column(
                                          children: [
                                            Text(
                                              item.toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Row(
                                              children: [
                                                Expanded(
                                                  child: Divider(
                                                    color: Colors.grey,
                                                    thickness: 0.3,
                                                    endIndent: 14,
                                                    indent: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }
}
