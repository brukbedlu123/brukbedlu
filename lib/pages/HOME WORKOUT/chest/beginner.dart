import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:etsport/pages/acc.dart';
import 'package:etsport/pages/firstpage.dart';
import 'package:etsport/pages/providers/break_provider.dart';
import 'package:etsport/pages/providers/level_provider.dart';
import 'package:etsport/widgets/gender.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ReusableWorkoutPage(
        title: '',
        subtitle: '',
        backgroundImage: '',
        workouts: [],
      ),
    );
  }
}

class ReusableWorkoutPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String backgroundImage;
  final List<Map<String, String>> workouts;

  const ReusableWorkoutPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundImage,
    required this.workouts,
  });

  @override
  _ReusableWorkoutPageState createState() => _ReusableWorkoutPageState();
}

class _ReusableWorkoutPageState extends State<ReusableWorkoutPage> {
  void _startWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(
          workouts: widget.workouts,
          onWorkoutComplete: (completedIndex) {
            // Handle workout complete logic if necessary
          },
          workoutId: '',
        ),
      ),
    );
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
                    'x ${workout['rep']}',
                    style:
                        GoogleFonts.poppins(fontSize: 18, color: Colors.green),
                  ),
                if (workout['sec'] != null && workout['sec']!.isNotEmpty)
                  Text(
                    '${workout['sec']} sec',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.15),
        child: ClipRRect(
          child: Stack(
            children: [
              // Background Image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.backgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),

              // Transparent AppBar with Back Button
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.055,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              // Title Positioned at Bottom
              Positioned(
                left: MediaQuery.of(context).size.width * 0.09,
                bottom: MediaQuery.of(context).size.height * 0.025,
                child: Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.058,
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(
                        blurRadius: 6.0,
                        color: Colors.black54,
                        offset: Offset(0, 2),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.015,
              horizontal: MediaQuery.of(context).size.width * 0.06,
            ),
            child: Center(
              child: Text(
                widget.subtitle,
                style: GoogleFonts.poppins(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: MediaQuery.of(context).size.width * 0.048,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final themeProvider = Provider.of<ThemeProvider>(context);
                final isDark = themeProvider.isDarkMode;
                return ListView.separated(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.02,
                  ),
                  itemCount: widget.workouts.length,
                  itemBuilder: (context, workoutIndex) {
                    final workout = widget.workouts[workoutIndex];
                    final isTimeBased = (workoutIndex == 0 ||
                        workoutIndex >= widget.workouts.length - 2);
                    final gender =
                        Provider.of<GenderProvider>(context).selectedGender;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          _showWorkoutDetailDialog(context, workout);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 10,
                          color:
                              isDark ? const Color(0xFF232323) : Colors.white,
                          shadowColor: isDark
                              ? Colors.greenAccent.withOpacity(0.10)
                              : Colors.green.withOpacity(0.25),
                          child: Container(
                            height: 120,
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
                              color: isDark ? const Color(0xFF232323) : null,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
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
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                              workout['rep']!.isNotEmpty) ...[
                                            Text(
                                              'x',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 16),
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              workout['rep']!,
                                              style: GoogleFonts.poppins(
                                                color: Colors.green,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                          if (workout['sec'] != null &&
                                              workout['sec']!.isNotEmpty) ...[
                                            if (workout['rep'] != null &&
                                                workout['rep']!.isNotEmpty)
                                              const Text(' • ',
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 18)),
                                            const Icon(Icons.timer_rounded,
                                                color: Colors.green, size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              workout['sec']!,
                                              style: GoogleFonts.poppins(
                                                color: Colors.green,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ],
                                      )
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
                  separatorBuilder: (context, index) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          final isDark = themeProvider.isDarkMode;
          final size = MediaQuery.of(context).size;
          final width = size.width;
          final height = size.height;

          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF232323) : Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(height * 0.025)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, -height * 0.005),
                  blurRadius: height * 0.01,
                ),
              ],
            ),
            child: BottomAppBar(
              elevation: 0,
              color: Colors.transparent,
              child: Center(
                child: ElevatedButton(
                  onPressed: _startWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(width * 0.9, height * 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 6,
                    shadowColor: Colors.green.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow,
                          size: height * 0.035, color: Colors.white),
                      SizedBox(width: width * 0.02),
                      Text(
                        "Start",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: height * 0.025,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// The complete WorkoutScreen with countdown, breaks, and control buttons.

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
                        'x ${workout['rep']!}',
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

  const WorkoutCompleteScreen({
    super.key,
    required this.onRestart,
    required this.onCompleteWorkout,
    required this.elapsedTime,
    required this.onWorkoutComplete,
    required List<Map<String, String>> workouts,
  });

  @override
  _WorkoutCompleteScreenState createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  final _progress = ProgressService();
  final ScreenshotController _screenshotController = ScreenshotController();
  int _selectedLevel = 0;
  int _selectedDay = 0;
  int _completedDay = 0;

  @override
  void initState() {
    super.initState();
    () async {
      _selectedLevel = await _progress.getSelectedLevel();
      _completedDay = await _progress.getCompletedDay(_selectedLevel);
      setState(() => _selectedDay = _completedDay);
    }();
  }

  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    return "$minutes min $seconds sec";
  }

  Future<void> _shareScreenshot() async {
    final image = await _screenshotController.capture();
    if (image == null) return;

    final directory = await getTemporaryDirectory();
    final imagePath =
        await File('${directory.path}/workout_complete.png').create();
    await imagePath.writeAsBytes(image);

    await Share.shareXFiles(
      [XFile(imagePath.path)],
      text:
          'I just completed my workout in ${_formatDuration(widget.elapsedTime)} using Tena+ 💪🔥 #TenaPlus',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(double.infinity, 56),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
    );
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 📸 Screenshot Area — This gets captured
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.06,
                    vertical: width * 0.16,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    /* boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(0, 4),
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

                      const SizedBox(height: 20),
                      Text(
                        "Workout Completed!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Time: ${_formatDuration(widget.elapsedTime)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Slogan: English
                      Text(
                        "Tena+ — Strong Body, Strong Mind!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ✅ Slogan: Amharic (no leading spaces)
                      Text(
                        "      — ጠንካራ አካል፣ ጠንካራ አእምሮ!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// 🟦 Share Button

// 🔵 Share Button
              ElevatedButton.icon(
                onPressed: _shareScreenshot,
                icon: const Icon(Icons.share, color: Colors.white, size: 24),
                label: const Text(
                  "Share Achievement",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: buttonStyle.copyWith(
                  backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                ),
              ),

              const SizedBox(height: 16),

// 🔁 Restart Workout Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onRestart();
                },
                icon: const Icon(Icons.refresh, color: Colors.black, size: 24),
                label: const Text(
                  "Restart Workout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                style: buttonStyle.copyWith(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.orangeAccent,
                  ),
                ),
              ),

              const SizedBox(height: 16),

// ✅ Complete & Go Home Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const firstpage1()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.check_circle,
                    color: Colors.white, size: 24),
                label: const Text(
                  "Workout Complete",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: buttonStyle.copyWith(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
