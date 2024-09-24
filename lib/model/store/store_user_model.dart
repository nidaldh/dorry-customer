class StorePartnerModel {
  final dynamic id;
  final String name;
  final String mobileNumber;

  StorePartnerModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
  });

  factory StorePartnerModel.fromJson(Map<String, dynamic> json) {
    return StorePartnerModel(
      id: json['id'],
      name: json['name'],
      mobileNumber: json['mobile_number'],
    );
  }
}
