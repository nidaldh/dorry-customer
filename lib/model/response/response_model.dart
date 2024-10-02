class BaseResponseModel {
  final bool? success;
  final String? message;
  final String? status;

  BaseResponseModel({
    this.success,
    this.message,
    this.status,
  });

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    return BaseResponseModel(
      success: json['success'],
      message: json['message'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
    };
  }
}
