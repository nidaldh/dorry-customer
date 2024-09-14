import 'package:dorry/const/api_uri.dart';
import 'package:flutter/material.dart';
import 'package:dorry/model/customer/appointment_model.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  Future<void> cancelAppointment(BuildContext context) async {
    final response = await ApiService().postRequest(
        '${ApiUri.customerAppointment}/${appointment.id}/cancel', {});

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إلغاء الموعد بنجاح')),
      );
      Navigator.pop(
          context, true); // Return to the previous screen with a success result
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إلغاء الموعد')),
      );
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
        actions: [
          if (appointment.status != 'cancelled')
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () => showCancelConfirmationDialog(context),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppointmentHeader(),
            const SizedBox(height: 20),
            _buildAppointmentDetails(),
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
              child: _buildServicesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentHeader() {
    return Text(
      'موعد مع ${appointment.user}',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAppointmentDetails() {
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

  Widget _buildServicesList() {
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
    final DateFormat dayFormatter = DateFormat('EEEE', 'ar');
    final DateFormat dayDateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormatter = DateFormat('HH:mm');

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