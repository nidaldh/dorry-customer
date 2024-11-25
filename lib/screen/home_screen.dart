import 'dart:io';

import 'package:dorry/app_theme.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/main.dart';
import 'package:dorry/screen/appointments/appointment_list_screen.dart';
import 'package:dorry/screen/customer/customer_info_screen.dart';
import 'package:dorry/screen/qr_scanner_screen.dart';
import 'package:dorry/screen/store/store_list_screen.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:dorry/widget/base_scaffold_widget.dart';

// import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  void showNotificationDialog(RemoteNotification notification) {
    showDialog(
      context: appContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification.title ?? 'Notification'),
          content: Text(notification.body ?? 'You have a new message.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _getToken();
      FirebaseMessaging.instance.subscribeToTopic('all');
      // FirebaseInAppMessaging.instance.setMessagesSuppressed(false);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showNotificationDialog(message.notification!);
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future _getToken() async {
    final _firebaseMessaging = FirebaseMessaging.instance;
    String? token;
    if (Platform.isIOS) {
      String? apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        await _firebaseMessaging.subscribeToTopic('all');
      } else {
        await Future<void>.delayed(
          const Duration(
            seconds: 3,
          ),
        );
        apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          await _firebaseMessaging.subscribeToTopic('all');
          token = await FirebaseMessaging.instance.getToken();
        }
      }
    } else {
      await _firebaseMessaging.subscribeToTopic('all');
      token = await FirebaseMessaging.instance.getToken();
    }
    if (token != null && CustomerManager.token != null) {
      ApiService().postRequest(ApiUri.fcmToken, {'token': token});
    }
  }

  // List of pages corresponding to each tab
  final List<Widget> _pages = [
    const CustomerInfoScreen(),
    const StoreListScreen(),
    const QRScannerScreen(),
    const AppointmentsListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScaffoldWidget(
      showAppBar: false,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            activeIcon: Icon(Icons.explore_outlined),
            label: 'استكشف',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'المواعيد',
          ),
        ],
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: Sizes.elevation_1,
        iconSize: Sizes.iconSize_20,
        selectedFontSize: 12,
        unselectedFontSize: 12,
      ),
      title: '',
    );
  }
}
