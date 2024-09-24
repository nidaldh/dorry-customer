import 'package:dorry/const/api_uri.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:dorry/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:dorry/model/customer/appointment_model.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final dynamic appointmentId;

  const AppointmentDetailsScreen({super.key, required this.appointmentId});

  Future<void> cancelAppointment(BuildContext context) async {
    final response = await ApiService()
        .postRequest('${ApiUri.customerAppointment}/$appointmentId/cancel', {});

    if (response.statusCode == 200) {
      successSnackBar('تم إلغاء الموعد بنجاح');
      router.pop(true);
    } else {
      errorSnackBar('فشل في إلغاء الموعد');
    }
  }

  Future<Appointment> fetchAppointmentDetails() async {
    final response = await ApiService()
        .getRequest('${ApiUri.customerAppointment}/$appointmentId');

    if (response.statusCode == 200) {
      return Appointment.fromJson(response.data['appointment']);
    } else {
      throw Exception('Failed to load appointment details');
    }
  }

  Future<void> showCancelConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الإلغاء'),
          content: const Text('هل أنت متأكد أنك تريد إلغاء هذا الموعد؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('لا'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('نعم'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                cancelAppointment(context); // Proceed with cancellation
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الموعد'),
        centerTitle: true,
      ),
      body: FutureBuilder<Appointment>(
        future: fetchAppointmentDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return Center(child: Text('خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('لا توجد تفاصيل للموعد.'));
          } else {
            final appointment = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppointmentHeader(appointment),
                  const SizedBox(height: 20),
                  _buildAppointmentDetails(appointment),
                  const SizedBox(height: 20),
                  const Text(
                    'الخدمات:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildServicesList(appointment),
                  ),
                  if (appointment.status == 'booked')
                    ElevatedButton(
                      onPressed: () {
                        showCancelConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('إلغاء الموعد'),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAppointmentHeader(Appointment appointment) {
    return Text(
      'موعد مع ${appointment.partner}',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAppointmentDetails(Appointment appointment) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'التاريخ',
              value:
                  _formatDateTime(appointment.startTime, appointment.endTime),
            ),
            const Divider(),
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'السعر الإجمالي',
              value: '₪${appointment.totalPrice}',
            ),
            const Divider(),
            _buildDetailRow(
              icon: Icons.info,
              label: 'الحالة',
              value: _getStatusText(appointment.status),
              valueColor: _getStatusColor(appointment.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: valueColor ?? Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(Appointment appointment) {
    return ListView.builder(
      itemCount: appointment.services.length,
      itemBuilder: (context, index) {
        final service = appointment.services[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(service.name, style: const TextStyle(fontSize: 18)),
            subtitle: Text(
              'السعر: ₪${service.price}',
              style: const TextStyle(fontSize: 16),
            ),
            trailing: Text(
              ' ${_formatDuration(service.duration)}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime startTime, DateTime endTime) {
    return '${dayFormatter.format(startTime)}, ${dayDateFormatter.format(startTime)} - ${timeFormatter.format(startTime)} إلى ${timeFormatter.format(endTime)}';
  }

  String _formatDuration(int duration) {
    if (duration >= 60) {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      return minutes > 0 ? '$hours ساعة و $minutes دقيقة' : '$hours ساعة';
    } else {
      return '$duration دقيقة';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'booked':
        return 'تم الحجز';
      case 'running':
        return 'جاري';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغى';
      default:
        return 'غير معروف';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'booked':
        return Colors.blue;
      case 'running':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
