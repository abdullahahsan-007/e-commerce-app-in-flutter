import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up
  Future<User?> signUp(String email, String password, String username, String role) async {
    try {
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name
      await result.user?.updateDisplayName(username);
      await result.user?.reload();

      // Add user role and additional details to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'username': username, // Storing the username
        'role': role, // 'admin' or 'user'
      });

      return result.user;
    } catch (e) {
      print('Error during sign up: $e');
      return null;
    }
  }

  // Sign In
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      // Sign in user
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch role from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(result.user!.uid).get();

      return {
        'user': result.user,
        'role': userDoc['role'], // 'admin' or 'user'
        'username': userDoc['username'], // Fetch username if needed
      };
    } catch (e) {
      print('Error during sign in: $e');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }
}
