import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:etsport/pages/Featured/normal_workout.dart';
import 'package:etsport/pages/acc.dart';
import 'package:etsport/pages/firstpage.dart';
import 'package:etsport/pages/full%20body/fullbody.dart';
import 'package:etsport/pages/providers/favourite_provider.dart';
import 'package:etsport/pages/providers/recent_provider.dart';
import 'package:etsport/widgets/bottom%20appbar.dart';
import 'package:etsport/widgets/gender.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:etsport/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ correct

import 'package:url_launcher/url_launcher_string.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Add this method to fetch online workouts
  Future<List<Map<String, dynamic>>> fetchOnlineWorkouts() async {
    final response = await supabase.from('workoutPages').select();

    return response.map<Map<String, dynamic>>((item) {
      return {
        'workoutId': item['id'],
        'title': item['title'] ?? '',
        'subtitle': item['subtitle'] ?? '',
        'duration': item['duration'] ?? '',
        'image': item['image'] ?? '',
        'route': item['route'] ?? '',
      };
    }).toList();
  }

  // Optional: already defined add method
  Future<void> addOnlineWorkout(Map<String, dynamic> workout) async {
    final workoutId = workout['workoutId'];
    if (workoutId == null || workoutId.toString().isEmpty) {
      debugPrint('❌ Supabase workoutId is missing');
      return;
    }

    await supabase.from('workoutPages').insert({
      'workoutId': workout['workoutId'], // your custom ID
      'title': workout['title'],
      'subtitle': workout['subtitle'],
      'duration': workout['duration'],
      'image': workout['image'],
      'route': workout['route'],
      'workouts': [], // optional
    });
  }
}

Future<void> addWorkoutToFirestore(Map<String, dynamic> workout) async {
  final workoutId = workout['workoutId'];
  if (workoutId == null || workoutId.toString().isEmpty) {
    debugPrint('❌ workoutId is null or empty');
    return;
  }

  await FirebaseFirestore.instance
      .collection('workoutPages')
      .doc(workoutId)
      .set({
    'title': workout['title'],
    'subtitle': workout['subtitle'],
    'duration': workout['duration'],
    'image': workout['image'],
    'route': workout['route'],
    'workouts': [], // optional
  });
}

//final supabaseService = SupabaseService();
// Remove the top-level await; fetch data inside a FutureBuilder or async function when needed

class Discovery extends StatefulWidget {
  const Discovery({super.key});

  @override
  State<Discovery> createState() => _DiscoveryState();
}

class _DiscoveryState extends State<Discovery> {
  @override
  void initState() {
    super.initState();
    _preloadRewardedAd(); // ✅ preload when Discovery screen opens
  }

