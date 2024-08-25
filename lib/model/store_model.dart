class StoreModel {
  final int id;
  final String storeName;
  final String storeType;
  final String userId;
  final String? createdAt;
  final String? updatedAt;

  StoreModel({
    required this.id,
    required this.storeName,
    required this.storeType,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      storeName: json['store_name'],
      storeType: json['store_type'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_name': storeName,
      'store_type': storeType,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
