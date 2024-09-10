// lib/model/user_model.dart
class StoreUserModel {
  final dynamic id;
  final String name;
  final String mobileNumber;

  StoreUserModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
  });

  factory StoreUserModel.fromJson(Map<String, dynamic> json) {
    return StoreUserModel(
      id: json['id'],
      name: json['name'],
      mobileNumber: json['mobile_number'],
    );
  }
}
