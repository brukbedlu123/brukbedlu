import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const _languageCodeKey = 'languageCode';

  Locale _locale = const Locale('en'); // Default to English

  Locale get locale => _locale;

  bool get isEnglish => _locale.languageCode == 'en';

  LanguageProvider() {
    _loadLocale();
  }

  void toggleLanguage() {
    _locale = isEnglish ? const Locale('am') : const Locale('en');
    _saveLocale(_locale.languageCode);
    notifyListeners();
  }

  void setLanguage(bool isEnglish) {
    _locale = isEnglish ? const Locale('en') : const Locale('am');
    _saveLocale(_locale.languageCode);
    notifyListeners();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_languageCodeKey) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> _saveLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, code);
  }
}
