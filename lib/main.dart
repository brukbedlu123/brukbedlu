import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etsport/pages/Discovery/Discovery.dart';
import 'package:etsport/pages/Discovery/Quick%20tips/nutrition.dart';
import 'package:etsport/pages/Discovery/Quick%20tips/skin_care.dart';
import 'package:etsport/pages/Discovery/Quick%20tips/weight%20gain.dart';
import 'package:etsport/pages/Discovery/belly_fat.dart';
import 'package:etsport/pages/Discovery/butt_workout.dart';
import 'package:etsport/pages/Discovery/chestandbiceps.dart';

import 'package:etsport/pages/Discovery/quick_pump.dart';
import 'package:etsport/pages/Featured/link.dart';
import 'package:etsport/pages/Featured/normal_workout.dart';

import 'package:etsport/pages/HOME%20WORKOUT/abs/advanced_workout_abs.dart';
import 'package:etsport/pages/HOME%20WORKOUT/abs/beginner_abs.dart';

import 'package:etsport/pages/HOME%20WORKOUT/abs/intermediate_abs.dart';

import 'package:etsport/pages/HOME%20WORKOUT/arm/advanced_arm.dart';

import 'package:etsport/pages/HOME%20WORKOUT/arm/beginner_arm.dart';

import 'package:etsport/pages/HOME%20WORKOUT/arm/intermediate_arm.dart';
import 'package:etsport/pages/HOME%20WORKOUT/back%20and%20shoulder/advanced.dart';
import 'package:etsport/pages/HOME%20WORKOUT/back%20and%20shoulder/beginner.dart';
import 'package:etsport/pages/HOME%20WORKOUT/back%20and%20shoulder/intermediate.dart';

import 'package:etsport/pages/HOME%20WORKOUT/chest/advanced.dart';
import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';

import 'package:etsport/pages/HOME%20WORKOUT/chest/intermediate.dart';
import 'package:etsport/pages/HOME%20WORKOUT/legs/advanced_abs.dart';

import 'package:etsport/pages/HOME%20WORKOUT/legs/beginner_abs.dart';

import 'package:etsport/pages/HOME%20WORKOUT/legs/intermediate_abs.dart';

import 'package:etsport/pages/acc.dart';

import 'package:etsport/pages/firstpage.dart';
import 'package:etsport/pages/full%20body/fullbody.dart';
import 'package:etsport/pages/homework.dart';
import 'package:etsport/pages/intro.dart';
import 'package:etsport/pages/providers/break_provider.dart';
import 'package:etsport/pages/providers/favourite_provider.dart';
import 'package:etsport/pages/providers/languageprovide.dart';
import 'package:etsport/pages/providers/notification_provider.dart';
import 'package:etsport/pages/providers/permission_handler.dart';

import 'package:etsport/pages/providers/recent_provider.dart';
import 'package:etsport/pages/providers/reminder_provider.dart';
//import 'package:etsport/pages/providers/user_provider.dart';
import 'package:etsport/pages/providers/user_provider.dart' as user_provider;

import 'package:etsport/pages/settings.dart';
import 'package:etsport/pages/special/weghitloss.dart';

import 'package:etsport/widgets/gender.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
/*import 'package:flutter_localizations/flutter_localizations.dart';*/
import 'package:provider/provider.dart';

