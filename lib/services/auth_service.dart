
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register a new user
  Future<UserCredential> register(
      String email,
      String password,
      ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Login an existing user
  Future<UserCredential> login(
      String email,
      String password,
      ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Logout the current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get the currently logged-in user
  User? get currentUser => _auth.currentUser;
}