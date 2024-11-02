class StoreServiceModel {
  final dynamic id;
  final String name;
  final num price;
  final int duration;
  final String? description;
  final String? category;
  final int? isStandalone;
  final num? discountPrice;

  StoreServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    this.description,
    this.category,
    this.isStandalone,
    this.discountPrice,
  });

  factory StoreServiceModel.fromJson(Map<String, dynamic> json) {
    return StoreServiceModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      duration: json['duration'],
      description: json['description'],
      category: json['category'],
      isStandalone: json['is_standalone'],
      discountPrice: json['discount_price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
      'category': category,
      'is_standalone': isStandalone,
      'discount_price': discountPrice,
    };
  }
}
