import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenderSelectionPage extends StatelessWidget {
  const GenderSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final genderProvider = Provider.of<GenderProvider>(context);
    String selectedGender = genderProvider.selectedGender;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Gender'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                genderProvider.setGender('male');
                Navigator.pop(context);
              },
              child: const Text('Male'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                genderProvider.setGender('female');
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              child: const Text('Female'),
            ),
          ],
        ),
      ),
    );
  }
}

class GenderProvider with ChangeNotifier {
  String _selectedGender = 'male'; // Default gender is 'male'

  String get selectedGender => _selectedGender;

  GenderProvider() {
    _loadGender();
  }

  Future<void> _loadGender() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedGender =
        prefs.getString('gender') ?? 'male'; // Load from shared preferences
    notifyListeners();
  }

  Future<void> setGender(String gender) async {
    _selectedGender = gender;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'gender', gender); // Save the selected gender to shared preferences
  }
}
