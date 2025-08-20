import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied ||
      await Permission.notification.isPermanentlyDenied) {
    final status = await Permission.notification.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      // Optional: Guide user to settings if permanently denied
      openAppSettings(); // Opens device settings for this app
    }
  }
}
