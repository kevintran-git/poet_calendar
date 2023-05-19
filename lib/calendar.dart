import 'package:cron/cron.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:poet_calendar/auth.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class PoemWidget extends StatefulWidget {
  const PoemWidget({Key? key}) : super(key: key);

  @override
  State<PoemWidget> createState() => PoemWidgetState();
}

class PoemWidgetState extends State<PoemWidget> {
  String poem = "Loading...";

  @override
  void initState() {
    super.initState();
    // Call updatePoem here
    _updatePoem();

    final cron = Cron();
    cron.schedule(Schedule(days: 1), () {
      _updatePoem();
    });
  }

  // A method to fetch the user's calendar events
  Future<String?> _fetchEvents(CalendarApi calendarApi) async {
// Get a list of calendars
    var calList = await calendarApi.calendarList.list();
// Get the start and end of today in UTC
    var now = DateTime.now();
    var startOfDay = DateTime(now.year, now.month, now.day);
    var endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));
    List<calendar.Event> allEvents = [];

// Iterate over the calendars
    for (var cal in calList.items!) {
      // Get the calendar id
      var calId = cal.id!;

      // Get the events for this calendar that occur today
      var calEvents = await calendarApi.events.list(calId,
          timeMin: startOfDay,
          timeMax: endOfDay,
          timeZone: 'America/Los_Angeles');

      allEvents.addAll(calEvents.items as Iterable<calendar.Event>);
    }

    // event in allEvents

    var events = allEvents.map((e) => {e.summary}).join("\n");

    if (kDebugMode) {
      print(events);
    }

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
    var calendarApi = calendar.CalendarApi(authenticatedClient);
    var events = await _fetchEvents(calendarApi);
    var generatedPoem = await _generatePoem(events);
    setState(() {
      poem = generatedPoem;
      if (kDebugMode) {
        print(poem);
      }
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
