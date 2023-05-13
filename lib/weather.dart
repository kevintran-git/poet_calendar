import 'package:weather/weather.dart';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

import 'env/env.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  WeatherWidgetState createState() => WeatherWidgetState();
}

class WeatherWidgetState extends State<WeatherWidget> {
  Weather? weather; // The current weather
  WeatherFactory wf = WeatherFactory(Env.weatherApiKey); // The weather factory

  @override
  void initState() {
    super.initState();
    fetchWeather(); // Fetch the weather when the widget is initialized
  }

  // A function to fetch the weather for a given location
  void fetchWeather() async {
    Weather w = await wf.currentWeatherByCityName("Stanford, US"); // Get the current weather by city name
    setState(() {
      weather = w; // Update the state with the new weather
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BoxedIcon(
              // display an icon based on the weather condition code
              WeatherIcons.day_sunny,
              size: 40,
            ),
            const SizedBox(width: 16),
            Text(
              '${weather?.temperature?.fahrenheit?.toStringAsFixed(1)}°F', // display the temperature in celsius
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          weather?.weatherDescription ?? "No weather description", // display the weather description if available
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
