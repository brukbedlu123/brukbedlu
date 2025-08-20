/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData {
    return ThemeData(
      textTheme: TextTheme(
        titleMedium: TextStyle(
          color: _isDarkMode ? Colors.green : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color:
              _isDarkMode ? Color.fromARGB(255, 188, 203, 187) : Colors.black,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: _isDarkMode ? Colors.green : Colors.green,
          fontSize: 16,
        ),
      ),
      scaffoldBackgroundColor: _isDarkMode ? Colors.black : Colors.white,
      primaryColor: _isDarkMode ? Colors.grey[800] : Colors.green,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
              _isDarkMode ? Colors.green : Colors.green),
          elevation: WidgetStateProperty.all(5),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          )),
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12, horizontal: 30)),
        ),
      ),
    );
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }
}*/
