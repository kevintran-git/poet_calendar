import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A widget that displays a clock with the current time.
class ClockWidget extends StatefulWidget {
  final double size; // A parameter to adjust the size of the clock

  const ClockWidget({Key? key, this.size = 1.0}) : super(key: key);

  @override
  ClockWidgetState createState() => ClockWidgetState();
}

class ClockWidgetState extends State<ClockWidget> {
  late String _timeString; // A string to store the formatted time
  late String _ampmString; // A string to store the AM/PM indicator

  @override
  void initState() {
    super.initState();
    _updateTimeStrings(DateTime
        .now()); // Initialize the time and AM/PM strings with the current time
    Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) =>
            _getTime()); // Create a timer that updates the time every second
  }

  // A method that gets the current time and updates the state
  void _getTime() {
    final DateTime now = DateTime.now(); // Get the current date and time
    _updateTimeStrings(
        now); // Update the time and AM/PM strings with the new values
    setState(() {}); // Update the state to trigger a rebuild
  }

  // A method that updates the time and AM/PM strings with a given date and time
  void _updateTimeStrings(DateTime dateTime) {
    _timeString = DateFormat('hh:mm')
        .format(dateTime); // Format the hours and minutes as a string
    _ampmString = DateFormat('a')
        .format(dateTime); // Format the AM/PM indicator as a string
  }

  @override
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      // Use a fitted box widget to make the container fit the size of the clock
      child: Container(
        // Surround the clock with a container widget
        padding: EdgeInsets.all(
            8 * widget.size), // Add some padding around the clock
        // decoration: BoxDecoration(
        //   // Add some decoration to the container
        //   border: Border.all(
        //       width:
        //           2 * widget.size), // Add a black border with adjustable width
        //   borderRadius: BorderRadius.circular(
        //       16 * widget.size), // Add some rounded corners to the container
        // ),
        child: Row(
          // Use a row widget to display the time horizontally
          mainAxisAlignment: MainAxisAlignment.center, // Center the row widget
          children: [
            Text(
              _timeString, // Display the hours and minutes as a text widget
              style: TextStyle(
                fontSize: 48 *
                    widget
                        .size, // Adjust the font size according to the size parameter
                fontWeight: FontWeight.bold,
              ),
            ),

            // Add a sized box to separate the hours and minutes from the seconds and AM/PM indicator
            SizedBox(
              width: 8 * widget.size,
            ),

            Column(
              // Use a column widget to display the seconds and AM/PM indicator vertically
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the column widget
              children: [
                Text(
                  _ampmString, // Display the AM/PM indicator as a text widget
                  style: TextStyle(
                    fontSize: 17 *
                        widget
                            .size, // Adjust the font size according to the size parameter
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('ss').format(
                      DateTime.now()), // Display the seconds as a text widget
                  style: TextStyle(
                    fontSize: 20 *
                        widget
                            .size, // Adjust the font size according to the size parameter
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
