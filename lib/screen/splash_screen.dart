import 'package:dorry/constants.dart';
import 'package:dorry/screen/create_store_screen.dart';
import 'package:dorry/screen/home_screen.dart';
import 'package:dorry/screen/login_screen.dart';
import 'package:dorry/utils/token_manager.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUser();
  }

  void checkUser() async {
    final token = await TokenManager.getToken();
    if (token != null) {
      final user = await UserManager.getUser();
      if (user != null) {
        final store = await UserManager.getStore();
        if (store != null) {
          // Get.offAll(() => HomeScreen(type: store.storeType));
          Get.offAll(() => HomeScreen());
        } else {
          Get.offAll(() => const CreateStoreScreen());
        }
      } else {
        Get.offAll(() => const LoginScreen());
      }
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              Constants.appTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}