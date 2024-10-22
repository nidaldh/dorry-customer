import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/main.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:dorry/router.dart';

class ApiService {
  ApiService({bool isAuth = false}) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = CustomerManager.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['appVersion'] = packageInfo.version;
        options.headers['appBuildNumber'] = packageInfo.buildNumber;
        options.headers['platform'] = Platform.isAndroid ? 'android' : 'ios';
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 &&
            !isAuth &&
            CustomerManager.token != null) {
          await CustomerManager.clear();
          router.go('/login');
          return;
        }
        if (e.response?.statusCode == 500) {
          handleError(e);
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

  void handleError(DioException e) {
    dynamic data = e.response?.data;
    if (data is Map) {
      errorSnackBar(data['message'] ?? data['error'] ?? 'خطأ غير معروف');
    } else {
      errorSnackBar('خطأ غير معروف');
    }
  }

  //log error
  void logError(dynamic message, dynamic stackTrace) async {
    print('Error: $message');
    print('Stack Trace: $stackTrace');
    // navigation.Get.snackbar('Error', message.toString());
  }

  Future<Response> uploadImage(String path, File image) async {
    try {
      final formData = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(
          image.path,
          filename: 'profile_image.jpg',
        ),
      });

      return await _dio.post(path, data: formData);
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }
}
