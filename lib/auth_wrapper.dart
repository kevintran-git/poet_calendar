import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poet_calendar/auth.dart';

class AuthWrapper extends StatelessWidget {
  // The widget that requires authentication
  final Widget child;

  const AuthWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Listen to the user stream from the auth class
    return StreamBuilder<GoogleSignInAccount?>(
      stream: AuthManager().onAuthStateChanged,
      builder: (context, snapshot) {
        // If the user is not null, pass it to the child widget
        if (snapshot.hasData && snapshot.data != null) {
          return child;
        }
        // Otherwise, show a sign in button
        else {
          return Center(
            child: ElevatedButton(
              onPressed: () => AuthManager().signIn(),
              child: const Text('Sign in with Google'),
            ),
          );
        }
      },
    );
  }
}