  RewardedAd? _rewardedAd;
  bool _isLoadingAd = false;
  void _preloadRewardedAd() {
    if (_rewardedAd != null || _isLoadingAd) return;

    _isLoadingAd = true;
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3708730951742349/4490314233',
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
      adUnitId: 'ca-app-pub-3708730951742349/4490314233',
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

  final Set<String> _unlockedWorkouts = {};
  void showUnlockDialog(
    BuildContext context,
    Map<String, String> workout,
    VoidCallback onAdComplete,
  ) {
    final String workoutRoute = workout['route']!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    // ✅ Check if this workout is already unlocked
    if (_unlockedWorkouts.contains(workoutRoute)) {
      onAdComplete();
      return;
    }

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
              isEnglish ? 'WATCH VIDEO TO UNLOCK' : 'ቪዲዮ ተመልከት እና አውጣ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isEnglish
                  ? 'Watch the video to use training plan'
                  : 'ስልጠናውን ለመክፈት ቪዲዮውን ይመልከቱ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                minimumSize: Size(double.infinity, 48),
              ),
              icon: Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                isEnglish ? "UNLOCK" : "ክፈት",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();

                showAdThenNavigate(
                  context,
                  workoutRoute,
                  () {
                    _unlockedWorkouts
                        .add(workoutRoute); // 🔓 Unlock only this one
                    onAdComplete(); // Continue to workout
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    List<Map<String, String>> buildItemList(AppLocalizations localizations) => [
          {
            'title': localizations
                .chestAndBiceps, // Add this key to your ARB/localizations
            'subtitle': localizations.strengthTone15Moves,
            'duration': localizations.sixToEightReps,
            'image': 'images/discovery/chest and biceps.webp',
            'route': '/bicepsandchest',
            // 'route': '/workoutup',
            //'route': '/link',
          },
          // ...add more items as needed...
        ];

    final quicktips = [
      {
        'title': localizations.weightGain,
        'subtitle': '',
        'duration': localizations.sevenMin,
        'image': 'images/discovery/weight gain.webp',
        'route': '/weightgain',
      },
      {
        'title': localizations.nutrition,
        'subtitle': '',
        'duration': '',
        'image': 'images/discovery/nutrition.webp',
        'route': '/nutrition',
      },
      {
        'title': localizations.skinCare,
        'subtitle': localizations.noEquipment,
        'duration': localizations.days30,
        'image': 'images/discovery/skin care.webp',
        'route': '/skincare',
      },
    ];
    List<Map<String, String>> buildFeaturedWorkouts(
      AppLocalizations localizations,
      String gender,
    ) =>
        [
          {
            'title': localizations.homeCardio,
            'subtitle': localizations.noEquipment,
            'duration': localizations.days30,
            'image': gender == 'female'
                ? 'images/discovery/home girl.webp'
                : 'images/discovery/home boy.webp',
            'route': '/homecardio',
          },
          {
            'title': localizations.buttWork,
            'subtitle': localizations.noEquipment,
            'duration': localizations.sevenMin,
            'image': gender == 'female'
                ? 'images/discovery/butt workout.webp'
                : 'images/discovery/butt workout.webp',
            'route': '/buttworkout',
          },
          {
            'title': localizations.quickPump,
            'subtitle': localizations.dumbbells,
            'duration': localizations.fiveMin,
            'image': gender == 'female'
                ? 'images/discovery/quick pump.webp'
                : 'images/discovery/quick pump.webp',
            'route': '/quickpump',
          },
          {
            'title': localizations.bellyFat,
            'subtitle': localizations.noEquipment,
            'duration': localizations.sevenMin,
            'image': gender == 'female'
                ? 'images/discovery/belly fat girl.webp'
                : 'images/discovery/belly fat.webp',
            'route': '/bellyfat',
          },
          {
            'title': localizations.dailyStretch,
            'subtitle': localizations.noEquipment,
            'duration': localizations.tenMin,
            'image': gender == 'female'
                ? 'images/discovery/stretch girl.webp'
                : 'images/discovery/stretch boy.webp',
            'route': '/dailystrech',
          },
        ];

    Future<List<Map<String, dynamic>>> fetchAllFeaturedWorkouts() async {
      // Fetch from Firestore
      final firestoreSnapshot =
          await FirebaseFirestore.instance.collection('workoutPages').get();
      final firestoreWorkouts = firestoreSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'workoutId': doc.id,
          'title': data['title']?.toString() ?? '',
          'subtitle': data['subtitle']?.toString() ?? '',
          'duration': data['duration']?.toString() ?? '',
          'image': data['image']?.toString() ?? '',
          'route': data['route']?.toString() ?? '',
          'source': 'firestore',
        };
      }).toList();

      // Fetch from Supabase
      final supabaseWorkouts = await SupabaseService().fetchOnlineWorkouts();
      final supabaseWorkoutsWithSource = supabaseWorkouts
          .map((w) => {
                ...w,
                'source': 'supabase',
              })
          .toList();

      // Combine both sources
      return [...firestoreWorkouts, ...supabaseWorkoutsWithSource];
    }

    Future<List<Map<String, dynamic>>> loadCombinedWorkouts() async {
      final firestore = FirebaseFirestore.instance;
      final supabase = Supabase.instance.client;

      final Map<String, Map<String, dynamic>> uniqueWorkouts = {};

      // Fetch from Firebase with error handling
      try {
        final firebaseSnap = await firestore.collection('workoutPages').get();
        for (var doc in firebaseSnap.docs) {
          final data = doc.data();
          data['workoutId'] = doc.id;
          uniqueWorkouts[doc.id] = data; // use doc.id as the unique key
        }
      } catch (e) {
        debugPrint('❌ Firebase fetch failed: $e');
      }

      // Fetch from Supabase with error handling
      try {
        final response = await supabase.from('workoutPages').select();
        for (var item in response as List) {
          final mapItem = Map<String, dynamic>.from(item);
          final id = mapItem['id'] ?? mapItem['workoutId'];
          if (id != null && !uniqueWorkouts.containsKey(id)) {
            mapItem['workoutId'] = id;
            uniqueWorkouts[id] = mapItem;
          }
        }
      } catch (e) {
        debugPrint('❌ Supabase fetch failed: $e');
      }

      return uniqueWorkouts.values.toList();
    }

