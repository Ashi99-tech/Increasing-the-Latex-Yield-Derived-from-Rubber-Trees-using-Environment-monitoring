class WeatherData {
  final List<String> time;
  final List<double> showers;

  WeatherData({required this.time, required this.showers});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      time: List<String>.from(json['hourly']['time']),
      showers: List<double>.from(json['hourly']['showers']),
    );
  }
}
