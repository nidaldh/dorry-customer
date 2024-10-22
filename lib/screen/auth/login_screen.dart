import 'package:dorry/app_theme.dart';
import 'package:dorry/controller/auth_controller.dart';
import 'package:dorry/model/response/auth/auth_failed_response_model.dart';
import 'package:dorry/router.dart';
import 'package:dorry/widget/auth_text_field.dart';
import 'package:dorry/widget/base_scaffold_widget.dart';
import 'package:dorry/widget/phone_number_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final formKey = GlobalKey<FormState>(); // Key for form validation
  Map<String, String?> errors = {};
  bool isLoading = false; // Add this line

  void login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Show the progress indicator
      });

      final response = await authController.loginWithPhone();

      setState(() {
        isLoading = false; // Hide the progress indicator
      });

      if (response is AuthFailedResponseModel) {
        if (response.status == 'otp_required') {
          router.push('/verify-otp');
          return;
        }
        setState(() {
          errors = {
            'mobileNumber': response.data.mobileNumber,
            'password': response.data.password,
            'message': response.message,
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffoldWidget(
      title: null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            // Scrollable in case of smaller screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // App icon with rounded corners and shadow
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: const Image(
                      image: AssetImage('assets/image/icon.png'),
                    ),
                  ),
                ),
                CustomPhoneNumberField(
                  authController: authController,
                  errorText: errors['mobileNumber'] ?? errors['message'],
                  changeCountryCode: (code) {
                    authController.countryCode = code;
                  },
                ),
                const SizedBox(height: 24),
                // Password Field
                Obx(() => AuthTextField(
                      controller: authController.passwordController,
                      labelText: 'كلمة المرور',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      isPasswordVisible: authController.isPasswordVisible.value,
                      togglePasswordVisibility:
                          authController.togglePasswordVisibility,
                      errorText: errors['password'],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال كلمة المرور';
                        }
                        if (value.length < 6) {
                          return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Add forgot password logic
                      context.push('/forget-password');
                    },
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        color: Color(0xFF0C8B93),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Login Button with loading indicator
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    // Disable button when loading
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ), // Button text color
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign-up Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ليس لديك حساب؟',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/sign-up');
                      },
                      child: const Text(
                        'إنشاء حساب',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0C8B93),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
