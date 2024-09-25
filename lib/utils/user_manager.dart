import 'dart:convert';

import 'package:dorry/model/store/store_model.dart';
import 'package:dorry/model/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerManager {
  static const String _customerKey = 'customer';
  static StoreModel? store;
  static CustomerModel? user;

  static Future<void> saveUser(CustomerModel newUser) async {
    user = newUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customerKey, jsonEncode(newUser.toJson()));
  }

  static Future<CustomerModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_customerKey);
    if (userData != null) {
      user = CustomerModel.fromJson(jsonDecode(userData));
      return user;
    }
    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customerKey);
  }
}
