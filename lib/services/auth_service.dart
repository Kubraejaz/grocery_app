// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';

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

  // ── Profile ───────────────────────────────────────────────
  Future<UserProfile?> fetchProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;

    try {
      final res = await _client
          .from(Tables.profiles)
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (res != null) {
        return UserProfile.fromJson(res);
      }
    } catch (_) {
      // Fallback if profiles table is not yet migrated
    }

    // Fallback: check user metadata or default to regular customer
    final metaType = (currentUser?.userMetadata?['user_type'] as num?)?.toInt() ?? UserTypes.user;
    return UserProfile(
      id:        uid,
      fullName:  userName,
      email:     userEmail,
      userType:  metaType,
      createdAt: DateTime.now(),
    );
  }

  // ── Sign Up ───────────────────────────────────────────────
  // Returns true  → registered AND logged in (email confirm OFF)
  // Returns false → email confirmation required
  // Throws        → on any real error
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    int userType = UserTypes.user,
  }) async {
    final response = await _client.auth.signUp(
      email:    email,
      password: password,
      data: {
        'full_name': fullName,
        'user_type': userType,
      },
    );

    // If session exists, also ensure profile record is inserted
    if (response.session != null && response.user != null) {
      try {
        await _client.from(Tables.profiles).upsert({
          'id':        response.user!.id,
          'full_name': fullName,
          'email':     email,
          'user_type': userType,
        });
      } catch (_) {}
      return true;
    }

    return false; // needs email confirmation
  }

  // ── Sign In ───────────────────────────────────────────────
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email:    email,
      password: password,
    );

    return response.session != null;
  }

  // ── Sign Out ──────────────────────────────────────────────
  Future<void> signOut() => _client.auth.signOut();
}
