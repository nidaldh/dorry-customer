import 'package:dorry/const/api_uri.dart';
import 'package:dorry/main.dart';
import 'package:dorry/model/response/auth/success_response_model.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    try {
      if (await _checkForUpdate()) {
        router.replace(needUpdatePath);
        return;
      }
      final token = await CustomerManager.getToken();
      if (token != null && await CustomerManager.customerInfo()) {
        await CustomerManager.getUser();
        router.replace(homePath);
        return;
      }
    } catch (e) {
      if (kDebugMode) print(e);
      CustomerManager.clear();
    }
    router.replace(homePath);
  }

  Future<bool> _checkForUpdate() async {
    try {
      final response =
          await ApiService(isAuth: true).getRequest(ApiUri.checkForUpdate);
      if (response.statusCode == 200) {
        final data = response.data;
        showDeleteButton = data['showDeleteButton'] ?? false;
        return data['needsUpdate'] ?? false;
      }
    } catch (e) {
      if (kDebugMode) print(e);
      showDeleteButton = false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const Image(
              image: AssetImage('assets/image/icon.png'),
            ),
          ),
        ),
      ),
    );
  }
}
