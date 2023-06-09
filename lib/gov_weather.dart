import "package:http/http.dart" as http;
import "dart:convert" as convert;

// This module implements a simple NWS weather REST client. More info here:
// https://www.weather.gov/documentation/services-web-api

// Holds a single observation returned from the NWS API. This could be
// expanded to hold more data later, but for now we're only interested
// in barometric pressure in Pa and the weather description.
class Observation {
  // The timestamp of the observation.
  final DateTime timestamp;

  // The temperature in Fahrenheit.
  final double temperature;

  // The human-readable description of conditions (e.g. "Overcast").
  final String description;

  // The icon
  final String icon;

  const Observation({ required this.timestamp, required this.temperature, required this.description, required this.icon });

  // Formats an observation for text display in the app.
  String format() {
    final now = DateTime.now();
    final diffHours = now.difference(timestamp).inHours;
    return "$diffHours hours ago - $temperature kPa - $description";
  }

  // toString() is a special method that is called when an object is
  // converted to a string. This is useful for debugging.
  @override
  String toString() {
    return "Observation(timestamp=$timestamp, temperature=$temperature, description=$description)";
  }
}

final _headers = {
  // Ask for data in a JSON form.
  "Accept": "application/geo+json",

  // The NWS requests this header as a condition of using their APIs.
  "User-Agent": "Jason's Mirror",
};

/*
  The relevant part of the JSON that this returns is in this structure:

  {
    "observationStations": [
      "url",
      "url",
      ...
    ]
  }

  Observation stations seem to be sorted by distance from the specified point.

  We'll just grab the first one. It's possible that the list may be empty for
  a given GPS coordinate (or even a bad GPS coordinate), but for the sake of
  simplicity in this learning app, we'll just assume there's at least one.
 */
// Future<String> _getStationUrl() async {
//   const latitude = "37.4275";
//   const longitude = "-122.1697";
//   final response = await http.get(// uri
//       Uri.parse("https://api.weather.gov/points/$latitude%2C$longitude/stations"),
//       headers: _headers
//   );

//   if (response.statusCode == 200) {
//     final json = convert.jsonDecode(response.body);
//     return json["observationStations"][0];
//   } else {
//     return "Error: ${response.statusCode}";
//   }
// }

/*
  The relevant part of the JSON that this returns is in this structure:

  {
    "features": [
      {
        "properties": {
          "timestamp": "<timestamp in ISO 8601>",
          "textDescription": "Overcast With a Chance of Brimstone",
          "barometricPressure": {
            "value": 12345,
            "unitCode": "unit:Pa"
          }
        }
      }
    ]
  }

  There is a lot more there, but we're not taking it for this simple app.
 */
Future<List<Observation>?> _getPressureHistoryByStationUrl(String stationUrl) async {
  // In practice, the resolution of data we will get back is one hour. So we have to
  // request a few hours in order to get much of anything.
  // final now = DateTime.now();
  //final requestLimit = now.subtract(const Duration(hours: 4));

  // NWS doesn't allow us to pass milliseconds, but Dart's date formatting
  // puts it on there. So just chop it off and re-add the Z.
  // final requestLimitString = "${requestLimit
  //     .toUtc()
  //     .toIso8601String()
  //     .substring(0, 19)}Z";

  final response = await http.get(
      Uri.parse("$stationUrl/observations"), //?start=$requestLimitString"),
      headers: _headers
  );

  // 200 is HTTP OK, or success.
  if (response.statusCode == 200) {
    final json = convert.jsonDecode(response.body);
    final features = json["features"];

    // Ideally, we would check properties["barometricPressure"]["unitCode"] to
    // verify that it's "unit:Pa", but since this is a simple learning app,
    // I'm skipping that check here.
    final convertedFeatures = features.map<Observation>((feature) {
      //final properties = feature["properties"];
      
    }).toList();

    // This sorts in descending date/time so that the newest observations are first.
    convertedFeatures.sort(
            (Observation obs1, Observation obs2) => obs2.timestamp.difference(obs1.timestamp).inSeconds
    );

    return convertedFeatures;
  } else {
    // Leave these for debugging by the developer. Ideally this would be
    // turned into diagnostics for the user, but for this simple app, I'm
    // leaving it this way.
    // print(response.statusCode);
    // print(response.body);
    return null;
  }
}


Future<List<Observation>> getWeatherData() async {
  //final url = await _getStationUrl();
  return await _getPressureHistoryByStationUrl("https://api.weather.gov/stations/KSFO") ?? [];
}