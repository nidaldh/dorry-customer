class StoreServiceModel {
  final dynamic id;
  final String name;
  final num price;
  final int duration;
  final String? description;

  StoreServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    this.description,
  });

  factory StoreServiceModel.fromJson(Map<String, dynamic> json) {
    return StoreServiceModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      duration: json['duration'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
    };
  }
}
