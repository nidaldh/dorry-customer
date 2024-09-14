import 'package:dorry/const/api_uri.dart';
import 'package:dorry/model/customer/appointment_model.dart';
import 'package:dorry/model/response/customer/appointment_list_response_model.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'appointment_details_screen.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  _AppointmentsListScreenState createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
   Future<List<Appointment>> futureAppointments = Future.value([]);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar', null).then((_) {
      setState(() {
        futureAppointments = fetchAppointments();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المواعيد'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Appointment>>(
        future: futureAppointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد مواعيد.'));
          } else {
            final appointments = snapshot.data!;
            return ListView.builder(
              itemCount: appointments.length,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentDetailsScreen(appointment: appointment),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAppointmentHeader(appointment),
                          const Divider(),
                          _buildAppointmentDetails(appointment),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Appointment>> fetchAppointments() async {
    final response = await ApiService().getRequest(ApiUri.customerAppointment);

    if (response.statusCode == 200) {
      return AppointmentListResponseModel.fromJson(response.data).appointments;
    } else {
      throw Exception('فشل في تحميل المواعيد');
    }
  }

  Widget _buildAppointmentHeader(Appointment appointment) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'موعد مع ${appointment.user}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(appointment.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(appointment.status),
            style: TextStyle(
              fontSize: 14,
              color: _getStatusColor(appointment.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentDetails(Appointment appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              _formatDateTime(appointment.startTime, appointment.endTime),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.attach_money, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'السعر الإجمالي: ₪${appointment.totalPrice}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateTime(DateTime startTime, DateTime endTime) {
    final DateFormat dayFormatter = DateFormat('EEEE', 'ar');
    final DateFormat dayDateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormatter = DateFormat('HH:mm');

    return '${dayFormatter.format(startTime)}, ${dayDateFormatter.format(startTime)} - ${timeFormatter.format(startTime)} إلى ${timeFormatter.format(endTime)}';
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