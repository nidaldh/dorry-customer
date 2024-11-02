import 'dart:convert';

import 'package:dorry/const/api_uri.dart';
import 'package:dorry/model/response/auth/success_response_model.dart';
import 'package:dorry/model/store/store_model.dart';
import 'package:dorry/model/customer_model.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerManager {
  static const String _customerKey = 'customer';
  static const String _tokenKey = 'auth_token';
  static StoreModel? store;
  static CustomerModel? user;
  static String? token;

  static Future<void> saveUser(
      CustomerModel newUser, String currentToken) async {
    user = newUser;
    _saveToken(currentToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customerKey, jsonEncode(newUser.toJson()));
  }

  static Future<CustomerModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_customerKey);
    getToken();
    if (userData != null) {
      user = CustomerModel.fromJson(jsonDecode(userData));
      return user;
    }
    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    _clearToken();
    user = null;
    await prefs.remove(_customerKey);
  }

  static Future<void> _saveToken(String currentToken) async {
    final prefs = await SharedPreferences.getInstance();
    token = currentToken;
    await prefs.setString(_tokenKey, currentToken);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
    return token;
  }

  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    token = null;
  }

  static Future<bool> customerInfo() async {
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
}
