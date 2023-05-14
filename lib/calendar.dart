import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:poet_calendar/auth.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class CalendarWidget extends StatefulWidget {

  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
   // A list of events to display on the screen
  // List<calendar.Event> _events = [];
  String poem = "Loading...";

  // A method to fetch the user's calendar events
  void _fetchEvents() async {
    // Get an authenticated HTTP client from the AuthManager singleton
    var httpClient = await AuthManager().authenticatedClient;

    // Create a CalendarApi client which can be used to fetch calendar events
    var calendarApi = calendar.CalendarApi(httpClient);

    var calEvents = await calendarApi.events.list('primary', maxResults: 10);
    var events = calEvents.items!;
    var eventsText = events.map((e) =>
    e.summary
    ).join("\n");

    var prompt = "create a poem from my calendar events: $eventsText";
    print(prompt);

    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: prompt,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );

    print(chatCompletion.choices.first.message.content);


    setState(() {
      poem = chatCompletion.choices.first.message.content;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          poem,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: _fetchEvents,
          child: const Text("Fetch events"),
        ),
      ],
    );
  }
}

