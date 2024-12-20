import 'package:dorry/const/api_uri.dart';
import 'package:dorry/main.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

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
        // FlutterNativeSplash.remove();
        router.replace(needUpdatePath);
        return;
      }
      final token = await CustomerManager.getToken();
      if (token != null && await CustomerManager.customerInfo()) {
        await CustomerManager.getUser();
      } else {
        CustomerManager.clear();
      }
    } catch (e) {
      if (kDebugMode) print(e);
      CustomerManager.clear();
    }
    router.replace(homePath);
    // FlutterNativeSplash.remove();
  }

  Future<bool> _checkForUpdate() async {
    try {
      final response =
          await ApiService(isAuth: true).getRequest(ApiUri.checkForUpdate);
      if (response.statusCode == 200) {
        final data = response.data;
        showDeleteButton = data['showDeleteButton'] ?? false;
        hideWhatsappIcon = data['hideWhatsappIcon'] ?? false;
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
          padding: EdgeInsets.all(Sizes.paddingAll_20),
          margin: EdgeInsets.only(bottom: Sizes.height_25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Sizes.radius_10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Sizes.radius_10),
            child: const Image(
              image: AssetImage('assets/image/icon.png'),
            ),
          ),
        ),
      ),
    );
  }
}
