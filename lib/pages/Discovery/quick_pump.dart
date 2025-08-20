import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:etsport/pages/acc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class QuickPump extends StatefulWidget {
  final String title;
  final String subtitle;
  final String backgroundImage;
  final Map<String, List<Map<String, String>>> workoutsByType;

  const QuickPump({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundImage,
    required this.workoutsByType,
  });

  @override
  State<QuickPump> createState() => _QuickPumpState();
}

class _QuickPumpState extends State<QuickPump> {
  String selectedType = 'Bodyweight';

  void _startWorkout() {
    final workouts = widget.workoutsByType[selectedType]!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(
          workouts: workouts,
          workoutId: selectedType.toLowerCase(),
          onWorkoutComplete: (index) {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workouts = widget.workoutsByType[selectedType]!;
    final size = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = screenWidth * 0.060;
    final fontSize = screenWidth * 0.055;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

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
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.green),
                    ),
                  if (workout['sec'] != null && workout['sec']!.isNotEmpty)
                    Text(
                      '${workout['sec']} sec',
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.green),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.15),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon:
                    Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.03),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      dropdownColor: Colors.black87,
                      icon: Icon(Icons.arrow_drop_down,
                          color: Colors.white, size: iconSize),
                      items: widget.workoutsByType.keys
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedType = value!),
                    ),
                  ),
                ),
              ],
            ),

            // Title Positioned at Bottom Left
            Positioned(
              left: screenWidth * 0.08,
              bottom: screenHeight * 0.025,
              child: Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            '${widget.subtitle} ($selectedType)',
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        // Add this at the start of your build method or before the ListView:

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            itemCount: workouts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final w = workouts[index];
              final isTimeBased = w.containsKey('sec');
              return GestureDetector(
                onTap: () {
                  _showWorkoutDetailDialog(context, w);
                },
                child: Card(
                  elevation: 6,
                  color: isDark ? const Color(0xFF232323) : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  shadowColor: isDark
                      ? Colors.greenAccent.withOpacity(0.10)
                      : Colors.green.withOpacity(0.25),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? null
                          : LinearGradient(
                              colors: [Colors.white, Colors.green.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(16),
                      color: isDark ? const Color(0xFF232323) : null,
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                w['image']!,
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w['name']!,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  )),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    isTimeBased ? Icons.timer : Icons.repeat,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isTimeBased ? w['sec']! : 'x ${w['rep']}',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ],
                              )
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

// Update your bottomNavigationBar:
      ]),
      bottomNavigationBar: Builder(
        builder: (context) {
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

// Dummy WorkoutScreen — replace with your real one
