import 'package:flutter/material.dart';

class StoreModel {
  final dynamic id;
  final String name;
  final String? area;
  final dynamic areaId;
  final String? address;
  final String? image;

  StoreModel({
    required this.id,
    required this.name,
    this.areaId,
    this.area,
    this.address,
    this.image,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      name: json['store_name'],
      area: json['area'],
      areaId: json['area_id'],
      address: json['address'],
      image: json['image'],
    );
  }
}

String getStatusText(String status) {
  switch (status) {
    case 'booked':
      return 'تم الحجز';
    case 'running':
      return 'جاري';
    case 'completed':
      return 'مكتمل';
    case 'cancelled':
      return 'ملغى';
    default:
      return 'غير معروف';
  }
}

Color getStatusColor(String status) {
  switch (status) {
    case 'booked':
      return Colors.blue;
    case 'running':
      return Colors.orange;
    case 'completed':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.black;
  }
}