import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RecentProvider with ChangeNotifier {
  final List<Map<String, String>> _recentItems = [];

  List<Map<String, String>> get recentItems => List.unmodifiable(_recentItems);

  RecentProvider() {
    _loadRecentItems(); // Load recent items when the provider is created
  }

  // Add a new recent item
  void addRecentItem(Map<String, String> item) {
    // Check if the item already exists; if so, remove it
    _recentItems.removeWhere((existing) => existing['route'] == item['route']);
    // Insert the item at the beginning of the list
    _recentItems.insert(0, item);
    // Limit the list to 5 items
    if (_recentItems.length > 5) {
      _recentItems.removeLast();
    }
    // Save the updated list to SharedPreferences
    _saveRecentItems();
    notifyListeners(); // Notify listeners after adding a recent item
  }

  // Clear all recent items
  Future<void> clearRecentItems() async {
    _recentItems.clear(); // Clear the recent items list
    final prefs = await SharedPreferences.getInstance();
    await prefs
        .remove('recentItems'); // Remove the saved items from SharedPreferences
    notifyListeners(); // Notify listeners after clearing recent items
  }

  // Save the recent items to SharedPreferences
  Future<void> _saveRecentItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_recentItems); // Encoding the list of maps
    await prefs.setString('recentItems', jsonString); // Saving the string
  }

  // Load the recent items from SharedPreferences
  Future<void> _loadRecentItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItems = prefs.getString('recentItems') ??
        '[]'; // Get saved items or default to an empty list
    try {
      final List decodedData = json.decode(savedItems);
      _recentItems.clear();
      // Use `Map<String, String>` to properly type the list items
      _recentItems
          .addAll(decodedData.map((item) => Map<String, String>.from(item)));
    } catch (e) {
      print("Error loading recent items: $e");
    }
    notifyListeners(); // Notify listeners after loading recent items
  }
}
