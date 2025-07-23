import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'models/weather_data.dart';
import 'dart:math';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  WeatherData? weatherData;
  bool isLoading = false;
  Map<String, List<int>> recommendedIndicesByDate = {};

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  void generateRecommendations() {
    if (weatherData == null) return;

    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    final tomorrowStr = tomorrow.toString().split(' ')[0];

    // Always set 3 AM and 4 AM as recommended times
    recommendedIndicesByDate[tomorrowStr] = [3, 4];
  }

  Future<void> fetchWeatherData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=7.2906&longitude=80.6336&hourly=showers&timezone=auto&forecast_days=3',
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          weatherData = WeatherData.fromJson(jsonDecode(response.body));
          generateRecommendations(); // Generate recommendations after getting weather data
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<double> getTomorrowData() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final List<double> tomorrowData = [];

    if (weatherData == null || weatherData!.time.isEmpty) {
      return List.filled(24, 0.0); // Return default data if no data available
    }

    for (var i = 0; i < weatherData!.time.length; i++) {
      final date = DateTime.parse(weatherData!.time[i]);
      if (date.year == tomorrow.year &&
          date.month == tomorrow.month &&
          date.day == tomorrow.day) {
        tomorrowData.add(weatherData!.showers[i]);
      }
    }

    // If no data found, return default values
    if (tomorrowData.isEmpty) {
      return List.filled(24, 0.0);
    }

    return tomorrowData;
  }

  double getTotalRainfall() {
    return getTomorrowData().reduce((a, b) => a + b);
  }

  String getStatus(int timeSlot) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowStr = tomorrow.toString().split(' ')[0];
    return recommendedIndicesByDate[tomorrowStr]?.contains(timeSlot) ?? false
        ? 'Recommended'
        : 'Normal';
  }

  Color getStatusColor(int timeSlot) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowStr = tomorrow.toString().split(' ')[0];
    return recommendedIndicesByDate[tomorrowStr]?.contains(timeSlot) ?? false
        ? Colors.green
        : Colors.blue;
  }

  bool areAllTimeSlotsRecommended() {
    return getTomorrowData()
        .asMap()
        .entries
        .where((entry) => entry.key >= 1 && entry.key <= 6)
        .every((entry) => entry.value <= 0.5);
  }

  bool shouldShowNextDayWarning() {
    double totalRainfall = getTomorrowData().reduce((a, b) => a + b);
    return totalRainfall > 4.0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('HARVEST PREDICTION'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? Container(
                color: Colors.black,
                width: double.infinity,
                height: size.height,
                child: const Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              )
              : weatherData == null
              ? const Center(child: Text('Failed to load data'))
              : SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(color: Colors.black),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Rainfall Forecast',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rainfall Forecast for ${DateTime.now().add(Duration(days: 1)).toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '(Tomorrow)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 400,
                        child: LineChart(
                          LineChartData(
                            maxX: 23,
                            minY: 0,
                            maxY: 30,
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                                axisNameWidget: const Text(
                                  'Rainfall (mm)',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() % 3 == 0) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${value.toInt()}:00',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 40,
                                ),
                                axisNameWidget: const Text(
                                  'Date',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots:
                                    getTomorrowData()
                                        .asMap()
                                        .entries
                                        .map(
                                          (e) => FlSpot(
                                            e.key.toDouble(),
                                            e.value < 0 ? 0 : e.value,
                                          ),
                                        )
                                        .toList(),
                                isCurved: true,
                                curveSmoothness: 0.3,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color.fromARGB(
                                    123,
                                    33,
                                    149,
                                    243,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 64),
                      const Text(
                        'Harvesting suggestion',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     _buildConditionIndicator(
                      //       'Recommended',
                      //       Colors.green,
                      //       '< 5mm',
                      //     ),
                      //     const SizedBox(width: 16),
                      //     _buildConditionIndicator(
                      //       'Moderate',
                      //       Colors.orange,
                      //       '5mm - 10mm',
                      //     ),
                      //     const SizedBox(width: 16),
                      //     _buildConditionIndicator(
                      //       'Not Recommended',
                      //       Colors.red,
                      //       '> 10mm',
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 20),
                      if (areAllTimeSlotsRecommended())
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Note: All time slots are recommended for harvesting',
                            style: TextStyle(color: Colors.green),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (shouldShowNextDayWarning())
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Warning: Do not harvest the day after tomorrow due to rainfall tomorrow',
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      DataTable(
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Time',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                        rows: List.generate(6, (index) {
                          final timeSlot = index + 1;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '$timeSlot:00',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DataCell(
                                Text(
                                  getStatus(timeSlot),
                                  style: TextStyle(
                                    color: getStatusColor(timeSlot),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
