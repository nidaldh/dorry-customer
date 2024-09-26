import 'package:dio/dio.dart';
import 'package:dorry/app_theme.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/controller/auth_controller.dart';
import 'package:dorry/model/response/auth/auth_failed_response_model.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/widget/auth_scaffold.dart';
import 'package:dorry/widget/phone_number_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final AuthController authController = Get.find<AuthController>();
  final formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? errorMessage;
  bool isOtpSent = false;
  bool isOtpVerified = false;
  String _resetPasswordToken = '';
  String statusMessage = '';

  void _resetPassword() async {
    if (formKey.currentState!.validate()) {
      final response = await authController.requestResetPassword();

      if (response is AuthFailedResponseModel) {
        setState(() {
          errorMessage = response.data.mobileNumber ?? response.message;
        });
      } else {
        setState(() {
          isOtpSent = true;
          errorMessage = null;
          statusMessage = 'أدخل رمز التحقق المرسل إلى الوتساب';
        });
      }
    }
  }

  void _verifyOtp() async {
    if (formKey.currentState!.validate()) {
      try {
        String phoneNumber = authController.phoneNumberController.text;
        phoneNumber = '${authController.countryCode}$phoneNumber';
        final response =
            await ApiService().postRequest(ApiUri.validateResetPasswordOtp, {
          'mobile_number': phoneNumber,
          'otp': otpController.text,
        });
        if (response.statusCode == 200) {
          _resetPasswordToken = response.data['token'];
          setState(() {
            isOtpVerified = true;
            errorMessage = null;
            statusMessage = 'ادخل كلمة المرور الجديدة';
          });
        }
      } catch (e) {
        if (e is DioException) {
          final res = AuthFailedResponseModel.fromJson(e.response!.data);
          setState(() {
            errorMessage = res.message;
          });
        }
      }
    }
  }

  Future<void> _updatePassword() async {
    if (formKey.currentState!.validate()) {
      final newPassword = newPasswordController.text;
      final confirmPassword = confirmPasswordController.text;
      if (newPassword == confirmPassword) {
        try {
          String phoneNumber = authController.phoneNumberController.text;
          phoneNumber = '${authController.countryCode}$phoneNumber';
          final response =
              await ApiService().postRequest('/api/customer/password/reset', {
            'mobile_number': phoneNumber,
            'token': _resetPasswordToken,
            'password': newPassword,
            'password_confirmation': confirmPassword,
          });
          if (response.statusCode == 200) {
            router.replace('/');
          }
        } catch (e) {
          if (e is DioException) {
            final res = AuthFailedResponseModel.fromJson(e.response!.data);
            setState(() {
              errorMessage = res.message;
            });
          }
        }
      } else {
        setState(() {
          errorMessage = 'كلمات المرور غير متطابقة';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: const Image(
                      image: AssetImage('assets/image/icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (statusMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      statusMessage,
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (!isOtpSent) ...[
                  CustomPhoneNumberField(
                    authController: authController,
                    changeCountryCode: (code) {
                      authController.countryCode = code;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0C8B93),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إعادة تعيين كلمة المرور',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else if (!isOtpVerified) ...[
                  TextFormField(
                    controller: otpController,
                    decoration: InputDecoration(
                      labelText: 'رمز التحقق',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رمز التحقق';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0C8B93),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'تحقق',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  TextFormField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الجديدة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كلمة المرور الجديدة';
                      }
                      if (value.length < 6) {
                        return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء تأكيد كلمة المرور';
                      }
                      if (value != newPasswordController.text) {
                        return 'كلمات المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updatePassword,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0C8B93),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'تحديث كلمة المرور',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
