class CustomerModel {
  final String name;
  final String mobileNumber;
  final String? profileImage;
  final String? qrCode;
  final DateTime? birthDate;

  CustomerModel({
    required this.name,
    required this.mobileNumber,
    this.profileImage,
    this.qrCode,
    this.birthDate,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      name: json['name'],
      mobileNumber: json['mobile_number'],
      profileImage: json['profile_image'],
      qrCode: json['qr_code'],
      birthDate:
          json['birthdate'] != null ? DateTime.parse(json['birthdate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile_number': mobileNumber,
      'profile_image': profileImage,
      'qr_code': qrCode,
      'birthdate': birthDate?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }

  String prepareForQrCode() {
    return "{\"qr_code\":\"$qrCode\",\"mobile_number\":\"$mobileNumber\"}";
  }
}
