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
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) =>
      _client.auth.signUp(
        email:    email,
        password: password,
        data:     {'full_name': fullName},
      );

  // ── Sign In ───────────────────────────────────────────────
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) =>
      _client.auth.signInWithPassword(
        email:    email,
        password: password,
      );

  // ── Sign Out ──────────────────────────────────────────────
  Future<void> signOut() => _client.auth.signOut();
}