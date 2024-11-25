import 'package:dorry/app_theme.dart';
import 'package:dorry/model/store/store_model.dart';
import 'package:dorry/providers/appointment_details_provider.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/formatter.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dorry/model/customer/appointment_model.dart';
import 'package:dorry/widget/base_scaffold_widget.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final dynamic appointmentId;

  const AppointmentDetailsScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AppointmentDetailsProvider()..fetchAppointmentDetails(appointmentId),
      child: BaseScaffoldWidget(
        title: 'تفاصيل الموعد',
        body: Consumer<AppointmentDetailsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (provider.hasError) {
              return Center(child: Text('خطأ: فشل في تحميل تفاصيل الموعد.'));
            } else if (provider.appointment == null) {
              return const Center(child: Text('لا توجد تفاصيل للموعد.'));
            } else {
              final appointment = provider.appointment!;
              return Padding(
                padding: EdgeInsets.all(Sizes.paddingAll_16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppointmentHeader(appointment),
                    SizedBox(height: Sizes.height_20),
                    _buildAppointmentDetails(appointment),
                    SizedBox(height: Sizes.height_20),
                    Text(
                      'الخدمات:',
                      style: TextStyle(
                        fontSize: Sizes.textSize_20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Sizes.height_8),
                    Expanded(
                      child: _buildServicesList(appointment),
                    ),
                    if (appointment.status == 'booked')
                      ElevatedButton(
                        onPressed: () {
                          _showCancelReasonSheet(
                            context,
                            appointmentId,
                            provider,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Sizes.radius_10),
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
      ),
    );
  }

  Widget _buildAppointmentHeader(Appointment appointment) {
    return GestureDetector(
      onTap: () {
        router.push('/store/${appointment.storeId}');
      },
      child: Text(
        appointment.storeName ?? appointment.partner,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: Sizes.textSize_24,
          fontWeight: FontWeight.bold,
          color: kPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildAppointmentDetails(Appointment appointment) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radius_16),
      ),
      elevation: Sizes.elevation_8,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(Sizes.paddingAll_16),
        child: Column(
          children: [
            _buildDetailRow(
              icon: Icons.person,
              label: 'الزميل',
              value: appointment.partner,
            ),
            const Divider(),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'التاريخ',
              value:
                  '${dayFormatter.format(appointment.startTime)}, ${dayDateFormatter.format(appointment.startTime)}',
            ),
            const Divider(),
            _buildDetailRow(
              icon: Icons.access_time,
              label: 'الوقت',
              value:
                  '${timeFormatter.format(appointment.startTime)} الى ${timeFormatter.format(appointment.endTime)}',
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
              value: getStatusText(appointment.status),
              valueColor: getStatusColor(appointment.status),
            ),
            if (appointment.cancelReason != null)
              Column(
                children: [
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.info,
                    label: 'سبب الإلغاء',
                    value: appointment.cancelReason!,
                    valueColor: Colors.red,
                  ),
                ],
              ),
            if (appointment.note != null)
              Column(
                children: [
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.info,
                    label: ' ملاحظة',
                    value: appointment.note!,
                    valueColor: Colors.green,
                  ),
                ],
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
        Icon(icon, size: Sizes.iconSize_20, color: Colors.grey[700]),
        SizedBox(width: Sizes.width_12),
        Text(
          '$label: ',
          style: TextStyle(
              fontSize: Sizes.textSize_18, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: Sizes.textSize_14,
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
          margin: EdgeInsets.symmetric(vertical: Sizes.vertical_5),
          elevation: Sizes.elevation_1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radius_10),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(Sizes.paddingAll_16),
            title: Text(service.name,
                style: TextStyle(fontSize: Sizes.textSize_18)),
            subtitle: Text(
              'السعر: ₪${service.price}',
              style: TextStyle(fontSize: Sizes.textSize_16),
            ),
            trailing: Text(
              ' ${_formatDuration(service.duration)}',
              style: TextStyle(fontSize: Sizes.textSize_16),
            ),
          ),
        );
      },
    );
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

  void _showCancelReasonSheet(
    BuildContext context,
    String appointmentId,
    AppointmentDetailsProvider provider,
  ) {
    final TextEditingController _reasonController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: Sizes.paddingAll_16,
            right: Sizes.paddingAll_16,
            top: Sizes.paddingAll_16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'سبب الإلغاء',
                  style: TextStyle(
                      fontSize: Sizes.textSize_16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: Sizes.height_16),
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'ادخل سبب الإلغاء',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال سبب الإلغاء';
                    }
                    if (value.length < 10) {
                      return 'سبب الإلغاء يجب أن يكون أكثر من 10 حروف';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Sizes.height_16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      router.pop();
                      provider.cancelAppointment(
                        context,
                        appointmentId,
                        _reasonController.text,
                      );
                    }
                  },
                  child: Text('الغاء الموعد'),
                ),
                SizedBox(height: Sizes.height_50),
              ],
            ),
          ),
        );
      },
    );
  }
}
