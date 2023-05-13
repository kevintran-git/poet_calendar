import 'package:flutter/material.dart';
import 'package:poet_calendar/auth.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:poet_calendar/clock.dart';
import 'package:poet_calendar/weather.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Demo',
      darkTheme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'Calendar Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Modify the _MyHomePageState class to use the AuthManager class instead of directly using the GoogleSignIn object
class _MyHomePageState extends State<MyHomePage> {
  // A list of events to display on the screen
  List<calendar.Event> _events = [];

  // A method to fetch the user's calendar events
  void _fetchEvents() async {
    // Get an authenticated HTTP client from the AuthManager singleton
    var httpClient = await AuthManager().authenticatedClient;

    // Create a CalendarApi client which can be used to fetch calendar events
    var calendarApi = calendar.CalendarApi(httpClient);

    var calEvents = await calendarApi.events.list('primary', maxResults: 10);
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _events without calling setState(), the the build method would not be
      // called again, and so nothing would appear to happen.

      _events = calEvents.items!; // Store the events in the _events list

      // print data from getWeatherData(). It returns Future<List<Observation>> getWeatherData()
    });
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _fetchEvents method above.

    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    bool isLoggedIn = AuthManager().currentUser != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ), // display the clock on the top left corner
      body: // clock on the top left corner
           const Stack(
        children: [
          Positioned(
            top: 30,
            left: 30,
            child: ClockWidget(size: 1.3),
          ),
          // right button that calls a method
          Positioned(
            top: 30,
            right: 30,
            child: WeatherWidget(),//WeatherWidget(city: "Stanford, US", apiKey: "2486eb6a56d9df5491125265cb03659e"),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: // display the calendar events on the screen
          //       ListView.builder(
          //     itemCount: _events.length,
          //     itemBuilder: (context, index) {
          //       var event = _events[index];
          //       return Card(
          //         child: ListTile(
          //           title: Text(event.summary ?? ''),
          //           subtitle: Text(event.description ?? ''),
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isLoggedIn) {
            await AuthManager().signOut();
            setState(() {
              _events = [];
            });
          } else {
            await AuthManager().signIn();
            _fetchEvents();
          }
        },
        tooltip: isLoggedIn ? 'Sign Out' : 'Sign In',
        child: Icon(isLoggedIn ? Icons.logout : Icons.login),
      ),
    );
  }
}
