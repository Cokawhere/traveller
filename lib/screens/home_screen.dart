import 'package:flutter/material.dart';
import 'package:traveller/enums/user_enum.dart';
import 'package:traveller/models/user_model.dart';
import 'package:traveller/services/auth.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _authService.getCurrentUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return Scaffold(body: Center(child: CircularProgressIndicator()));
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
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
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
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
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
                          SizedBox(width: 16),
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
                                SizedBox(height: 4),
                                Text(
                                  user.name,
                                  style: TextStyle(
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
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_getRoleDisplayName(user.role)} Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // User Info Section
                Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),

                _buildInfoCard('Email', user.email, Icons.email_outlined),
                SizedBox(height: 12),
                _buildInfoCard('Role', _getRoleDisplayName(user.role), _getRoleIcon(user.role)),
                SizedBox(height: 12),
                _buildInfoCard('Account Type', _getRoleDescription(user.role), Icons.info_outlined),

                SizedBox(height: 32),
                
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
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 20, left: 20, right: 20),
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
                SizedBox(height: 12),
                Text(
                  user.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRoleDisplayName(user.role),
                    style: TextStyle(
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
                SizedBox(height: 8),
                
                // Profile menu item (for all roles)
                ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.blue[600]),
                  title: Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                
                Divider(height: 24, thickness: 1, indent: 16, endIndent: 16),
                
                ..._getRoleSpecificMenuItems(user.role, context),
                
                Divider(height: 32, thickness: 1),
                
                // Common menu items
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.grey[700]),
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Settings clicked')),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.grey[700]),
                  title: Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to help
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Help & Support clicked')),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey[700]),
                  title: Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Show about dialog
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),

          // Logout button at bottom
          Divider(height: 1, thickness: 1),
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
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
          SizedBox(height: 8),
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
          },
          {
            'title': 'System Settings',
            'icon': Icons.settings_applications,
            'color': Colors.orange[600],
          },
          {
            'title': 'Reports & Analytics',
            'icon': Icons.analytics,
            'color': Colors.purple[600],
          },
          {
            'title': 'View All Reports',
            'icon': Icons.report,
            'color': Colors.red[400],
          },
          {
            'title': 'Manage Evaluations',
            'icon': Icons.star_rate,
            'color': Colors.amber[600],
          },
        ];
        break;

      case UserRole.traveler:
        items = [
          {
            'title': 'Browse Trips',
            'icon': Icons.explore,
            'color': Colors.blue[600],
          },
          {
            'title': 'My Trips',
            'icon': Icons.card_travel,
            'color': Colors.green[600],
          },
          {
            'title': 'Create Trip',
            'icon': Icons.add_location_alt,
            'color': Colors.teal[600],
          },
          {
            'title': 'Share Location',
            'icon': Icons.location_on,
            'color': Colors.red[600],
          },
          {
            'title': 'My Evaluations',
            'icon': Icons.star_border,
            'color': Colors.amber[600],
          },
          {
            'title': 'Travel History',
            'icon': Icons.history,
            'color': Colors.indigo[600],
          },
          {
            'title': 'Community Posts',
            'icon': Icons.forum,
            'color': Colors.purple[600],
          },
        ];
        break;

      case UserRole.companier:
        items = [
          {
            'title': 'Browse Trips',
            'icon': Icons.search,
            'color': Colors.teal[600],
          },
          {
            'title': 'Send Request',
            'icon': Icons.send,
            'color': Colors.blue[600],
          },
          {
            'title': 'My Requests',
            'icon': Icons.inbox,
            'color': Colors.orange[600],
          },
          {
            'title': 'Accepted Trips',
            'icon': Icons.check_circle,
            'color': Colors.green[600],
          },
          {
            'title': 'My Evaluations',
            'icon': Icons.rate_review,
            'color': Colors.amber[600],
          },
          {
            'title': 'Community Posts',
            'icon': Icons.article,
            'color': Colors.purple[600],
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          // Handle navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item['title']} clicked')),
          );
        },
      );
    }).toList();
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
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
          SizedBox(width: 12),
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
                SizedBox(height: 2),
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
          title: Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to logout?'),
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
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Logout'),
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
              SizedBox(width: 8),
              Text('About'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Traveller App',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Version 1.0.0'),
              SizedBox(height: 16),
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
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}