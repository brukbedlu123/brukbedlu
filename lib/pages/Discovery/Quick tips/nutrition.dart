import 'dart:async';
import 'package:etsport/pages/acc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// ---- Model Class ----
class SkinCarePageData {
  final String title;
  final String description;
  final String image;
  final IconData icon;
  final List<String> tips;

  SkinCarePageData({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
    required this.tips,
  });
}

// ---- Main Reusable Page ----
class Nutrition extends StatefulWidget {
  final String pageTitle;
  final List<String> tabTitles;
  final List<SkinCarePageData> pages;

  const Nutrition({
    super.key,
    required this.pageTitle,
    required this.tabTitles,
    required this.pages,
  });

  @override
  _NutritionState createState() => _NutritionState();
}

class _NutritionState extends State<Nutrition>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Timer _timer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.pages.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _resetTimer();
      }
    });

    _startTimer();
  }

  void _startTimer() {
    _progress = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        _progress += 0.005;
        if (_progress >= 1.0) {
          _progress = 0.0;
          int nextIndex = (_tabController.index + 1) % _tabController.length;
          _tabController.animateTo(nextIndex);
        }
      });
    });
  }

  void _resetTimer() {
    _timer.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTab(String title, int index) {
    bool isActive = _tabController.index == index;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white24,
            borderRadius: BorderRadius.circular(3),
          ),
          child: isActive
              ? LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          widget.pageTitle,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [
              Shadow(
                blurRadius: 8,
                color: Colors.black26,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeProvider.isDarkMode ? Colors.black : const Color(0xFF2193b0),
              const Color(0xFF6dd5ed),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20), // <-- Add this line for spacing
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                tabs: List.generate(
                  widget.tabTitles.length,
                  (index) => _buildTab(widget.tabTitles[index], index),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: widget.pages
                      .map((data) => SkinCarePage(data: data))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Reusable Content Widget ----
class SkinCarePage extends StatelessWidget {
  final SkinCarePageData data;

  const SkinCarePage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(data.icon, size: 64, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black26,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tips',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: data.tips
                .map((tip) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle,
                            color: Colors.teal, size: 26),
                        title: Text(
                          tip,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
