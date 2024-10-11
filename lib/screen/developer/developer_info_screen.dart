import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperInfoScreen extends StatefulWidget {
  const DeveloperInfoScreen({super.key});

  @override
  _DeveloperInfoScreenState createState() => _DeveloperInfoScreenState();
}

class _DeveloperInfoScreenState extends State<DeveloperInfoScreen> {
  String buildNumber = '';
  String buildVersion = '';
  String developerPhone = '+970595998795';

  @override
  void initState() {
    super.initState();
    _fetchBuildInfo();
  }

  Future<void> _fetchBuildInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      buildNumber = packageInfo.buildNumber;
      buildVersion = packageInfo.version;
    });
  }

  Future<void> _launchWhatsApp() async {
    final url = 'https://wa.me/$developerPhone';
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
        title: const Text('معلومات المطور'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            _buildAppInfoSection(),
            const SizedBox(height: 32),
            _buildContactSection(),
            const SizedBox(height: 32),
            _buildFooterMessage(),
          ],
        ),
      ),
    );
  }

  // Widget for the app description and vision statement
  Widget _buildAppInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "في 'دوري'، نؤمن بأن التعاون هو مفتاح النجاح. نسعى معًا لبناء مجتمع يسهل فيه حجز المواعيد واستغلال الوقت بشكل أفضل. شاركنا أفكارك ومقترحاتك حول كيفية تحسين تطبيق 'دوري' لتلبية احتياجاتك بشكل كامل. معًا، يمكننا خلق تجربة استثنائية.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.build, color: Colors.blueAccent, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Version: $buildVersion (Build $buildNumber)',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget for the contact section
  Widget _buildContactSection() {
    return Column(
      children: [
        const Text(
          'للتواصل مع المطور:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _launchWhatsApp,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.greenAccent[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.message, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  developerPhone,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget for the footer message
  Widget _buildFooterMessage() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          'شكراً لاستخدامكم تطبيق دوري! نأمل أن يكون هذا التطبيق مساعداً لكم ولأعمالكم.',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}