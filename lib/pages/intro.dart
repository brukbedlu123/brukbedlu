import 'package:etsport/pages/acc.dart';
import 'package:etsport/pages/firstpage.dart';
import 'package:etsport/pages/providers/languageprovide.dart';
import 'package:etsport/widgets/gender.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroScreen extends StatefulWidget {
  final VoidCallback onDone;

  const IntroScreen({super.key, required this.onDone});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String? _selectedGender;
  String? _selectedLanguage;

  List<Map<String, String>> get _introPages {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (languageProvider.isEnglish) {
      return [
        {
          'title': 'Welcome to Tena + 💪',
          'description':
              'Your 30-day bodyweight fitness challenge starts now. Let’s get stronger, together.',
          'imagePath': 'images/intro/intro 1.webp',
        },
        {
          'title': 'Track Every Rep 📊',
          'description':
              'Measure progress, unlock new routines, and stay motivated on your transformation journey.',
          'imagePath': 'images/intro/intro 2.webp',
        },
        {
          'title': 'Custom Plans for Every Body 🧠',
          'description':
              'No matter your gender or fitness level, we tailor workouts to your goals — from abs to arms, legs to full-body. Your body, your plan.',
          'imagePath': 'images/intro/intro 3.webp',
        },
      ];
    } else {
      return [
        {
          'title': 'እንኳን ወደ ጤና + በደህና መጡ 💪',
          'description':
              'የ30 ቀናት የአካል አቀናባበር ፊትነስ ፈተናዎ አሁን ይጀምራል። አብረን እንጠናቀቅ።',
          'imagePath': 'images/intro/intro 1.webp',
        },
        {
          'title': 'እያንዳንዱን እንቅስቃሴ ይቆጥሩ 📊',
          'description': 'እድገትዎን ይመረምሩ፣ አዲስ እርምጃዎችን ይከፍቱ፣ በለውጡ ጉዞዎ ላይ ተነሳና ንቃ።',
          'imagePath': 'images/intro/intro 2.webp',
        },
        {
          'title': 'ለእያንዳንዱ አካል የተስተካከለ እቅድ 🧠',
          'description':
              'ፆታዎ ወይም የእንቅስቃሴ ደረጃዎ ምንም ቢሆን፣ እኛ እንቅስቃሴዎችን ለግብዎ እናስተካክላለን — ከሆድ እስከ ክንድ፣ ከእግር እስከ ሙሉ አካል። አካልዎ፣ እቅድዎ።',
          'imagePath': 'images/intro/intro 3.webp',
        },
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isEnglish = languageProvider.isEnglish;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF004D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _introPages.length + 1, // +1 for selection page
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Gender & Language selection page
                  return _buildGenderLanguagePage(context, width, height);
                } else {
                  final page = _introPages[index - 1];
                  return _buildPage(
                    context,
                    title: page['title']!,
                    description: page['description']!,
                    imagePath: page['imagePath']!,
                    showDone: index == _introPages.length,
                    index: index - 1,
                    width: width,
                    height: height,
                    onDone: widget.onDone,
                  );
                }
              },
            ),
            Align(
              alignment: const Alignment(0, 0.9),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _introPages.length + 1,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white54,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 6,
                  expansionFactor: 4,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
            if (_currentPage < _introPages.length)
              Positioned(
                top: height * 0.06,
                right: width * 0.06,
                child: SafeArea(
                  child: TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        _introPages.length,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Text(
                      isEnglish ? 'Skip' : 'ዝለውጥ',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderLanguagePage(
      BuildContext context, double width, double height) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final genderProvider = Provider.of<GenderProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isEnglish = languageProvider.isEnglish;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isEnglish
                ? "Let's personalize your experience!"
                : "እባክዎን ተለዋዋጭ ልምድዎን ይምረጡ!",
            style: GoogleFonts.poppins(
              fontSize: width * 0.07,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: height * 0.04),

          // Gender selection using Provider
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: isDark ? Colors.black : Colors.white,
            ),
            title: Text(
              isEnglish ? "Gender" : "ጾታ",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isDark ? Colors.black : Colors.white,
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
                  value: genderProvider.selectedGender.isNotEmpty
                      ? genderProvider.selectedGender
                      : null,
                  dropdownColor: isDark ? Colors.white54 : Colors.white,
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
                  items: ['male', 'female'].map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(
                        gender[0].toUpperCase() + gender.substring(1),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black,
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
                              color: isDark ? Colors.white54 : Colors.black,
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

          SizedBox(height: height * 0.03),

          // Language selection as Dropdown
          ListTile(
            leading: Icon(
              Icons.language,
              color: isDark ? Colors.black : Colors.white,
            ),
            title: Text(
              "Language",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isDark ? Colors.black : Colors.white,
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
                  dropdownColor: isDark ? Colors.white54 : Colors.white,
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
                              color: isDark ? Colors.white54 : Colors.black,
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

          SizedBox(height: height * 0.2),
          ElevatedButton(
            onPressed: (genderProvider.selectedGender.isNotEmpty)
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              padding: EdgeInsets.symmetric(
                  vertical: height * 0.018, horizontal: width * 0.18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 6,
            ),
            child: Text(
              isEnglish ? "Continue" : "ቀጥል",
              style: GoogleFonts.poppins(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    BuildContext context, {
    required String title,
    required String description,
    required String imagePath,
    required int index,
    required double width,
    required double height,
    bool showDone = false,
    VoidCallback? onDone,
  }) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isEnglish = languageProvider.isEnglish;
    switch (index) {
      case 0:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  imagePath,
                  height: height * 0.26,
                  width: height * 0.26,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: height * 0.05),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: width * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: width * 0.045,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
            ],
          ),
        );

      case 1:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Row(
            children: [
              Expanded(
                child: Image.asset(
                  imagePath,
                  height: height * 0.4,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: width * 0.055,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: width * 0.04,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 2:
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.6)),
            Padding(
              padding: EdgeInsets.all(width * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: width * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: width * 0.043,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  if (showDone)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          onDone!();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => firstpage1()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          padding:
                              EdgeInsets.symmetric(vertical: height * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                        ),
                        child: Text(
                          isEnglish ? "Let’s Begin" : "እንጀምር",
                          style: GoogleFonts.poppins(
                            fontSize: width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: height * 0.04),
                ],
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
