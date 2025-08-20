import 'dart:convert';
import 'package:etsport/pages/acc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Assuming these providers exist or are defined below
// (Keeping them here for clarity if you have them in separate files)
import 'providers/break_provider.dart';
import 'providers/theme_provider.dart';

// --- ReminderProvider Class (formerly in providers/reminder_provider.dart) ---
class ReminderProvider with ChangeNotifier {
  TimeOfDay? _reminderTime;
  List<String> _selectedDays = [];

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _baseNotificationId = 200;

  ReminderProvider() {
    // tz.initializeTimeZones() is now handled globally in main()
    _initNotifications();
    _loadSavedPreferences();

    // Debug print for ReminderProvider's view of local timezone
    final now = tz.TZDateTime.now(tz.local);
    print('ReminderProvider: tz.local name: ${tz.local.name}');
    print(
        'ReminderProvider: tz.local offset: ${now.timeZoneOffset.inHours} hours');
    print('ReminderProvider: Current tz.local time: $now');
  }

  TimeOfDay? get reminderTime => _reminderTime;
  List<String> get selectedDays => _selectedDays;

  Future<void> _initNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(); // Added iOS settings
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _notifications.initialize(settings);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel',
      'Workout Reminders',
      description: 'Scheduled workout notifications',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getString('reminder_time');
    final savedDays = prefs.getString('reminder_days');

    if (savedTime != null) {
      final parts = savedTime.split(':');
      _reminderTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    if (savedDays != null) {
      _selectedDays = List<String>.from(jsonDecode(savedDays));
    }

    notifyListeners();
  }

