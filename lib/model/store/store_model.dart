class StoreModel {
  final dynamic id;
  final String storeName;

  StoreModel({
    required this.id,
    required this.storeName,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      storeName: json['store_name'],
    );
  }
}
