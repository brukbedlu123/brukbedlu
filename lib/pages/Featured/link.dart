import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TestLinkScreen extends StatelessWidget {
  final Uri testUri = Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Link')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            if (await canLaunchUrl(testUri)) {
              await launchUrl(testUri, mode: LaunchMode.platformDefault);
            } else {
              print('❌ Could not launch URL');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open test link')),
              );
            }
          },
          child: Text('Open YouTube Link'),
        ),
      ),
    );
  }
}
