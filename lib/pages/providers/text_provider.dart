import 'dart:io';

import 'package:etsport/pages/acc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserProfile {
  String username;
  String email;
  int age;
  String gender;
  File? profileImage;

  UserProfile({
    required this.username,
    required this.email,
    required this.age,
    required this.gender,
    this.profileImage,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile user = UserProfile(
    username: "Anna Miller",
    email: "anna@profile.com",
    age: 25,
    gender: "Female",
    profileImage: null,
  );

  void _navigateToEditProfile() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
    );

    if (updatedUser != null && updatedUser is UserProfile) {
      setState(() {
        user = updatedUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  String _selectedGender = "Female";
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _selectedGender = widget.user.gender;
    _selectedImage = widget.user.profileImage;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    final updatedUser = UserProfile(
      username: _usernameController.text,
      email: _emailController.text,
      age: int.tryParse(_ageController.text) ?? 0,
      gender: _selectedGender,
      profileImage: _selectedImage,
    );

    Navigator.pop(context, updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : AssetImage('assets/profile.jpg') as ImageProvider,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                labelStyle:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Age",
                labelStyle:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: "Gender",
                labelStyle:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              ),
              dropdownColor: isDark ? Colors.grey[900] : Colors.white,
              items: ["Male", "Female", "Other"].map((String gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode
                    ? Colors.tealAccent[700]
                    : Colors.lightBlueAccent,
              ),
              child: Text("Save",
                  style:
                      TextStyle(color: isDark ? Colors.black : Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
