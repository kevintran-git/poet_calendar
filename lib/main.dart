import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poet_calendar/auth_wrapper.dart';
import 'package:poet_calendar/calendar.dart';
import 'package:poet_calendar/clock.dart';
import 'package:poet_calendar/env/env.dart';
import 'package:poet_calendar/weather.dart';
import 'package:flutter/services.dart'; // For `SystemChrome`
import 'package:wakelock/wakelock.dart';


void main() {
  OpenAI.apiKey = Env.openAiKey;
  runApp(
    const ProviderScope(child: 
    MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []); // Hide status bar
    Wakelock.enable(); // Prevent screen from sleeping
    return MaterialApp(
      title: 'Jason\'s Magic Calendar',
      darkTheme: ThemeData(
        // This is the theme of your application.
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // basic layout widget that provides app structure
      body: SafeArea(
        // avoids status bar, notch
        child: Column(
          // arranges a list of widgets vertically
          children: [
            Row(
              // arrange a list of widgets horizontally
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // controls how children are aligned along the main axis
              children: [
                const ClockWidget(),
                WeatherWidget(),
              ],
            ),
            const Expanded(
              child: AuthWrapper(
                  child: // helper class that displays different widgets depending on auth status
                      FittedBox(
                fit: BoxFit.scaleDown, // scales text to fit in the available space
                child: PoemWidget(),
              )), // your poem widget
            ),
          ],
        ),
      ),
    );
  }
}
