import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:poet_calendar/auth.dart';
import 'package:poet_calendar/auth_wrapper.dart';
import 'package:poet_calendar/calendar.dart';
import 'package:poet_calendar/clock.dart';
import 'package:poet_calendar/env/env.dart';
import 'package:poet_calendar/weather.dart';


void main() {
  OpenAI.apiKey = Env.openAiKey;
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
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.black,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: Colors.black,
          onBackground: Colors.white,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
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
          // display the calendar events on the center of the  screen
          Center(
            child: AuthWrapper(child: CalendarWidget()),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isLoggedIn) {
            await AuthManager().signOut();
          } else {
            await AuthManager().signIn();
          }
        },
        tooltip: isLoggedIn ? 'Sign Out' : 'Sign In',
        child: Icon(isLoggedIn ? Icons.logout : Icons.login),
      ),
    );
  }
}
