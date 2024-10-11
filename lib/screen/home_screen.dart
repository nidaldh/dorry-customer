import 'dart:io';

import 'package:dorry/const/api_uri.dart';
import 'package:dorry/main.dart';
import 'package:dorry/screen/appointments/appointment_list_screen.dart';
import 'package:dorry/screen/customer/customer_info_screen.dart';
import 'package:dorry/screen/store/store_list_screen.dart';
import 'package:dorry/utils/api_service.dart';
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
        }
      }
    } else {
      await _firebaseMessaging.subscribeToTopic('all');
    }
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      ApiService().postRequest(ApiUri.fcmToken, {'token': token});
    }
  }

  // List of pages corresponding to each tab
  final List<Widget> _pages = [
    const CustomerInfoScreen(),
    const StoreListScreen(),
    const AppointmentsListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'المعلومات الشخصية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'قائمة الصالونات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'قائمة المواعيد',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
      ),
    );
  }
}
