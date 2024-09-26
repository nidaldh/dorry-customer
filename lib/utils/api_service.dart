import 'package:dio/dio.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/utils/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:dorry/main.dart';
import 'package:dorry/router.dart';

class ApiService {
  ApiService({bool isAuth = false}) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenManager.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 && !isAuth) {
          await TokenManager.clearToken();
          router.go('/');
          return;
        }
        if (e.response?.statusCode == 500) {
          ScaffoldMessenger.of(appContext!).showSnackBar(
            SnackBar(
              content: Text(e.response?.data['message'] ?? 'خطأ غير معروف'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response> postRequest(String path, Map<String, dynamic> data) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> patchRequest(String path, Map<String, dynamic> data) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> getRequest(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiUri.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  Future<Response> putRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteRequest(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } catch (e, s) {
      logError(e, s);
      rethrow;
    }
  }

  //log error
  void logError(dynamic message, dynamic stackTrace) {
    print('Error: $message');
    print('Stack Trace: $stackTrace');
    // navigation.Get.snackbar('Error', message.toString());
  }
}
