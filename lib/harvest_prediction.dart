// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:intl/intl.dart';
import 'Ideal_times.dart';

class HarvestPrediction extends StatefulWidget {
  const HarvestPrediction({Key? key}) : super(key: key);

  @override
  _HarvestPredictionState createState() => _HarvestPredictionState();
}

class _HarvestPredictionState extends State<HarvestPrediction>
    with TickerProviderStateMixin {
  bool isLoading = true;
  List<Prediction> predictionItem = [];
  final firestoreInstance = FirebaseFirestore.instance;
  late final GifController controller1;

  Future<void> fetchModulesData() async {
    try {
      final querySnapshot =
          await firestoreInstance.collection('prediction').get();
      predictionItem =
          querySnapshot.docs.map((doc) {
            Timestamp timestamp = doc.get("date");
            DateTime dateTime = timestamp.toDate();

            return Prediction(
              predictionID: doc.id,
              amount: doc.get("amount"),
              date: dateTime,
              temperature: doc.get("temperature"),
              rainfall: doc.get("rainfall"),
              humidity: doc.get("humidity"),
            );
          }).toList();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchModulesData();
    controller1 = GifController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text(
          'Harvest Prediction',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/machine-learning.png',
                          width: 80,
                          height: 80,
                        ),
                        // Gif(
                        //   width: 120,
                        //   height: 120,
                        //   autostart: Autostart.loop,
                        //   image: const AssetImage('assets/images/giphy.gif'),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: predictionItem.length,
                      itemBuilder: (context, index) {
                        String formattedDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(predictionItem[index].date);
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: Colors.white.withOpacity(0.2),
                          child: ListTile(
                            title: Text(
                              formattedDate.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Predicted latex Amount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${predictionItem[index].amount}kg',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Humidity',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${predictionItem[index].humidity}%',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Rainfall',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      predictionItem[index].rainfall,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Temperature',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${predictionItem[index].temperature}\u00B0C',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => IdealTimes(
                                              documentId:
                                                  predictionItem[index]
                                                      .predictionID,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Ideal times for tap rubber',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(
                                        Icons.navigate_next,
                                        color: Colors.white,
                                      ),
                                      //Text(predictionItem[index].temperature.toString() + '\u00B0C', style: const TextStyle(fontSize: 15, color: Colors.white),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}

class Prediction {
  final String predictionID;
  final double amount;
  final DateTime date;
  final double humidity;
  final String rainfall;
  final double temperature;

  Prediction({
    required this.predictionID,
    required this.amount,
    required this.date,
    required this.humidity,
    required this.rainfall,
    required this.temperature,
  });
}
