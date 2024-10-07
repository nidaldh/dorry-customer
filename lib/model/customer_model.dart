class CustomerModel {
  final String name;
  final String mobileNumber;
  final String? profileImage;

  CustomerModel({
    required this.name,
    required this.mobileNumber,
    this.profileImage,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      name: json['name'],
      mobileNumber: json['mobile_number'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile_number': mobileNumber,
      'profile_image': profileImage,
    };
  }
}
