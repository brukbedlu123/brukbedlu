import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:etsport/main.dart';
import 'package:etsport/pages/acc.dart';
import 'package:etsport/pages/appbar/fav.dart';
import 'package:etsport/pages/appbar/recent.dart';
import 'package:etsport/pages/firstpage.dart';
import 'package:etsport/pages/intro.dart';
import 'package:etsport/pages/providers/favourite_provider.dart';
import 'package:etsport/pages/providers/languageprovide.dart';
import 'package:etsport/pages/providers/notification_provider.dart';
import 'package:etsport/pages/providers/recent_provider.dart';
import 'package:etsport/pages/providers/user_provider.dart' as user_provider;
import 'package:etsport/widgets/gender.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:etsport/gen_l10n/app_localizations.dart'; // ✅ correct

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenIntro = prefs.getBool('seenIntro') ?? false;

  runApp(MyApp(showIntro: !hasSeenIntro));
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  //const MyApp({super.key});
  final File? image;

  const MyApp({super.key, this.image, required this.showIntro});
  final bool showIntro;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(
          titleSmall: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
      home: showIntro
          ? IntroScreen(
              onDone: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seenIntro', true);
                runApp(const MyApp(showIntro: false));
              },
            )
          : const firstpage1(),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 10);

    // One smooth wave curve
    final controlPoint = Offset(size.width / 3, size.height);
    final endPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

bool _isDarkMode = false;

class firstpage1 extends StatefulWidget {
  final File? image;

  const firstpage1({super.key, this.image});

  @override
  _FirstPageState createState() => _FirstPageState();
}

class WorkoutData {
  final String title;
  final String subtitle;
  final String image;
  final String duration;

  WorkoutData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.duration,
  });
}

List<Map<String, String>> _recentWorkouts = [];
List<Map<String, String>> _favorites = [];

class _FirstPageState extends State<firstpage1> with WidgetsBindingObserver {
  final bool _isEnglish = true;
  late user_provider.UserProfile user;

  // ...other code...
  @override
  void initState() {
    super.initState();
    _loadUserData();
    //_preloadRewardedAd();

    ///loadRewardedAd(); // Load ad at startup
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndAskNotificationPermission(context as BuildContext);
    });*/
    WidgetsBinding.instance.addObserver(this);
  }
