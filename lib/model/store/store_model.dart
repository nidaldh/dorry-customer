class StoreModel {
  final dynamic id;
  final String storeName;
  final String? area;
  final dynamic areaId;
  final String? address;
  final String? image;

  StoreModel({
    required this.id,
    required this.storeName,
    this.areaId,
    this.area,
    this.address,
    this.image,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      storeName: json['store_name'],
      area: json['area'],
      areaId: json['area_id'],
      address: json['address'],
      image: json['image'],
    );
  }
}
