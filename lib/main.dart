import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:traveller/screens/browse_trips_screen.dart';
import 'package:traveller/screens/home_screen.dart';
import 'package:traveller/screens/login_screen.dart';
import 'package:traveller/screens/my_trips_screen.dart';
import 'package:traveller/screens/profile_screen.dart';
import 'package:traveller/screens/register_screen.dart';
import 'package:traveller/screens/share_location_screen.dart';
import 'package:traveller/screens/trip_details_screen.dart';
import 'package:traveller/services/auth.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Role-Based Auth App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        // Traveler routes
        '/my-trips': (context) => MyTripsScreen(),
        '/browse-trips': (context) => BrowseTripsScreen(),
        '/share-location': (context) => ShareLocationScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == '/trip-details') {
          final tripId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => TripDetailsScreen(tripId: tripId),
          );
        }
        return null;
      },
    );
  }
}