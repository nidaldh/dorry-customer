
class Appointment {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status;
  final String user;
  final List<AppointmentService> services;

  Appointment({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.user,
    required this.services,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      totalPrice: json['total_price'].toDouble(),
      status: json['status'],
      user: json['user'],
      services: (json['services'] as List)
          .map((service) => AppointmentService.fromJson(service))
          .toList(),
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
