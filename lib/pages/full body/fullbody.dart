// Place this in lib/pages/full_body_beginner.dart (or the original full bodfuy.txt path)
// This is the modified version of your provided file.
import 'dart:io';
import 'dart:ui';
import 'dart:convert'; // Import for JSON decoding

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show rootBundle; // Import for loading assets
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

// Assuming these imports exist in your project structure
import 'package:etsport/pages/acc.dart';
import 'package:etsport/pages/firstpage.dart';
import 'package:etsport/pages/providers/break_provider.dart';
import 'package:etsport/pages/providers/level_provider.dart'; // Assuming ThemeProvider is here
// Place this in lib/services/supabase_service.dart

import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart'; // For better logging

int _selectedDay = 0;
int _completedDay = 0;

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches workout content from Supabase.
  Future<Map<String, List<List<Map<String, String>>>>>
      getWorkoutsContent() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from('workout_content')
          .select('level, day_index, exercises')
          .order('level', ascending: true)
          .order('day_index', ascending: true);

      Map<String, List<List<Map<String, String>>>> workouts = {};

      for (var row in response) {
        String levelName = row['level'];
        int dayIndex = row['day_index'];
        List<dynamic> exercisesRaw = row['exercises'] ?? [];

        workouts.putIfAbsent(levelName, () => []);

        while (workouts[levelName]!.length <= dayIndex) {
          workouts[levelName]!.add([]);
        }

        List<Map<String, String>> dayExercises = exercisesRaw
            .map((e) => Map<String, String>.from(e as Map<String, dynamic>))
            .toList();

        workouts[levelName]![dayIndex] = dayExercises;
      }

      developer.log('Supabase: Workout content fetched successfully.');
      return workouts;
    } catch (e) {
      developer.log('Supabase: Error fetching workout content: $e');
      return {};
    }
  }

  /// Save workout content to local file cache
  Future<void> saveWorkoutsToCache(
      Map<String, List<List<Map<String, String>>>> workouts) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/workout_cache.json');
      final jsonStr = jsonEncode(workouts);
      await file.writeAsString(jsonStr);
      developer.log('Cached workout data to local file.');
    } catch (e) {
      developer.log('Failed to save workout cache: $e');
    }
  }

  /// Load workout content from local file cache
  Future<Map<String, List<List<Map<String, String>>>>>
      loadCachedWorkouts() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/workout_cache.json');
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

        return decoded.map((key, value) {
          final dayList = List<List<Map<String, String>>>.from(
            value.map((day) => List<Map<String, String>>.from(
                  day.map((exercise) => Map<String, String>.from(exercise)),
                )),
          );
          return MapEntry(key, dayList);
        });
      }
    } catch (e) {
      developer.log('Failed to load cached workouts: $e');
    }
    return {};
  }
}

class ProgressService {
  ProgressService(); // No SupabaseService dependency in constructor

  // --- Selected Level Management ---

  /// Loads the selected level from SharedPreferences.
  Future<int> getSelectedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final localLevel = prefs.getInt('selectedLevel') ?? 0;
    developer.log(
        'ProgressService: Loaded selected level from SharedPreferences: $localLevel');
    return localLevel; // Default to 0 (Beginner)
  }

  /// Saves the selected level to SharedPreferences.
  Future<void> saveSelectedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedLevel', level);
    developer.log(
        'ProgressService: Saved selected level to SharedPreferences: $level');
  }

  // --- Completed Day Management ---

  /// Loads the completed day for a given level from SharedPreferences.
  Future<int> getCompletedDay(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final localDay = prefs.getInt('completedDay_level$level') ?? 0;
    developer.log(
        'ProgressService: Loaded completed day from SharedPreferences for level $level: $localDay');
    return localDay; // Default to 0
  }

  /// Saves the completed day for a given level to SharedPreferences.
  Future<void> saveCompletedDay(int level, int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completedDay_level$level', day);
    developer.log(
        'ProgressService: Saved completed day to SharedPreferences for level $level: $day');
  }

  // --- Reset Progress ---

  /// Resets all progress from SharedPreferences.
  Future<void> resetProgress(List<String> levelNames) async {
    final prefs = await SharedPreferences.getInstance();

    // Clear SharedPreferences
    await prefs.remove('selectedLevel');
    for (int i = 0; i < levelNames.length; i++) {
      await prefs.remove('completedDay_level$i');
    }
    developer.log('ProgressService: Cleared SharedPreferences progress.');
  }
}

class fullbodybeginner extends StatefulWidget {
  final String title;
  final String backgroundImage;
  final List<List<Map<String, String>>>
      workouts; // Kept for compatibility, now fetched
  final List<String> messages;

  const fullbodybeginner({
    super.key,
    required this.title,
    required this.backgroundImage,
    required this.workouts,
    required this.messages,
  });

  @override
  _WorkoutChallengePageState createState() => _WorkoutChallengePageState();
}

class _WorkoutChallengePageState extends State<fullbodybeginner> {
  int _lastCompletedDay = 0;
  late final PageController _pageController;

  int _selectedLevel = 0;

  final List<String> levelNames = ['Beginner', 'Intermediate', 'Advanced'];
  late final ProgressService _progress; // Initialize in initState
  late final SupabaseService
      _supabaseService; // NEW: SupabaseService for content

  Map<String, List<List<Map<String, String>>>>? _cachedWorkouts;

  @override
  void initState() {
    super.initState();
    // ProgressService now only uses SharedPreferences
    _progress = ProgressService();
    // Initialize SupabaseService for workout content
    _supabaseService = SupabaseService();

    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);

