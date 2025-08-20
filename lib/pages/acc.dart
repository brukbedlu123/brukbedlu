import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etsport/pages/firstpage.dart';
import 'package:etsport/pages/providers/languageprovide.dart';

import 'package:etsport/pages/settings.dart';

import 'package:etsport/widgets/bottom%20appbar.dart';
import 'package:etsport/widgets/gender.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:etsport/gen_l10n/app_localizations.dart'; // ✅ correct

import 'package:etsport/pages/providers/user_provider.dart' as user_provider;

//late user_provider.UserProfile user;

@override
Widget build(BuildContext context) {
  return MaterialApp(
    locale: Provider.of<LanguageProvider>(context).locale,
    theme: Provider.of<ThemeProvider>(context).themeData, // Use dynamic theme
    home: const Acc(),
  );
}

class TextProvider with ChangeNotifier {
  String _motivationText = '';

  String get motivationText => _motivationText;

  void updateMotivation(String newText) {
    _motivationText = newText;
    notifyListeners();
  }
}

/*
class LanguageProvider extends ChangeNotifier {
  bool _isEnglish = true;

  Locale get locale => _isEnglish ? const Locale('en') : const Locale('am');

  LanguageProvider() {
    _loadLanguage();
  }

  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    _saveLanguage();
    notifyListeners();
  }

  bool get isEnglish => _isEnglish;

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnglish = prefs.getBool('isEnglish') ?? true;
    notifyListeners();
  }

  Future<void> _saveLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isEnglish', _isEnglish);
  }
}
*/
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
          color: _isDarkMode
              ? const Color.fromARGB(255, 188, 203, 187)
              : Colors.black,
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
            _isDarkMode ? Colors.green : Colors.green,
          ),
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
}

class Acc extends StatefulWidget {
  const Acc({super.key});

  @override
  _AccState createState() => _AccState();
}

class ProfileImageProvider extends ChangeNotifier {
  File? _image;

  File? get image => _image;