    Future<void> addWorkoutToFirestore(Map<String, dynamic> workout) async {
      final workoutId = workout['workoutId'];
      if (workoutId == null) return;

      await FirebaseFirestore.instance
          .collection('workoutPages')
          .doc(workoutId) // 👈 sets Firestore doc ID
          .set({
        'title': workout['title'],
        'subtitle': workout['subtitle'],
        'duration': workout['duration'],
        'image': workout['image'],
        'route': workout['route'],
        'workouts': [], // Optional: Add workout list here too
      });
    }

// ...existing code...

    Widget buildWorkoutScrollList(List<Map<String, dynamic>> workouts) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            final id = workout['workoutId'] ?? workout['id'];
            final isComingSoon = id == 'coming_soon1' ||
                id == 'coming_soon2' ||
                id == 'coming_soon3' ||
                id == 'coming_soon4' ||
                id == 'coming_soon5';
            final isAd = id == 'ad1' ||
                id == 'ad2' ||
                id == 'ad3' ||
                id == 'ad4' ||
                id == 'ad5' ||
                id == 'ad6' ||
                id == 'ad7' ||
                id == 'ad8' ||
                id == 'ad9';
            final rawImageUrl =
                workout['image']?.toString().replaceAll('\n', '').trim();

            String? getParsedImageUrl(String? url) {
              if (url == null || !url.startsWith('http')) return null;

              if (url.contains('drive.google.com')) {
                final uri = Uri.tryParse(url);
                String? id;

                // Extract the file ID from common Google Drive formats
                if (url.contains('/file/d/')) {
                  final parts = url.split('/file/d/');
                  if (parts.length > 1) {
                    id = parts[1].split('/').first;
                  }
                } else if (uri?.queryParameters.containsKey('id') == true) {
                  id = uri!.queryParameters['id'];
                }

                if (id != null) {
                  return 'https://drive.google.com/uc?export=view&id=$id';
                }
              }

              // Add noCache param to standard image URLs
              return '$url${url.contains('?') ? '&' : '?'}noCache=${DateTime.now().millisecondsSinceEpoch}';
            }

            final parsedImageUrl = getParsedImageUrl(rawImageUrl);

