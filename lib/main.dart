import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/firebase_options.dart';
import 'package:flutter_application/router.dart';
import 'services/position_firestore.dart';

// This is the entry point of the Flutter application.
// The main function is where the app starts running.
void main() async {
  // This line ensures that Flutter is properly initialized before doing anything else.
  // It's important for apps that need to do setup work before the UI loads.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the options for the current platform (Android, iOS, etc.).
  // Firebase is a backend service that helps with things like authentication and databases.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final positionFirestore = PositionFirestore();
    final positions = await positionFirestore.getAllPositions();
    if (positions.isEmpty) {
      await positionFirestore.seedDefaultPositions();
    }
  } catch (e) {
    // Firebase not configured for this platform (e.g., Windows)
    // Continue without Firebase for development
    // print('Firebase not available: $e'); // Commented out for production
  }
  // Run the app by creating an instance of MyApp.
  runApp(const MyApp());
}

// MyApp is the root widget of the application.
// It sets up the overall structure of the app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Build the MaterialApp with a router configuration.
    // MaterialApp provides the basic Material Design theme and navigation.
    // routerConfig uses the router we defined in router.dart for handling page navigation.
    return MaterialApp.router(
      // Hide the debug banner that appears in debug mode.
      debugShowCheckedModeBanner: false,
      // Set up the router for navigating between screens.
      routerConfig: createRouter(),
    );
  }
}
