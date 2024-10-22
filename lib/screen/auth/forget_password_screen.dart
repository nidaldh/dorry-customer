import 'package:dio/dio.dart';
import 'package:dorry/app_theme.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/controller/auth_controller.dart';
import 'package:dorry/model/response/auth/auth_failed_response_model.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:dorry/utils/validators.dart';
import 'package:dorry/widget/base_scaffold_widget.dart';
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
  String statusMessage = 'أدخل رقم الهاتف الخاص بك لإعادة تعيين كلمة المرور';
  bool isLoading = false;

  void _resetPassword() async {
    setState(() {
      isLoading = true;
    });
    if (formKey.currentState!.validate()) {
      try {
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
      } catch (e) {
        if (e is DioException) {
          final res = AuthFailedResponseModel.fromJson(e.response!.data);
          setState(() {
            errorMessage = res.message;
          });
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void _verifyOtp() async {
    setState(() {
      isLoading = true;
    });
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
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updatePassword() async {
    setState(() {
      isLoading = true;
    });
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
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffoldWidget(
      title: 'إعادة تعيين كلمة المرور',
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.horizontal_16),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: Sizes.height_20),
                if (statusMessage.isNotEmpty)
                  Text(
                    statusMessage,
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: Sizes.textSize_18,
                    ),
                  ),
                SizedBox(height: Sizes.height_20),
                if (!isOtpSent) ...[
                  CustomPhoneNumberField(
                    authController: authController,
                    changeCountryCode: (code) {
                      authController.countryCode = code;
                    },
                  ),
                  SizedBox(height: Sizes.height_20),
                  submitButton(_resetPassword, 'إرسال رمز التحقق'),
                ] else if (!isOtpVerified) ...[
                  TextFormField(
                    controller: otpController,
                    decoration: InputDecoration(
                      labelText: 'رمز التحقق',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Sizes.radius_10),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: Sizes.vertical_15,
                          horizontal: Sizes.horizontal_16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رمز التحقق';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Sizes.height_20),
                  submitButton(_verifyOtp, 'تحقق'),
                ] else ...[
                  TextFormField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الجديدة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Sizes.radius_10),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: Sizes.vertical_15,
                          horizontal: Sizes.horizontal_16),
                    ),
                    obscureText: true,
                    validator: Validators.validatePassword,
                  ),
                  SizedBox(height: Sizes.height_16),
                  TextFormField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.radius_10),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: Sizes.vertical_15,
                            horizontal: Sizes.horizontal_16),
                      ),
                      obscureText: true,
                      validator: (value) {
                        return Validators.confirmPassword(
                            value, newPasswordController.text);
                      }),
                  SizedBox(height: Sizes.height_20),
                  submitButton(_updatePassword, 'تحديث كلمة المرور'),
                ],
                if (errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: Sizes.paddingAll_8),
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

  Widget submitButton(VoidCallback? onPressed, String label) {
    return SizedBox(
      width: double.infinity,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: kPrimaryColor,
                padding: EdgeInsets.symmetric(vertical: Sizes.vertical_15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.radius_10),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: Sizes.textSize_18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
