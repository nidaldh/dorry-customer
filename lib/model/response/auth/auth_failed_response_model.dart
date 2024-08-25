import 'package:dorry/model/response/response_model.dart';

class AuthFailedResponseModel extends BaseResponseModel {
  final Data data;

  AuthFailedResponseModel({
    required super.success,
    required super.message,
    required this.data,
  });

  factory AuthFailedResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthFailedResponseModel(
      success: json['success'],
      message: json['message'],
      data: Data.fromJson(json['errors']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class Data {
  final String? name;
  final String? mobileNumber;
  final String? password;
  final String? otp;

  Data({
    required this.name,
    required this.mobileNumber,
    required this.password,
    required this.otp,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      name: json['name'],
      mobileNumber: json['mobile_number'],
      password: json['password'],
      otp: json['otp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile_number': mobileNumber,
      'password': password,
      'otp': otp,
    };
  }
}
