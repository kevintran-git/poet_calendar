import 'dart:async';
import 'dart:convert';
import 'package:dart_openai/openai.dart';
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
    startCalendar();
  }

  void startCalendar() async {
    var authenticatedClient = await AuthManager().authenticatedClient;
    var calendarApi = calendar.CalendarApi(authenticatedClient);
    var calendarIds = await _fetchCalendars(calendarApi);
    // Call updatePoem here
    _updatePoem(calendarApi, calendarIds);

    Timer.periodic(const Duration(days: 1), (timer) {
      _updatePoem(calendarApi, calendarIds);
    });
  }

  Future<List<String>> _fetchCalendars(CalendarApi calendarApi) async {
    // Get a list of all the users' calendars
    var calList = await calendarApi.calendarList.list();
    List<String> calendarIds = [];

    // ignore: use_build_context_synchronously
    List<bool>? checkedList = await showDialog<List<bool>>(
      context: context,
      builder: (BuildContext context) {
        return CalendarPopup(calList: calList.items ?? []);
      },
    );

    if (checkedList != null) {
      for (int i = 0; i < checkedList.length; i++) {
        if (checkedList[i]) {
          var calId = calList.items?[i].id;
          if (calId == null) continue;
          calendarIds.add(calId);
        }
      }
    }
    return calendarIds;
  }

  // A method to fetch the user's calendar events
  Future<String> _fetchEvents(CalendarApi calendarApi, List<String> calendarIds) async {
    // Get the start and end of today in UTC
    var now = DateTime.now();
    var startOfDay = DateTime(now.year, now.month, now.day);
    var endOfDay = startOfDay
        .add(const Duration(days: 7))
        .subtract(const Duration(seconds: 1));
    List<calendar.Event> allEvents = [];

    // For each calendar, get the events for today
    for (var calId in calendarIds) {
      var calEvents = await calendarApi.events.list(calId,
          timeMin: startOfDay,
          timeMax: endOfDay,
          timeZone: 'America/Los_Angeles');

      for(Event event in calEvents.items as Iterable<calendar.Event>) {
          if (event.recurrence != null && event.recurrence!.isNotEmpty){
            var instances = await calendarApi.events.instances(calId, event.id.toString(),
                timeMin: startOfDay,
                timeMax: endOfDay,
                timeZone: 'America/Los_Angeles');
                allEvents.addAll(instances.items as Iterable<calendar.Event>);
          } else {
            allEvents.add(event);
          }
        }
      }

    // filter out events that have a null or empty start or end time
    var events = allEvents.where((e) => e.start?.dateTime != null && e.end?.dateTime != null)
    .map((e) => {eventToJson(e)})
    .join("\n");

    // ignore: avoid_print
    print(events);
    return events;
  }

  Future<String> _generatePoem(String events) async {
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

  void _updatePoem(CalendarApi calendarApi, List<String> calendarIds) async {
    var events = await _fetchEvents(calendarApi, calendarIds);
    var generatedPoem = await _generatePoem(events);
    setState(() {
      poem = generatedPoem;
      // ignore: avoid_print
      print(poem);
    });
  }

  // This code block defines a function named eventToJson that takes an Event object as input and returns a JSON-encoded string.
  // The function first creates an empty list of maps named attendees.
  // It then iterates over the attendees list of the input event object and adds a map containing the attendee's name and email to the attendees list.
  // Finally, the function creates a map named body containing the event's summary, start and end times, location, and attendees list.
  // The body map is then encoded to a JSON string and returned.

  String eventToJson(Event event) {
    List<Map<String, dynamic>> attendees = [];

    event.attendees?.forEach((attendee) {
      attendees.add({
        'name': attendee.displayName,
        'email': attendee.email,
        // 'is_friend': false,
        // 'importance': 'high',
      });
    });

    Map<String, dynamic> body = {
      'title': event.summary,
      'start': event.start?.dateTime?.toString(),
      'end': event.end?.dateTime?.toString(),
      'location': event.location,
      'attendees': attendees,
    };

    return jsonEncode(body);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      poem,
      style: Theme.of(context).textTheme.displaySmall,
    );
  }
}

class CalendarPopup extends StatefulWidget {
  final List<CalendarListEntry> calList;
  const CalendarPopup({super.key, required this.calList});

  @override
  State<CalendarPopup> createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<CalendarPopup> {
  bool _selectAll = true;
  List<bool> _checkedList = [];

  @override
  void initState() {
    super.initState();
    _checkedList = List<bool>.filled(widget.calList.length, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Calendars'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              child: Text(_selectAll ? 'Deselect All' : 'Select All'),
              onPressed: () {
                setState(() {
                  _selectAll = !_selectAll;
                  _checkedList =
                      List<bool>.filled(widget.calList.length, _selectAll);
                });
              },
            ),
            const Divider(),
            ...List<Widget>.generate(widget.calList.length, (index) {
              return CheckboxListTile(
                title: Text(widget.calList[index].summary ?? "No summary"),
                value: _checkedList[index],
                onChanged: (bool? value) {
                  setState(() {
                    _checkedList[index] = value!;
                  });
                },
              );
            }),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(_checkedList);
          },
        ),
      ],
    );
  }
}
