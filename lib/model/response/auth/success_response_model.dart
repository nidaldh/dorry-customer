import 'package:dorry/model/response/response_model.dart';
import 'package:dorry/model/store_model.dart';
import 'package:dorry/model/user_model.dart';

class SuccessResponseModel extends BaseResponseModel {
  final UserModel user;
  final StoreModel? store;
  final String token;

  SuccessResponseModel({
    super.message,
    super.success,
    required this.user,
    this.store,
    required this.token,
  });

  factory SuccessResponseModel.fromJson(Map<String, dynamic> json) {
    return SuccessResponseModel(
      user: UserModel.fromJson(json['user']),
      store: json['store'] != null ? StoreModel.fromJson(json['store']) : null,
      token: json['token'],
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'store': store?.toJson(),
      'token': token,
    };
  }
}
