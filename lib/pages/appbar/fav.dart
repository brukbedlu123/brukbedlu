import 'package:etsport/main.dart';
import 'package:etsport/pages/acc.dart';
import 'package:etsport/pages/firstpage.dart';
import 'package:etsport/pages/providers/favourite_provider.dart';
import 'package:etsport/widgets/bottom%20appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:etsport/gen_l10n/app_localizations.dart'; // ✅ correct

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites =
        context.watch<FavoritesProvider>().favorites.reversed.toList();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color.fromARGB(221, 30, 34, 32)
          : Colors.white,
      appBar: AppBar(
        title: Text(
          localizations.favorites,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor:
            themeProvider.isDarkMode ? Colors.green.shade900 : Colors.green,
        elevation: 2,
        centerTitle: true,

        // 👇 This makes the back button white
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Text(
                'No favorites added yet!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return Card(
                  elevation: 3,
                  color: themeProvider.isDarkMode
                      ? Colors.grey.shade500
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item['image']!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      item['title']!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode
                            ? Colors.greenAccent
                            : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      item['subtitle']!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        context
                            .read<FavoritesProvider>()
                            .removeFavorite(item['route']!);
                      },
                      tooltip: 'Remove from favorites',
                    ),
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const firstpage1()),
            (route) => false,
          );
        },
        backgroundColor: Colors.green,
        elevation: 5,
        child: const Icon(
          Icons.home,
          size: 28,
          color: Colors.black,
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentPage: 'favorite'),
    );
  }
}
