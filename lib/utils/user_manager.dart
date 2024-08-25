
import 'dart:convert';

import 'package:dorry/model/store_model.dart';
import 'package:dorry/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  static const String _userKey = 'user';
  static const String _storeKey = 'store';
  static StoreModel? store;
  static UserModel? user;

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      user = UserModel.fromJson(jsonDecode(userData));
      return user;
    }
    return null;
  }

  static Future<void> saveStore(StoreModel? store) async {
    final prefs = await SharedPreferences.getInstance();
    if (store != null) {
      await prefs.setString(_storeKey, jsonEncode(store.toJson()));
    } else {
      await prefs.remove(_storeKey);
    }
  }

  static Future<StoreModel?> getStore() async {
    final prefs = await SharedPreferences.getInstance();
    final storeData = prefs.getString(_storeKey);
    if (storeData != null) {
      store = StoreModel.fromJson(jsonDecode(storeData));
      return store;
    }
    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_storeKey);
  }
}
