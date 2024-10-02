import 'package:dorry/model/response/response_model.dart';

class AuthFailedResponseModel extends BaseResponseModel {
  final Data data;

  AuthFailedResponseModel({
    super.success,
    super.message,
    super.status,
    required this.data,
  });

  factory AuthFailedResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AuthFailedResponseModel(
        success: false,
        message: json?['message'] ?? 'Something went wrong',
        data: Data(
          name: '',
          mobileNumber: json?['message'] ?? 'Something went wrong',
          password: '',
          otp: '',
        ),
      );
    }
    return AuthFailedResponseModel(
      success: json['success'],
      message: json['message'],
      status: json['status'],
      data: Data.fromJson(json['errors'] ?? {}),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
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
