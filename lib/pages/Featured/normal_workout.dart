import 'dart:async';
import 'package:etsport/pages/acc.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';

class ReusableWorkoutPage2 extends StatefulWidget {
  final String workoutId;
  const ReusableWorkoutPage2({super.key, required this.workoutId});

  @override
  State<ReusableWorkoutPage2> createState() => _ReusableWorkoutPage2State();
}

class _ReusableWorkoutPage2State extends State<ReusableWorkoutPage2> {
  List<Map<String, dynamic>> workouts = [];
  List<bool> imageLoadStatus = [];
  bool allImagesLoaded = false;
  bool buttonDelayExpired = false;
  int countdown = 5;
  Timer? countdownTimer;

  Map<String, dynamic>? workoutData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          countdown = 0;
          buttonDelayExpired = true;
        });
      }
    });

    loadWorkoutById(widget.workoutId).then((data) async {
      if (mounted) {
        workoutData = data;
        isLoading = false;

        // Pre-cache header background image
        final headerImage = parseImageUrl(workoutData?['backgroundImage']);
        if (headerImage != null && headerImage.startsWith('http')) {
          await precacheImage(NetworkImage(headerImage), context);
        }

        setState(() {});
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    });
  }

  Future<Map<String, dynamic>?> loadWorkoutById(String workoutId) async {
    final firestore = FirebaseFirestore.instance;
    final supabase = Supabase.instance.client;

    final docSnap =
        await firestore.collection('workoutPages').doc(workoutId).get();
    if (docSnap.exists) {
      return docSnap.data() as Map<String, dynamic>;
    }

    final response = await supabase
        .from('workoutPages')
        .select()
        .eq('id', workoutId)
        .maybeSingle();

    return response != null ? Map<String, dynamic>.from(response) : null;
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $error')),
      );
    }

    if (workoutData == null) {
      return const Scaffold(
        body: Center(child: Text('No workout found for this ID.')),
      );
    }

    final title = workoutData!['title'] ?? '';
    final subtitle = workoutData!['subtitle'] ?? '';
    final backgroundImage = workoutData!['backgroundImage'] ?? '';
    workouts = List<Map<String, dynamic>>.from(workoutData!['workouts'] ?? []);

    if (imageLoadStatus.length != workouts.length) {
      imageLoadStatus = List.filled(workouts.length, false);
      allImagesLoaded = false;
    }

    return Scaffold(
      appBar: buildHeader(context, title, backgroundImage),
      body: buildWorkoutBody(context, subtitle),
      bottomNavigationBar: buildStartButton(context),
    );
  }

  void _markImageLoaded(int index) {
    if (!imageLoadStatus[index]) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            imageLoadStatus[index] = true;
            allImagesLoaded = imageLoadStatus.every((loaded) => loaded);
          });
        }
      });
    }
  }

  String? parseImageUrl(String? rawUrl) {
    if (rawUrl == null || !rawUrl.startsWith('http')) return null;
    rawUrl = rawUrl.replaceAll('\n', '').trim();

    if (rawUrl.contains('drive.google.com/file/d/')) {
      final id = rawUrl.split('/file/d/')[1].split('/').first;
      return 'https://drive.google.com/uc?export=view&id=$id';
    }

    if (rawUrl.contains('drive.google.com') && rawUrl.contains('id=')) {
      final uri = Uri.tryParse(rawUrl);
      final id = uri?.queryParameters['id'];
      if (id != null) {
        return 'https://drive.google.com/uc?export=view&id=$id';
      }
    }

    return rawUrl;
  }

  PreferredSize buildHeader(
      BuildContext context, String title, String imageUrl) {
    final parsedUrl = parseImageUrl(imageUrl);
    return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.15),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: (parsedUrl != null
                        ? CachedNetworkImageProvider(parsedUrl)
                        : const NetworkImage(
                            'https://images.unsplash.com/photo-1519864600265-abb23847ef2c'))
                    as ImageProvider<Object>,
                fit: BoxFit.cover,
              ),
            ),
          ),
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
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWorkoutBody(BuildContext context, String subtitle) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            subtitle,
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        // Add this at the start of your build method or before the ListView:

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: workouts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final w = workouts[index];
              final isTimeBased = w.containsKey('sec');
              final imageUrl = parseImageUrl(w['image']);
              return Card(
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
                            child: CachedNetworkImage(
                              imageUrl: imageUrl ?? '',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[200],
                                child: const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              ),
                              imageBuilder: (context, imageProvider) {
                                _markImageLoaded(index);
                                return Image(
                                  image: imageProvider,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 19,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w['name'] ?? '',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                                  isTimeBased
                                      ? '${w['sec']} sec'
                                      : 'x ${w['rep']}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget buildStartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: (allImagesLoaded && buttonDelayExpired)
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutScreen(
                      workouts: workouts.map<Map<String, String>>((w) {
                        final parsedUrl = parseImageUrl(w['image']);
                        return {
                          ...w.map((key, value) => MapEntry(
                              key.toString(), value?.toString() ?? '')),
                          'parsedImageUrl': parsedUrl ?? '',
                        };
                      }).toList(),
                      onWorkoutComplete: (completedIndex) {},
                      workoutId: widget.workoutId,
                    ),
                  ),
                );
              }
            : null,
        icon: const Icon(Icons.play_arrow, size: 25, color: Colors.white),
        label: Text(
          buttonDelayExpired ? "Start" : "Wait for images to load $countdown",
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          disabledBackgroundColor: Colors.grey,
        ),
      ),
    );
  }
}
