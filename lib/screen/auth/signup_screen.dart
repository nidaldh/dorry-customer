import 'package:dorry/app_theme.dart';
import 'package:dorry/controller/auth_controller.dart';
import 'package:dorry/model/gender_model.dart';
import 'package:dorry/model/response/auth/auth_failed_response_model.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:dorry/utils/validators.dart';
import 'package:dorry/widget/auth_text_field.dart';
import 'package:dorry/widget/base_scaffold_widget.dart';
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
  bool isLoading = false;

  void _signUp() async {
    setState(() {
      isLoading = true;
    });
    try {
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
    } catch (e) {
      setState(() {
        errors['name'] = e.toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void _verifyOtp() async {
    setState(() {
      isLoading = true;
    });
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
      setState(() {
        errors['otp'] = e.toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffoldWidget(
      title: 'إنشاء حساب',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(padding: const EdgeInsets.only(top: 16)),
                if (!isOtpSent) ...[
                  AuthTextField(
                    controller: nameController,
                    labelText: 'الاسم',
                    prefixIcon: Icons.person,
                    isPassword: false,
                    isPasswordVisible: false,
                    togglePasswordVisibility: () {},
                    validator: Validators.validateName,
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
                        validator: Validators.validatePassword,
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
                  submitButton(_signUp, 'إنشاء حساب'),
                ] else ...[
                  Text(
                    'تم إرسال الرمز الى رقم الوتساب',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: Sizes.textSize_18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    controller: otpController,
                    labelText: 'الرمز',
                    prefixIcon: Icons.lock,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال الرمز';
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
                  submitButton(_verifyOtp, 'تحقق'),
                ],
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