    _pageController = PageController(initialPage: (_selectedDay / 7).floor());
    _loadProgressAndSetInitialPage();
    _loadPreloadedWorkouts();
    _showLevelSheetIfFirstTime();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showLevelSheetIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('hasSeenLevelSheet') ?? false;
    if (!hasSeen) {
      // Wait for the first frame to ensure context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLevelSelectionSheet();
      });
      await prefs.setBool('hasSeenLevelSheet', true);
    }
  }

  Future<void> _loadProgressAndSetInitialPage() async {
    _selectedLevel = await _progress.getSelectedLevel();
    _completedDay = await _progress.getCompletedDay(_selectedLevel);
    setState(() {
      _selectedDay = _completedDay;
      _pageController.jumpToPage((_selectedDay / 7).floor());
    });
  }

  bool _isWeekCompleted(int weekIndex, int totalDays) {
    final startDay = weekIndex * 7;
    final endDay = ((startDay + 7) > totalDays) ? totalDays : (startDay + 7);
    for (int i = startDay; i < endDay; i++) {
      if (i >= _completedDay) return false;
    }
    return true;
  }

  Future<void> _loadPreloadedWorkouts() async {
    Map<String, List<List<Map<String, String>>>> workouts = {};

    workouts = await _supabaseService.getWorkoutsContent();
    if (workouts.isNotEmpty) {
      await _supabaseService.saveWorkoutsToCache(workouts);
    } else {
      workouts = await _supabaseService.loadCachedWorkouts();
      if (workouts.isNotEmpty) {
        print('Loaded workouts from local cache.');
      } else {
        try {
          final response = await rootBundle.loadString('assets/workouts.json');
          final data = json.decode(response) as Map<String, dynamic>;

          for (final level in ['beginner', 'intermediate', 'advanced']) {
            final daysMap =
                (data[level]?['days'] ?? {}) as Map<String, dynamic>;
            final sortedKeys = daysMap.keys.toList()
              ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
            final daysList = List<List<Map<String, String>>>.from(
              sortedKeys.map((key) {
                final dayExercises = daysMap[key] as List;
                return List<Map<String, String>>.from(
                  dayExercises.map((e) =>
                      Map<String, String>.from(e as Map<String, dynamic>)),
                );
              }),
            );
            workouts[level] = daysList;
          }
          print('Loaded workouts from bundled JSON.');
        } catch (e) {
          print('Failed to load bundled workouts: $e');
        }
      }
    }

    setState(() {
      _cachedWorkouts = workouts;
    });
  }

  // MODIFIED: This stream now tries to get data from Supabase first, then Firestore.
  Stream<Map<String, List<List<Map<String, String>>>>>
      streamFullBodyWorkouts() async* {
    // 1. Try fetching from Supabase first
    try {
      final supabaseWorkouts = await _supabaseService.getWorkoutsContent();
      if (supabaseWorkouts.isNotEmpty) {
        print('Using workout data from Supabase.');
        yield supabaseWorkouts; // Emit Supabase data
        return; // Stop here if Supabase data is successfully loaded
      }
    } catch (e) {
      print(
          'Error fetching workouts from Supabase: $e. Falling back to Firestore.');
    }

    // 2. Fallback to Firestore if Supabase fails or returns no data
    print('Using workout data from Firestore.');
    yield* FirebaseFirestore.instance
        .collection('workouts')
        .doc('full_body')
        .snapshots() // Use snapshots() for real-time updates from Firestore
        .map((doc) {
      if (!doc.exists) {
        print(
            'Firestore document "full_body" does not exist. Using cached or pre-loaded data.');
        return _cachedWorkouts ?? {}; // Return empty or existing cached
      }

      Map<String, List<List<Map<String, String>>>> result = {};
      for (final level in ['beginner', 'intermediate', 'advanced']) {
        final levelData = doc.data()?[level];
        if (levelData != null &&
            levelData is Map<String, dynamic> &&
            levelData.containsKey('days')) {
          final daysMap = levelData['days'] as Map<String, dynamic>;
          final sortedKeys = daysMap.keys.toList()
            ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

          final daysList = List<List<Map<String, String>>>.from(
            sortedKeys.map((key) {
              final dayExercises = daysMap[key] as List;
              return List<Map<String, String>>.from(
                dayExercises.map(
                    (e) => Map<String, String>.from(e as Map<String, dynamic>)),
              );
            }),
          );
          result[level] = daysList;
        } else {
          print(
              'Warning: No "days" data found for level: $level from Firestore.');
          result[level] = [];
        }
      }
      print('Firestore data updated and processed.');
      return result;
    }).handleError((error) {
      print('Error in Firestore stream: $error');
      return _cachedWorkouts ?? {};
    });
  }

  void _showWorkoutDetailDialog(
      BuildContext context, Map<String, String> workout) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: workout['image'] != null &&
                              (workout['image']!.startsWith('http') ||
                                  workout['image']!.startsWith('https'))
                          ? Image.network(
                              workout['image']!,
                              width: 300,
                              height: 240,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              workout['image'] ?? 'images/placeholder.png',
                              width: 300,
                              height: 280,
                              fit: BoxFit.cover,
                            ),
                    ),
                    // White box overlay at top left
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 100,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  workout['name'] ?? '',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (workout['rep'] != null && workout['rep']!.isNotEmpty)
                  Text(
                    ' ${workout['rep']}',
                    style:
                        GoogleFonts.poppins(fontSize: 18, color: Colors.green),
                  ),
                if (workout['sec'] != null && workout['sec']!.isNotEmpty)
                  Text(
                    '${workout['sec']} ',
                    style:
                        GoogleFonts.poppins(fontSize: 18, color: Colors.green),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onWorkoutComplete(int level, int dayIndex) {
    final levelKeys = ['beginner', 'intermediate', 'advanced'];
    final selectedLevelKey = levelKeys[_selectedLevel];
    final workoutsForLevel = _cachedWorkouts?[selectedLevelKey] ?? [];
    final totalDays = workoutsForLevel.length;

    // Prevent unlocking more days after the last day
    if (_completedDay >= totalDays - 1) {
      debugPrint("Already at the last day. No more days to unlock.");
      return;
    }

    if (dayIndex == _completedDay && _completedDay < totalDays - 1) {
      setState(() {
        _completedDay = _completedDay + 1;
        _selectedDay = _completedDay;
      });

      _progress.saveCompletedDay(_selectedLevel, _completedDay);

      final currentWeek = (_completedDay - 1) ~/ 7;
      if (_isWeekCompleted(currentWeek, totalDays) &&
          _completedDay < totalDays) {
        final nextPage = currentWeek + 1;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(nextPage);
        }
      }
    } else {
      debugPrint(
          "Workout completed but no new day unlocked or already unlocked.");
    }
  }

  void _resetProgress() async {
    await _progress.resetProgress(
        levelNames); // Use ProgressService's reset (SharedPreferences only)
    setState(() {
      _selectedLevel = 0;
      _selectedDay = 0;
      _completedDay = 0;
      _pageController.jumpToPage(0);
    });
  }

  void _showLevelSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 450,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Select Your Level",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        final savedCompletedDay = await _progress.getCompletedDay(
                            index); // Use ProgressService (SharedPreferences only)

                        setState(() {
                          _selectedLevel = index;
                          _selectedDay = savedCompletedDay;
                          _completedDay = savedCompletedDay;
                          _pageController
                              .jumpToPage((_selectedDay / 7).floor());
                        });

                        _progress.saveSelectedLevel(
                            index); // Use ProgressService (SharedPreferences only)
                        Navigator.pop(context);
                      },
                      child: Card(
                        color: _selectedLevel == index
                            ? Colors.blueAccent.shade700
                            : Colors.grey.shade900,
                        elevation: _selectedLevel == index ? 10 : 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _selectedLevel == index
                                ? Colors.blueAccent
                                : Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    levelNames[index],
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    index == 0
                                        ? '0–5 Push ups'
                                        : index == 1
                                            ? '5–10 Push ups'
                                            : 'Above 10 Push ups',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              if (_selectedLevel == index)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, List<List<Map<String, String>>>>>(
      stream: streamFullBodyWorkouts(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          _cachedWorkouts = snapshot.data;
        }

        if (_cachedWorkouts == null || _cachedWorkouts!.isEmpty) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Error fetching workouts: ${snapshot.error}");
            return Center(
                child: Text('Error loading workouts: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: Colors.white)));
          }
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.white70),
                  const SizedBox(height: 16),
                  Text(
                    'No Internet Connection',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This section requires a one-time internet connection to load its content.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final workoutsByLevel = _cachedWorkouts!;
        final levelKeys = ['beginner', 'intermediate', 'advanced'];
        final selectedLevelKey = levelKeys[_selectedLevel];

        final workoutsForSelectedLevel =
            workoutsByLevel[selectedLevelKey] ?? [];
        final totalDaysInSelectedLevel = workoutsForSelectedLevel.length;

        _selectedDay = _selectedDay.clamp(
            0, totalDaysInSelectedLevel > 0 ? totalDaysInSelectedLevel - 1 : 0);
        _completedDay = _completedDay.clamp(
            0, totalDaysInSelectedLevel > 0 ? totalDaysInSelectedLevel : 0);

        final selectedWorkouts = (totalDaysInSelectedLevel > 0 &&
                _selectedDay < totalDaysInSelectedLevel)
            ? workoutsForSelectedLevel[_selectedDay]
            : <Map<String, String>>[];
        final isRestDay = [7, 14, 21, 28].contains(_selectedDay + 1);
        return Scaffold(
          appBar: PreferredSize(
            preferredSize:
                Size.fromHeight(MediaQuery.of(context).size.height * 0.15),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom:
                    Radius.circular(MediaQuery.of(context).size.height * 0.025),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.backgroundImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                    child: Container(
                      color: Colors.black.withOpacity(0.35),
                    ),
                  ),
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
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white),
                    leading: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.04,
                        top: MediaQuery.of(context).size.height * 0.015,
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.025),
                          child:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ),
                    actions: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'reset') {
                            _resetProgress();
                          } else if (value == 'levelup') {
                            _showLevelSelectionSheet();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                              value: 'reset', child: Text('Reset Progress')),
                          PopupMenuItem(
                              value: 'levelup', child: Text('Change Level')),
                        ],
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ],
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.08,
                    bottom: MediaQuery.of(context).size.height * 0.025,
                    child: Text(
                      '${levelNames[_selectedLevel]} - ${totalDaysInSelectedLevel - _completedDay} days left',
                      style: GoogleFonts.poppins(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            blurRadius: 6.0,
                            color: Colors.black54,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 130,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: (30 / 7.0).ceil(),
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _selectedDay = pageIndex * 7;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    final startDay = pageIndex * 7;
                    final endDay = (startDay + 7).clamp(0, 30);
                    final isEndOfWeek = (_completedDay % 7 == 0);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Week ${pageIndex + 1}',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '${_completedDay}/30',
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:
                                List.generate(endDay - startDay, (dayOffset) {
                              final dayIndex = startDay + dayOffset;
                              final isCompleted = dayIndex < _completedDay;
                              final isCurrent = dayIndex == _completedDay;
                              final isUnlocked = dayIndex <= _completedDay;
                              final isRestDay =
                                  [7, 14, 21, 28].contains(_selectedDay + 1);

                              Widget dayCircle = Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompleted
                                      ? Colors.greenAccent.shade700
                                      : isCurrent
                                          ? Colors.white
                                          : Colors.grey.shade200,
                                  border: Border.all(
                                    color: isCurrent
                                        ? Colors.green
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: isCurrent
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.green.withOpacity(0.4),
                                            blurRadius: 6,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: isCompleted
                                      ? Icon(Icons.check,
                                          color: Colors.white, size: 20)
                                      : Text(
                                          '${dayIndex + 1}',
                                          style: GoogleFonts.poppins(
                                            color: isUnlocked
                                                ? Colors.black
                                                : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              );

                              return GestureDetector(
                                onTap: isUnlocked
                                    ? () {
                                        setState(() {
                                          _selectedDay = dayIndex;
                                        });
                                      }
                                    : null,
                                child: dayCircle,
                              );
                            }),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                child: Text(
                  'Day ${_selectedDay + 1} Workout • ${selectedWorkouts.length} exercises',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                  child: isRestDay
                      ? Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.self_improvement_rounded,
                                color: Colors.white),
                            label: Text(
                              "Take Rest",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 36, vertical: 20),
                              elevation: 10,
                              backgroundColor: Colors.blue.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              shadowColor: Colors.green.withOpacity(0.3),
                            ),
                            onPressed: _selectedDay <= _completedDay
                                ? () {
                                    _onWorkoutComplete(
                                        _selectedLevel, _selectedDay);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Rest day completed!"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.02,
                          ),
                          itemCount: selectedWorkouts.length,
                          itemBuilder: (context, index) {
                            final workout = selectedWorkouts[index];
                            final themeProvider =
                                Provider.of<ThemeProvider>(context);
                            final isDark = themeProvider.isDarkMode;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.02,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _showWorkoutDetailDialog(context, workout);
                                },
                                child: Card(
                                  elevation: 10,
                                  color: isDark
                                      ? const Color(0xFF232323)
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadowColor: isDark
                                      ? Colors.greenAccent.withOpacity(0.10)
                                      : Colors.green.withOpacity(0.25),
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: isDark
                                          ? null
                                          : LinearGradient(
                                              colors: [
                                                Colors.white,
                                                Colors.green.shade50
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                      color: isDark
                                          ? const Color(0xFF232323)
                                          : null,
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.asset(
                                                workout['image']!,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              child: Container(
                                                width: 25,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                workout['name']!,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  if (workout['rep'] != null &&
                                                      workout['rep']!
                                                          .isNotEmpty) ...[
                                                    Text(
                                                      '',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      workout['rep']!,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.green,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                  if (workout['sec'] != null &&
                                                      workout['sec']!
                                                          .isNotEmpty) ...[
                                                    if (workout['rep'] !=
                                                            null &&
                                                        workout['rep']!
                                                            .isNotEmpty)
                                                      const Text(' • ',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: 18)),
                                                    const Icon(
                                                        Icons.timer_rounded,
                                                        color: Colors.green,
                                                        size: 16),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      workout['sec']!,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.green,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
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
                          separatorBuilder: (_, __) => SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015),
                        )),
              if (!isRestDay)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedDay <= _completedDay
                          ? () {
                              setState(() {});
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkoutScreen(
                                    workouts: selectedWorkouts,
                                    onWorkoutComplete:
                                        (int completedExerciseIndex) {
                                      _onWorkoutComplete(
                                          _selectedLevel, _selectedDay);
                                    },
                                    workoutId:
                                        'level_${_selectedLevel}_day_${_selectedDay}',
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedDay <= _completedDay
                            ? Colors.greenAccent.shade700
                            : Colors.grey.shade300,
                        elevation: 10,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: Colors.black45,
                        textStyle: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(
                        'GO!',
                        style: GoogleFonts.poppins(
                          color: _selectedDay <= _completedDay
                              ? Colors.white
                              : Colors.black26,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class WorkoutScreen extends StatefulWidget {
  final List<Map<String, String>> workouts;
  final Function(int) onWorkoutComplete;
  final String workoutId;

  const WorkoutScreen({
    super.key,
    required this.workouts,
    required this.onWorkoutComplete,
    required this.workoutId,
  });

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class RoundedCropClipper extends CustomClipper<Path> {
  final double borderRadius;
  final double topCrop;

  RoundedCropClipper({required this.borderRadius, required this.topCrop});

  @override
  Path getClip(Size size) {
    final path = Path();

    final width = size.width;
    final height = size.height;

    path.moveTo(0, topCrop + borderRadius);
    path.quadraticBezierTo(0, topCrop, borderRadius, topCrop);
    path.lineTo(width - borderRadius, topCrop);
    path.quadraticBezierTo(width, topCrop, width, topCrop + borderRadius);
    path.lineTo(width, height - borderRadius);
    path.quadraticBezierTo(width, height, width - borderRadius, height);
    path.lineTo(borderRadius, height);
    path.quadraticBezierTo(0, height, 0, height - borderRadius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _countdown = 0;
  final int _readyCountdown = 7;
  bool _isBreak = false;
  bool _isGettingReady = true;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _donebutton = false;
  bool _isPaused = false;
  bool _nextButtonClicked = false;
  bool _previousButtonClicked = false;
  final Stopwatch _workoutTimer = Stopwatch();

  bool _isCurrentWorkoutSecBased = false;
  int _currentWorkoutOriginalTime = 0;

  static const String _prefCurrentIndexKey = '_currentIndex';
  static const String _prefCountdownKey = '_countdown';
  static const String _prefIsSecBasedKey = '_isSecBased';
  static const String _prefIsGettingReadyKey = '_isGettingReady';
  static const String _prefIsBreakKey = '_isBreak';
  static const String _prefIsPausedKey = '_isPaused';

  String? googleDriveDirectUrl(String url) {
    final regex = RegExp(r'https://drive\.google\.com/file/d/([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    return null;
  }

  Widget buildWorkoutImage(Map<String, dynamic> workout) {
    final parsedImageUrl = workout['parsedImageUrl']?.toString();
    final imageUrl = workout['image']?.toString();

    if (parsedImageUrl != null && parsedImageUrl.startsWith('http')) {
      return Image(
        image: CachedNetworkImageProvider(parsedImageUrl),
        fit: BoxFit.cover,
        width: 340,
        height: 320,
      );
    } else if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image(
        image: CachedNetworkImageProvider(imageUrl),
        fit: BoxFit.cover,
        width: 340,
        height: 320,
      );
    } else {
      return Image.asset(
        imageUrl ?? 'images/placeholder.png',
        fit: BoxFit.cover,
        width: 340,
        height: 320,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _workoutTimer.start();

    _loadWorkoutStateAndShowDialog();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _workoutTimer.stop();
    WidgetsBinding.instance.removeObserver(this);
    _saveWorkoutState();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveWorkoutState();
    }
  }

  String _getUniqueWorkoutKey(String keySuffix) {
    return '${widget.workoutId}_$keySuffix';
  }

  Future<void> _saveWorkoutState() async {
    final prefs = await SharedPreferences.getInstance();
    if (widget.workouts.isNotEmpty && _currentIndex < widget.workouts.length) {
      await prefs.setInt(
          _getUniqueWorkoutKey(_prefCurrentIndexKey), _currentIndex);
      await prefs.setInt(_getUniqueWorkoutKey(_prefCountdownKey), _countdown);
      await prefs.setBool(
          _getUniqueWorkoutKey(_prefIsSecBasedKey), _isCurrentWorkoutSecBased);
      await prefs.setBool(
          _getUniqueWorkoutKey(_prefIsGettingReadyKey), _isGettingReady);
      await prefs.setBool(_getUniqueWorkoutKey(_prefIsBreakKey), _isBreak);
      await prefs.setBool(_getUniqueWorkoutKey(_prefIsPausedKey), _isPaused);
      print(
          'Workout state saved: index=$_currentIndex, countdown=$_countdown, isSecBased=$_isCurrentWorkoutSecBased, isGettingReady=$_isGettingReady, isBreak=$_isBreak, isPaused=$_isPaused');
    } else {
      _clearWorkoutState();
    }
  }

  Future<Map<String, dynamic>?> _loadWorkoutState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_getUniqueWorkoutKey(_prefCurrentIndexKey));

    if (savedIndex != null) {
      final savedCountdown =
          prefs.getInt(_getUniqueWorkoutKey(_prefCountdownKey)) ?? 0;
      final savedIsSecBased =
          prefs.getBool(_getUniqueWorkoutKey(_prefIsSecBasedKey)) ?? false;
      final savedIsGettingReady =
          prefs.getBool(_getUniqueWorkoutKey(_prefIsGettingReadyKey)) ?? true;
      final savedIsBreak =
          prefs.getBool(_getUniqueWorkoutKey(_prefIsBreakKey)) ?? false;
      final savedIsPaused =
          prefs.getBool(_getUniqueWorkoutKey(_prefIsPausedKey)) ?? false;
      print(
          'Workout state loaded: index=$savedIndex, countdown=$savedCountdown, isSecBased=$savedIsSecBased, isGettingReady=$savedIsGettingReady, isBreak=$savedIsBreak, isPaused=$savedIsPaused');
      return {
        'index': savedIndex,
        'countdown': savedCountdown,
        'isSecBased': savedIsSecBased,
        'isGettingReady': savedIsGettingReady,
        'isBreak': savedIsBreak,
        'isPaused': savedIsPaused,
      };
    }
    return null;
  }

  Future<void> _clearWorkoutState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getUniqueWorkoutKey(_prefCurrentIndexKey));
    await prefs.remove(_getUniqueWorkoutKey(_prefCountdownKey));
    await prefs.remove(_getUniqueWorkoutKey(_prefIsSecBasedKey));
    await prefs.remove(_getUniqueWorkoutKey(_prefIsGettingReadyKey));
    await prefs.remove(_getUniqueWorkoutKey(_prefIsBreakKey));
    await prefs.remove(_getUniqueWorkoutKey(_prefIsPausedKey));
    print('Workout state cleared.');
  }

  Future<void> _loadWorkoutStateAndShowDialog() async {
    final savedState = await _loadWorkoutState();
    if (savedState != null) {
      final savedIndex = savedState['index'] as int;
      final totalWorkouts = widget.workouts.length;
      final halfWorkoutsThreshold = (totalWorkouts / 2).floor();

      if (savedIndex >= 0 &&
          savedIndex < totalWorkouts &&
          savedIndex >= halfWorkoutsThreshold &&
          savedIndex < totalWorkouts - 1) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                'Continue Workout?',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Do you want to continue your previous workout from where you left off?',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Restart',
                      style: GoogleFonts.poppins(color: Colors.redAccent)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restartWorkout();
                  },
                ),
                TextButton(
                  child: Text('Continue',
                      style: GoogleFonts.poppins(color: Colors.greenAccent)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _continueWorkout(savedState);
                  },
                ),
              ],
            );
          },
        );
      } else {
        _clearWorkoutState();
        _startInitialCountdown();
      }
    } else {
      _startInitialCountdown();
    }
  }

  void _continueWorkout(Map<String, dynamic> savedState) {
    setState(() {
      _currentIndex = savedState['index'];
      _countdown = savedState['countdown'];
      _isCurrentWorkoutSecBased = savedState['isSecBased'];
      _isGettingReady = savedState['isGettingReady'];
      _isBreak = savedState['isBreak'];
      _isPaused = savedState['isPaused'];

      if (_isCurrentWorkoutSecBased && _currentIndex < widget.workouts.length) {
        String secValue = widget.workouts[_currentIndex]['sec']!;
        _currentWorkoutOriginalTime =
            int.tryParse(secValue.replaceAll(' sec', '')) ?? 0;
      }
    });
    if (_isPaused) {
      print('Workout resumed in paused state. User needs to press play.');
      _timer?.cancel();
    } else if (_isGettingReady || _isBreak || _isCurrentWorkoutSecBased) {
      _resumeCountdown();
    } else {
      _donebutton = true;
    }
  }

  /* Future<void> _playAudio(String assetPath) async {
    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }
*/
  Future<void> _playAudio(String assetPath) async {
    try {
      await _audioPlayer.stop(); // Stop if something is already playing
      print("DEBUG: Attempting to play audio from path: '$assetPath'");
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
  }

  void _startInitialCountdown() {
    _timer?.cancel();
    setState(() {
      _isGettingReady = true;
      _isBreak = false;
      _countdown = _readyCountdown;
      _donebutton = false;
      _isPaused = false;
    });
    _playAudio('audio/getready.mp3');

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (_countdown > 0) {
          setState(() {
            _countdown--;
            if (_countdown == 3) {
              _playAudio('audio/bleep.mp3');
            }
          });
        } else {
          _timer?.cancel();
          setState(() {
            _isGettingReady = false;
          });
          _startWorkoutLogic();
        }
      }
    });
  }

  void _startWorkoutLogic() {
    _timer?.cancel();

    if (_currentIndex >= widget.workouts.length) {
      print(
          'DEBUG: _startWorkoutLogic: All exercises completed. Calling _doneWorkout.');
      _doneWorkout();
      return;
    }

    final currentWorkout = widget.workouts[_currentIndex];
    _isCurrentWorkoutSecBased = currentWorkout.containsKey('sec');

    if (currentWorkout.containsKey('audio') &&
        currentWorkout['audio'] != null) {
      _playAudio(currentWorkout['audio']!);
    } else {
      print("No audio specified for workout: ${currentWorkout['name']}");
    }

    if (_isCurrentWorkoutSecBased) {
      String secValue = currentWorkout['sec']!;
      _currentWorkoutOriginalTime =
          int.tryParse(secValue.replaceAll(' sec', '')) ?? 0;

      if (!_isPaused ||
          (_isPaused && _countdown <= 0 && _currentWorkoutOriginalTime > 0)) {
        setState(() {
          _countdown = _currentWorkoutOriginalTime;
          _donebutton = false;
        });
      } else {
        setState(() {
          _donebutton = false;
        });
      }

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isPaused) {
          if (_countdown > 0) {
            setState(() {
              _countdown--;
              if (_countdown == 3 || _countdown == 2 || _countdown == 1) {
                _playAudio('audio/bleep.mp3');
              }
            });
          } else {
            _timer?.cancel();
            _playAudio('audio/bleep.mp3');
            print(
                'DEBUG: _startWorkoutLogic: Timed workout $_currentIndex finished. Calling _doneWorkout.');
            _doneWorkout();
          }
        }
      });
    } else {
      setState(() {
        _donebutton = true;
        _countdown = 0;
      });
    }
  }

  void _skipBreak() {
    _timer?.cancel();
    _stopAudio();

    setState(() {
      _isBreak = false;
      _isGettingReady = true;
      _countdown = _readyCountdown;
      _nextButtonClicked = false;
      _previousButtonClicked = false;
      _isPaused = false;
    });
    _startInitialCountdown();
  }

  void _extendBreak() {
    setState(() {
      _countdown += 20;
    });
  }

  void _doneWorkout() {
    _timer?.cancel();
    _stopAudio();

    if (_currentIndex < widget.workouts.length - 1) {
      final breakProvider = Provider.of<BreakProvider>(context, listen: false);
      setState(() {
        _currentIndex++;
        _isBreak = true;
        _countdown = breakProvider.breakSeconds;
        _donebutton = false;
        _isPaused = false;
      });
      _playAudio('audio/takeabreak.mp3');

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isPaused) {
          if (_countdown > 0) {
            setState(() {
              _countdown--;
              if (_countdown == 3) {
                _playAudio('audio/bleep.mp3');
              }
            });
          } else {
            timer.cancel();
            setState(() {
              _isBreak = false;
              _isGettingReady = true;
              _countdown = _readyCountdown;
              _donebutton = false;
            });
            _startInitialCountdown();
          }
        }
      });
    } else {
      print('DEBUG: _doneWorkout: All exercises in workout session completed.');
      _workoutTimer.stop();
      Duration elapsedTime = _workoutTimer.elapsed;

      widget.onWorkoutComplete(_currentIndex);

      _clearWorkoutState();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutCompleteScreen(
            workouts: widget.workouts,
            elapsedTime: elapsedTime,
            onRestart: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutScreen(
                    workouts: widget.workouts,
                    onWorkoutComplete: (completedIndex) {},
                    workoutId: widget.workoutId,
                  ),
                ),
              );
            },
            onCompleteWorkout: () {},
            onWorkoutComplete: () {},
          ),
        ),
      );
    }
  }

  void _pauseOrPlayWorkout() {
    setState(() {
      _isPaused = !_isPaused;
      if (!_isPaused) {
        if (_isGettingReady || _isBreak || _isCurrentWorkoutSecBased) {
          _resumeCountdown();
        }
      } else {
        _timer?.cancel();
        _stopAudio();
      }
    });
  }

  void _resumeCountdown() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (_countdown > 0) {
          setState(() {
            _countdown--;
            if (_countdown == 3 || _countdown == 2 || _countdown == 1) {
              _playAudio('audio/bleep.mp3');
            }
          });
        } else {
          timer.cancel();
          if (_isGettingReady) {
            setState(() {
              _isGettingReady = false;
            });
            _startWorkoutLogic();
          } else if (_isBreak) {
            _doneWorkout();
          } else if (_isCurrentWorkoutSecBased) {
            _playAudio('audio/bleep.mp3');
            _doneWorkout();
          }
        }
      }
    });
  }

  void _nextWorkout() async {
    _timer?.cancel();
    _stopAudio();
    _donebutton = false;

    if (_currentIndex < widget.workouts.length - 1) {
      final breakProvider = Provider.of<BreakProvider>(context, listen: false);
      setState(() {
        _currentIndex++;
        _isBreak = true;
        _countdown = breakProvider.breakSeconds;
        _nextButtonClicked = true;
        _isPaused = false;
      });

      _playAudio('audio/takeabreak.mp3'); // <-- Make sure this is here!

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isPaused) {
          if (_countdown > 0) {
            setState(() {
              _countdown--;
              if (_countdown == 3) {
                _playAudio('audio/bleep.mp3');
              }
            });
          } else {
            timer.cancel();
            setState(() {
              _isGettingReady = true;
              _isBreak = false;
              _countdown = _readyCountdown;
              _nextButtonClicked = false;
            });
            _startInitialCountdown();
          }
        }
      });
    } else {
      _workoutTimer.stop();
      Duration elapsedTime = _workoutTimer.elapsed;
      widget.onWorkoutComplete(_currentIndex);
      await _clearWorkoutState();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutCompleteScreen(
            onRestart: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutScreen(
                    workouts: widget.workouts,
                    onWorkoutComplete: (completedIndex) {},
                    workoutId: widget.workoutId,
                  ),
                ),
              );
            },
            workouts: widget.workouts,
            elapsedTime: elapsedTime,
            onCompleteWorkout: () {},
            onWorkoutComplete: () {},
          ),
        ),
      );
    }
  }

  void _previousWorkout() {
    if (_currentIndex == 0) {
      return;
    }

    _timer?.cancel();
    _stopAudio();
    _donebutton = false;

    final breakProvider = Provider.of<BreakProvider>(context, listen: false);
    setState(() {
      _currentIndex--;
      _isBreak = true;
      _countdown = breakProvider.breakSeconds;
      _previousButtonClicked = true;
      _nextButtonClicked = false;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (_countdown > 0) {
          setState(() {
            _countdown--;
            if (_countdown == 3) {
              _playAudio('audio/bleep.mp3');
            }
          });
        } else {
          timer.cancel();
          setState(() {
            _isGettingReady = true;
            _isBreak = false;
            _countdown = _readyCountdown;
            _previousButtonClicked = false;
          });
          _startInitialCountdown();
        }
      }
    });
  }

  void _restartWorkout() {
    _clearWorkoutState();
    setState(() {
      _currentIndex = 0;
      _isGettingReady = true;
      _isBreak = false;
      _countdown = _readyCountdown;
      _isPaused = false;
    });
    _startInitialCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (widget.workouts.isEmpty || _currentIndex >= widget.workouts.length) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No workout data available or invalid index.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      );
    }

    final workout = widget.workouts[_currentIndex];
    final isSecBased = workout.containsKey('sec');
    final isRepBased = workout.containsKey('rep');
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 4,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Workout',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
      ),
      body: Container(
        color: isDark ? Colors.black : Colors.white,
        width: screenWidth,
        height: screenHeight,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.05),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black54 : Colors.white,
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 340,
                              height: 320,
                              color: Colors.black,
                              child: Center(
                                child: Stack(
                                  children: [
                                    // Conditional image display
                                    buildWorkoutImage(
                                        workout), // <-- Call the function here

                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Container(
                                        width: 105,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: screenHeight * 0.02,
                          right: screenWidth * 0.025,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.006,
                              horizontal: screenWidth * 0.035,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentIndex + 1}/${widget.workouts.length}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    if (!_isBreak)
                      Text(
                        workout['name']!,
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: screenWidth * 0.065,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      _isGettingReady
                          ? 'Getting Ready!'
                          : _isBreak
                              ? 'Break Time!'
                              : 'Workout Time!',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w600,
                        color: Colors.greenAccent,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    if (_isGettingReady || _isBreak)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            child: CircularProgressIndicator(
                              value: _countdown /
                                  (_isGettingReady
                                      ? _readyCountdown
                                      : Provider.of<BreakProvider>(context)
                                          .breakSeconds),
                              strokeWidth: 8,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.greenAccent),
                            ),
                          ),
                          Text(
                            '$_countdown',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      )
                    else if (isSecBased)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            child: CircularProgressIndicator(
                              value: (_currentWorkoutOriginalTime > 0)
                                  ? (_countdown / _currentWorkoutOriginalTime)
                                  : 0,
                              strokeWidth: 8,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.greenAccent),
                            ),
                          ),
                          Text(
                            '$_countdown',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      )
                    else if (isRepBased)
                      Text(
                        ' ${workout['rep']!}',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    SizedBox(height: screenHeight * 0.025),
                    if (_donebutton &&
                        isRepBased &&
                        !(_isGettingReady || _isBreak))
                      ElevatedButton(
                        onPressed: _donebutton ? _doneWorkout : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade700,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                              vertical: screenHeight * 0.015),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Done',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_isBreak)
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenHeight * 0.02, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _skipBreak,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.06,
                                    vertical: screenHeight * 0.015),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Skip Break",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _extendBreak,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.05,
                                    vertical: screenHeight * 0.015),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Add 20 Seconds',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w500,
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
            Container(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.015,
                horizontal: screenWidth * 0.06,
              ),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(screenWidth * 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black38 : Colors.white60,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentIndex == 0 ? null : _previousWorkout,
                    icon: Icon(
                      Icons.arrow_back,
                      color: (_currentIndex == 0 && !isDark)
                          ? Colors.grey
                          : isDark
                              ? Colors.white
                              : Colors.black38,
                    ),
                    iconSize: screenWidth * 0.08,
                  ),
                  IconButton(
                    onPressed: _pauseOrPlayWorkout,
                    icon: Icon(
                      _isPaused ? Icons.play_arrow : Icons.pause,
                      color: isDark ? Colors.white : Colors.black38,
                    ),
                    iconSize: screenWidth * 0.09,
                  ),
                  IconButton(
                    onPressed: _currentIndex == widget.workouts.length - 1
                        ? null
                        : _nextWorkout,
                    icon: Icon(
                      Icons.arrow_forward,
                      color: (_currentIndex == widget.workouts.length - 1 &&
                              !isDark)
                          ? Colors.grey
                          : isDark
                              ? Colors.white
                              : Colors.black38,
                    ),
                    iconSize: screenWidth * 0.08,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutCompleteScreen extends StatefulWidget {
  final VoidCallback onRestart;
  final VoidCallback onCompleteWorkout;
  final Duration elapsedTime;
  final VoidCallback onWorkoutComplete;
  final List<Map<String, String>> workouts;

  const WorkoutCompleteScreen({
    super.key,
    required this.onRestart,
    required this.onCompleteWorkout,
    required this.workouts,
    required this.elapsedTime,
    required this.onWorkoutComplete,
  });

  @override
  _WorkoutCompleteScreenState createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  int _selectedLevel = 0;

  bool _workoutMarkedComplete = false;

  final ScreenshotController _screenshotController = ScreenshotController();
  late final ProgressService _progress;

  @override
  void initState() {
    super.initState();
    // ProgressService initialized without SupabaseService
    _progress = ProgressService();
    _initializeProgress();
  }

  Future<void> _initializeProgress() async {
    _selectedLevel = await _progress.getSelectedLevel();
    _completedDay = await _progress.getCompletedDay(_selectedLevel);

    setState(() {
      _selectedDay = _completedDay;
    });
  }

  Future<void> _shareWorkoutCompletion() async {
    try {
      final image = await _screenshotController.capture();

      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = File('${directory.path}/workout_completion.png');
        await imagePath.writeAsBytes(image);

        final String formattedTime = _formatDuration(widget.elapsedTime);
        final String message =
            "🥳 I just completed my workout in $formattedTime! #WorkoutComplete #FitnessJourney";

        await Share.shareXFiles([XFile(imagePath.path)], text: message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to capture screenshot. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error sharing screenshot: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error sharing achievement: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_workoutMarkedComplete) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
              const SizedBox(width: 12),
              Text(
                'Complete Workout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          content: Text(
            'You have not marked the workout complete yet.\nAre you sure you want to leave?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.4,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Stay',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 6,
                shadowColor: Colors.deepOrange.withOpacity(0.4),
              ),
              child: Text(
                'Leave',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
      return leave ?? false;
    }
    return true;
  }

  void _markWorkoutComplete() async {
    setState(() {
      _workoutMarkedComplete = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Workout completed for Day ${_selectedDay + 1}!"),
        backgroundColor: Colors.green,
      ),
    );

    widget.onWorkoutComplete();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const firstpage1()),
      (_) => false,
    );
  }

  Widget _buildButton(BuildContext context,
      {required IconData icon,
      required String text,
      required Color color,
      required double width,
      required VoidCallback onTap}) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 22),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: color.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, double width) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        _buildButton(
          context,
          icon: Icons.refresh,
          text: "Restart Workout",
          color: Colors.orangeAccent,
          width: screenSize.width * 0.70,
          onTap: () {
            Navigator.pop(context);
            widget.onRestart();
          },
        ),
        SizedBox(height: screenSize.height * 0.01),
        _buildButton(
          context,
          icon: Icons.share,
          text: "Share Achievement",
          color: Colors.blueAccent,
          width: screenSize.width * 0.70,
          onTap: _shareWorkoutCompletion,
        ),
        const SizedBox(height: 16),
        _buildButton(
          context,
          icon: Icons.check_circle,
          text: "Mark Workout Complete",
          color: Colors.green,
          width: screenSize.width * 0.85,
          onTap: _markWorkoutComplete,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final screenSize = MediaQuery.of(context).size;
    final paddingHorizontal = screenSize.width * 0.05;
    final maxWidth = 600.0;

    final bgColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final cardBgColor = isDark ? Colors.grey[850] : Colors.white;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    String formattedTime = _formatDuration(widget.elapsedTime);
    int displayDay = _selectedDay + 1;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final containerWidth = constraints.maxWidth * 0.9 > maxWidth
                    ? maxWidth
                    : constraints.maxWidth * 0.9;
                final buttonWidth = containerWidth;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Screenshot(
                      controller: _screenshotController,
                      child: Container(
                        width: containerWidth,
                        padding: EdgeInsets.symmetric(
                          horizontal: paddingHorizontal,
                          vertical: screenSize.height * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(24),
                          /* boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black45
                                  : Colors.grey.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],*/
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'images/logo.png',
                                width: width * 0.4,
                                height: width * 0.4,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.03),
                            Text(
                              "Awesome Work! 💪",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: screenSize.width * 0.08 > 32
                                    ? 32
                                    : screenSize.width * 0.08,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.015),
                            Text(
                              "You’ve successfully completed your workout!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: screenSize.width * 0.045 > 17
                                    ? 17
                                    : screenSize.width * 0.045,
                                fontWeight: FontWeight.w400,
                                color: subtitleColor,
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            Column(
                              children: [
                                Text(
                                  "Day ${displayDay - 1} ( Complete)",
                                  style: GoogleFonts.poppins(
                                    fontSize: screenSize.width * 0.06 > 22
                                        ? 22
                                        : screenSize.width * 0.06,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.teal,
                                  ),
                                ),
                                SizedBox(height: screenSize.height * 0.015),
                                Text(
                                  "Time: $formattedTime",
                                  style: GoogleFonts.poppins(
                                    fontSize: screenSize.width * 0.05 > 18
                                        ? 18
                                        : screenSize.width * 0.05,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.04),
                    _buildActionButtons(context, buttonWidth),
                    SizedBox(height: screenSize.height * 0.02),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
