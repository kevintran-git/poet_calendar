import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poet_calendar/timesignalnotifier.dart';
import 'package:weather/weather.dart';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

import 'env/env.dart';

class WeatherWidget extends ConsumerWidget {
  WeatherWidget({Key? key}) : super(key: key);
  final WeatherFactory wf =
      WeatherFactory(Env.weatherApiKey); // The weather factory

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(clockProvider.select((clock) => clock.minute)); // fetch the weather every minute

    return FutureBuilder<Weather>(
      future: wf.currentWeatherByCityName("Stanford, US"),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(8),
            child: Column (
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
                      '${snapshot.data?.temperature?.fahrenheit?.toStringAsFixed(1)}°F',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  snapshot.data?.weatherDescription ?? "clear",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