            final card = Stack(
              children: [
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: (parsedImageUrl != null
                              ? CachedNetworkImageProvider(parsedImageUrl)
                              : const CachedNetworkImageProvider(
                                  'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=400&q=80'))
                          as ImageProvider<Object>,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isComingSoon)
                        Text(
                          workout['title'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        workout['subtitle'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workout['duration'] ?? '',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                        ),
                      ),
                      if (isComingSoon)
                        Text(
                          workout['title'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (isComingSoon)
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Text(
                            'Coming Soon',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: (isComingSoon || isAd)
                  ? card
                  : GestureDetector(
                      onTap: () async {
                        final url = workout['url']?.toString().trim();
                        final isLinkWorkout =
                            id == 'link1' || id == 'link2' || id == 'link3';

                        if (isLinkWorkout) {
                          if (url != null && url.isNotEmpty) {
                            final launched = await launchUrlString(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!launched) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Could not open link')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No valid URL')),
                            );
                          }
                        } else if (id != null && id.toString().isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReusableWorkoutPage2(workoutId: id),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Workout ID not found')),
                          );
                        }
                      },
                      child: card,
                    ),
            );
          },
        ),
      );
    }

    /// Preload Rewarded Ad

    final gender = Provider.of<GenderProvider>(context).selectedGender;
    final item = buildItemList(localizations);
    final featuredWorkouts = buildFeaturedWorkouts(localizations, gender);

    List<Map<String, String>> favorites = [];
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final supabaseService = SupabaseService();
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color.fromARGB(221, 30, 34, 32)
          : Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false, // Removes the back button

            backgroundColor: themeProvider.isDarkMode
                ? const Color.fromARGB(221, 30, 34, 32)
                : Colors.white,
            floating: true,
            expandedHeight: 70, // Increased height for the background image
            flexibleSpace: FlexibleSpaceBar(
              background: const Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  /* Positioned(
                    left:
                        400, // Adjust as needed for desired horizontal position
                    top: 0, // Start from the top of the SliverAppBar
                    bottom: 0, // Stretch it to the bottom of the SliverAppBar
                    child: Container(
                      width: 2, // Width of the line
                      color: Colors.white, // Color of the line
                    ),
                  ),*/
                ],
              ),
              title: Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Aligns text to the left
                children: [
                  const SizedBox(width: 20),
                  Text(
                    localizations.discovery, // First text
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.greenAccent
                          : Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              final workout = item[index];
              final isFavorited = favoritesProvider.isFavorite(
                workout['route']!,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: GestureDetector(
                  onTap: () {
                    showUnlockDialog(context, workout, () {
                      context.read<RecentProvider>().addRecentItem(workout);
                      Navigator.pushNamed(context, workout['route']!);
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage(
                              'images/discovery/chest and biceps.webp',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // "NEW" Label
                      Positioned(
                        top: -10,
                        left: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.4),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'NEW',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      // ❤️ Favorite Button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            isFavorited
                                ? favoritesProvider.removeFavorite(
                                    workout['route']!,
                                  )
                                : favoritesProvider.addFavorite(workout);
                          },
                          child: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                isFavorited ? Colors.redAccent : Colors.white,
                            size: 28,
                          ),
                        ),
                      ),

                      // 📋 Workout Text Content
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout['title']!,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              workout['subtitle']!,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Duration: ${workout['duration']}',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, workout['route']!);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent.shade700,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                localizations.startnow,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: item.length),
          ),

          /*  SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Text(
                localizations.mostpopular,
                style: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                final cardHeight = screenHeight * 0.25;
                final cardWidth = screenWidth * 0.55;
                final padding = screenWidth * 0.04;

                return SizedBox(
                  height: cardHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    itemCount: featuredWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = featuredWorkouts[index];

                      final isFavorited =
                          favoritesProvider.isFavorite(workout['route']!);
                      return Padding(
                        padding: EdgeInsets.only(right: padding),
                        child: GestureDetector(
                          onTap: () {
                            context.read<RecentProvider>().addRecentItem(
                                workout.map((key, value) =>
                                    MapEntry(key, value?.toString() ?? '')));
                            Navigator.pushNamed(context, workout['route']!);
                          },
                          child: Container(
                            width: cardWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: AssetImage(workout['image']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // Overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.6),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight,
                                      ),
                                    ),
                                  ),

                                  // Like button (top-right)
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
                                          favoritesProvider.removeFavorite(
                                              workout['route']!);
                                        } else {
                                          favoritesProvider
                                              .addFavorite(workout);
                                        }
                                      },
                                    ),
                                  ),

                                  // Details
                                  Positioned(
                                    left: padding,
                                    bottom: padding,
                                    right: padding,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          workout['title']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.greenAccent.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          workout['subtitle']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.schedule,
                                                color: Colors.white70,
                                                size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              workout['duration']!,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.white70,
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
                  ),
                );
              },
            ),
          ),*/
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Text(
                localizations.featured,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: loadCombinedWorkouts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No workouts available.'));
                }

                final workouts = snapshot.data!;
                return buildWorkoutScrollList(workouts);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Text(
                localizations.quicktips,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220, // Slightly taller for visual balance
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20, bottom: 40),
                itemCount: quicktips.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final workout = quicktips[index];
                  return GestureDetector(
                    onTap: () {
                      showUnlockDialog(context, workout, () {
                        context.read<RecentProvider>().addRecentItem(workout);
                        Navigator.pushNamed(context, workout['route']!);
                      });
                    },
                    child: Stack(
                      children: [
                        // 📸 Background Image
                        Container(
                          height: 200,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(workout['image']!),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),

                        // 🌫️ Blur Overlay
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 1.5,
                                sigmaY: 1.5,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 🟩 Text Container at Bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade300,
                                    Colors.green.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Text(
                                workout['title']!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 5), // Positive Y offset = move down
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
            size: 30,
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final workout = {
            'workoutId': 'partner_workout',
            'title': 'Partner Workout',
            'subtitle': 'No Equipment — Just Teamwork',
            'duration': '30 min',
            'image':
                'https://www.sparkpeople.com/news/genericpictures/bigpictures/couple_workout_header.png',
            'route': '/partnerfullbodyblast',
            // 'partnerWorkout': true,
          };

          try {
            final supabaseService = SupabaseService();
            await supabaseService.addOnlineWorkout(workout);
            debugPrint('✅ Supabase upload successful');

            await addWorkoutToFirestore(workout);
            debugPrint('✅ Firestore upload successful');

            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Workout added!')),
            );
          } catch (e) {
            debugPrint('❌ Upload failed: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: $e')),
            );
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),*/
      bottomNavigationBar: const CustomBottomNav(currentPage: 'discovery'),
    );
  }

  //  void setState(Null Function() param0) {}
}
