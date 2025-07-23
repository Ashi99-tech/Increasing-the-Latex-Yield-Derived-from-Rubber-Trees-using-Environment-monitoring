// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, non_constant_identifier_names, unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rubber_lk/Components/myprovider.dart';
import 'package:rubber_lk/user_profile.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';

class WeatherDashboardScreen extends StatefulWidget {
  const WeatherDashboardScreen({Key? key}) : super(key: key);

  @override
  _WeatherDashboardScreenState createState() => _WeatherDashboardScreenState();
}

class _WeatherDashboardScreenState extends State<WeatherDashboardScreen> {
  WeatherFactory wf = WeatherFactory(
    "6d6fde202290e617a90a412bc2287335",
  ); // Replace with your API key
  Weather? w;
  Position? position;

  final TextEditingController location = TextEditingController(text: 'Colombo');

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> getWeatherByCurrentLocation() async {
    try {
      position = await _getCurrentLocation();
      if (position != null) {
        w = await wf.currentWeatherByLocation(
          position!.latitude,
          position!.longitude,
        );
        location.text = w?.areaName ?? 'Unknown Location';
        setState(() {});
      }
    } catch (e) {
      print('Error getting weather: $e');
    }
  }

  String get locationImage {
    if (position == null) {
      return '';
    }
    final lat = position!.latitude;
    final lng = position!.longitude;
    return "https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=17&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyAcKZHMOpRIqKUPAAP1U-n8Vp6nEtg7pcs";
  }

  @override
  void initState() {
    super.initState();
    getWeatherByCurrentLocation(); // Start with current location
  }

  Future<void> getWeather(String location) async {
    try {
      w = await wf.currentWeatherByCityName(location);
    } catch (e) {
      print('Invalid Location');
    }
    setState(() {}); // Update the state to trigger a rebuild
  }

  @override
  Widget build(BuildContext context) {
    return w !=
            null // Check if w is initialized before building the UI
        ? Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Userprofile(),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1518333648466-e7e0bb965e70?w=1280&h=720',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            foregroundColor: Colors.white,
            title: const Text(
              'Weather Dashboard',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: location,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 18,
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0),
                    ),
                    hintText: 'Search',
                    suffixIcon: IconButton(
                      onPressed: () {
                        getWeather(location.text);
                        Provider.of<MyProvider>(
                          context,
                          listen: false,
                        ).updateVariable(location.text);
                      },
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(locationImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: 150,
                  width: 250,
                ),
                const SizedBox(height: 20),
                CurrentDayWeatherCard(
                  temperature:
                      w?.temperature?.celsius?.toStringAsFixed(0) ?? '',
                  condition: w?.weatherDescription ?? '',
                  icon: _getWeatherIcon(w?.weatherMain ?? ''),
                  icolor: _getWeatherColor(w?.weatherMain ?? ''),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OtherDetailsCard(
                      title: 'Humidity',
                      value: '${w?.humidity?.toString()}%' ?? '',
                      icon: Icons.water_damage,
                      icolor: Colors.blueAccent,
                    ),
                    OtherDetailsCard(
                      title: 'Pressure',
                      value: '${w?.pressure?.toStringAsFixed(0)}hPa' ?? '',
                      icon: Icons.compress,
                      icolor: Colors.amber,
                    ),
                    OtherDetailsCard(
                      title: 'Wind',
                      value: '${w?.windSpeed?.toString()} km/h' ?? '',
                      icon: Icons.wind_power,
                      icolor: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                WeatherWeekDetails(location: location.text),
              ],
            ),
          ),
        )
        : const Scaffold(
          body: Center(
            child:
                CircularProgressIndicator(), // Show loading indicator while fetching weather data
          ),
        );
  }
}

class CurrentLocationCard extends StatelessWidget {
  final String location;
  const CurrentLocationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return _buildCardLocation(
      content: Text(location, style: const TextStyle(fontSize: 18)),
      icon: Icons.location_on,
      icolor: Colors.red,
    );
  }
}

class CurrentDayWeatherCard extends StatelessWidget {
  final String temperature;
  final String condition;
  final IconData icon;
  final Color icolor;

