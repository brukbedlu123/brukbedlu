// lib/services/progress_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _selectedLevelKey = 'selectedLevel';
  static String _completedKey(int level) => 'completedDay_level$level';

  /// ───── getters ─────
  Future<int> getSelectedLevel() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_selectedLevelKey) ?? 0;
  }

  Future<int> getCompletedDay(int level) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_completedKey(level)) ?? 0;
  }

  /// ───── setters ─────
  Future<void> setSelectedLevel(int level) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_selectedLevelKey, level);
  }

  Future<void> setCompletedDay(int level, int day) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_completedKey(level), day);
  }

  /// Auto‑advance when today’s workout finishes
  Future<int> completeToday(int level) async {
    final nextDay = (await getCompletedDay(level)) + 1;
    await setCompletedDay(level, nextDay);
    return nextDay; // you may want this value in the UI
  }
}
