import 'package:dorry/router.dart';
import 'package:flutter/material.dart';
import 'package:dorry/model/customer/appointment_model.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/utils/app_snack_bar.dart';

class AppointmentDetailsProvider with ChangeNotifier {
  Appointment? _appointment;
  bool _isLoading = false;
  bool _hasError = false;

  Appointment? get appointment => _appointment;

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  Future<void> fetchAppointmentDetails(dynamic appointmentId) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await ApiService()
          .getRequest('${ApiUri.customerAppointment}/$appointmentId');

      if (response.statusCode == 200) {
        _appointment = Appointment.fromJson(response.data['appointment']);
      } else {
        _hasError = true;
      }
    } catch (e) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelAppointment(
    BuildContext context,
    dynamic appointmentId,
    String cancelReason,
  ) async {
    final response = await ApiService()
        .postRequest('${ApiUri.customerAppointment}/$appointmentId/cancel', {
      'cancel_reason': cancelReason,
    });
    if (response.statusCode == 200) {
      successSnackBar('تم إلغاء الموعد بنجاح');
      router.pop();
      notifyListeners();
    } else {
      errorSnackBar('فشل في إلغاء الموعد');
    }
  }
}
