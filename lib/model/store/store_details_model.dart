import 'package:dorry/model/store/store_service_model.dart';
import 'package:dorry/model/store/store_user_model.dart';

class StoreDetailsModel {
  final dynamic id;
  final String name;
  final String storeType;
  final dynamic partnerId;
  final List<StorePartnerModel> partners;
  final List<StoreServiceModel> services;
  final String? image;
  final String? area;
  final String? address;

  StoreDetailsModel({
    required this.id,
    required this.name,
    required this.storeType,
    required this.partnerId,
    required this.partners,
    required this.services,
    this.image,
    this.area,
    this.address,
  });

  factory StoreDetailsModel.fromJson(Map<String, dynamic> json) {
    return StoreDetailsModel(
      id: json['id'],
      name: json['store_name'],
      storeType: json['store_type'],
      partnerId: json['partner_id'],
      image: json['image'],
      area: json['area'],
      address: json['address'],
      partners: (json['partners'] as List)
          .map((user) => StorePartnerModel.fromJson(user))
          .toList(),
      services: (json['services'] as List)
          .map((service) => StoreServiceModel.fromJson(service))
          .toList(),
    );
  }
}
