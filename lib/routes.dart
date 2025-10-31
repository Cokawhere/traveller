import 'package:get/get.dart';
import 'package:traveller/features/auth/screens/login_screen.dart';
import 'package:traveller/features/auth/services/auth.dart';
import 'package:traveller/features/edit_trip/edit_trip_screen.dart';
import 'package:traveller/features/home/services/home_binding.dart';
import 'package:traveller/features/trip_details_traveler/traveler_trip_details_screen.dart';
import 'features/creat_trip/create_trip_screen.dart';
import 'features/home/screens/home_screenn.dart';
import 'features/my_trip/my_trips_screen.dart';
import 'screens/browse_trips_screen.dart';
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
  static const String createTrip = '/create-trip';
  static const String editTrip = '/editTrip';

  static final pages = [
    GetPage(name: initial, page: () => const AuthWrapper()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(
      name: home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: myTrips, page: () => MyTripsScreen()),
    GetPage(name: browseTrips, page: () => const BrowseTripsScreen()),
    GetPage(name: createTrip, page: () => CreateTripScreen()),
    GetPage(name: editTrip, page: () => EditTripScreen()),
    GetPage(
      name: tripDetails,
      page: () => TravelerTripDetailsScreen(),
    ),
    GetPage(name: shareLocation, page: () => const ShareLocationScreen()),
  ];
}
