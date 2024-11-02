class StorePartnerModel {
  final dynamic id;
  final String name;
  final String mobileNumber;
  final String? profileImage;

  StorePartnerModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    this.profileImage,
  });

  factory StorePartnerModel.fromJson(Map<String, dynamic> json) {
    return StorePartnerModel(
      id: json['id'],
      name: json['name'],
      mobileNumber: json['mobile_number'],
      profileImage: json['profile_image'],
    );
  }
}