/*
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkAndAskNotificationPermission(context as BuildContext);
      });
    }
  }*/

  List<Map<String, String>> _buildItemList(
          AppLocalizations localizations, String gender) =>
      [
        {
          'title': localizations.fullbody,
          'subtitle': localizations.noEquipment,
          'duration': localizations.days30,
          'image': gender == 'female'
              ? 'images/First three/full body/girl.webp'
              : 'images/First three/full body/boy.webp',
          'route': '/fullbody'
        },
        /* {
          'title': localizations.running,
          'subtitle': localizations.kmTracking,
          'duration': localizations.days30,
          'image': gender == 'female'
              ? 'images/First three/running/girl.webp'
              : 'images/First three/running/boy.webp',
          //'route': '/intro'
          'route': '/run'
        },*/
        {
          'title': localizations.weightLoss,
          'subtitle': localizations.noEquipment,
          'duration': '10 Min',
          'image': gender == 'female'
              ? 'images/First three/weight loss/girl.webp'
              : 'images/First three/weight loss/boy.webp',
          //'route': '/starting'
          'route': '/weghitloss'
          //  'route': '/days'
          //'route': '/not'
          //'route': '/fulltry'
        },
      ];

  List<Map<String, String>> _buildDuplicateWorkouts(
          AppLocalizations localizations, String gender) =>
      [
        {
          'title': localizations.homeWorkout,
          'subtitle': localizations.noEquipment,
          'duration': '',
          'image': gender == 'female'
              ? 'images/home workout/girl.webp'
              : 'images/home workout/boy.webp',
          'route': '/homework'
        },
        {
          'title': localizations.gymWorkout,
          'subtitle': localizations.withEquipment,
          'duration': localizations.specificBody,
          'image': gender == 'female'
              ? 'images/gym/gym.webp'
              : 'images/gym/gym.webp',
          'route': '/gym'
        },
        /*  {
          'title': localizations.calisthenics,
          'subtitle': localizations.bodyWeightExercises,
          'duration': localizations.withEquipment,
          'image': gender == 'female'
              ? 'images/calisthenics/girl.webp'
              : 'images/calisthenics/boy.webp',
          'route': '/calisthenics'
        },*/
      ];

  List<Map<String, String>> _buildFeaturedWorkouts(
          AppLocalizations localizations, String gender) =>
      [
        {
          'title': localizations.quickPump,
          'subtitle': localizations.dumbbells,
          'duration': localizations.fiveMin,
          'image': gender == 'female'
              ? 'images/discovery/quick pump.webp'
              : 'images/discovery/quick pump.webp',
          'route': '/quickpump'
        },
        {
          'title': localizations.buttWork,
          'subtitle': localizations.noEquipment,
          'duration': localizations.sevenMin,
          'image': gender == 'female'
              ? 'images/discovery/butt workout.webp'
              : 'images/discovery/butt workout.webp',
          'route': '/butt'
        },
        {
          'title': localizations.bellyFat,
          'subtitle': localizations.noEquipment,
          'duration': localizations.sevenMin,
          'image': gender == 'female'
              ? 'images/discovery/belly fat.webp'
              : 'images/discovery/belly fat.webp',
          'route': '/bellyfat'
        },
      ];
  /* RewardedAd? _rewardedAd;
  bool _isLoadingAd = false;

  /// Preload Rewarded Ad
  void _preloadRewardedAd() {
    if (_rewardedAd != null || _isLoadingAd) return;

    _isLoadingAd = true;
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('✅ Ad preloaded');
          _rewardedAd = ad;
          _isLoadingAd = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('❌ Failed to preload ad: $error');
          _isLoadingAd = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  Future<void> showAdThenNavigate(
    BuildContext context,
    String routeName,
    VoidCallback onAdComplete,
  ) async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("No Internet"),
          content: const Text("Please connect to the internet to continue."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
      return;
    }

    // If already loaded
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          _preloadRewardedAd(); // Preload next
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          _preloadRewardedAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onAdComplete(); // Navigate after watching ad
        },
      );

      _rewardedAd = null;
      return;
    }

    // Not loaded: Try to load again immediately
    _isLoadingAd = true;

    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('✅ Ad loaded after button press');

          _rewardedAd = ad;
          _isLoadingAd = false;

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _preloadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              _preloadRewardedAd();
            },
          );

          _rewardedAd!.show(
            onUserEarnedReward: (ad, reward) {
              onAdComplete(); // Only called when reward is earned
            },
          );

          _rewardedAd = null;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('❌ Failed to load ad after button press: $error');
          _isLoadingAd = false;

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Ad Failed"),
              content: const Text(
                "Unable to load ad. Please check your internet connection and try again.",
              ),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void showUnlockDialog(
    BuildContext context,
    Map<String, String> workout,
    VoidCallback onAdComplete,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              'WATCH VIDEO TO UNLOCK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Watch the video to use training plan',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                minimumSize: Size(double.infinity, 48),
              ),
              icon: Icon(Icons.play_arrow, color: Colors.white),
              label: Text("UNLOCK", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                showAdThenNavigate(
                  context,
                  workout['route']!,
                  onAdComplete,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
*/
  List<Widget> _buildBottomBarItems(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final items = [
      {
        'icon': Icons.star,
        'label': localizations.favorites,
        'onPressed': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            ),
        'offset': -5.0,
      },
      {
        'icon': Icons.history,
        'label': localizations.recent,
        'onPressed': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecentPage()),
            ),
        'offset': -5.0,
      },
      {
        'icon': Icons.featured_play_list_outlined,
        'label': localizations.discovery,
        'onPressed': () => Navigator.pushNamed(context, '/feature'),
        'offset': -5.0,
      },
      {
        'icon': Icons.person,
        'label': localizations.profile,
        'onPressed': () => Navigator.pushNamed(context, '/acc'),
        'offset': -5.0,
      },
    ];

    return [
      Expanded(
          child: _buildNavItemResponsive(context, items[0], themeProvider)),
      Expanded(
          child: _buildNavItemResponsive(context, items[1], themeProvider)),
      const SizedBox(width: 40), // Space for FAB
      Expanded(
          child: _buildNavItemResponsive(context, items[2], themeProvider)),
      Expanded(
          child: _buildNavItemResponsive(context, items[3], themeProvider)),
    ];
  }

  Widget _buildNavItemResponsive(
      BuildContext context, Map item, ThemeProvider themeProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double barHeight = constraints.maxHeight;
        final double iconSize = (barHeight * 0.30).clamp(22.0, 50.0);
        final double fontSize = (barHeight * 0.05).clamp(10.0, 18.0);

        return Transform.translate(
          offset: Offset(0, item['offset'] ?? -5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: item['onPressed'],
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.center,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'],
                      size: iconSize,
                      color: Colors.green,
                    ),
                    Text(
                      item['label'],
                      style: GoogleFonts.poppins(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialItem({
    required IconData icon,
    required String label,
    required Color color,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

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

  int _selectedLevel = 0;
  int _selectedDay = 0;
  int _completedDay = 0;

  /*void _resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 3; i++) {
      await prefs.remove('completedDay_level$i');
    }
    await prefs.remove('selectedLevel');

    setState(() {
      _selectedLevel = 0;
      _selectedDay = 0;
      _completedDay = 0;
    });
  }
*/
  void _resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedLevel');
    await prefs.remove('completedDay_level$_selectedLevel');

    setState(() {
      _selectedLevel = 0;
      _selectedDay = 0;
      _completedDay = 0;
    });
  }

  // Existing strings for UI
  String get _startnow => _isEnglish ? 'START NOW' : 'ጀምር';
  String get _running => 'RUNNING';
  String get _kmtrace => 'KM TRACING';
  String get _30days => '30 Days';
  bool _isUserLoaded = false;
  File? _image; // Add this line to declare the _image variable

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    //  final theme = Theme.of(context);
    // final localizations = AppLocalizations.of(context)!;
    final gender = Provider.of<GenderProvider>(context).selectedGender;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textProvider = Provider.of<TextProvider>(context);
    final File? image;

    final List<Map<String, String>> item =
        _buildItemList(localizations, gender);
    final List<Map<String, String>> _featuredWorkouts =
        _buildFeaturedWorkouts(localizations, gender);
    final List<Map<String, String>> _duplicateWorkouts =
        _buildDuplicateWorkouts(localizations, gender);
    final String heroText =
        gender == 'female' ? 'Welcome, Queen!' : localizations.home;
    // gender == 'male' ? 'Welcome, Queen!' : localizations.home;

    final String workoutText =
        gender == 'female' ? 'Let’s get fit your way!' : localizations.workout;

    final ImageProvider<Object> backgroundImage = _image != null
        ? FileImage(_image!) as ImageProvider<Object>
        : AssetImage(
            gender == 'female'
                ? 'images/app bar/girl.webp'
                : 'images/app bar/boy.webp',
          );
    final screenHeight = MediaQuery.of(context).size.height;
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    //final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    DateTime now = DateTime.now();
    // String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);

    Widget _buildDrawerItem({
      required IconData icon,
      required String label,
      required Color color,
      bool isDestructive = false,
      required VoidCallback onTap,
    }) {
      return ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: GoogleFonts.exo2(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: Colors.grey.shade100,
        onTap: onTap,
      );
    }
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
      final isEnglish = languageProvider.isEnglish;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color.fromARGB(221, 30, 34, 32)
          : Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.3,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(
              color: Colors
                  .white, // <- sets leading icon (e.g. back button) to white
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Wave-shaped background container
                  ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      /* decoration: BoxDecoration(
                        image: DecorationImage(
                          image: _image != null
                              ? FileImage(
                                  _image!) // Use the selected image if available
                              : AssetImage('image: backgroundImage,')
                                  as ImageProvider, // Default image if no image is passed
                          fit: BoxFit.cover,
                        ),
                      ),*/
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: backgroundImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              themeProvider.isDarkMode
                                  ? Colors.black.withOpacity(0.9)
                                  : Colors.black.withOpacity(0.5),
                              Colors.transparent
                            ],
                            //  color: themeProvider.isDarkMode ? Colors.white54 : Colors.black,
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Text content over the wave background
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnglish
                              ? 'Tena +'
                              : 'ጤና +', // Using the localized string for 'Home'
                          style: GoogleFonts.poppins(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                            letterSpacing: 1.3,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        /*  SizedBox(height: 4),
                        Text(
                          // heroText, // Using the localized string for 'Workout'
                          'Workouts',
                          style: GoogleFonts.exo2(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),*/
                        SizedBox(height: 6),
                        Text(
                          user.motivation,
                          style: GoogleFonts.exo2(
                            fontSize: 12,
                            color: Colors.white70,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final workout = item[index];

                final isFavorited =
                    favoritesProvider.isFavorite(workout['route']!);
                // Check if workout is already favorited

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: GestureDetector(
                    onTap: () {
                      context.read<RecentProvider>().addRecentItem(workout);
                      Navigator.pushNamed(context, workout['route']!);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: MediaQuery.of(context).size.height * 0.21,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.white10
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: themeProvider.isDarkMode
                              ? Colors.black54
                              : Colors.white.withOpacity(0.2),
                          //  color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background Image

                            Image.asset(
                              workout['image']!,
                              fit: BoxFit.cover,
                            ),

                            // Gradient Overlay for readability
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),

                            // Frosted Glass Blur
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                              child: Container(
                                color: themeProvider.isDarkMode
                                    ? Colors.black.withOpacity(0.04)
                                    : Colors.black.withOpacity(0.2),
                                //  color: Colors.black.withOpacity(0.1),
                              ),
                            ),

                            // Favorite Icon
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: Icon(
                                  isFavorited
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                onPressed: () {
                                  if (isFavorited) {
                                    favoritesProvider
                                        .removeFavorite(workout['route']!);
                                  } else {
                                    favoritesProvider.addFavorite(workout);
                                  }
                                },
                              ),
                            ),

                            // Title and Details
                            Positioned(
                              left: 20,
                              bottom: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workout['title']!,
                                    style: GoogleFonts.exo2(
                                      color: Colors.greenAccent.shade700,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 5,
                                          color: Colors.black87,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 18,
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        workout['duration']!,
                                        style: GoogleFonts.exo2(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.directions_run,
                                        size: 18,
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        workout['subtitle']!,
                                        style: GoogleFonts.exo2(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: item.length,
            ),
          ),
          /*SliverList(
  delegate: SliverChildBuilderDelegate(
    (BuildContext context, int index) {
      final workout = item[index];
      final isFavorited = favoritesProvider.isFavorite(workout['route']!);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: GestureDetector(
          onTap: () {
            context.read<RecentProvider>().addRecentItem(workout);
            Navigator.pushNamed(context, workout['route']!);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: MediaQuery.of(context).size.height * 0.23,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.05), Colors.white10],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 📸 Background Image
                  Image.asset(
                    workout['image']!,
                    fit: BoxFit.cover,
                  ),

                  // 🟩 Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),

                  // 🌫️ Frosted blur overlay
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.4, sigmaY: 0.4),
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),

                  // ❤️ Favorite Icon
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (isFavorited) {
                          favoritesProvider.removeFavorite(workout['route']!);
                        } else {
                          favoritesProvider.addFavorite(workout);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorited ? Colors.redAccent : Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),

                  // 📋 Title and Info
                  Positioned(
                    left: 20,
                    bottom: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout['title']!,
                          style: GoogleFonts.exo2(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                            shadows: [
                              const Shadow(
                                blurRadius: 6,
                                color: Colors.black87,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 18, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              workout['duration']!,
                              style: GoogleFonts.exo2(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.directions_run,
                                size: 18, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              workout['subtitle']!,
                              style: GoogleFonts.exo2(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    childCount: item.length,
  ),
),
*/
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, ''),
                    child: Text(
                      localizations.discovery,
                      style: GoogleFonts.exo2(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/feature'),
                    style: TextButton.styleFrom(
                      foregroundColor: themeProvider.isDarkMode
                          ? Colors.white30
                          : Colors.black87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      textStyle: GoogleFonts.exo2(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      localizations.see_all,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /*
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('workouts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No workouts available.'));
                }

                var _featuredWorkouts = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {
                    'title': data.containsKey('title')
                        ? data['title'] as String
                        : '',
                    'subtitle': data.containsKey('subtitle')
                        ? data['subtitle'] as String
                        : '',
                    'duration': data.containsKey('duration')
                        ? data['duration'] as String
                        : '',
                    'image': data.containsKey('image')
                        ? data['image'] as String
                        : '',
                    'route': data.containsKey('route')
                        ? data['route'] as String
                        : '',
                  };
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var workout in _featuredWorkouts)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              context
                                  .read<RecentProvider>()
                                  .addRecentItem(workout);
                              Navigator.pushNamed(context, workout['route']!);
                            },
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.26,
                              width: MediaQuery.of(context).size.width * 0.73,
                              child: Stack(
                                children: [
                                  // Background Image with Blur and Dark Overlay
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.26,
                                    width: MediaQuery.of(context).size.width *
                                        0.73,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(workout['image']!),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: .10, sigmaY: .10),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Favorite Button
                                  Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.02,
                                    left: MediaQuery.of(context).size.width *
                                        0.015,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.10),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            _favorites.any((fav) =>
                                                    fav['route'] ==
                                                    workout['route'])
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              final isFavorited =
                                                  _favorites.any((fav) =>
                                                      fav['route'] ==
                                                      workout['route']);

                                              if (isFavorited) {
                                                _favorites.removeWhere((fav) =>
                                                    fav['route'] ==
                                                    workout['route']);
                                              } else {
                                                _favorites.insert(0, workout);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Workout Details and Start Now Button
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.025,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.02,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          final alreadyInList =
                                              _recentWorkouts.any((recent) =>
                                                  recent['route'] ==
                                                  workout['route']);

                                          if (!alreadyInList) {
                                            if (_recentWorkouts.length >= 5) {
                                              _recentWorkouts.removeAt(0);
                                            }
                                            _recentWorkouts.add(workout);
                                          }
                                        });
                                        Navigator.pushNamed(
                                            context, workout['route']!);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.012,
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.045,
                                        ),
                                        elevation: 4,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Start Now',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.025,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: MediaQuery.of(context).size.width *
                                        0.055,
                                    left: MediaQuery.of(context).size.width *
                                        0.25,
                                    top: MediaQuery.of(context).size.height *
                                        0.01,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.04,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          workout['title']!,
                                          style: TextStyle(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.07,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        Text(
                                          workout['subtitle']!,
                                          style: TextStyle(
                                            color: themeProvider.isDarkMode
                                                ? Colors.green
                                                : Colors.white70,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.001),
                                        Text(
                                          workout['duration']!,
                                          style: TextStyle(
                                            color: themeProvider.isDarkMode
                                                ? Colors.green
                                                : Colors.white70,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.0255,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),*/

          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.26,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _featuredWorkouts.length,
                itemBuilder: (context, index) {
                  final workout = _featuredWorkouts[index];
                  final isFavorited =
                      _favorites.any((fav) => fav['route'] == workout['route']);

                  return Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      /*  onTap: () {
                        showUnlockDialog(context, workout, () {
                          context.read<RecentProvider>().addRecentItem(workout);
                          Navigator.pushNamed(context, workout['route']!);
                        });
                      },*/
                      onTap: () {
                        context.read<RecentProvider>().addRecentItem(workout);
                        Navigator.pushNamed(context, workout['route']!);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Stack(
                          children: [
                            // 🔳 Background image
                            Container(
                              width: MediaQuery.of(context).size.width * 0.73,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(workout['image']!),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),

                            // 🌫️ Blur and dark overlay
                            Positioned.fill(
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                              ),
                            ),

                            // ❤️ Favorite button
                            Positioned(
                              top: 12,
                              left: 12,
                              child: ClipOval(
                                child: Container(
                                  //  color: Colors.black.withOpacity(0.2),
                                  child: IconButton(
                                    icon: Icon(
                                      isFavorited
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (isFavorited) {
                                          _favorites.removeWhere((fav) =>
                                              fav['route'] == workout['route']);
                                        } else {
                                          _favorites.insert(0, workout);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),

                            // ▶️ Start Now button
                            Positioned(
                              left: 16,
                              bottom: 16,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    final alreadyInList = _recentWorkouts.any(
                                        (recent) =>
                                            recent['route'] ==
                                            workout['route']);
                                    if (!alreadyInList) {
                                      if (_recentWorkouts.length >= 5) {
                                        _recentWorkouts.removeAt(0);
                                      }
                                      _recentWorkouts.add(workout);
                                    }
                                  });
                                  Navigator.pushNamed(
                                      context, workout['route']!);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent.shade700,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  localizations.startnow,
                                  style: GoogleFonts.exo2(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            // 📋 Workout title & subtitle
                            Positioned(
                              right: 16,
                              left: MediaQuery.of(context).size.width * 0.25,
                              top: 20,
                              bottom: 16,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    workout['title']!,
                                    style: GoogleFonts.exo2(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    workout['subtitle']!,
                                    style: GoogleFonts.exo2(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    workout['duration']!,
                                    style: GoogleFonts.exo2(
                                      fontSize: 12,
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Duplicated section using _duplicateWorkouts list
          // Workouts Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: GestureDetector(
                onTap: () {},
                child: SizedBox(
                  height: 60,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizations.workout,
                      style: GoogleFonts.exo2(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

// Workouts List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final workout = _duplicateWorkouts[index];
                final size = MediaQuery.of(context).size;
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final isFavorited =
                    favoritesProvider.isFavorite(workout['route']!);

                // Coming Soon card for index 1
                if (index == 1) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.015,
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(workout['image']!),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Dark overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.85),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // Centered text
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'GYM Workout',
                                    style: GoogleFonts.exo2(
                                      fontSize: size.width * 0.06,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    'Coming Soon',
                                    style: GoogleFonts.exo2(
                                      fontSize: size.width * 0.045,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Normal workout card for all other indices
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.015,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      context.read<RecentProvider>().addRecentItem(workout);
                      Navigator.pushNamed(context, workout['route']!);
                    },
                    child: AspectRatio(
                      aspectRatio: 16 / 8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                workout['image']!,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.75),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: IconButton(
                                  icon: Icon(
                                    isFavorited
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  onPressed: () {
                                    if (isFavorited) {
                                      favoritesProvider
                                          .removeFavorite(workout['route']!);
                                    } else {
                                      favoritesProvider.addFavorite(workout);
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(size.width * 0.045),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workout['title']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.exo2(
                                        fontSize: size.width * 0.06,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.004),
                                    Text(
                                      workout['subtitle']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.exo2(
                                        fontSize: size.width * 0.04,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.004),
                                    Text(
                                      workout['duration']!,
                                      style: GoogleFonts.exo2(
                                        fontSize: size.width * 0.035,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const Spacer(),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            workout['route']!,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.greenAccent.shade700,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.035,
                                            vertical: size.height * 0.005,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: Text(
                                          localizations.startnow,
                                          style: GoogleFonts.exo2(
                                            color: Colors.white,
                                            fontSize: size.width * 0.030,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: _duplicateWorkouts.length,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // 🔝 Custom Drawer Header
            Consumer<ProfileImageProvider>(
              builder: (context, profileImageProvider, child) {
                final imageFile = profileImageProvider.image;

                return UserAccountsDrawerHeader(
                  accountName: Text(
                    user.username,
                    style: GoogleFonts.exo2(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: Text(
                    user.email,
                    style: GoogleFonts.exo2(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: user.profileImage != null
                        ? FileImage(user.profileImage!)
                        : const AssetImage('assets/profile.jpg')
                            as ImageProvider,
                    radius: 30,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.isDarkMode
                            ? Colors.green.shade900
                            : Colors.green.shade400,
                        Colors.green.shade600
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),

            // 🔽 Drawer Items
            Expanded(
              child: Column(
                children: [
                  // Top Section (Main Items)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      children: [
                        /* _buildDrawerItem(
                          icon: Icons.refresh,
                          label: localizations.resetprogress,
                          color: Colors.blueAccent,
                          onTap: _resetProgress,
                        ),
                        const SizedBox(height: 12),*/
                        _buildDrawerItem(
                          icon: Icons.settings,
                          label: localizations.setting,
                          color: Colors.blueAccent,
                          onTap: () {
                            Navigator.pushNamed(context, '/setting');
                          },
                        ),
                        const SizedBox(height: 5),
                        Divider(
                          thickness: 1,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),

                  // Bottom Section (About & Socials)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSocialItem(
                          icon: Icons.camera_alt_outlined,
                          label: 'Instagram',
                          color: Colors.purple,
                          url:
                              'https://www.instagram.com/tena_plus/profilecard/?igsh=MTFrbXIyNTl2ZjlnbA==',
                        ),
                        const SizedBox(height: 10),
                        _buildSocialItem(
                          icon: Icons.send,
                          label: 'Telegram',
                          color: Colors.blue,
                          url: 'https://t.me/+8sr6spsuBNczNzY0',
                        ),
                        const SizedBox(height: 10),
                        _buildSocialItem(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          color: Colors.indigo,
                          url: 'https://www.facebook.com/share/1BwSATKKYd/',
                        ),
                        const SizedBox(height: 10),
                        _buildSocialItem(
                          icon: Icons.video_collection_outlined,
                          label: 'TikTok',
                          color: Colors.black,
                          url:
                              'https://www.tiktok.com/@tena.plus?_t=ZM-8yAH07KVgVc&_r=1',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5), // Bottom padding of 3
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const firstpage1()),
              (route) => false,
            );
          },
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.home,
            color: Colors.black,
            size: 30, // Optional: icon size
          ),
        ),
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = MediaQuery.of(context).size.height;
          // Use the same formula as in bottom appbar.dart for consistency
          final double bottomBarHeight = (screenHeight * 0.7).clamp(35.0, 65.0);

          return BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 6.0,
            height: bottomBarHeight,
            color:
                Colors.transparent, // Set the background color to transparent
            elevation: 0, // Remove elevation for a flat appearance
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildBottomBarItems(context),
            ),
          );
        },
      ),
    );
  }
}

class Level extends StatelessWidget {
  const Level({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 400, // Adjust height to fit text
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(''), // Replace with your background image
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'How many pushups can you do?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildLevelButton(
              context,
              title: 'Beginner',
              subtitle: '0-5 Push ups',
              route: '/fullbody',
            ),
            const SizedBox(height: 20),
            _buildLevelButton(
              context,
              title: 'Intermediate',
              subtitle: '5-10 Push ups',
              route: '/homework',
            ),
            const SizedBox(height: 20),
            _buildLevelButton(
              context,
              title: 'Advanced',
              subtitle: 'Above 10 Push ups',
              route: '/homework',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context,
      {required String title,
      required String subtitle,
      required String route}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(5),
          color: Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
