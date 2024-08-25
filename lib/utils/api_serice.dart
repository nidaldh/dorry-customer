import 'package:dio/dio.dart';
import 'package:dorry/screen/login_screen.dart';
import 'package:dorry/utils/token_manager.dart';
import 'package:get/get.dart' as Navigation;
import 'package:get/get_core/src/get_main.dart';

class ApiService {
  ApiService() {
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
        if (e.response?.statusCode == 401) {
          // Handle unauthorized response
          await TokenManager.clearToken();
          Get.offAll(() => const LoginScreen());
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response> postRequest(String path, Map<String, dynamic> data) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> getRequest(String path) async {
    return await _dio.get(path);
  }

  final Dio _dio = Dio(BaseOptions(
    // baseUrl: 'http://mahali.khidmatna.com',
    // baseUrl: 'http://127.0.0.1:8000',
    baseUrl: 'http://192.168.50.169:8000',
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
    Navigation.Get.snackbar('Error', message.toString());
  }
}
