import 'dart:io';

import 'package:dorry/main.dart';
import 'package:dorry/model/customer_model.dart';
import 'package:dorry/web_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dorry/controller/auth_controller.dart';
import 'package:dorry/utils/user_manager.dart';

class CustomerInfoScreen extends StatefulWidget {
  const CustomerInfoScreen({super.key});

  @override
  _CustomerInfoScreenState createState() => _CustomerInfoScreenState();
}

class _CustomerInfoScreenState extends State<CustomerInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final CustomerModel customer = CustomerManager.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المعلومات الشخصية'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('تسجيل الخروج'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                Get.find<AuthController>().signOut();
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple,
                child: Text(
                  customer!.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الاسم: ${customer.name}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'رقم الهاتف: ${customer.mobileNumber}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewScreen(
                      url: 'https://dorry.khidmatna.com/privacy-policy',
                      title: 'سياسة الخصوصية',
                    ),
                  ),
                );
              },
              child: const Text('سياسة الخصوصية'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewScreen(
                      url: 'https://dorry.khidmatna.com/terms-and-conditions',
                      title: 'الشروط والأحكام',
                    ),
                  ),
                );
              },
              child: const Text('الشروط والأحكام'),
            ),
            const SizedBox(height: 12),
            //if iphone.
            if (Platform.isIOS && showDeleteButton)
              ElevatedButton(
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('حذف الحساب'),
                      content: const Text(
                          'سيتم حذف معلومات الحساب بعد ١٤ يوم من الان، في حال قررت التراجع عن هذا القرار يمكن تسجيل الدخول قبل انقضاء المدة'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('موافق'),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true) {
                    // Implement account deletion logic here
                    Get.find<AuthController>().signOut();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('حذف الحساب'),
              ),
          ],
        ),
      ),
    );
  }
}
