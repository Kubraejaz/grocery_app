// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final _svc = AuthService();

  UserProfile? _profile;
  bool         _loading           = false;
  String?      _error;
  bool         _needsConfirmation = false;

  // ── Getters ───────────────────────────────────────────────
  User?        get user               => _svc.currentUser;
  bool         get loggedIn           => _svc.isLoggedIn;
  String       get userName           => _profile?.fullName ?? _svc.userName;
  String       get userEmail          => _profile?.email ?? _svc.userEmail;
  UserProfile? get profile            => _profile;
  int          get userType           => _profile?.userType ?? UserTypes.user;
  bool         get isAdmin            => _profile?.isAdmin ?? false;
  bool         get isCustomer         => !isAdmin;
  bool         get loading            => _loading;
  String?      get error              => _error;
  bool         get needsConfirmation  => _needsConfirmation;

  void _setState(bool load, [String? err]) {
    _loading = load;
    _error   = err;
    notifyListeners();
  }

  // ── Load Profile ──────────────────────────────────────────
  Future<void> loadProfile() async {
    if (!loggedIn) {
      _profile = null;
      notifyListeners();
      return;
    }
    _profile = await _svc.fetchProfile();
    notifyListeners();
  }

  // ── Sign In ───────────────────────────────────────────────
  Future<bool> signIn(String email, String password) async {
    _setState(true);
    _needsConfirmation = false;
    try {
      final success = await _svc.signIn(email: email, password: password);
      if (success) {
        await loadProfile();
        _setState(false);
        return true;
      } else {
        _setState(false, 'Login failed. Please try again.');
        return false;
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('email not confirmed')) {
        _needsConfirmation = true;
        _setState(false, 'Please confirm your email before logging in.');
      } else if (e.message.toLowerCase().contains('invalid login credentials')) {
        _setState(false, 'Incorrect email or password. Please try again.');
      } else {
        _setState(false, e.message);
      }
      return false;
    } catch (e) {
      _setState(false, 'Something went wrong. Please try again.');
      return false;
    }
  }

  // ── Sign Up ───────────────────────────────────────────────
  Future<String> signUp(
    String email,
    String password,
    String fullName, {
    int userType = UserTypes.user,
  }) async {
    _setState(true);
    _needsConfirmation = false;
    try {
      final loggedIn = await _svc.signUp(
        email:    email,
        password: password,
        fullName: fullName,
        userType: userType,
      );

      if (loggedIn) {
        await loadProfile();
        _setState(false);
        return 'success';
      } else {
        _needsConfirmation = true;
        _setState(false);
        return 'confirm';
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered')) {
        _setState(false, 'This email is already registered. Please login.');
      } else {
        _setState(false, e.message);
      }
      return 'error';
    } catch (e) {
      _setState(false, 'Something went wrong. Please try again.');
      return 'error';
    }
  }

  // ── Sign Out ──────────────────────────────────────────────
  Future<void> signOut() async {
    await _svc.signOut();
    _profile = null;
    _needsConfirmation = false;
    notifyListeners();
  }
}
