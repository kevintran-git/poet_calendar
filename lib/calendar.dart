import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:poet_calendar/auth.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  String poem = "Loading...";

  @override
  void initState() {
    super.initState();
    // Call updatePoem here
    _updatePoem();
  }

  // A method to fetch the user's calendar events
  Future<String?> _fetchEvents(Client authenticatedClient) async {
// Create a CalendarApi client which can be used to fetch calendar events
    var calendarApi = calendar.CalendarApi(authenticatedClient);

// Get a list of calendars
    var calList = await calendarApi.calendarList.list();

// Get the start and end of today in UTC
    var now = DateTime.now();
    var startOfDay = DateTime.utc(now.year, now.month, now.day);
    var endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));
    List<calendar.Event> allEvents = [];

// Iterate over the calendars
    for (var cal in calList.items!) {
      // Get the calendar id
      var calId = cal.id!;
      // Get the events for this calendar that occur today
      var calEvents = await calendarApi.events
          .list(calId, timeMin: startOfDay, timeMax: endOfDay);

      allEvents.addAll(calEvents.items as Iterable<calendar.Event>);
    }

    // event in allEvents

    var events = allEvents.map((e) => {e.summary}).join("\n");

    return events;
  }

  Future<String> _generatePoem(String? events) async {
    var prompt = "create a poem from my calendar events: $events";

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: prompt,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );

    return chatCompletion.choices.first.message.content;
  }

  void _updatePoem() async {
    var authenticatedClient = await AuthManager().authenticatedClient;
    var events = await _fetchEvents(authenticatedClient);
    // var generatedPoem = await _generatePoem(events);
    setState(() {
      poem = events ?? "no events :(";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      poem,
      style: Theme.of(context).textTheme.displaySmall,
    );
  }
}
