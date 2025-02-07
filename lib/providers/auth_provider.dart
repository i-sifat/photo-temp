import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> authenticate() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) return false;

      _isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your photos',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (_isAuthenticated) {
        final prefs = await SharedPreferences.getInstance();
        final isFirstTime = !prefs.containsKey('first_launch');
        if (isFirstTime) {
          await prefs.setBool('first_launch', false);
        }
      }

      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
