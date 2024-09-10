import 'package:dorry/model/store/store_service_model.dart';
import 'package:dorry/model/store/store_user_model.dart';

class StoreDetailsModel {
  final int id;
  final String name;
  final String storeType;
  final String userId;
  final List<StoreUserModel> users;
  final List<StoreServiceModel> services;

  StoreDetailsModel({
    required this.id,
    required this.name,
    required this.storeType,
    required this.userId,
    required this.users,
    required this.services,
  });

  factory StoreDetailsModel.fromJson(Map<String, dynamic> json) {
    return StoreDetailsModel(
      id: json['id'],
      name: json['store_name'],
      storeType: json['store_type'],
      userId: json['user_id'],
      users: (json['users'] as List)
          .map((user) => StoreUserModel.fromJson(user))
          .toList(),
      services: (json['services'] as List)
          .map((service) => StoreServiceModel.fromJson(service))
          .toList(),
    );
  }
}