import 'package:etsport/gen_l10n/app_localizations.dart'; // ✅ correct

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// Adjust the import based on your project structure
//final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver analyticsObserver =
    FirebaseAnalyticsObserver(analytics: analytics);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezones
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Addis_Ababa'));

  // Ads → only Android/iOS
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await MobileAds.instance.initialize();
  }

  // Screen orientation → skip on web
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Supabase init (ok for web)
  await Supabase.initialize(
    url: 'https://cyngnoznxoubkctfjsmb.supabase.co',
    anonKey: 'YOUR_KEY_HERE',
    debug: true,
  );

  // Firebase init
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDszFuA-lNiujIA97gsd32yTAZAZlmUrQ4",
        authDomain: "home-workout-app-61a7d.firebaseapp.com",
        projectId: "home-workout-app-61a7d",
        storageBucket: "home-workout-app-61a7d.appspot.com",
        messagingSenderId: "437003377452",
        appId: "1:437003377452:web:e5b9a922e23bb07890aa89",
        measurementId: "G-SM00E3KG8P",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(MyApp(isFirstLaunch: isFirstLaunch));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => BreakProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TextProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => RecentProvider()),
        ChangeNotifierProvider(create: (_) => ProfileImageProvider()),
        ChangeNotifierProvider(create: (_) => GenderProvider()),
        ChangeNotifierProvider(
          create: (_) => user_provider.UserProfile(
            username: '',
            email: '',
            age: 0,
            gender: 'male',
          ),
        ),
      ],
      child: MyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkAndRequestNotificationPermission();
  }

  // Removed the unused requestNotificationPermissionCrossPlatform method.
  // The logic is now handled in _checkAndRequestNotificationPermission.

  Future<void> _checkAndRequestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      // This will trigger the system notification permission dialog on iOS & Android 13+
      final result = await Permission.notification.request();

      if (result.isGranted) {
        print('Notification permission granted');
        // You can schedule notifications here if needed,
        // or let NotificationProvider handle it on its own initialization/toggle.
      } else {
        print('Notification permission denied');
      }
    } else {
      print('Notification permission already granted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, _) {
      return MaterialApp(
        navigatorObservers: [
          analyticsObserver
        ], // 👈 This auto-tracks page views
        locale: languageProvider.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('am', ''),
        ],
        theme: themeProvider.themeData,
        debugShowCheckedModeBanner: false,
        home: widget.isFirstLaunch
            ? IntroScreen(
                onDone: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isFirstLaunch', false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const firstpage1()),
                  );
                },
              )
            : const firstpage1(),
        routes: {
          '/firstpage': (context) => const firstpage1(),

          '/homework': (context) {
            final gender = Provider.of<GenderProvider>(context).selectedGender;

            final items = [
              // Level 1
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/chest.webp'
                    : 'images/home workout/boy/chest.webp',
                'title': 'CHEST',
                'route': '/beginner',
                'subtitle': 'Upper chest',
                'duration': 'Lower chest',
                'text3': 'Level 1'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/arm.webp'
                    : 'images/home workout/boy/arm.webp',
                'title': 'ARMS',
                'route': '/beginnerarm',
                'subtitle': 'Biceps',
                'duration': 'Triceps',
                'text3': 'Level 1'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/abs.webp'
                    : 'images/home workout/boy/abs.webp',
                'title': 'ABS',
                'route': '/beginnerabs',
                'subtitle': 'Core Strength',
                'duration': '6 pack',
                'text3': 'Level 1'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/leg.webp'
                    : 'images/home workout/boy/leg.webp',
                'title': 'LEGS',
                'route': '/beginnerleg',
                'subtitle': 'Calf',
                'duration': 'Hamstring',
                'text3': 'Level 1'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/back and shoulder.webp'
                    : 'images/home workout/boy/back and shoulder.webp',
                'title': 'BACK AND SHOULDERS',
                'route': '/beginnerbackandshoulder',
                'subtitle': 'Upper back',
                'duration': 'Shoulders',
                'text3': 'Level 1'
              },

              // Level 2
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/chest.webp'
                    : 'images/home workout/boy/chest.webp',
                'title': 'CHEST',
                'route': '/intermediatechest',
                'subtitle': 'Upper chest',
                'duration': 'Lower chest',
                'text3': 'Level 2'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/arm.webp'
                    : 'images/home workout/boy/arm.webp',
                'title': 'ARMS',
                'route': '/intermediatearm',
                'subtitle': 'Biceps',
                'duration': 'Triceps',
                'text3': 'Level 2'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/abs.webp'
                    : 'images/home workout/boy/abs.webp',
                'title': 'ABS',
                'route': '/intermediateabs',
                'subtitle': 'Core Strength',
                'duration': '6 pack',
                'text3': 'Level 2'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/leg.webp'
                    : 'images/home workout/boy/leg.webp',
                'title': 'LEGS',
                'route': '/intermediateleg',
                'subtitle': 'Calf',
                'duration': 'Hamstring',
                'text3': 'Level 2'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/back and shoulder.webp'
                    : 'images/home workout/boy/back and shoulder.webp',
                'title': 'BACK AND SHOULDERS',
                'route': '/intermediatebackandshoulder',
                'subtitle': 'Upper back',
                'duration': 'Shoulders',
                'text3': 'Level 2'
              },

              // Level 3
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/chest.webp'
                    : 'images/home workout/boy/chest.webp',
                'title': 'CHEST',
                'route': '/advancechest',
                'subtitle': 'Upper chest',
                'duration': 'Lower chest',
                'text3': 'Level 3'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/arm.webp'
                    : 'images/home workout/boy/arm.webp',
                'title': 'ARMS',
                'route': '/advancedarm',
                'subtitle': 'Biceps',
                'duration': 'Triceps',
                'text3': 'Level 3'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/abs.webp'
                    : 'images/home workout/boy/abs.webp',
                'title': 'ABS',
                'route': '/advanced_absworkout',
                'subtitle': 'Core Strength',
                'duration': '6 pack',
                'text3': 'Level 3'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/leg.webp'
                    : 'images/home workout/boy/leg.webp',
                'title': 'LEGS',
                'route': '/advancedworkleg',
                'subtitle': 'Calf',
                'duration': 'Hamstring',
                'text3': 'Level 3'
              },
              {
                'image': gender == 'female'
                    ? 'images/home workout/girl/back and shoulder.webp'
                    : 'images/home workout/boy/back and shoulder.webp',
                'title': 'BACK AND SHOULDERS',
                'route': '/Advancedbackandshoulder',
                'subtitle': 'Upper back',
                'duration': 'Shoulders',
                'text3': 'Level 3'
              },
            ];

            return HomeWorkoutPage(
              title: 'Home Workout',
              items: items,
            );
          },

          '/beginner': (context) {
            final gender = Provider.of<GenderProvider>(context).selectedGender;
            final backgroundimage = gender == 'female'
                ? 'images/home workout/girl/chest.webp'
                : 'images/home workout/boy/chest.webp';
            return ReusableWorkoutPage(
              title: 'Chest Beginner',
              subtitle: '7 mins - 5 Workouts',
              backgroundImage: backgroundimage,
              workouts: [
                {
                  'name': 'Jumping Jacks',
                  'image': 'images/workouts/jumping-jack.gif',
                  'sec': '30 sec'
                },
                {
                  'name': 'Wall Push-up',
                  'image': 'images/workouts/wall-push-up.gif',
                  'rep': '10'
                },
                {
                  'name': 'Knee Push-Ups',
                  'image': 'images/workouts/knee-push-up.gif',
                  'rep': '5'
                },
                {
                  'name': 'Incline Push-Ups',
                  'image': 'images/workouts/incline-push-up.gif',
                  'rep': '5'
                },
                {
                  'name': 'Knee Push-Ups',
                  'image': 'images/workouts/knee-push-up.gif',
                  'rep': '5'
                },
              ],
            );
          },
          '/intermediatechest': (context) => const intermediate(),
          '/advancechest': (context) => const Advancedchest(),
          '/beginnerarm': (context) => const beginner_armworkout(),

          '/beginnerbackandshoulder': (context) =>
              const beginnerbackandshoulder(),
          '/intermediatearm': (context) => const intermediate_armworkout(),
          '/advancedarm': (context) => const advanced_armworkout(),
          '/beginnerabs': (context) => const beginner_absworkout(),
          '/intermediateabs': (context) => const intermediate_absworkout(),
          '/intermediatebackandshoulder': (context) =>
              const intermediatebackandshoulder(),
          '/advanced_absworkout': (context) => const advanced_absworkout(),
          '/beginnerleg': (context) => const beginner_legworkout(),
          '/intermediateleg': (context) => const intermediate_legworkout(),
          '/advancedworkleg': (context) => const advanced_legworkout(),
          //   '/weghitloss': (context) => const weghitloss(),
          '/Advancedbackandshoulder': (context) =>
              const Advancedbackandshoulder(),
          '/acc': (context) => const Acc(),

          '/weightgain': (context) => const Weightgain(),
          '/skincare': (context) => const SkinCare(),
          //  '/calisthenics': (context) => const Calisthenics(),
          '/nutrition': (context) {
            final lang =
                Provider.of<LanguageProvider>(context).locale.languageCode;

            final pageTitle = lang == 'am' ? 'ምግብ ምርጫ' : 'Nutrition';
            final tabTitles = lang == 'am'
                ? ['የቀኑ ተደጋጋሚ እንቅስቃሴ', 'ከእንቅስቃሴ በፊት/በኋላ', 'ጤናማ ልምዶች']
                : ['Everyday Fitness', 'Pre/Post Workout', 'Healthy Habits'];

            return Nutrition(
              pageTitle: pageTitle,
              tabTitles: tabTitles,
              pages: [
                SkinCarePageData(
                  title: lang == 'am'
                      ? 'የቀኑ ተደጋጋሚ እንቅስቃሴ ምግብ'
                      : 'Everyday Fitness Nutrition',
                  description: lang == 'am'
                      ? 'በቀኑ ሁሉ የተመጣጠነ ምግብ በመብላት ኃይል፣ ጽናት እና ጤናዎን ይጠብቁ።'
                      : 'Maintain energy, stamina, and health with well-balanced meals throughout the day.',
                  image: 'images/discovery/nutrition.webp',
                  icon: Icons.directions_run,
                  tips: lang == 'am'
                      ? [
                          'ቀኑን በፕሮቲን የበለፀገ የቀን መጀመሪያ ምግብ ይጀምሩ።',
                          'በምግቦቻችሁ ውስጥ የተሟላ እህል፣ ፕሮቲን እና አትክልት ያካትቱ።',
                          'በቀኑ ሁሉ 5-6 ትንሽ ምግቦች ይብሉ።',
                          'አቅምዎን ለመጠበቅ በቀኑ 2-3 ሊትር ውሃ ይጠጡ።',
                          'Metabolism በትክክል እንዲሰራ ምግቦችን መተው ማይገባ ነው።',
                        ]
                      : [
                          'Start your day with a protein-rich breakfast.',
                          'Include whole grains, lean protein, and vegetables in meals.',
                          'Eat 5–6 small meals throughout the day.',
                          'Stay hydrated — aim for 2–3 liters of water daily.',
                          'Avoid skipping meals to maintain metabolism.',
                        ],
                ),
                SkinCarePageData(
                  title: lang == 'am'
                      ? 'ከእንቅስቃሴ በፊት/በኋላ ምግብ'
                      : 'Pre/Post Workout Nutrition',
                  description: lang == 'am'
                      ? 'እንቅስቃሴዎን ለማጎልበት እና ለመመለስ በተለየ ምግብ ይምጡ።'
                      : 'Fuel your workouts and support recovery with targeted nutrition before and after exercise.',
                  image: 'images/discovery/nutrition.webp',
                  icon: Icons.fitness_center,
                  tips: lang == 'am'
                      ? [
                          'ከእንቅስቃሴ 30-60 ደቂቃ በፊት በካርቦሃይድሬት የተባበሰ ትንሽ ምግብ ይብሉ።',
                          'ከእንቅስቃሴ በኋላ ፕሮቲን እና ካርቦሃይድሬት ያካትቱ።',
                          'ሙዝ ፣ ኦትስ  ወይም የግሪክ ዮጎርት እንደ እንቅስቃሴ ቀድሞ ትንሽ ምግብ ይሆናሉ።',
                          'ከእንቅስቃሴ በፊት፣ በመካከል እና በኋላ ውሃ ይጠጡ።',
                          'ከእንቅስቃሴ በፊት የተጨናነቀ ወይም ከባድ ምግብ አትብሉ።',
                        ]
                      : [
                          'Eat a small carb-based meal 30–60 mins before workouts.',
                          'Include protein and carbs in post-workout meals.',
                          'Bananas, oats, or Greek yogurt make great pre-workout snacks.',
                          'Drink water before, during, and after exercising.',
                          'Avoid high-fat or heavy meals right before training.',
                        ],
                ),
                SkinCarePageData(
                  title: lang == 'am'
                      ? 'ጤናማ የምግብ ልምዶች'
                      : 'Healthy Nutrition Habits',
                  description: lang == 'am'
                      ? 'በጥቅም ላይ በሚውሉ የምግብ ልምዶች ጤናዎን ያጠናክሩ።'
                      : 'Build long-term fitness with smart, sustainable nutrition habits.',
                  image: 'assets/images/healthy_habits.jpg',
                  icon: Icons.health_and_safety,
                  tips: lang == 'am'
                      ? [
                          'የምግብ መለያዎችን ያንብቡ እና መጠኑን ይቆጡ።',
                          'እንደ ተቆጣጠሩ እንዲሆኑ ብዙ ምግቦችን በቤት ይበሉ።',
                          'ከጭቃ ምግቦች ይቆጡ እና በአትክልት፣ በፍራፍሬ ወይም በዮጎርት ይቆዩ።',
                          'ስኳር ያለው መጠጥና የተሰራ ምግቦችን ያገድሉ።',
                          'ምግቦችዎን ተከታትሉ እንዲቀጥሉና እንዲረዱ ያደርጉ።',
                        ]
                      : [
                          'Read food labels and watch portion sizes.',
                          'Cook more meals at home to control ingredients.',
                          'Snack on nuts, fruits, or yogurt instead of junk food.',
                          'Limit sugary drinks and processed snacks.',
                          'Track your meals to stay consistent and accountable.',
                        ],
                ),
              ],
            );
          },

          '/fullbody': (context) => const fullbodybeginner(
                title: 'Full Body',
                backgroundImage: 'images/First three/full body/boy.webp',
                workouts: [
                  // Add additional days as needed
                ],
                messages: [
                  'Every Thing Has A Beginning',
                  'Consistency is Key',
                  'Push Your Limits',
                  'Push Your Limits',
                  // Add more messages for each day as needed
                ],
              ),
          '/Level': (context) => const Level(),
          '/link': (context) => TestLinkScreen(),

          '/butt': (context) => const ButtWorkout(),

          '/weghitloss': (context) => weghitloss(),
          '/feature': (context) => const Discovery(),

          '/gender': (context) => GenderSelectionPage(),

          '/quickpump': (context) => QuickPump(
                title: 'Quick Pump Workout',
                subtitle: 'Select type and begin',
                backgroundImage: 'images/discovery/quick pump.webp',
                workoutsByType: {
                  'Bodyweight': [
                    {
                      'name': 'Jumping Jacks',
                      'image': 'images/workouts/jumping-jack.gif',
                      'sec': '30 sec'
                    },
                    {
                      'name': 'Standard Push-Ups',
                      'image':
                          'images/workouts/push-up.gif', // Placeholder for Push-Ups GIF
                      'rep': '15'
                    },
                    {
                      'name':
                          'Knee Push-Ups', // Added a more basic push-up variation
                      'image':
                          'images/workouts/knee-push-up.gif', // Placeholder for Knee Push-Ups GIF
                      'rep': '15'
                    },
                    {
                      'name': 'Incline Push-Ups',
                      'image':
                          'images/workouts/incline-push-up.gif', // Placeholder for Incline Push-Ups GIF
                      'rep': '12'
                    },
                    {
                      'name': 'Diamond Push-Ups',
                      'image':
                          'images/workouts/diamond-push-up.gif', // Placeholder for Diamond Push-Ups GIF
                      'rep': '10'
                    },
                    {
                      'name': 'Triceps Dips (Chair)',
                      'image':
                          'images/workouts/triceps-dips.gif', // Placeholder for Triceps Dips GIF
                      'rep': '12'
                    },
                  ],
                  'Dumbbells': [
                    {
                      'name': 'Jumping Jacks',
                      'image': 'images/workouts/jumping-jack.gif',
                      'sec': '30 sec'
                    },
                    {
                      'name': 'Dumbbell Bench Press',
                      'image':
                          'images/workouts/db-bench-press.gif', // Placeholder for Dumbbell Bench Press GIF
                      'rep': '12'
                    },
                    {
                      'name': 'Dumbbell Bicep Curls',
                      'image':
                          'images/workouts/db-bicep-curl.gif', // Placeholder for Dumbbell Bicep Curls GIF
                      'rep': '12'
                    },
                    {
                      'name': 'Dumbbell Shoulder Press',
                      'image':
                          'images/workouts/db-shoulder.gif', // Placeholder for Dumbbell Shoulder Press GIF
                      'rep': '10'
                    },
                    {
                      'name': 'Dumbbell Triceps Extension (Overhead)',
                      'image':
                          'images/workouts/db-triceps-ext.gif', // Placeholder for Dumbbell Triceps Extension GIF
                      'rep': '10'
                    },
                    {
                      'name': 'Bent Over Dumbbell Row',
                      'image':
                          'images/workouts/Bent-Over-Dumbbell-Row.gif', // Placeholder for Dumbbell Bicep Curls GIF
                      'rep': '12'
                    },
                  ]
                },
              ),
          '/intro': (context) => IntroScreen(
                onDone: () {},
              ),
          '/bellyfat': (context) => BellyFat(),
          '/bicepsandchest': (context) => Bicepsandchest(),
          '/setting': (context) => SettingsPage(),

          '/re': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>;
            final workoutId = args['workoutId']!;
            return ReusableWorkoutPage2(workoutId: workoutId);
          },
        },
      );
    });
  }
}
