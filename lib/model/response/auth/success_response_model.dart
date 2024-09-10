import 'package:dorry/model/response/response_model.dart';
import 'package:dorry/model/store/store_model.dart';
import 'package:dorry/model/customer_model.dart';

class SuccessResponseModel extends BaseResponseModel {
  final CustomerModel customer;
  final StoreModel? store;
  final String token;

  SuccessResponseModel({
    super.message,
    super.success,
    required this.customer,
    this.store,
    required this.token,
  });

  factory SuccessResponseModel.fromJson(Map<String, dynamic> json) {
    return SuccessResponseModel(
      customer: CustomerModel.fromJson(json['customer']),
      store: json['store'] != null ? StoreModel.fromJson(json['store']) : null,
      token: json['token'],
      success: json['success'],
      message: json['message'],
    );
  }
}
