import 'package:get/get.dart';
import 'package:traveller/features/auth/screens/login_screen.dart';
import 'package:traveller/features/auth/services/auth.dart';
import 'screens/browse_trips_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/profile_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'screens/share_location_screen.dart';
import 'screens/trip_details_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String myTrips = '/my-trips';
  static const String browseTrips = '/browse-trips';
  static const String tripDetails = '/trip-details';
  static const String shareLocation = '/share-location';

  static final pages = [
    GetPage(name: initial, page: () => const AuthWrapper()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: myTrips, page: () => const MyTripsScreen()),
    GetPage(name: browseTrips, page: () => const BrowseTripsScreen()),
    GetPage(
      name: tripDetails,
      page: () {
        final args = Get.arguments as String; // tripId
        return TripDetailsScreen(tripId: args);
      },
    ),
    GetPage(name: shareLocation, page: () => const ShareLocationScreen()),
  ];
}
