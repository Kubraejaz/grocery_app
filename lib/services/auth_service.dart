// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  // ── Getters ───────────────────────────────────────────────
  User?  get currentUser => _client.auth.currentUser;
  bool   get isLoggedIn  => currentUser != null;
  String get userName    =>
      currentUser?.userMetadata?['full_name'] as String? ?? 'User';
  String get userEmail   => currentUser?.email ?? '';
  String get userId      => currentUser?.id    ?? '';

  Stream<AuthState> get authStream => _client.auth.onAuthStateChange;

  // ── Sign Up ───────────────────────────────────────────────
  // Returns true  → registered AND logged in (email confirm OFF)
  // Returns false → email confirmation required
  // Throws        → on any real error
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email:    email,
      password: password,
      data:     {'full_name': fullName},
    );

    // If session is null, Supabase is waiting for email confirmation
    if (response.session == null) {
      return false; // needs email confirmation
    }

    // Session exists → user is logged in immediately
    return true;
  }

  // ── Sign In ───────────────────────────────────────────────
  // Throws AuthException on wrong credentials or unconfirmed email
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email:    email,
      password: password,
    );

    // Must have a valid session to be considered logged in
    return response.session != null;
  }

  // ── Sign Out ──────────────────────────────────────────────
  Future<void> signOut() => _client.auth.signOut();
}