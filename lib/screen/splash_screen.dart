import 'package:dorry/router.dart';
import 'package:dorry/utils/token_manager.dart';
import 'package:dorry/utils/user_manager.dart';
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
    final token = await TokenManager.getToken();
    if (token != null) {
      final user = await CustomerManager.getUser();
      if (user != null) {
        router.replace('/home');
        return;
      }
    }
    router.replace('/login');
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
