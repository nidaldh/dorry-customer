import 'package:dorry/controller/auth_controller.dart';
import 'package:dorry/router.dart';
import 'package:dorry/widget/auth_scaffold.dart';
import 'package:dorry/widget/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AuthTextField(
            controller: authController.phoneNumberController,
            labelText: 'رقم الهاتف',
            prefixIcon: Icons.phone,
          ),
          const SizedBox(height: 16),
          Obx(() => AuthTextField(
            controller: authController.passwordController,
            labelText: 'كلمة المرور',
            prefixIcon: Icons.lock,
            isPassword: true,
            isPasswordVisible: authController.isPasswordVisible.value,
            togglePasswordVisibility: authController.togglePasswordVisibility,
          )),
          const SizedBox(height: 8),
          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Add forgot password logic
              },
              child: const Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Login Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: authController.loginWithPhone,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  color: Color(0xFF6A1B9A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Sign Up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ليس لديك حساب؟',
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  router.push('/sign-up');
                },
                child: const Text(
                  'إنشاء حساب',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}