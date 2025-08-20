import 'dart:ui';
import 'package:etsport/pages/acc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../pages/appbar/fav.dart';
import '../pages/appbar/recent.dart';
import '../pages/providers/favourite_provider.dart';
import '../pages/providers/theme_provider.dart';
import 'package:etsport/gen_l10n/app_localizations.dart'; // ✅ correct

import 'package:etsport/pages/firstpage.dart';

class HomeWorkoutPage extends StatelessWidget {
  final List<Map<String, String>> items;
  final String title;

  const HomeWorkoutPage({
    super.key,
    required this.items,
    required this.title,
  });

  int _getLevel(String? text) {
    switch (text?.toLowerCase()) {
      case 'level 1':
        return 1;
      case 'level 2':
        return 2;
      case 'level 3':
        return 3;
      default:
        return 1;
    }
  }

  List<Map<String, String>> _filterByLevel(int level) {
    return items.where((item) => _getLevel(item['text3']) == level).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    final beginnerItems = _filterByLevel(1);
    final intermediateItems = _filterByLevel(2);
    final advancedItems = _filterByLevel(3);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          if (beginnerItems.isNotEmpty)
            _buildSection(context, 'Beginner', beginnerItems),
          if (intermediateItems.isNotEmpty)
            _buildSection(context, 'Intermediate', intermediateItems),
          if (advancedItems.isNotEmpty)
            _buildSection(context, 'Advanced', advancedItems),
        ],
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

  Widget _buildSection(
      BuildContext context, String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.greenAccent
                  : Colors.black,
            ),
          ),
        ),
        ...items.map((item) => _buildWorkoutCard(context, item)).toList(),
      ],
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Map<String, String> item) {
    final isFavorite =
        Provider.of<FavoritesProvider>(context).isFavorite(item['route']!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, item['route']!),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 0.6, sigmaY: 0.6),
                  child: Image.asset(
                    item['image']!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.2),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    //  const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            _getLevel(item['text3']).clamp(1, 3),
                            (index) => const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.bolt,
                                  color: Colors.amber, size: 20),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, item['route']!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Start Now',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : Colors.white,
                      size: 26,
                    ),
                    onPressed: () {
                      final provider = Provider.of<FavoritesProvider>(context,
                          listen: false);
                      isFavorite
                          ? provider.removeFavorite(item['route']!)
                          : provider.addFavorite(item);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    ];

    return [
      Expanded(
          child: _buildNavItemResponsive(context, items[0], themeProvider)),
      const SizedBox(width: 40), // Space for FAB
      Expanded(
          child: _buildNavItemResponsive(context, items[1], themeProvider)),

      /* Expanded(
          child: _buildNavItemResponsive(context, items[2], themeProvider)),
      Expanded(
          child: _buildNavItemResponsive(context, items[3], themeProvider)),
    ];*/
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
}
