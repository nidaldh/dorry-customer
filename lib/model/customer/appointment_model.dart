class Appointment {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status;
  final String partner;
  final String? storeName;
  final dynamic storeId;
  final List<AppointmentService> services;
  final String? cancelReason;
  final String? note;

  Appointment({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.partner,
    required this.services,
    this.storeName,
    this.storeId,
    this.cancelReason,
    this.note,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      totalPrice: json['total_price'].toDouble(),
      status: json['status'],
      partner: json['partner'],
      storeName: json['store_name'],
      storeId: json['store_id'],
      note: json['note'],
      services: (json['services'] as List)
          .map((service) => AppointmentService.fromJson(service))
          .toList(),
      cancelReason: json['cancel_reason'],
    );
  }
}

class AppointmentService {
  final String name;
  final double price;
  final int duration;
  final String? description;

  AppointmentService({
    required this.name,
    required this.price,
    required this.duration,
    this.description,
  });

  factory AppointmentService.fromJson(Map<String, dynamic> json) {
    return AppointmentService(
      name: json['name'],
      price: json['price'].toDouble(),
      duration: json['duration'],
      description: json['description'],
    );
  }
}
