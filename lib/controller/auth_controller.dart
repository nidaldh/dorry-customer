import 'package:dio/dio.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/enums/store_type.dart';
import 'package:dorry/model/response/auth/auth_failed_response_model.dart';
import 'package:dorry/model/response/auth/success_response_model.dart';
import 'package:dorry/model/response/response_model.dart';
import 'package:dorry/screen/home_screen.dart';
import 'package:dorry/screen/splash_screen.dart';
import 'package:dorry/utils/api_serice.dart';
import 'package:dorry/utils/token_manager.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final ApiService _apiService = ApiService();
  late StoreType storeType;

  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  var isPasswordVisible = false.obs;

  @override
  void onReady() {
    super.onReady();
    // Add any initialization logic here
  }

  Future<BaseResponseModel?> signUpWithPhone(
    String phoneNumber,
    String password,
    String name,
  ) async {
    try {
      final response = await _apiService.postRequest(ApiUri.register, {
        'mobile_number': phoneNumber,
        'password': password,
        'name': name,
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
      Get.snackbar("Sign Up Failed", e.toString());
      return null;
    }
  }

  Future<void> _sendOtp(String phoneNumber) async {
    try {
      final response = await _apiService.postRequest('/send-otp', {
        'mobile_number': phoneNumber,
      });
      if (response.statusCode == 200) {
        // Handle successful OTP send
      } else {
        Get.snackbar("Send OTP Failed", response.data['message']);
      }
    } catch (e) {
      Get.snackbar("Send OTP Failed", e.toString());
    }
  }

  Future<BaseResponseModel?> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _apiService.postRequest(ApiUri.validateOtp, {
        'mobile_number': phoneNumber,
        'otp': otp,
      });
      if (response.statusCode == 200) {
        final successResponse = SuccessResponseModel.fromJson(response.data);
        await _handleSuccessfulLogin(successResponse);
      } else {
        Get.snackbar("OTP Verification Failed", response.data['message']);
      }
    } catch (e) {
      if (e is DioException) {
        return BaseResponseModel.fromJson(e.response!.data);
      }
      Get.snackbar("OTP Verification Failed", e.toString());
    }
    return null;
  }

  Future<void> loginWithPhone() async {
    final phoneNumber = phoneNumberController.text;
    final password = passwordController.text;

    try {
      final response = await _apiService.postRequest(ApiUri.login, {
        'mobile_number': phoneNumber,
        'password': password,
      });
      if (response.statusCode == 200) {
        final successResponse = SuccessResponseModel.fromJson(response.data);
        await _handleSuccessfulLogin(successResponse);
      } else {
        Get.snackbar("Login Failed", response.data['message']);
      }
    } catch (e) {
      if (e is DioException) {
        Get.snackbar("Login Failed", e.response!.data['message']);
      } else {
        Get.snackbar("Login Failed", e.toString());
      }
    }
  }

  Future<void> _handleSuccessfulLogin(SuccessResponseModel response) async {
    // Save the token
    await TokenManager.saveToken(response.token);
    await CustomerManager.saveUser(response.customer);
    Get.offAll(() => const HomeScreen());
  }

  void signOut() async {
    final response = await _apiService.postRequest(ApiUri.logout, {});
    if (response.statusCode == 200) {
      await TokenManager.clearToken();
      await CustomerManager.clear();
      Get.offAll(() => const SplashScreen());
    } else {
      Get.snackbar("Sign Out Failed", response.data['message']);
    }
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
