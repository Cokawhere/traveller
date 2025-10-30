import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traveller/enums/user_enum.dart';
import 'package:traveller/models/user_model.dart';
import 'package:traveller/routes.dart';
import 'package:traveller/features/auth/services/auth.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _authService.getCurrentUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => Get.offAllNamed(AppRoutes.login));
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        UserModel user = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.grey[800]),
            title: Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.grey[800]),
                onPressed: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
          drawer: _buildDrawer(context, user),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getRoleGradientColors(user.role),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getRoleIcon(user.role),
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back!',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_getRoleDisplayName(user.role)} Account',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // User Info Section
                Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                _buildInfoCard('Email', user.email, Icons.email_outlined),
                const SizedBox(height: 12),
                _buildInfoCard('Role', _getRoleDisplayName(user.role),
                    _getRoleIcon(user.role)),
                const SizedBox(height: 12),
                _buildInfoCard('Account Type', _getRoleDescription(user.role),
                    Icons.info_outlined),

                const SizedBox(height: 32),

                // Quick Stats or Recent Activity
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildActivityCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, UserModel user) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 20,
                left: 20,
                right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getRoleGradientColors(user.role),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Icon(
                    _getRoleIcon(user.role),
                    size: 35,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRoleDisplayName(user.role),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Role-specific menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),

                // Profile menu item (for all roles)
                ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.blue[600]),
                  title: const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Get.back(); // Close drawer
                    Get.toNamed(AppRoutes.profile);
                  },
                ),

                const Divider(
                    height: 24, thickness: 1, indent: 16, endIndent: 16),

                ..._getRoleSpecificMenuItems(user.role, context),

                const Divider(height: 32, thickness: 1),

                // Common menu items
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.grey[700]),
                  title: const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    // TODO: Add settings route
                    Get.snackbar(
                        'Coming Soon', 'Settings page is under development.');
                    // Get.toNamed(AppRoutes.settings);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.grey[700]),
                  title: const Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    // TODO: Add help & support route
                    Get.snackbar('Coming Soon',
                        'Help & Support page is under development.');
                    // Get.toNamed(AppRoutes.helpSupport);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey[700]),
                  title: const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),

          // Logout button at bottom
          const Divider(height: 1, thickness: 1),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[600]),
            title: Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red[600],
              ),
            ),
            onTap: () {
              Get.back();
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Widget> _getRoleSpecificMenuItems(UserRole role, BuildContext context) {
    List<Map<String, dynamic>> items = [];

    switch (role) {
      case UserRole.admin:
        items = [
          {
            'title': 'User Management',
            'icon': Icons.people,
            'color': Colors.red[600],
            'route': '/user-management',
          },
          {
            'title': 'System Settings',
            'icon': Icons.settings_applications,
            'color': Colors.orange[600],
            'route': '/system-settings',
          },
          {
            'title': 'Reports & Analytics',
            'icon': Icons.analytics,
            'color': Colors.purple[600],
            'route': '/reports-analytics',
          },
          {
            'title': 'View All Reports',
            'icon': Icons.report,
            'color': Colors.red[400],
            'route': '/all-reports',
          },
          {
            'title': 'Manage Evaluations',
            'icon': Icons.star_rate,
            'color': Colors.amber[600],
            'route': '/manage-evaluations',
          },
        ];
        break;

      case UserRole.traveler:
        items = [
          {
            'title': 'Browse Trips',
            'icon': Icons.explore,
            'color': Colors.blue[600],
            'route': '/browse-trips',
          },
          {
            'title': 'My Trips',
            'icon': Icons.card_travel,
            'color': Colors.green[600],
            'route': '/my-trips',
          },
          {
            'title': 'Create Trip',
            'icon': Icons.add_location_alt,
            'color': Colors.teal[600],
            'route': '/create-trip',
          },
          {
            'title': 'Share Location',
            'icon': Icons.location_on,
            'color': Colors.red[600],
            'route': '/share-location',
          },
          {
            'title': 'My Evaluations',
            'icon': Icons.star_border,
            'color': Colors.amber[600],
            'route': '/my-evaluations',
          },
          {
            'title': 'Travel History',
            'icon': Icons.history,
            'color': Colors.indigo[600],
            'route': '/travel-history',
          },
          {
            'title': 'Community Posts',
            'icon': Icons.forum,
            'color': Colors.purple[600],
            'route': '/community-posts',
          },
        ];
        break;

      case UserRole.companier:
        items = [
          {
            'title': 'Browse Trips',
            'icon': Icons.search,
            'color': Colors.teal[600],
            'route': '/browse-trips',
          },
          {
            'title': 'Send Request',
            'icon': Icons.send,
            'color': Colors.blue[600],
            'route': '/send-request',
          },
          {
            'title': 'My Requests',
            'icon': Icons.inbox,
            'color': Colors.orange[600],
            'route': '/my-requests',
          },
          {
            'title': 'Accepted Trips',
            'icon': Icons.check_circle,
            'color': Colors.green[600],
            'route': '/accepted-trips',
          },
          {
            'title': 'My Evaluations',
            'icon': Icons.rate_review,
            'color': Colors.amber[600],
            'route': '/my-evaluations',
          },
          {
            'title': 'Community Posts',
            'icon': Icons.article,
            'color': Colors.purple[600],
            'route': '/community-posts',
          },
        ];
        break;
    }

    return items.map((item) {
      return ListTile(
        leading: Icon(
          item['icon'] as IconData,
          color: item['color'] as Color,
        ),
        title: Text(
          item['title'] as String,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (item['route'] != null) {
            Get.toNamed(item['route'] as String);
          }
        },
      );
    }).toList();
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.upcoming,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No recent activity',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your activities will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getRoleGradientColors(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [Colors.red[400]!, Colors.red[600]!];
      case UserRole.traveler:
        return [Colors.blue[400]!, Colors.blue[600]!];
      case UserRole.companier:
        return [Colors.teal[400]!, Colors.teal[600]!];
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.traveler:
        return Icons.card_travel;
      case UserRole.companier:
        return Icons.business;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.traveler:
        return 'Traveler';
      case UserRole.companier:
        return 'Companier';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'System Administrator with full access';
      case UserRole.traveler:
        return 'Customer account for booking services';
      case UserRole.companier:
        return 'Business account for service providers';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _authService.logout();
                Get.back(); // Close dialog
                Get.offAllNamed(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Text('About'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Traveller App',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Version 1.0.0'),
              const SizedBox(height: 16),
              Text(
                'A companion travel app connecting travelers with companions for safer journeys.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
