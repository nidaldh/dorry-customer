import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  Future<void> _launchStore() async {
    const url = 'https://apps.apple.com/vn/app/dorry/id6711327053';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديث مطلوب'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'يتوفر إصدار جديد من التطبيق. يرجى التحديث للمتابعة.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _launchStore,
                child: const Text('تحديث الآن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