  // Renamed to updateReminder to encapsulate both time and day changes
  Future<void> updateReminder(
      {TimeOfDay? newTime, List<String>? newDays}) async {
    if (newTime != null) {
      _reminderTime = newTime;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'reminder_time', '${newTime.hour}:${newTime.minute}');
    }
    if (newDays != null) {
      _selectedDays = newDays;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reminder_days', jsonEncode(newDays));
    }
    // Always reschedule when reminder settings change
    await _scheduleReminders();
    notifyListeners();
  }

  void toggleDay(String day) {
    if (_selectedDays.contains(day)) {
      _selectedDays.remove(day);
    } else {
      _selectedDays.add(day);
    }
    // No direct call to _scheduleReminders here. It will be called by updateReminder
    // when changes are finalized or user explicitly saves.
    notifyListeners(); // Notify UI instantly for selection change
  }

  Future<void> _scheduleReminders() async {
    await _notifications.cancelAll();

    if (_reminderTime == null || _selectedDays.isEmpty) {
      print(
          "❗ Reminder time or days not set. Cancelling all custom reminders.");
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    final hour = _reminderTime!.hour;
    final minute = _reminderTime!.minute;

    print("🔁 Scheduling reminders at $hour:$minute on days $_selectedDays");
    print('Current tz.local time used for scheduling check: $now');

    for (String day in _selectedDays) {
      final weekday = _dayToWeekdayInt(day);
      if (weekday == null) continue;

      tz.TZDateTime scheduledDate =
          _nextInstanceOfWeekday(weekday, hour, minute);
      print(
          "📆 Will schedule for $day at $scheduledDate (TZ: ${scheduledDate.location.name}, Offset: ${scheduledDate.timeZoneOffset.inHours}h)");

      await _notifications.zonedSchedule(
        _baseNotificationId + weekday,
        '⏰ Workout Reminder',
        'It’s time for your workout!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Workout Reminders',
            channelDescription: 'Scheduled workout notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  int? _dayToWeekdayInt(String day) {
    switch (day) {
      case 'Mon':
        return DateTime.monday;
      case 'Tue':
        return DateTime.tuesday;
      case 'Wed':
        return DateTime.wednesday;
      case 'Thu':
        return DateTime.thursday;
      case 'Fri':
        return DateTime.friday;
      case 'Sat':
        return DateTime.saturday;
      case 'Sun':
        return DateTime.sunday;
      default:
        return null;
    }
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    _reminderTime = null;
    _selectedDays.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reminder_time');
    await prefs.remove('reminder_days');
    notifyListeners();
  }
}

// --- NotificationProvider Class (formerly in providers/notification_provider.dart) ---
class NotificationProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  static const String _channelId = 'main_channel';
  static const String _channelName = 'Workout Reminders';
  static const String _channelDescription = 'Reminders to stay active';

  NotificationProvider() {
    // tz.initializeTimeZones() is now handled globally in main()
    _initialize();

    // Debug print for NotificationProvider's view of local timezone
    final now = tz.TZDateTime.now(tz.local);
    print('NotificationProvider: tz.local name: ${tz.local.name}');
    print(
        'NotificationProvider: tz.local offset: ${now.timeZoneOffset.inHours} hours');
    print('NotificationProvider: Current tz.local time: $now');
  }

  Future<void> _initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings();
    final settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final status = await Permission.notification.status;
    final prefs = await SharedPreferences.getInstance();
    final savedPreference = prefs.getBool('notifications_enabled') ?? false;

    _isEnabled = status.isGranted && savedPreference;

    if (!_isEnabled) {
      await _plugin.cancelAll();
    }

    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (enabled) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        _isEnabled = true;
        await prefs.setBool('notifications_enabled', true);
        await scheduleWeeklyNotifications(); // ⬅ Schedule when enabled
      } else {
        _isEnabled = false;
        await prefs.setBool('notifications_enabled', false);
        await _plugin.cancelAll();
      }
    } else {
      _isEnabled = false;
      await prefs.setBool('notifications_enabled', false);
      await _plugin.cancelAll();
    }

    notifyListeners();
  }

  Future<void> scheduleWeeklyNotifications() async {
    if (!_isEnabled) return;

    final now = tz.TZDateTime.now(tz.local);
    final time =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 12); // 12:00 PM
    final List<int> weekdays = [DateTime.monday, DateTime.thursday];
    int id = 100;
    print(
        'NotificationProvider: Current tz.local time for weekly scheduling: $now');

    for (int weekday in weekdays) {
      tz.TZDateTime scheduledDate = _nextInstanceOfWeekday(time, weekday);

      print(
          "NotificationProvider: Will schedule weekly for weekday $weekday at $scheduledDate (TZ: ${scheduledDate.location.name}, Offset: ${scheduledDate.timeZoneOffset.inHours}h)");

      await _plugin.zonedSchedule(
        id++,
        '🏋️ Time to Work Out!',
        'Don’t forget your workout today! 💪',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }

    print('✅ Scheduled workout reminders for Monday and Thursday at 12:00 PM');
  }

  tz.TZDateTime _nextInstanceOfWeekday(tz.TZDateTime time, int weekday) {
    var scheduledDate = tz.TZDateTime(
        tz.local, time.year, time.month, time.day, time.hour, time.minute);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    // If the scheduled date is in the past, add 7 days to get the next occurrence
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }

  Future<void> triggerTestNotification() async {
    if (!_isEnabled) {
      print('Notification is disabled.');
      return;
    }

    await _plugin.show(
      999,
      '🚀 Workout Reminder',
      'This is your test notification! 💪',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'test',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    _isEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', false);
    notifyListeners();
  }
}

// --- BreakProvider (Assuming this is external, or defined here) ---

