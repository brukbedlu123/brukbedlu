import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BreakProvider with ChangeNotifier {
  static const String _breakSecondsKey = 'breakSeconds';
  int _breakSeconds = 30; // Default break time

  BreakProvider() {
    _loadBreakSeconds();
  }

  int get breakSeconds => _breakSeconds;

  Future<void> _loadBreakSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    _breakSeconds =
        prefs.getInt(_breakSecondsKey) ?? 30; // Default to 5 if not found
    notifyListeners();
  }

  Future<void> setBreakSeconds(int seconds) async {
    if (seconds > 0) {
      _breakSeconds = seconds;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_breakSecondsKey, seconds);
      notifyListeners();
    }
  }
}
