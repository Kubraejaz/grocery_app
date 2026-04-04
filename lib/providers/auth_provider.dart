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

  bool    _loading = false;
  String? _error;

  bool    get loading => _loading;
  String? get error   => _error;

  void _setState(bool load, [String? err]) {
    _loading = load;
    _error   = err;
    notifyListeners();
  }

  // ── Sign In ───────────────────────────────────────────────
  Future<bool> signIn(String email, String password) async {
    _setState(true);
    try {
      await _svc.signIn(email: email, password: password);
      _setState(false);
      return true;
    } on AuthException catch (e) {
      _setState(false, e.message);
      return false;
    } catch (e) {
      _setState(false, 'Something went wrong. Please try again.');
      return false;
    }
  }

  // ── Sign Up ───────────────────────────────────────────────
  Future<bool> signUp(
      String email, String password, String fullName) async {
    _setState(true);
    try {
      await _svc.signUp(
          email: email, password: password, fullName: fullName);
      _setState(false);
      return true;
    } on AuthException catch (e) {
      _setState(false, e.message);
      return false;
    } catch (e) {
      _setState(false, 'Something went wrong. Please try again.');
      return false;
    }
  }

  // ── Sign Out ──────────────────────────────────────────────
  Future<void> signOut() async {
    await _svc.signOut();
    notifyListeners();
  }
}