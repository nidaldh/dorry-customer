import 'dart:io';

import 'package:dorry/controller/common_controller.dart';
import 'package:dorry/main.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:dorry/web_view_screen.dart';
import 'package:dorry/widget/base_scaffold_widget.dart';
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
    return GetBuilder<CommonController>(
      id: 'customer_info',
      builder: (logic) {
        return BaseScaffoldWidget(
          title: null,
          actions: CustomerManager.user != null
              ? [
                  IconButton(
                    onPressed: () async {
                      final shouldLogout = await _showLogoutDialog(context);
                      if (shouldLogout == true) {
                        Get.find<AuthController>().signOut();
                      }
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ]
              : [],
          showBackButton: false,
          body: Padding(
            padding: EdgeInsets.all(Sizes.paddingAll_12),
            child: CustomerManager.user == null
                ? _buildLoggedOutView(context)
                : _buildLoggedInView(context),
          ),
        );
      },
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
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
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text('الرجاء تسجيل الدخول لعرض معلومات الحساب'),
        ),
        SizedBox(height: Sizes.height_20),
        ElevatedButton(
          onPressed: () {
            router.push(loginPath);
          },
          child: const Text('تسجيل الدخول'),
        ),
        SizedBox(height: Sizes.height_20),
        ElevatedButton(
          onPressed: () {
            router.push(developerInfoPath);
          },
          child: const Text('تواصل معنا'),
        ),
      ],
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CircleAvatar(
            radius: Sizes.radius_50,
            backgroundColor: Colors.deepPurple,
            child: Text(
              CustomerManager.user!.name[0].toUpperCase(),
              style:
                  TextStyle(fontSize: Sizes.textSize_40, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: Sizes.height_20),
        _buildUserInfoCard(context),
        SizedBox(height: Sizes.height_20),
        ElevatedButton(
          onPressed: () {
            router.push(developerInfoPath);
          },
          child: const Text('تواصل معنا'),
        ),
        SizedBox(height: Sizes.height_10),
        if (Platform.isIOS && showDeleteButton)
          ElevatedButton(
            onPressed: () async {
              final shouldDelete = await _showDeleteAccountDialog(context);
              if (shouldDelete == true) {
                Get.find<AuthController>().signOut();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف الحساب'),
          ),
        _buildPrivacyAndTermsLinks(context),
      ],
    );
  }

  Future<bool?> _showDeleteAccountDialog(BuildContext context) {
    return showDialog<bool>(
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
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
      elevation: Sizes.elevation_4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radius_10),
      ),
      child: Padding(
        padding: EdgeInsets.all(Sizes.paddingAll_16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الاسم: ${CustomerManager.user!.name}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: Sizes.height_8),
            Text(
              'رقم الهاتف: ${CustomerManager.user!.mobileNumber}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyAndTermsLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WebViewScreen(
                  url: 'https://dorry.khidmatna.com/privacy-policy',
                  title: 'سياسة الخصوصية',
                ),
              ),
            );
          },
          child: const Text('سياسة الخصوصية'),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WebViewScreen(
                  url: 'https://dorry.khidmatna.com/terms-and-conditions',
                  title: 'الشروط والأحكام',
                ),
              ),
            );
          },
          child: const Text('الشروط والأحكام'),
        ),
      ],
    );
  }
}
