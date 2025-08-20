import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// ReminderProvider with notification scheduling
class Reminder with ChangeNotifier {
  TimeOfDay? _reminderTime;
  List<String> _selectedDays = [];
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin(); // 4]

  // Unique starting ID for custom daily/weekly reminders 5]
  // Each day will get a unique ID based on this base + weekday int 5]
  static const int _customReminderBaseId = 200; // 5]

  // We need a way to get the current notification permission status.
  // Instead of passing context or making ReminderProvider a Consumer,
  // we can directly check the permission status where needed.

  ReminderProvider() {
    tz.initializeTimeZones(); // Ensure timezones are initialized 6, 2]
    _initNotifications(); // 6]
    _loadReminderSettings(); // 6]
  }

  TimeOfDay? get reminderTime => _reminderTime; // 7]
  List<String> get selectedDays => _selectedDays; // 7]

  Future<void> _initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // 7]
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      // 8]
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        print(
            'iOS Custom Reminder Received: id=$id, title=$title, body=$body, payload=$payload');
      },
      requestAlertPermission: true, // 8]
      requestBadgePermission: true, // 8]
      requestSoundPermission: true, // 8]
    );
    final settings = InitializationSettings(
      // 9]
      android: androidSettings,
      iOS: initializationSettingsDarwin, // 9]
    );
    await _notifications.initialize(settings,
        onDidReceiveNotificationResponse: // 10]
            (NotificationResponse response) async {
      print(
          'Custom Reminder Notification Response: payload=${response.payload}'); // 10]
    }, onDidReceiveBackgroundNotificationResponse:
            (NotificationResponse response) async {
      print(
          'Custom Reminder Background Notification Response: payload=${response.payload}'); // 10]
    });
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance(); // 11]
    final timeJson = prefs.getString('reminderTime'); // 11]

    if (timeJson != null) {
      // 12]
      final timeMap = jsonDecode(timeJson) as Map<String, dynamic>; // 12]
      _reminderTime = TimeOfDay(
        // 13]
        hour: timeMap['hour'] as int, // 13]
        minute: timeMap['minute'] as int, // 13]
      );
    }
    _selectedDays = prefs.getStringList('selectedDays') ?? []; // 14]
    notifyListeners(); // 14]
  }

  Future<void> _saveReminderSettings() async {
    final prefs = await SharedPreferences.getInstance(); // 15]

    if (_reminderTime != null) {
      // 16]
      final timeMap = {
        'hour': _reminderTime!.hour, // 16]
        'minute': _reminderTime!.minute // 16]
      };
      await prefs.setString('reminderTime', jsonEncode(timeMap)); // 17]
    } else {
      await prefs.remove('reminderTime'); // 17]
    }
    await prefs.setStringList('selectedDays', _selectedDays); // 17]
  }

  void toggleDay(String day) {
    if (_selectedDays.contains(day)) {
      // 18]
      _selectedDays.remove(day); // 18]
    } else {
      _selectedDays.add(day); // 19]
    }
    _saveReminderSettings(); // Save changes immediately 19, 20]
    _scheduleCustomReminders(); // Reschedule all custom reminders 20]
    notifyListeners(); // 20]
  }

  void setReminderTime(TimeOfDay time) {
    _reminderTime = time; // 21]
    _saveReminderSettings(); // Save changes immediately 21, 22]
    _scheduleCustomReminders(); // Reschedule all custom reminders 22]
    notifyListeners(); // 22]
  }

  /// Schedules all custom workout reminders based on selected time and days.
  Future<void> _scheduleCustomReminders() async {
    // 23, 24]
    // 1. Check Notification Permission
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      print(
          'Notification permission not granted. Cannot schedule custom reminders.');
      // Consider showing a snackbar or similar message here if you have context
      // (though a Provider shouldn't directly show UI elements).
      // The SettingsPage already handles this for the main toggle.
      return; // Exit if permission is not granted
    }

    if (_reminderTime == null || _selectedDays.isEmpty) {
      // 25]
      print(
          'No reminder time or days selected. Cancelling all custom reminders.'); // 25]
      await cancelAllCustomReminders(); // Make sure to cancel if settings are cleared
      return; // 26]
    }

    // Cancel all previously scheduled custom reminders (using their unique IDs) 24]
    for (int i = 0; i < 7; i++) {
      await _notifications.cancel(_customReminderBaseId + i); // 24]
    }

    final now =
        tz.TZDateTime.now(tz.local); // Get current time in local timezone

    for (var day in _selectedDays) {
      final weekday = _weekdayNameToInt(day); // 26]
      if (weekday == null) continue; // 27]

      // Calculate the next occurrence of the selected day at the specified time
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, // Use local timezone for scheduling
        now.year,
        now.month,
        now.day,
        _reminderTime!.hour, // 27]
        _reminderTime!.minute, // 27]
      );

      // Adjust scheduledDate to be in the future and match the correct weekday
      // This loop will correctly advance the date if the target time for today has passed,
      // or if today is not the target weekday.
      while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
        // 28]
        scheduledDate = scheduledDate.add(const Duration(days: 1)); // 28]
      }

      print(
          'Scheduling custom reminder for $day at $scheduledDate (ID: ${_customReminderBaseId + weekday})'); // 29]
      await _notifications.zonedSchedule(
        _customReminderBaseId +
            weekday, // Unique ID for each day of the week 30]
        'Custom Workout Reminder', // 30]
        'It\'s time to get your body moving! 💪', // 30]
        scheduledDate, // 30]
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'custom_workout_reminder_channel', // 30]
            'Custom Workout Reminder', // 30]
            importance: Importance.max, // 31]
            priority: Priority.high, // 31]
            icon: '@mipmap/ic_launcher', // 31]
          ),
          iOS:
              DarwinNotificationDetails(), // Ensure iOS details are also provided for consistency
        ),
        androidAllowWhileIdle: true, // 31]
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime, // 31]
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // 31]
      ); // 32]
    }
  }

  /// Converts a three-letter weekday name to its corresponding DateTime.weekday integer.
  int? _weekdayNameToInt(String name) {
    // 32, 33]
    switch (name.toLowerCase()) {
      case 'mon':
        return DateTime.monday; // 33]
      case 'tue':
        return DateTime.tuesday; // 34]
      case 'wed':
        return DateTime.wednesday; // 35]
      case 'thu':
        return DateTime.thursday; // 36]
      case 'fri':
        return DateTime.friday; // 37]
      case 'sat':
        return DateTime.saturday; // 38]
      case 'sun':
        return DateTime.sunday; // 39]
      default:
        return null; // 40]
    }
  }

  /// Cancels all custom workout reminders.
  Future<void> cancelAllCustomReminders() async {
    // 40, 41]
    for (int i = 0; i < 7; i++) {
      // 41]
      await _notifications.cancel(_customReminderBaseId + i); // 41]
    }
    _reminderTime = null; // 42]
    _selectedDays = []; // 42]
    _saveReminderSettings(); // 42]
    notifyListeners(); // 42]
  }
}

