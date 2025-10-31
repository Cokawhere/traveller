// lib/features/home/services/home_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:traveller/models/user_model.dart';

class HomeService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user data from users collection
  Future<UserModel?> getCurrentUserData() async {
    try {
      auth.User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get detailed user data based on role
  Future<Map<String, dynamic>?> getDetailedUserData() async {
    try {
      auth.User? user = _auth.currentUser;
      if (user == null) return null;

      // First get the role from users collection
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      String role = (userDoc.data() as Map<String, dynamic>)['role'];

      // Then get detailed data from role-specific collection
      DocumentSnapshot detailedDoc;
      switch (role) {
        case 'admin':
          detailedDoc =
              await _firestore.collection('admins').doc(user.uid).get();
          break;
        case 'traveler':
          detailedDoc =
              await _firestore.collection('travelers').doc(user.uid).get();
          break;
        case 'companier':
          detailedDoc =
              await _firestore.collection('companiers').doc(user.uid).get();
          break;
        default:
          return null;
      }

      if (detailedDoc.exists) {
        return detailedDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting detailed user data: $e');
      return null;
    }
  }

  // Get current Firebase user
  auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }

  // Check if user is authenticated
  bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  // Get user statistics (for activity section)
  Future<Map<String, int>> getUserStatistics(String userId, String role) async {
    try {
      Map<String, int> stats = {
        'totalTrips': 0,
        'activeTrips': 0,
        'completedTrips': 0,
        'pendingRequests': 0,
      };

      if (role == 'traveler') {
        // Get trips statistics for traveler
        final tripsSnapshot = await _firestore
            .collection('trips')
            .where('travelerId', isEqualTo: userId)
            .get();

        stats['totalTrips'] = tripsSnapshot.docs.length;

        for (var doc in tripsSnapshot.docs) {
          var data = doc.data();
          DateTime tripTime =
              DateTime.parse(data['time'] ?? DateTime.now().toIso8601String());
          if (tripTime.isAfter(DateTime.now())) {
            stats['activeTrips'] = stats['activeTrips']! + 1;
          } else {
            stats['completedTrips'] = stats['completedTrips']! + 1;
          }
        }

        // Get pending requests for traveler's trips
        final requestsSnapshot = await _firestore
            .collection('requests')
            .where('status', isEqualTo: 'pending')
            .get();

        int pendingCount = 0;
        for (var request in requestsSnapshot.docs) {
          String tripId = request.data()['tripId'];
          var tripDoc =
              await _firestore.collection('trips').doc(tripId).get();
          if (tripDoc.exists &&
              tripDoc.data()?['travelerId'] == userId) {
            pendingCount++;
          }
        }
        stats['pendingRequests'] = pendingCount;
      } else if (role == 'companier') {
        // Get requests statistics for companier
        final requestsSnapshot = await _firestore
            .collection('requests')
            .where('companionId', isEqualTo: userId)
            .get();

        stats['totalTrips'] = requestsSnapshot.docs.length;

        for (var doc in requestsSnapshot.docs) {
          var status = doc.data()['status'];
          if (status == 'pending') {
            stats['pendingRequests'] = stats['pendingRequests']! + 1;
          } else if (status == 'accepted') {
            stats['activeTrips'] = stats['activeTrips']! + 1;
          } else if (status == 'completed') {
            stats['completedTrips'] = stats['completedTrips']! + 1;
          }
        }
      }

      return stats;
    } catch (e) {
      print('Error getting user statistics: $e');
      return {
        'totalTrips': 0,
        'activeTrips': 0,
        'completedTrips': 0,
        'pendingRequests': 0,
      };
    }
  }

  // Stream user data changes
  Stream<UserModel?> streamUserData() {
    auth.User? user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore.collection('users').doc(user.uid).snapshots().map(
      (doc) {
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
        return null;
      },
    );
  }
}