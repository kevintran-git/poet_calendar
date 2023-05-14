import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'env/env.dart';

// Create a new class called AuthManager that handles the authentication logic
class AuthManager {
  // Make this class a singleton so that only one instance exists
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  // Declare a GoogleSignIn object with the same scopes and client ID as before
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      calendar.CalendarApi.calendarReadonlyScope,
    ],
    clientId: Env.googleClientId,
  );


  Stream<GoogleSignInAccount?> get onAuthStateChanged => _googleSignIn.onCurrentUserChanged;

  Future get authenticatedClient async {
    return (await _googleSignIn.authenticatedClient())!;
  }

  // Declare a method to sign in to Google
  Future<void> signIn() async {
    await _googleSignIn.signIn();
  }

  // Declare a method to sign out of Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  // Declare a getter for the current user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}