  void setImage(File? newImage) {
    _image = newImage;
    notifyListeners();
  }
}
/*
class UserProfile {
  String username;
  String email;
  int age;
  String gender;
  File? profileImage;
  final String motivation; // <-- Add this if not already present

  UserProfile({
    required this.username,
    required this.email,
    required this.age,
    required this.gender,
    this.profileImage,
    required this.motivation, // <-- Include here
  });
}*/

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _AccState extends State<Acc> {
  late user_provider.UserProfile user;
  bool _isUserLoaded = false;

  File? _image;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Use `context` from the State class — it's already a BuildContext
        Provider.of<ProfileImageProvider>(context, listen: false)
            .setImage(imageFile);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const firstpage1(),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _navigateToEditProfile() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
    );

    if (updatedUser != null && updatedUser is user_provider.UserProfile) {
      setState(() {
        user = updatedUser;
      });
    }
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  // late User user;

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user = user_provider.UserProfile(
        username: prefs.getString('username') ?? "Tena +",
        email: prefs.getString('email') ?? "Tena+@profile.com",
        age: prefs.getInt('age') ?? 25,
        gender: prefs.getString('gender') ?? "Female",
        profileImage: prefs.getString('profileImage') != null
            ? File(prefs.getString('profileImage')!)
            : null,
        motivation: prefs.getString('motivation') ?? "Let's Goo",
      );
      _isUserLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final theme = Theme.of(context);
    final lang = AppLocalizations.of(context)!;
    final genderProvider = Provider.of<GenderProvider>(context);
    bool isNotificationsEnabled = false;
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    final isDark = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color.fromARGB(221, 30, 34, 32)
          : Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white54 : Colors.black,
        ),
        title: Text(
          localizations.profile,
          style: GoogleFonts.poppins(
            textStyle: theme.textTheme.titleLarge,
            color: themeProvider.isDarkMode ? Colors.white54 : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: themeProvider.isDarkMode ? Colors.white54 : Colors.black,
            ),
            onSelected: (value) async {
              if (value == 'reset') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('gender');
                await prefs.remove('motivation');
                final localizations = AppLocalizations.of(context)!;
                final themeProvider =
                    Provider.of<ThemeProvider>(context, listen: false);
                final languageProvider =
                    Provider.of<LanguageProvider>(context, listen: false);
                if (themeProvider.isDarkMode) themeProvider.toggleDarkMode();
                if (!languageProvider.isEnglish)
                  languageProvider.toggleLanguage();

                final genderProvider =
                    Provider.of<GenderProvider>(context, listen: false);
                genderProvider.setGender("male");

                setState(() {
                  user = user_provider.UserProfile(
                    username: user.username,
                    email: user.email,
                    age: user.age,
                    gender: localizations.female,
                    profileImage: user.profileImage,
                    motivation: "Let's Goo",
                  );
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile reset to default')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset Profile'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: user.profileImage != null
                      ? FileImage(user.profileImage!)
                      : const AssetImage('assets/profile.jpg') as ImageProvider,
                  radius: 35,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: themeProvider.isDarkMode
                            ? Colors.white54
                            : Colors.black,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: _navigateToEditProfile,
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              label: Text(
                localizations.editprofile,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // MOTIVATION
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.military_tech,
                          color: themeProvider.isDarkMode
                              ? Colors.amberAccent
                              : Colors.green.shade800),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          user.motivation,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // THEME TOGGLE
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    final isDark = themeProvider.isDarkMode;
                    final localizations = AppLocalizations.of(context)!;
                    return ListTile(
                      leading: Icon(Icons.brightness_6,
                          color: isDark ? Colors.white : Colors.black),
                      title: Text(
                        localizations.theme,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          themeProvider.toggleDarkMode();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.white24 : Colors.black12,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            isDark
                                ? Icons.nightlight_round
                                : Icons.wb_sunny_outlined,
                            color: isDark ? Colors.yellow : Colors.orange,
                            size: 26,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                /*   // NOTIFICATIONS
                Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, _) {
                    return ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text(localizations.notification),
                      subtitle:
                          Text(notificationProvider.isEnabled ? "ON" : "OFF"),
                      trailing: Switch(
                        value: notificationProvider.isEnabled,
                        onChanged: (val) {
                          notificationProvider.toggleNotifications(val);
                        },
                      ),
                    );
                  },
                ),
*/
                // LANGUAGE
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, _) {
                    final localizations = AppLocalizations.of(context)!;

                    return ListTile(
                      leading: Icon(
                        Icons.language,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      title: Text(
                        "Language",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? Colors.white30 : Colors.grey,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: false,
                            value: languageProvider.isEnglish ? 'en' : 'am',
                            dropdownColor:
                                isDark ? Colors.white54 : Colors.white,
                            iconEnabledColor: Colors.black,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: isDark ? Colors.white70 : Colors.black,
                            ),
                            hint: Text(
                              "Select",
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white54 : Colors.black,
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'en',
                                child: Text(
                                  'English',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'am',
                                child: Text(
                                  'አማርኛ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                languageProvider.setLanguage(value == 'en');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Language set to ${value == 'en' ? 'English' : 'አማርኛ'}",
                                      style: GoogleFonts.poppins(
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black,
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // GENDER
                ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    localizations.gender,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor, // 🔸 Button background color
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeProvider.isDarkMode
                            ? Colors.white30
                            : Colors.grey,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: false, // Set to false for compact look
                        value: genderProvider.selectedGender.isNotEmpty
                            ? genderProvider.selectedGender
                            : null,
                        dropdownColor: themeProvider.isDarkMode
                            ? Colors.white54
                            : Colors.white, // 🔸 Dropdown menu background
                        iconEnabledColor: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.black,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black,
                        ),
                        hint: Text(
                          "Select",
                          style: GoogleFonts.poppins(
                            color: themeProvider.isDarkMode
                                ? Colors.white54
                                : Colors.black,
                          ),
                        ),
                        items: ['male', 'female'].map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(
                              gender[0].toUpperCase() + gender.substring(1),
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: themeProvider.isDarkMode
                                    ? Colors.black
                                    : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            genderProvider.setGender(value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Gender set to ${value[0].toUpperCase() + value.substring(1)}",
                                  style: GoogleFonts.poppins(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white54
                                        : Colors.black,
                                  ),
                                ),
                                backgroundColor: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // LOG OUT
                /*  ListTile(
                  leading: Icon(
                    Icons.logout,
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                  title: Text(localizations.logout,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      )),
                  // ...existing code...
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(localizations.confirmlogout,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold)),
                        content: Text(localizations.sure,
                            style: GoogleFonts.poppins()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(localizations.cancel,
                                style: GoogleFonts.poppins()),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context); // Close dialog
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const firstpage1()),
                                (route) => false,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Logged out",
                                      style: GoogleFonts.poppins()),
                                ),
                              );
                            },
                            child:
                                Text("Log out", style: GoogleFonts.poppins()),
                          ),
                        ],
                      ),
                    );
                  },
// ...existing code...
                ),*/
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const firstpage1()),
            (route) => false,
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.home, size: 28, color: Colors.black),
      ),
      bottomNavigationBar: const CustomBottomNav(currentPage: 'profile'),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final user_provider.UserProfile user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _motivationController;

  String _selectedGender = "male";
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _usernameController = TextEditingController(text: user.username);
    _emailController = TextEditingController(text: user.email);
    _ageController = TextEditingController(text: user.age.toString());
    _selectedGender = user.gender;
    _selectedImage = user.profileImage;
    _motivationController = TextEditingController(text: user.motivation);

    // Fetch Firestore data if user is signed in
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _loadUserDataFromFirestore(currentUser.uid);
    }
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

  Future<void> _onSignInSuccess(User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      final username = data['username'] ?? '';
      final email = data['email'] ?? user.email ?? '';
      // Use these values in your app, e.g.:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(username: username, email: email)));
    }
  }

  void _loadUserDataFromFirestore(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _usernameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
      });
    }
  }

  Future<void> _saveProfile() async {
    final updatedUser = user_provider.UserProfile(
      username: _usernameController.text,
      email: _emailController.text,
      age: int.tryParse(_ageController.text) ?? 0,
      gender: _selectedGender,
      profileImage: _selectedImage,
      motivation: _motivationController.text,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', updatedUser.username);
    await prefs.setString('email', updatedUser.email);
    await prefs.setInt('age', updatedUser.age);
    await prefs.setString('gender', updatedUser.gender);
    await prefs.setString('motivation', updatedUser.motivation);
    if (updatedUser.profileImage != null) {
      await prefs.setString('profileImage', updatedUser.profileImage!.path);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );

    Navigator.pop(context, updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final genderProvider = Provider.of<GenderProvider>(context);
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : Colors.white,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.green.withOpacity(0.3),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : const AssetImage('assets/profile.jpg')
                            as ImageProvider,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Username
            TextField(
              controller: _usernameController,
              style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: localizations.username,
                labelStyle: GoogleFonts.poppins(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextField(
              controller: _emailController,
              style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: localizations.email,
                labelStyle: GoogleFonts.poppins(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Age
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: localizations.age,
                labelStyle: GoogleFonts.poppins(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 9),

            // Gender
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.person_outline,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                localizations.gender,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              trailing: DropdownButton<String>(
                value: genderProvider.selectedGender.isNotEmpty
                    ? genderProvider.selectedGender
                    : null,
                underline: const SizedBox(),
                dropdownColor: Theme.of(context).cardColor,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black,
                ),
                hint: Text("Select", style: GoogleFonts.poppins()),
                items: ['male', 'female'].map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(
                      gender[0].toUpperCase() + gender.substring(1),
                      style: GoogleFonts.poppins(),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    genderProvider.setGender(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Gender set to ${value[0].toUpperCase() + value.substring(1)}",
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 9),

            // Motivation Title
            Row(
              children: [
                Icon(Icons.military_tech,
                    color: isDark ? Colors.amberAccent : Colors.green.shade800),
                const SizedBox(width: 8),
                Text(
                  localizations.motivation,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Motivation Text Area
            TextField(
              controller: _motivationController,
              maxLength: 15,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Stay strong and consistent...',
                hintStyle: GoogleFonts.poppins(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 6.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),

            const SizedBox(height: 10),

            // Save Button
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 4,
              ),
              child: Text(
                localizations.saveprofile,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),
/*
            if (!isLoggedIn)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthPage(
                        initialEmail: _emailController.text,
                        initialUsername: _usernameController.text,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 4,
                ),
                child: Text(
                  localizations.signup,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),*/
          ],
        ),
      ),
    );
  }
}
