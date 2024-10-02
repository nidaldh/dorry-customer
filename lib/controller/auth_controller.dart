import 'package:dio/dio.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/enums/store_type.dart';
import 'package:dorry/model/gender_model.dart';
import 'package:dorry/model/response/auth/auth_failed_response_model.dart';
import 'package:dorry/model/response/auth/success_response_model.dart';
import 'package:dorry/model/response/response_model.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:dorry/utils/token_manager.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final ApiService _apiService = ApiService(isAuth: true);
  late StoreType storeType;
  String countryCode = '970';

  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  var isPasswordVisible = false.obs;

  Future<BaseResponseModel?> signUpWithPhone(
    String name,
    GenderModel gender,
  ) async {
    try {
      String phoneNumber = phoneNumberController.text;
      phoneNumber = '$countryCode$phoneNumber';
      final response = await _apiService.postRequest(ApiUri.register, {
        'mobile_number': phoneNumber,
        'password': passwordController.text,
        'name': name,
        'gender': gender.code.name
      });
      if (response.statusCode == 200) {
        return null;
      } else {
        return AuthFailedResponseModel.fromJson(response.data);
      }
    } catch (e) {
      if (e is DioException) {
        return AuthFailedResponseModel.fromJson(e.response!.data);
      }
      errorSnackBar("Sign Up Failed$e");
      return AuthFailedResponseModel(
        success: false,
        message: e.toString(),
        data: Data(
          name: '',
          mobileNumber: null,
          password: '',
          otp: '',
        ),
      );
    }
  }

  Future<void> _sendOtp() async {
    try {
      String phoneNumber = phoneNumberController.text;
      phoneNumber = '$countryCode$phoneNumber';
      final response = await _apiService.postRequest('/send-otp', {
        'mobile_number': phoneNumber,
      });
      if (response.statusCode == 200) {
        // Handle successful OTP send
      } else {
        errorSnackBar("Send OTP Failed ${response.data['message']}");
      }
    } catch (e) {
      errorSnackBar("Send OTP Failed $e");
    }
  }

  Future<BaseResponseModel?> verifyOtp(String otp) async {
    try {
      String phoneNumber = phoneNumberController.text;
      phoneNumber = '$countryCode$phoneNumber';
      final response = await _apiService.postRequest(ApiUri.validateOtp, {
        'mobile_number': phoneNumber,
        'otp': otp,
      });
      if (response.statusCode == 200) {
        final successResponse = SuccessResponseModel.fromJson(response.data);
        await _handleSuccessfulLogin(successResponse);
      } else {
        errorSnackBar("OTP Verification Failed ${response.data['message']}");
      }
    } catch (e) {
      if (e is DioException) {
        return BaseResponseModel.fromJson(e.response!.data);
      }
      errorSnackBar("OTP Verification Failed $e");
    }
    return null;
  }

  Future<BaseResponseModel?> loginWithPhone() async {
    final password = passwordController.text;
    try {
      String phoneNumber = phoneNumberController.text;
      phoneNumber = '$countryCode$phoneNumber';
      final response = await _apiService.postRequest(ApiUri.login, {
        'mobile_number': phoneNumber,
        'password': password,
      });
      if (response.statusCode == 200) {
        final successResponse = SuccessResponseModel.fromJson(response.data);
        await _handleSuccessfulLogin(successResponse);
      } else {
        return AuthFailedResponseModel.fromJson(response.data);
      }
    } catch (e, s) {
      if (e is DioException) {
        return AuthFailedResponseModel.fromJson(e.response?.data);
      }
      _apiService.logError(e, s);
    }
    return null;
  }

  Future<void> _handleSuccessfulLogin(SuccessResponseModel response) async {
    // Save the token
    await TokenManager.saveToken(response.token);
    await CustomerManager.saveUser(response.customer);
    router.go('/home');
  }

  void signOut() async {
    final response = await _apiService.postRequest(ApiUri.logout, {});
    if (response.statusCode == 200) {
      await TokenManager.clearToken();
      await CustomerManager.clear();
      router.go('/');
    } else {
      errorSnackBar("Sign Out Failed ${response.data['message']}");
    }
  }

  Future<AuthFailedResponseModel?> requestResetPassword() async {
    String phoneNumber = phoneNumberController.text;
    phoneNumber = '$countryCode$phoneNumber';
    try {
      final response = await _apiService
          .postRequest('/api/customer/password/request-reset', {
        'mobile_number': phoneNumber,
      });
      if (response.statusCode == 200) {
        successSnackBar("تم رمز إعادة تعيين كلمة المرور إلى الوتساب.");
      } else {
        errorSnackBar("Failed ${response.data['message']}");
      }
    } catch (e, s) {
      if (e is DioException) {
        _apiService.logError(e, s);
        return AuthFailedResponseModel.fromJson(e.response?.data);
      }
    }
    return null;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
