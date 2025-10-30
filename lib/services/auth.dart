import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:traveller/models/user_model.dart';
import 'package:traveller/screens/home_screen.dart';
import 'package:traveller/screens/login_screen.dart';


class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('admins').doc(userCredential.user!.uid).set({
        'adminId': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'admin',
        'createdAt': DateTime.now().toIso8601String(),
      });

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': 'admin',
      });

      await userCredential.user!.updateDisplayName(name);
      return null; // Success
    } on auth.FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  Future<String?> registerTraveler({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String socialMedia,
    required int yearsOfDriving,
    required String carName,
    required String carModel,
  }) async {
    try {
      auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create traveler document
      await _firestore.collection('travelers').doc(userCredential.user!.uid).set({
        'travelerId': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'socialMedia': socialMedia,
        'yearsOfDriving': yearsOfDriving,
        'carName': carName,
        'carModel': carModel,
        'role': 'traveler',
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Also create in users collection for authentication
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': 'traveler',
      });

      await userCredential.user!.updateDisplayName(name);
      return null; // Success
    } on auth.FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Register Companier
  Future<String?> registerCompanier({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String socialMedia,
  }) async {
    try {
      auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create companier document
      await _firestore.collection('companiers').doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'socialMedia': socialMedia,
        'role': 'companier',
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Also create in users collection for authentication
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': 'companier',
      });

      await userCredential.user!.updateDisplayName(name);
      return null; // Success
    } on auth.FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      } else {
        return e.message ?? 'An error occurred during login.';
      }
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user data from users collection
  Future<UserModel?> getCurrentUserData() async {
    try {
      auth.User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get detailed user data based on role
  Future<Map<String, dynamic>?> getDetailedUserData() async {
    try {
      auth.User? user = _auth.currentUser;
      if (user == null) return null;

      // First get the role from users collection
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      String role = (userDoc.data() as Map<String, dynamic>)['role'];

      // Then get detailed data from role-specific collection
      DocumentSnapshot detailedDoc;
      switch (role) {
        case 'admin':
          detailedDoc = await _firestore.collection('admins').doc(user.uid).get();
          break;
        case 'traveler':
          detailedDoc = await _firestore.collection('travelers').doc(user.uid).get();
          break;
        case 'companier':
          detailedDoc = await _firestore.collection('companiers').doc(user.uid).get();
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

  // Get current user
  auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Handle auth exceptions
  String _handleAuthException(auth.FirebaseAuthException e) {
    if (e.code == 'weak-password') {
      return 'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      return 'An account already exists for that email.';
    } else {
      return e.message ?? 'An error occurred during registration.';
    }
  }
}



class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData) {
          return HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}