import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ClockNotifier sends the current time to any listeners every second
class ClockNotifier extends StateNotifier<DateTime> {
  // creates a timer that updates the state every second
  late final Timer _timer; 

  ClockNotifier() : super(DateTime.now()) {
    _timer = Timer.periodic(
      // every second, update the state with the current time
        const Duration(seconds: 1), (_) => state = DateTime.now());
  }
  
  // cancel the timer when the notifier is disposed
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

// creates a provider 
final clockProvider = StateNotifierProvider<ClockNotifier, DateTime>((ref) {
  return ClockNotifier();
});
