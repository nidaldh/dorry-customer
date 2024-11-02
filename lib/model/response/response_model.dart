class BaseResponseModel {
  final bool? success;
  final String? message;
  final String? status;

  // errors
  final Map<String, dynamic>? errors;

  BaseResponseModel({
    this.success,
    this.message,
    this.status,
    this.errors,
  });

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    print(json['errors']);
    return BaseResponseModel(
      success: json['success'],
      message: json['message'] ?? json['error'],
      status: json['status'],
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'errors': errors,
    };
  }
}
