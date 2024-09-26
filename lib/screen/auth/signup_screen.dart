import 'package:dorry/controller/auth_controller.dart';
import 'package:dorry/model/gender_model.dart';
import 'package:dorry/model/response/auth/auth_failed_response_model.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:dorry/widget/auth_scaffold.dart';
import 'package:dorry/widget/auth_text_field.dart';
import 'package:dorry/widget/phone_number_field.dart';
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
  final _formKey = GlobalKey<FormState>();
  Map<String, String?> errors = {};
  bool isOtpSent = false;
  GenderModel? selectedGender;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      final response = await authController.signUpWithPhone(
        nameController.text,
        selectedGender!,
      );
      if (response is AuthFailedResponseModel) {
        setState(() {
          errors = {
            'name': response.data.name,
            'mobileNumber': response.data.mobileNumber,
            'password': response.data.password,
            'otp': response.data.otp,
          };
        });
      } else if (response == null) {
        successSnackBar('تم إرسال الرمز الى رقم الوتساب');

        setState(() {
          isOtpSent = true;
          errors = {};
        });
      }
    }
  }

  void _verifyOtp() async {
    try {
      final response = await authController.verifyOtp(
        otpController.text.trim(),
      );
      if (response is AuthFailedResponseModel) {
        setState(() {
          errors['otp'] = response.data.otp ?? response.message ?? 'حدث خطأ ما';
        });
      } else {
        setState(() {
          isOtpSent = true;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        errors['otp'] = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
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
                if (!isOtpSent) ...[
                  AuthTextField(
                    controller: nameController,
                    labelText: 'الاسم',
                    prefixIcon: Icons.person,
                    isPassword: false,
                    isPasswordVisible: false,
                    togglePasswordVisibility: () {},
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال الاسم';
                      }
                      return null;
                    },
                    errorText: errors['name'],
                  ),
                  const SizedBox(height: 16),
                  CustomPhoneNumberField(
                    authController: authController,
                    errorText: errors['mobileNumber'],
                    changeCountryCode: (code) {
                      authController.countryCode = code;
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(() => AuthTextField(
                        controller: authController.passwordController,
                        labelText: 'كلمة المرور',
                        prefixIcon: Icons.lock,
                        isPassword: true,
                        isPasswordVisible:
                            authController.isPasswordVisible.value,
                        togglePasswordVisibility:
                            authController.togglePasswordVisibility,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          return null;
                        },
                        errorText: errors['password'],
                      )),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<GenderModel>(
                    value: selectedGender,
                    decoration: InputDecoration(
                      labelText: 'الجنس',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: genderList.map((GenderModel gender) {
                      return DropdownMenuItem<GenderModel>(
                        value: gender,
                        child: Text(gender.name),
                      );
                    }).toList(),
                    onChanged: (GenderModel? newValue) {
                      setState(() {
                        selectedGender = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'الرجاء اختيار الجنس';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0C8B93),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إنشاء حساب',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  AuthTextField(
                    controller: otpController,
                    labelText: 'الرمز',
                    prefixIcon: Icons.lock,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال OTP';
                      }
                      return null;
                    },
                  ),
                  if (errors['otp'] != null && errors['otp']!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        errors['otp']!,
                        style: const TextStyle(color: Colors.red),
                      ),
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
                        'تحقق من OTP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
