import 'package:dorry/controller/auth_controller.dart';
import 'package:dorry/model/response/auth/auth_failed_response_model.dart';
import 'package:dorry/widget/auth_scaffold.dart';
import 'package:dorry/widget/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController authController = Get.find<AuthController>();
  final nameController = TextEditingController();
  final otpController = TextEditingController();
  Map<String, String> errors = {};
  bool isOtpSent = false;

  void _signUp() async {
    final response = await authController.signUpWithPhone(
      authController.phoneNumberController.text,
      authController.passwordController.text,
      nameController.text,
    );

    if (response is AuthFailedResponseModel) {
      setState(() {
        errors = {
          'name': response.data.name ?? '',
          'mobileNumber': response.data.mobileNumber ?? '',
          'password': response.data.password ?? '',
          'otp': response.data.otp ?? '',
        };
      });
    } else if (response == null) {
      setState(() {
        isOtpSent = true;
        errors = {};
      });
    }
  }

  void _verifyOtp() async {
    try {
      final response = await authController.verifyOtp(
        authController.phoneNumberController.text.trim(),
        otpController.text.trim(),
      );
      if (response is AuthFailedResponseModel) {
        setState(() {
          // phoneError = response.data.mobileNumber;
        });
      } else {
        setState(() {
          isOtpSent = true;
        });
      }
    } catch (e) {
      setState(() {
        errors['otp'] = e.toString();
      });
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!isOtpSent) ...[
            AuthTextField(
              controller: nameController,
              labelText: 'الاسم',
              prefixIcon: Icons.person,
            ),
            if (errors['name'] != null && errors['name']!.isNotEmpty)
              Text(errors['name']!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            AuthTextField(
              controller: authController.phoneNumberController,
              labelText: 'رقم الهاتف',
              prefixIcon: Icons.phone,
            ),
            if (errors['mobileNumber'] != null &&
                errors['mobileNumber']!.isNotEmpty)
              Text(errors['mobileNumber']!,
                  style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            Obx(() => AuthTextField(
                  controller: authController.passwordController,
                  labelText: 'كلمة المرور',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  isPasswordVisible: authController.isPasswordVisible.value,
                  togglePasswordVisibility:
                      authController.togglePasswordVisibility,
                )),
            if (errors['password'] != null && errors['password']!.isNotEmpty)
              Text(errors['password']!,
                  style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            // Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'إنشاء حساب',
                  style: TextStyle(
                    color: Color(0xFF6A1B9A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            AuthTextField(
              controller: otpController,
              labelText: 'OTP',
              prefixIcon: Icons.lock,
            ),
            if (errors['otp'] != null && errors['otp']!.isNotEmpty)
              Text(errors['otp']!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            // Verify OTP Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'تحقق من OTP',
                  style: TextStyle(
                    color: Color(0xFF6A1B9A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