// --- SettingsPage Class (UPDATED TO INCORPORATE NOTIFICATIONPAGE LOGIC) ---
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Use a temporary list for UI selection before committing to ReminderProvider
  List<String> _tempSelectedDays = [];
  TimeOfDay _tempSelectedTime = const TimeOfDay(hour: 8, minute: 0);

  // Weekday mapping for UI
  final List<String> _uiDaysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      _checkNotificationPermission(notificationProvider);

      // Initialize temporary state from ReminderProvider's current state
      final reminderProvider =
          Provider.of<ReminderProvider>(context, listen: false);
      _tempSelectedDays = List.from(reminderProvider.selectedDays);
      _tempSelectedTime =
          reminderProvider.reminderTime ?? const TimeOfDay(hour: 8, minute: 0);
      setState(() {}); // Update local state for UI
    });
  }

  Future<void> _checkNotificationPermission(
      NotificationProvider provider) async {
    final status = await Permission.notification.status;
    if (status.isGranted) {
      await provider.toggleNotifications(true);
    } else {
      await provider.toggleNotifications(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final subtitleColor =
        isDark ? Colors.black54 : Colors.black54; // Adjust as needed
    final notificationProvider = Provider.of<NotificationProvider>(context);

    final dynamicTextColor =
        themeProvider.isDarkMode ? Colors.green : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Notifications toggle
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              return Card(
                color:
                    themeProvider.isDarkMode ? Colors.grey[200] : Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_active,
                    color: Colors.green,
                  ),
                  title: Text(
                    "Notifications",
                    style: GoogleFonts.poppins(
                      color: dynamicTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    notificationProvider.isEnabled ? "ON" : "OFF",
                    style: GoogleFonts.poppins(
                      color: notificationProvider.isEnabled
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  trailing: Switch(
                    value: notificationProvider.isEnabled,
                    activeColor: Colors.green,
                    onChanged: (val) async {
                      if (val) {
                        final status = await Permission.notification.request();
                        if (status.isGranted) {
                          await notificationProvider.toggleNotifications(true);
                        } else if (status.isPermanentlyDenied) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Notification permission permanently denied. Enable it in settings.',
                              ),
                              backgroundColor: Colors.red,
                              action: SnackBarAction(
                                label: 'Settings',
                                textColor: Colors.white,
                                onPressed: () => openAppSettings(),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Notification permission is required.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        await notificationProvider.toggleNotifications(false);
                      }
                    },
                  ),
                  onTap: () async {
                    if (notificationProvider.isEnabled) {
                      await notificationProvider.toggleNotifications(false);
                    } else {
                      final status = await Permission.notification.request();
                      if (status.isGranted) {
                        await notificationProvider.toggleNotifications(true);
                      } else if (status.isPermanentlyDenied) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Notification permission permanently denied. Enable it in settings.',
                            ),
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: 'Settings',
                              textColor: Colors.white,
                              onPressed: () => openAppSettings(),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Notification permission is required.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Consumer<BreakProvider>(
            builder: (context, breakProvider, _) {
              return Card(
                color:
                    themeProvider.isDarkMode ? Colors.grey[200] : Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(
                    Icons.timer,
                    color: Colors.green,
                  ),
                  title: Text(
                    "Break Duration",
                    style: GoogleFonts.poppins(
                      color: dynamicTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "${breakProvider.breakSeconds} seconds",
                    style: GoogleFonts.poppins(color: subtitleColor),
                  ),
                  trailing: Icon(Icons.edit, color: Colors.grey.shade600),
                  onTap: () async {
                    final controller = TextEditingController(
                        text: breakProvider.breakSeconds.toString());
                    final result = await showDialog<int>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        title: Text(
                          "Set Break Duration (seconds)",
                          style: GoogleFonts.poppins(
                            color: dynamicTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(color: dynamicTextColor),
                          decoration: InputDecoration(
                            labelText: "Break seconds",
                            labelStyle: TextStyle(color: subtitleColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: subtitleColor),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Cancel",
                                style: GoogleFonts.poppins(color: Colors.red)),
                          ),
                          TextButton(
                            onPressed: () {
                              final value = int.tryParse(controller.text);
                              if (value != null && value > 0) {
                                Navigator.of(context).pop(value);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Please enter a valid positive number.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Text("Save",
                                style:
                                    GoogleFonts.poppins(color: Colors.green)),
                          ),
                        ],
                      ),
                    );
                    if (result != null) {
                      breakProvider.setBreakSeconds(result);
                    }
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Break duration
          /*  Consumer<ReminderProvider>(
            builder: (context, reminderProvider, _) {
              // Sync local temp state for _tempSelectedDays only if provider state changes
              if (!listEquals(
                  _tempSelectedDays, reminderProvider.selectedDays)) {
                _tempSelectedDays = List.from(reminderProvider.selectedDays);
              }
              // Removed _tempSelectedTime synchronization here.
              // It is now initialized in initState and updated by setState when picker is used.

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.grey[200]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.alarm,
                            color: Colors.green,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Custom Workout Reminder",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: dynamicTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Select Days
                    Text('Repeat on:',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: dynamicTextColor)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _uiDaysOfWeek.map((day) {
                        final selected = _tempSelectedDays.contains(day);
                        return FilterChip(
                          label: Text(day,
                              style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : dynamicTextColor)),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              // Update local UI state
                              selected
                                  ? _tempSelectedDays.remove(day)
                                  : _tempSelectedDays.add(day);
                            });
                          },
                          selectedColor: Colors.green,
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: selected
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Select Time
                    Row(
                      children: [
                        Text('Reminder Time:',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: dynamicTextColor)),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime:
                                  _tempSelectedTime, // Uses local state
                            );
                            if (time != null) {
                              setState(() => _tempSelectedTime =
                                  time); // Updates local state
                            }
                          },
                          child: Text(
                            _tempSelectedTime
                                .format(context), // Displays local state
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.notifications),
                        label: const Text('Save & Schedule Reminders'),
                        onPressed: () async {
                          // Commit temporary UI state to Provider and trigger scheduling
                          await reminderProvider.updateReminder(
                            newTime: _tempSelectedTime,
                            newDays: _tempSelectedDays,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Reminders updated and scheduled!')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          reminderProvider.cancelAllReminders();
                          setState(() {
                            // Clear local UI state after cancelling
                            _tempSelectedDays.clear();
                            _tempSelectedTime = TimeOfDay
                                .now(); // Reset to current time after clearing
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Custom reminders cancelled.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: Icon(Icons.cancel_outlined, color: Colors.red),
                        label: Text(
                          "Cancel Custom Reminders",
                          style: GoogleFonts.poppins(
                              color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Test buttons remain for debugging notifications
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Trigger a test reminder 1 minute from now
              final now = TimeOfDay.now();
              final testTime = TimeOfDay(
                hour: now.hour,
                minute: (now.minute + 1) % 60,
              );
              // Set the reminder for today, 1 minute later
              Provider.of<ReminderProvider>(context, listen: false)
                  .updateReminder(
                      newTime: testTime,
                      newDays: [_dayIntToString(DateTime.now().weekday)]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Test reminder set for 1 minute later on current day.')),
              );
            },
            child: Text("Test Reminder in 1 Minute (Current Day)"),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.notifications_active),
            label: Text("Test Immediate Notification"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final plugin = FlutterLocalNotificationsPlugin();
              final permissionStatus = await Permission.notification.status;
              if (!permissionStatus.isGranted) {
                final result = await Permission.notification.request();
                if (!result.isGranted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification permission denied.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
              }

              final now = tz.TZDateTime.now(tz.local);
              print(
                  'Test Immediate Notification: current tz.local time: $now (TZ: ${now.location.name}, Offset: ${now.timeZoneOffset.inHours}h)');

              await plugin.show(
                998, // Unique ID
                '🚀 Test Reminder',
                'This is an immediate test notification from Tena+ 💪',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'reminder_channel', // Use an existing channel or define a new one
                    'Workout Reminders',
                    channelDescription: 'Immediate test notifications',
                    importance: Importance.max,
                    priority: Priority.high,
                    playSound: true,
                  ),
                  iOS: DarwinNotificationDetails(),
                ),
                payload: 'test_immediate',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚀 Immediate test notification triggered!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () async {
              final plugin = FlutterLocalNotificationsPlugin();

              const AndroidInitializationSettings androidSettings =
                  AndroidInitializationSettings('@mipmap/ic_launcher');
              const DarwinInitializationSettings iosSettings =
                  DarwinInitializationSettings();
              const InitializationSettings settings = InitializationSettings(
                android: androidSettings,
                iOS: iosSettings,
              );

              await plugin.initialize(settings);

              final now = DateTime
                  .now(); // Using DateTime.now() for simple system time check
              final String notificationTime =
                  "${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

              print(
                  'Immediate Notification: current DateTime.now(): $now (UTC offset: ${now.timeZoneOffset.inHours}h)');

              await plugin.show(
                1234,
                '🎯 Immediate Test',
                'This appeared at $notificationTime. Notifications are working!',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'immediate_channel',
                    'Immediate',
                    channelDescription: 'Immediate test',
                    importance: Importance.max,
                    priority: Priority.high,
                  ),
                  iOS: DarwinNotificationDetails(),
                ),
              );
            },
            child: Text("Show Immediate Notification (system time)"),
          ),*/
        ],
      ),
    );
  }

  // Helper to convert weekday int to String for the test button
  String _dayIntToString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}

// Utility function to compare two lists (used in _SettingsPageState)
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
