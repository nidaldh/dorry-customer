import 'package:dorry/model/customer/appointment_model.dart';

class AppointmentListResponseModel {
  final List<Appointment> appointments;

  AppointmentListResponseModel({
    required this.appointments,
  });

  factory AppointmentListResponseModel.fromJson(Map<String, dynamic> json) {
    return AppointmentListResponseModel(
      appointments: (json['appointments'] as List)
          .map((appointment) => Appointment.fromJson(appointment))
          .toList(),
    );
  }
}
