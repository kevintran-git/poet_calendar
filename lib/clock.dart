import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poet_calendar/timesignalnotifier.dart';

/// A widget that displays a clock with the current time.
class ClockWidget extends ConsumerWidget {
  final double size; // A parameter to adjust the size of the clock

  const ClockWidget({Key? key, this.size = 1.0}) : super(key: key);
  
@override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime dateTime = ref.watch(clockProvider);

    var timeString = DateFormat('hh:mm')
        .format(dateTime); // Format the hours and minutes as a string
    var ampmString = DateFormat('a')
        .format(dateTime); // Format the AM/PM indicator as a string

    return FittedBox(
      // Use a fitted box widget to make the container fit the size of the clock
      child: Container(
        // Surround the clock with a container widget
        padding: EdgeInsets.all(
            8 * size), // Add some padding around the clock
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
              timeString, // Display the hours and minutes as a text widget
              style: TextStyle(
                fontSize: 48 * size, // Adjust the font size according to the size parameter
                fontWeight: FontWeight.bold,
              ),
            ),

            // Add a sized box to separate the hours and minutes from the seconds and AM/PM indicator
            SizedBox(
              width: 8 * size,
            ),

            Column(
              // Use a column widget to display the seconds and AM/PM indicator vertically
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the column widget
              children: [
                Text(
                  ampmString, // Display the AM/PM indicator as a text widget
                  style: TextStyle(
                    fontSize: 17 * size, // Adjust the font size according to the size parameter
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('ss').format(
                      DateTime.now()), // Display the seconds as a text widget
                  style: TextStyle(
                    fontSize: 20 * size, // Adjust the font size according to the size parameter
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


