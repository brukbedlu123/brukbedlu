/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesProvider with ChangeNotifier {
  final List<Map<String, String>> _favorites = [];

  List<Map<String, String>> get favorites => List.unmodifiable(_favorites);

  FavoritesProvider() {
    _loadFavorites();
  }

  void addFavorite(Map<String, String> workout) {
    // Check if the item already exists; if so, remove it
    _favorites.removeWhere((item) => item['route'] == workout['route']);
    // Insert the item at the beginning of the list
    _favorites.insert(0, workout);
    _saveFavorites();
    notifyListeners();
  }

  void removeFavorite(String route) {
    _favorites.removeWhere((item) => item['route'] == route);
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String route) {
    return _favorites.any((item) => item['route'] == route);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(_favorites); // Encoding the list of maps
    await prefs.setString('favorites', encodedData); // Saving the string
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('favorites'); // Getting the saved string
    if (data != null) {
      // Decode the JSON string and make sure it's properly cast
      final List decodedData = jsonDecode(data);
      _favorites.clear();
      // Use `Map<String, String>` to properly type the list items
      _favorites
          .addAll(decodedData.map((item) => Map<String, String>.from(item)));
      notifyListeners();
    }
  }
}
*/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesProvider with ChangeNotifier {
  final List<Map<String, String>> _favorites = [];

  List<Map<String, String>> get favorites => List.unmodifiable(_favorites);

  FavoritesProvider() {
    _loadFavorites();
  }

  // Adding a new favorite
  void addFavorite(Map<String, String> workout) {
    // Check if the item already exists; if so, remove it
    _favorites.removeWhere((item) => item['route'] == workout['route']);
    // Insert the item at the beginning of the list
    _favorites.insert(0, workout);
    _saveFavorites();
    notifyListeners();
  }

  // Removing a favorite
  void removeFavorite(String route) {
    _favorites.removeWhere((item) => item['route'] == route);
    _saveFavorites();
    notifyListeners();
  }

  // Checking if an item is a favorite
  bool isFavorite(String route) {
    return _favorites.any((item) => item['route'] == route);
  }

  // Saving the favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(_favorites); // Encoding the list of maps
    await prefs.setString('favorites', encodedData); // Saving the string
  }

  // Loading the favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('favorites'); // Getting the saved string
    if (data != null) {
      try {
        final List decodedData = jsonDecode(data);
        _favorites.clear();
        // Use `Map<String, String>` to properly type the list items
        _favorites
            .addAll(decodedData.map((item) => Map<String, String>.from(item)));
      } catch (e) {
        print("Error loading favorites: $e");
      }
    }
    notifyListeners(); // Notify listeners after loading favorites
  }
}
