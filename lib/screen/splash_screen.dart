import 'package:dorry/const/api_uri.dart';
import 'package:dorry/model/response/auth/success_response_model.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/api_service.dart';
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
    final token = await CustomerManager.getToken();
    if (token != null && await _customerInfo()) {
      final user = await CustomerManager.getUser();

      if (user != null) {
        router.replace('/home');
        return;
      }
    }
    router.replace('/login');
  }

  Future<bool> _customerInfo() async {
    try {
      final response = await ApiService(isAuth: true).getRequest(ApiUri.info);
      if (response.statusCode == 200) {
        final data = SuccessResponseModel.fromJson(response.data);
        await CustomerManager.saveUser(data.customer, data.token);
        return true;
      }
    } catch (e) {
      CustomerManager.clear();
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