  const CurrentDayWeatherCard({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.icolor,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCardCurrent(
      content: Column(
        children: [
          const Text(
            'Today\'s Weather',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Temperature: $temperature',
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          Text(
            'Condition: $condition',
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
      icon: icon,
      icolor: icolor,
    );
  }
}

IconData _getWeatherIcon(String condition) {
  switch (condition) {
    case 'Thunderstorm':
      return Icons.flash_on;
    case 'Drizzle':
      return Icons.grain;
    case 'Rain':
      return Icons.beach_access;
    case 'Snow':
      return Icons.ac_unit;
    case 'Mist':
      return Icons.cloud_circle;
    case 'Smoke':
      return Icons.smoke_free;
    case 'Haze':
      return Icons.cloud;
    case 'Dust':
      return Icons.cloud;
    case 'Fog':
      return Icons.cloud;
    case 'Sand':
      return Icons.cloud;
    case 'Ash':
      return Icons.cloud;
    case 'Squall':
      return Icons.flash_on;
    case 'Tornado':
      return Icons.tornado;
    case 'Clear':
      return Icons.wb_sunny;
    case 'Clouds':
      return Icons.cloud;
    default:
      return Icons.cloud;
  }
}

String _getDate(int Day) {
  if (Day == 1) {
    return 'Monday';
  } else if (Day == 2) {
    return 'Tuesday';
  } else if (Day == 3) {
    return 'Wednesday';
  } else if (Day == 4) {
    return 'Thursday';
  } else if (Day == 5) {
    return 'Friday';
  } else if (Day == 6) {
    return 'Saturday';
  } else {
    return 'Sunday';
  }
}

Color _getWeatherColor(String condition) {
  switch (condition) {
    case 'Thunderstorm':
      return Colors.amber;
    case 'Drizzle':
      return Colors.blue;
    case 'Rain':
      return Colors.blue;
    case 'Snow':
      return Colors.blue;
    case 'Mist':
      return const Color.fromARGB(96, 113, 113, 113);
    case 'Smoke':
      return const Color.fromARGB(96, 113, 113, 113);
    case 'Haze':
      return const Color.fromARGB(96, 81, 81, 81);
    case 'Dust':
      return const Color.fromARGB(96, 113, 113, 113);
    case 'Fog':
      return const Color.fromARGB(96, 113, 113, 113);
    case 'Sand':
      return const Color.fromARGB(96, 113, 113, 113);
    case 'Ash':
      return const Color.fromARGB(96, 113, 113, 113);
    case 'Squall':
      return Colors.amber;
    case 'Tornado':
      return Colors.black;
    case 'Clear':
      return Colors.orange;
    case 'Clouds':
      return const Color.fromARGB(96, 113, 113, 113);
    default:
      return const Color.fromARGB(96, 113, 113, 113);
  }
}

class OtherDetailsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color icolor;

  const OtherDetailsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.icolor,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      content: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      icon: icon,
      icolor: icolor,
    );
  }
}

class WeatherWeekDetails extends StatefulWidget {
  final String location;
  const WeatherWeekDetails({super.key, required this.location});

  @override
  _WeatherWeekDetailsState createState() => _WeatherWeekDetailsState();
}

class _WeatherWeekDetailsState extends State<WeatherWeekDetails> {
  WeatherFactory wf = WeatherFactory(
    "6d6fde202290e617a90a412bc2287335",
  ); // Replace with your API key
  List<Weather> weeklyWeather = [];

  @override
  void initState() {
    super.initState();
    getWeeklyWeather();
  }

  Future<void> getWeeklyWeather() async {
    // Fetch weather data for the upcoming week using fiveDayForecastByCityName
    List<Weather> forecast = await wf.fiveDayForecastByCityName(
      widget.location,
    );

    // Select one weather data per day
    List<Weather> filteredForecast = [];
    DateTime currentDate = DateTime.now();
    for (Weather weather in forecast) {
      if (weather.date!.day != currentDate.day) {
        filteredForecast.add(weather);
        currentDate = weather.date!;
      }
    }

    weeklyWeather = filteredForecast;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Weekly Weather Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: weeklyWeather.map(_buildWeatherDetailCard).toList(),
        ),
      ],
    );
  }

  Widget _buildWeatherDetailCard(Weather dayWeather) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: dayWeatherCardContent(dayWeather),
      ),
    );
  }

  Widget dayWeatherCardContent(Weather dayWeather) {
    return Row(
      children: [
        Icon(
          _getWeatherIcon(dayWeather.weatherMain!),
          size: 36,
          color: _getWeatherColor(dayWeather.weatherMain!),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ListTile(
            title: Text(
              _getDate(dayWeather.date!.weekday),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ), // Display weekday
            subtitle: Text(
              '${dayWeather.temperature?.celsius?.toStringAsFixed(0) ?? ''}°C - ${dayWeather.weatherDescription}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildCard({
  Color? backgroundColor,
  required Widget content,
  required IconData icon,
  required Color icolor,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    color: Colors.white.withOpacity(0.2),

    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(icon, size: 36, color: icolor),
          const SizedBox(height: 10),
          content,
        ],
      ),
    ),
  );
}

Widget _buildCardLocation({
  Color? backgroundColor,
  required Widget content,
  required IconData icon,
  required Color icolor,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    color: backgroundColor,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: const DecorationImage(
          image: AssetImage("assets/images/map.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 36, color: icolor),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    ),
  );
}

Widget _buildCardCurrent({
  Color? backgroundColor,
  required Widget content,
  required IconData icon,
  required Color icolor,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    color: Colors.black,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: const DecorationImage(
          image: AssetImage("assets/images/wether.jpg"),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 36, color: icolor),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    ),
  );
}