// Ensure _showCustomTimePicker and SettingsPage are updated if they refer
// to ReminderProvider logic that needs a context (e.g., Snackbars)
// However, the core logic for scheduling is within the provider, which is good.

// The _showCustomTimePicker function outside the class remains mostly the same.
// Just ensure it is passing the correct provider instance.
void _showCustomTimePicker(BuildContext context, Reminder provider,
    {bool is24HourFormat = false}) {
  // 43]
  TimeOfDay selectedTime = provider.reminderTime ?? TimeOfDay.now(); // 43, 77]
  List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ]; // 44, 77]

  showModalBottomSheet(
    // 45, 78]
    context: context,
    isScrollControlled: true, // 45, 78]
    shape: const RoundedRectangleBorder(
      // 45, 78]
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // 45, 78]
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor, // 45, 78]
    builder: (context) {
      return Padding(
        // 45, 78]
        padding: MediaQuery.of(context).viewInsets, // 45, 78]
        child: StatefulBuilder(
          // 45, 78]
          builder: (context, setState) => Padding(
            // 45, 78, 79]
            padding: const EdgeInsets.all(24.0), // 46, 79]
            child: Column(
              // 46, 79]
              mainAxisSize: MainAxisSize.min, // 46, 79]
              children: [
                Container(
                  // 46, 80]
                  height: 5, // 47, 80]
                  width: 40, // 47, 80]
                  margin: const EdgeInsets.only(bottom: 20), // 47, 80]
                  decoration: BoxDecoration(
                    // 47, 80]
                    color: Colors.grey.shade400, // 47, 80]
                    borderRadius: BorderRadius.circular(10), // 47, 81]
                  ),
                ), // 48, 81]
                Text(
                  'Custom Reminder', // 48, 82]
                  style: GoogleFonts.poppins(
                    // 48, 82]
                    fontSize: 20, // 49, 82]
                    fontWeight: FontWeight.w600, // 49, 82]
                    color: Theme.of(context).textTheme.bodyLarge?.color, // 82]
                  ),
                ),
                const SizedBox(height: 24), // 49, 83]
                Container(
                  padding: const EdgeInsets.symmetric(
                      // 50, 83, 84]
                      horizontal: 16,
                      vertical: 12), // 50, 84]
                  decoration: BoxDecoration(
                    // 50, 84]
                    color: Theme.of(context).cardColor, // 50, 84]
                    borderRadius: BorderRadius.circular(16), // 50, 84]
                    boxShadow: [
                      BoxShadow(
                        // 51, 85]
                        color: Colors.black.withOpacity(0.05), // 51, 85]
                        blurRadius: 10, // 51, 85]
                        offset: const Offset(0, 4), // 51, 86]
                      ),
                    ], // 52, 86]
                  ),
                  child: TimePickerSpinner(
                    // 52, 86]
                    is24HourMode: is24HourFormat, // 52, 87]
                    normalTextStyle: TextStyle(
                        fontSize: 16, color: Colors.grey.shade500), // 53, 87]
                    highlightedTextStyle: TextStyle(
                      // 53, 87]
                      fontSize: 22, // 54, 88]
                      color: Theme.of(context)
                          .primaryColor, // Use theme primary color 54, 88]
                      fontWeight: FontWeight.bold, // 54, 88]
                    ), // 89]
                    spacing: 40, // 54, 89]
                    itemHeight: 60, // 54, 89]
                    isForce2Digits: true, // 55, 89]
                    time: DateTime(
                        // 55, 90]
                        2023,
                        1,
                        1,
                        selectedTime.hour,
                        selectedTime.minute), // 55, 90]
                    onTimeChange: (time) {
                      selectedTime = TimeOfDay.fromDateTime(time); // 56, 90]
                    }, // 57, 91]
                  ),
                ),
                const SizedBox(height: 28), // 57, 91]
                Align(
                  alignment: Alignment.centerLeft, // 58, 92]
                  child: Text(
                    "Repeat on", // 58, 92]
                    style: GoogleFonts.poppins(
                      // 58, 92]
                      fontSize: 16, fontWeight: FontWeight.w500, // 59, 93]
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color, // 93]
                    ),
                  ), // 59, 93]
                ),
                const SizedBox(height: 12), // 59, 94]
                Wrap(
                  spacing: 12, // 59, 94]
                  runSpacing: 12, // 59, 94]
                  children: weekDays.map((day) {
                    // 60, 95]
                    final isSelected =
                        provider.selectedDays.contains(day); // 60, 95]
                    return FilterChip(
                      label: Text(
                        day, // 61, 96]
                        style: TextStyle(
                          // 61, 96]
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color, // 61, 97]
                          fontWeight: FontWeight.w500, // 61, 97]
                        ), // 62, 98]
                      ),
                      selected: isSelected, // 62, 98]
                      onSelected: (_) {
                        provider.toggleDay(day); // 62, 98]
                        setState(
                            () {}); // Update the chip's selected state 63, 99]
                      },
                      selectedColor: Theme.of(context).primaryColor, // 63, 99]
                      backgroundColor: Theme.of(context).cardColor, // 63, 99]
                      shape: RoundedRectangleBorder(
                        // 63, 100]
                        borderRadius: BorderRadius.circular(10), // 64, 100]
                        side: BorderSide(
                          // 100]
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300, // 101]
                        ), // 102]
                      ), // 64, 102]
                    ); // 65, 103]
                  }).toList(),
                ),
                const SizedBox(height: 32), // 65, 103]
                SizedBox(
                  width: double.infinity, // 65, 103]
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline), // 66, 104]
                    label: const Text("Save Reminder"), // 66, 104]
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // 66]
                      foregroundColor: Colors.white, // 67]
                      padding: const EdgeInsets.symmetric(vertical: 14), // 67]
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600), // 67]
                      shape: RoundedRectangleBorder(
                        // 68]
                        borderRadius: BorderRadius.circular(14), // 68]
                      ),
                    ),
                    onPressed: () {
                      provider.setReminderTime(selectedTime); // 69, 104]
                      Navigator.pop(context); // 69, 105]
                    },
                  ),
                ),
              ], // 70, 106]
            ),
          ),
        ),
      ); // 71, 107]
    },
  );
}
