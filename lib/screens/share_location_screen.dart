// lib/screens/traveler/share_location_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class ShareLocationScreen extends StatefulWidget {
  const ShareLocationScreen({super.key});

  @override
  _ShareLocationScreenState createState() => _ShareLocationScreenState();
}

class _ShareLocationScreenState extends State<ShareLocationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _locationNameController = TextEditingController();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final userId = auth.FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        title: const Text(
          'Share Location',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Share your location with companions during trips for safer travel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active Location Shares
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('locationShares')
                  .where('travelerId', isEqualTo: userId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active location shares',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Share your location to get started',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var locationShare = snapshot.data!.docs[index];
                    var data = locationShare.data() as Map<String, dynamic>;
                    return _buildLocationCard(data, locationShare.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showShareLocationDialog,
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.location_on),
        label: const Text('Share Location'),
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location, String locationId) {
    DateTime timestamp = DateTime.parse(location['timestamp'] ?? DateTime.now().toIso8601String());
    Duration difference = DateTime.now().difference(timestamp);
    String timeAgo = _getTimeAgo(difference);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.location_on, color: Colors.blue[600], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location['locationName'] ?? 'Unknown Location',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Shared $timeAgo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[600]),
                  onPressed: () => _deleteLocationShare(locationId),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Location is being shared',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.add_location, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text('Share Location'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _locationNameController,
              decoration: InputDecoration(
                labelText: 'Location Name',
                hintText: 'e.g., Downtown Cairo, Highway Rest Stop',
                prefixIcon: const Icon(Icons.place),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your location will be shared with companions on your active trips',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareLocation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
            ),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareLocation() async {
    if (_locationNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a location name'),
          backgroundColor: Colors.orange[600],
        ),
      );
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      final userId = auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore.collection('locationShares').add({
        'travelerId': userId,
        'locationName': _locationNameController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
        'latitude': 0.0, // In production, use actual GPS coordinates
        'longitude': 0.0,
      });

      _locationNameController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location shared successfully!'),
          backgroundColor: Colors.green[600],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing location: ${e.toString()}'),
          backgroundColor: Colors.red[600],
        ),
      );
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  Future<void> _deleteLocationShare(String locationId) async {
    try {
      await _firestore.collection('locationShares').doc(locationId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location share removed'),
          backgroundColor: Colors.green[600],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing location share: ${e.toString()}'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  String _getTimeAgo(Duration difference) {
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    super.dispose();
  }
}