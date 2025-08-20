import 'package:etsport/pages/acc.dart';
import 'package:etsport/pages/firstpage.dart';
import 'package:etsport/widgets/bottom%20appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:etsport/pages/providers/recent_provider.dart';
import 'package:etsport/gen_l10n/app_localizations.dart'; // ✅ correct

class RecentPage extends StatelessWidget {
  const RecentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recentItems = context.watch<RecentProvider>().recentItems;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color.fromARGB(221, 30, 34, 32)
          : Colors.white,
      appBar: AppBar(
        backgroundColor:
            themeProvider.isDarkMode ? Colors.green.shade900 : Colors.green,
        elevation: 2,
        title: Text(
          localizations.recentworkouts,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Clear All',
            onPressed: () {
              context.read<RecentProvider>().clearRecentItems();
            },
          ),
        ],
      ),
      body: recentItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center,
                      size: 64, color: Colors.green.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    localizations.norecent,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: recentItems.length,
              itemBuilder: (context, index) {
                final item = recentItems[index];
                return Card(
                  elevation: 3,
                  color: themeProvider.isDarkMode
                      ? Colors.grey.shade500
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
                    onTap: () {
                      Navigator.pushNamed(context, item['route']!);
                    },
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
      bottomNavigationBar: const CustomBottomNav(currentPage: 'recent'),
    );
  }
}
