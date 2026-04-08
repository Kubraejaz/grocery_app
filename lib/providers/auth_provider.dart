// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _svc = AuthService();

  // ── Getters ───────────────────────────────────────────────
  User?  get user      => _svc.currentUser;
  bool   get loggedIn  => _svc.isLoggedIn;
  String get userName  => _svc.userName;
  String get userEmail => _svc.userEmail;

  bool    _loading           = false;
  String? _error;
  bool    _needsConfirmation = false;

  bool    get loading           => _loading;
  String? get error             => _error;
  bool    get needsConfirmation => _needsConfirmation;

  void _setState(bool load, [String? err]) {
    _loading = load;
    _error   = err;
    notifyListeners();
  }

  // ── Sign In ───────────────────────────────────────────────
  // Returns true  → logged in successfully
  // Returns false → wrong credentials or email not confirmed
  Future<bool> signIn(String email, String password) async {
    _setState(true);
    _needsConfirmation = false;
    try {
      final success = await _svc.signIn(email: email, password: password);
      if (success) {
        _setState(false);
        return true;
      } else {
        _setState(false, 'Login failed. Please try again.');
        return false;
      }
    } on AuthException catch (e) {
      // Supabase returns this specific message when email is not confirmed
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
  // Returns 'success'     → registered and logged in (go to home)
  // Returns 'confirm'     → registered but needs email confirmation
  // Returns 'error'       → registration failed
  Future<String> signUp(String email, String password, String fullName) async {
    _setState(true);
    _needsConfirmation = false;
    try {
      final loggedIn = await _svc.signUp(
        email:    email,
        password: password,
        fullName: fullName,
      );

      if (loggedIn) {
        // Email confirmation is OFF → user is logged in immediately
        _setState(false);
        return 'success';
      } else {
        // Email confirmation is ON → user needs to confirm email
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
    _needsConfirmation = false;
    notifyListeners();
  }
}