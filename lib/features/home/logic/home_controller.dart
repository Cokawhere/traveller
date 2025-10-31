// lib/features/home/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:traveller/enums/user_enum.dart';
import 'package:traveller/models/user_model.dart';
import 'package:traveller/routes.dart';
import '../services/home_service.dart';

class HomeController extends GetxController {
  final HomeService _homeService = HomeService();

  // Observable variables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // Load user data
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _homeService.getCurrentUserData();

      if (user == null) {
        // User not logged in, navigate to login
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      currentUser.value = user;
    } catch (e) {
      errorMessage.value = 'Failed to load user data: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _homeService.logout();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navigate to profile
  void navigateToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  // Navigate based on role-specific routes
  void navigateToRoute(String route) {
    try {
      Get.toNamed(route);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Route not found or under development.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get role gradient colors
  List<int> getRoleGradientColors(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [0xFFEF5350, 0xFFE53935]; // Red colors
      case UserRole.traveler:
        return [0xFF42A5F5, 0xFF1E88E5]; // Blue colors
      case UserRole.companier:
        return [0xFF26A69A, 0xFF00897B]; // Teal colors
    }
  }

  // Get role icon code
  int getRoleIconCode(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 0xe047; // Icons.admin_panel_settings
      case UserRole.traveler:
        return 0xe071; // Icons.card_travel
      case UserRole.companier:
        return 0xe0af; // Icons.business
    }
  }

  // Get role display name
  String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.traveler:
        return 'Traveler';
      case UserRole.companier:
        return 'Companier';
    }
  }

  // Get role description
  String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'System Administrator with full access';
      case UserRole.traveler:
        return 'Customer account for booking services';
      case UserRole.companier:
        return 'Business account for service providers';
    }
  }

  // Get role-specific menu items
  List<Map<String, dynamic>> getRoleSpecificMenuItems(UserRole role) {
    List<Map<String, dynamic>> items = [];

    switch (role) {
      case UserRole.admin:
        items = [
          {
            'title': 'User Management',
            'icon': 0xe7ef, // Icons.people
            'color': 0xFFE53935, // Colors.red[600]
            'route': '/user-management',
          },
          {
            'title': 'System Settings',
            'icon': 0xe8b9, // Icons.settings_applications
            'color': 0xFFFB8C00, // Colors.orange[600]
            'route': '/system-settings',
          },
          {
            'title': 'Reports & Analytics',
            'icon': 0xe037, // Icons.analytics
            'color': 0xFF8E24AA, // Colors.purple[600]
            'route': '/reports-analytics',
          },
          {
            'title': 'View All Reports',
            'icon': 0xe6dd, // Icons.report
            'color': 0xFFEF5350, // Colors.red[400]
            'route': '/all-reports',
          },
          {
            'title': 'Manage Evaluations',
            'icon': 0xe838, // Icons.star_rate
            'color': 0xFFFFB300, // Colors.amber[600]
            'route': '/manage-evaluations',
          },
        ];
        break;

      case UserRole.traveler:
        items = [
          {
            'title': 'My Trips',
            'icon': 0xe071, // Icons.card_travel
            'color': 0xFF43A047, // Colors.green[600]
            'route': AppRoutes.myTrips,
          },
          {
            'title': 'Create Trip',
            'icon': 0xe055, // Icons.add_location_alt
            'color': 0xFF00897B, // Colors.teal[600]
            'route': AppRoutes.createTrip,
          },
          {
            'title': 'Share Location',
            'icon': 0xe55c, // Icons.location_on
            'color': 0xFFE53935, // Colors.red[600]
            'route': AppRoutes.shareLocation,
          },
          {
            'title': 'My Evaluations',
            'icon': 0xe83a, // Icons.star_border
            'color': 0xFFFFB300, // Colors.amber[600]
            'route': '/my-evaluations',
          },
        ];
        break;

      case UserRole.companier:
        items = [
          {
            'title': 'Browse Trips',
            'icon': 0xe8b6, // Icons.search
            'color': 0xFF00897B, // Colors.teal[600]
            'route': AppRoutes.browseTrips,
          },
          {
            'title': 'Send Request',
            'icon': 0xe725, // Icons.send
            'color': 0xFF1E88E5, // Colors.blue[600]
            'route': '/send-request',
          },
          {
            'title': 'My Requests',
            'icon': 0xe3ee, // Icons.inbox
            'color': 0xFFFB8C00, // Colors.orange[600]
            'route': '/my-requests',
          },
          {
            'title': 'Accepted Trips',
            'icon': 0xe86c, // Icons.check_circle
            'color': 0xFF43A047, // Colors.green[600]
            'route': '/accepted-trips',
          },
          {
            'title': 'My Evaluations',
            'icon': 0xe6c9, // Icons.rate_review
            'color': 0xFFFFB300, // Colors.amber[600]
            'route': '/my-evaluations',
          },
        ];
        break;
    }

    return items;
  }
}
