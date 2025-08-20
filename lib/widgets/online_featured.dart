/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeaturedWorkouts extends StatelessWidget {
  final ThemeProvider themeProvider;

  FeaturedWorkouts({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('workouts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No workouts available.'));
          }

          var _featuredWorkouts = snapshot.data!.docs.map((doc) {
            return {
              'title': doc['title'],
              'subtitle': doc['subtitle'],
              'duration': doc['duration'],
              'image': doc['image'],
              'route': doc['route'],
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
                        context.read<RecentProvider>().addRecentItem(workout);
                        Navigator.pushNamed(context, workout['route']);
                      },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.26,
                        width: MediaQuery.of(context).size.width * 0.73,
                        child: Stack(
                          children: [
                            // Background Image with Blur and Dark Overlay
                            Container(
                              height: MediaQuery.of(context).size.height * 0.26,
                              width: MediaQuery.of(context).size.width * 0.73,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(workout['image']),
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
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Favorite Button
                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.02,
                              left: MediaQuery.of(context).size.width * 0.015,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _favorites.any(
                                        (fav) =>
                                            fav['route'] == workout['route'],
                                      )
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        final isFavorited = _favorites.any(
                                          (fav) =>
                                              fav['route'] == workout['route'],
                                        );

                                        if (isFavorited) {
                                          _favorites.removeWhere(
                                            (fav) =>
                                                fav['route'] ==
                                                workout['route'],
                                          );
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
                              left: MediaQuery.of(context).size.width * 0.025,
                              bottom: MediaQuery.of(context).size.height * 0.02,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    final alreadyInList = _recentWorkouts.any(
                                      (recent) =>
                                          recent['route'] == workout['route'],
                                    );

                                    if (!alreadyInList) {
                                      if (_recentWorkouts.length >= 5) {
                                        _recentWorkouts.removeAt(0);
                                      }
                                      _recentWorkouts.add(workout);
                                    }
                                  });
                                  Navigator.pushNamed(
                                      context, workout['route']);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width * 0.02,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.012,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
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
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.025,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: MediaQuery.of(context).size.width * 0.055,
                              left: MediaQuery.of(context).size.width * 0.25,
                              top: MediaQuery.of(context).size.height * 0.01,
                              bottom: MediaQuery.of(context).size.height * 0.04,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    workout['title'],
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white70
                                          : Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.07,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  Text(
                                    workout['subtitle'],
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.green
                                          : Colors.white70,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.001),
                                  Text(
                                    workout['duration'],
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.green
                                          : Colors.white70,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
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
    );
  }
}*/
