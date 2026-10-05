// lib/services/auth_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Firebase Authentication service — sign in, sign up, Google, sign out.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Current user stream ───────────────────────────────────────────────────
  static Stream<User?> get userStream => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;

  // ── Email / Password Sign In ──────────────────────────────────────────────
  static Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Email / Password Sign Up ──────────────────────────────────────────────
  static Future<UserCredential> signUp(
      String email, String password, String displayName) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
    return cred;
  }

  // ── Forgot Password ───────────────────────────────────────────────────────
  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Get ID Token ─────────────────────────────────────────────────────────
  static Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }
}
