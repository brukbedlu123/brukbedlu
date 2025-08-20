import 'dart:io';
import 'package:flutter/material.dart';

class UserProfile with ChangeNotifier {
  String _username;
  String _email;
  int _age;
  String _gender;
  File? _profileImage;
  String _motivation;

  UserProfile({
    required String username,
    required String email,
    required int age,
    required String gender,
    String motivation = '',
    File? profileImage,
  })  : _username = username,
        _email = email,
        _age = age,
        _gender = gender,
        _motivation = motivation,
        _profileImage = profileImage;

  // Getters
  String get username => _username;
  String get email => _email;
  int get age => _age;
  String get gender => _gender;
  File? get profileImage => _profileImage;
  String get motivation => _motivation;

  // Update method
  void updateProfile({
    String? username,
    String? email,
    int? age,
    String? gender,
    File? profileImage,
    String? motivation,
  }) {
    if (username != null) _username = username;
    if (email != null) _email = email;
    if (age != null) _age = age;
    if (gender != null) _gender = gender;
    if (profileImage != null) _profileImage = profileImage;
    if (motivation != null) _motivation = motivation;
    notifyListeners();
  }
}
