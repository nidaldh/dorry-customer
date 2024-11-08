import 'dart:io';

import 'package:dorry/app_theme.dart';
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
import 'package:qr_flutter/qr_flutter.dart';

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
                    tooltip: 'تسجيل الخروج',
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
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 100, color: kPrimaryColor),
            SizedBox(height: Sizes.height_20),
            Text(
              'قم بتسجيل الدخول للوصول إلى حسابك',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Sizes.height_20),
            ElevatedButton(
              onPressed: () {
                router.push(loginPath);
              },
              child: const Text('تسجيل الدخول'),
            ),
            SizedBox(height: Sizes.height_20),
            TextButton(
              onPressed: () {
                router.push(developerInfoPath);
              },
              child: const Text('تواصل معنا'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    final user = CustomerManager.user!;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'مرحبا، ${user.name}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: Sizes.height_20),
          if (user.qrCode != null)
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: kPrimaryColor,
                      width: 2,
                    ),
                  ),
                  child: QrImageView(
                    data: user.prepareForQrCode(),
                    version: QrVersions.auto,
                    size: Sizes.size_200,
                    semanticsLabel: 'رمز الاستجابة السريعة',
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: kPrimaryColor,
                    ),
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'رمز الاضافة السريعة',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          SizedBox(height: Sizes.height_20),
          _buildUserInfoCard(context),
          SizedBox(height: Sizes.height_20),
          ListTile(
            title: Text('تعديل المعلومات'),
            leading: Icon(Icons.edit),
            onTap: () {
              router.push(customerFormPath);
            },
          ),
          Divider(),
          ListTile(
            title: Text('تواصل معنا'),
            leading: Icon(Icons.contact_mail),
            onTap: () {
              router.push(developerInfoPath);
            },
          ),
          SizedBox(height: Sizes.height_10),
          if (Platform.isIOS && showDeleteButton)
            ElevatedButton.icon(
              onPressed: () async {
                final shouldDelete = await _showDeleteAccountDialog(context);
                if (shouldDelete == true) {
                  // Call delete account function here
                  // For example: await AuthController.deleteAccount();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              icon: Icon(Icons.delete_forever),
              label: const Text('حذف الحساب'),
            ),
          SizedBox(height: Sizes.height_20),
          _buildPrivacyAndTermsLinks(context),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteAccountDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
            'سيتم حذف معلومات الحساب بعد ١٤ يومًا من الآن. إذا قررت التراجع عن هذا القرار، يمكنك تسجيل الدخول قبل انقضاء المدة.'),
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
    final user = CustomerManager.user!;
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
            _buildUserInfoRow(Icons.person, 'الاسم', user.name),
            Divider(),
            _buildUserInfoRow(Icons.phone, 'رقم الهاتف', user.mobileNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: kPrimaryColor),
        SizedBox(width: Sizes.width_8),
        Text(
          '$label: $value',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildPrivacyAndTermsLinks(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Sizes.height_10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLinkText(
            context,
            'سياسة الخصوصية',
            'https://dorry.khidmatna.com/privacy-policy',
          ),
          SizedBox(width: Sizes.width_20),
          _buildLinkText(
            context,
            'الشروط والأحكام',
            'https://dorry.khidmatna.com/terms-and-conditions',
          ),
        ],
      ),
    );
  }

  Widget _buildLinkText(BuildContext context, String text, String url) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebViewScreen(
              url: url,
              title: text,
            ),
          ),
        );
      },
      child: Text(
        text,
        style: TextStyle(
          color: kPrimaryColor,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
