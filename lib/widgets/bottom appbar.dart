import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etsport/gen_l10n/app_localizations.dart'; // ✅ correct

import 'package:etsport/pages/acc.dart';
import 'package:etsport/pages/appbar/fav.dart';
import 'package:etsport/pages/appbar/recent.dart';

class CustomBottomNav extends StatelessWidget {
  final String currentPage;

  const CustomBottomNav({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> items = [
      {
        'id': 'favorite',
        'icon': Icons.star,
        'label': localizations.favorites,
        'route': '/favourites',
        'widget': const FavoritesPage(),
      },
      {
        'id': 'recent',
        'icon': Icons.history,
        'label': localizations.recent,
        'route': '/recent',
        'widget': const RecentPage(),
      },
      {
        'id': 'discovery',
        'icon': Icons.featured_play_list_outlined,
        'label': localizations.discovery,
        'route': '/feature',
        'widget': null,
      },
      {
        'id': 'profile',
        'icon': Icons.person,
        'label': localizations.profile,
        'route': '/acc',
        'widget': null,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;

        final double bottomBarHeight = (screenHeight * 0.7).clamp(35.0, 65.0);
        final double iconSize = (bottomBarHeight * 0.30).clamp(22.0, 50.0);
        final double fontSize = (bottomBarHeight * 0.05).clamp(10.0, 18.0);

        Widget buildNavItem(Map<String, dynamic> item) {
          final bool isSelected = currentPage == item['id'];
          final iconColor = isSelected ? Colors.green : Colors.grey;
          final textColor =
              themeProvider.isDarkMode ? Colors.white : Colors.black;

          return Expanded(
            child: InkWell(
              onTap: () {
                if (currentPage == item['id'])
                  return; // Prevent navigating to the same page

                if (item['widget'] != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => item['widget']),
                  );
                } else {
                  Navigator.pushReplacementNamed(context, item['route']);
                }
              },
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: bottomBarHeight * 0,
                    horizontal: screenWidth * 0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'],
                        size: iconSize,
                        color: iconColor,
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item['label'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          height: bottomBarHeight,
          color: themeProvider.isDarkMode ? Colors.transparent : Colors.white,
          elevation: 10,
          child: Row(
            children: [
              buildNavItem(items[0]),
              buildNavItem(items[1]),
              SizedBox(width: screenWidth * 0.10), // space for FAB
              buildNavItem(items[2]),
              buildNavItem(items[3]),
            ],
          ),
        );
      },
    );
  }
}
