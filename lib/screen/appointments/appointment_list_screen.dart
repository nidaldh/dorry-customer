import 'package:dorry/controller/common_controller.dart';
import 'package:dorry/model/customer/appointment_model.dart';
import 'package:dorry/model/store/store_model.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/formatter.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:dorry/widget/base_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  _AppointmentsListScreenState createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  final CommonController commonController = Get.find<CommonController>();

  @override
  void initState() {
    super.initState();
    commonController.fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommonController>(
      id: 'appointment_list',
      builder: (controller) {
        return BaseScaffoldWidget(
          title: 'قائمة المواعيد',
          showBackButton: false,
          actions: [
            if (CustomerManager.user != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  commonController.fetchAppointments();
                },
              ),
          ],
          body: controller.futureAppointments.isEmpty
              ? Center(
                  child: Text(
                    CustomerManager.user != null
                        ? 'لا توجد مواعيد.'
                        : 'الرجاء تسجيل الدخول لعرض المواعيد.',
                  ),
                )
              : ListView.builder(
                  itemCount: controller.futureAppointments.length,
                  padding: EdgeInsets.symmetric(
                    vertical: Sizes.paddingAll_8,
                    horizontal: Sizes.paddingAll_16,
                  ),
                  itemBuilder: (context, index) {
                    final appointment = controller.futureAppointments[index];
                    return GestureDetector(
                      onTap: () {
                        router.push('/appointment/${appointment.id}');
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          vertical: Sizes.paddingAll_8,
                        ),
                        elevation: Sizes.elevation_4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.radius_10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(Sizes.paddingAll_16),
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
                ),
        );
      },
    );
  }

  Widget _buildAppointmentHeader(Appointment appointment) {
    bool isToday = DateUtils.isSameDay(DateTime.now(), appointment.startTime);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            ' ${appointment.storeName}',
            style: TextStyle(
              fontSize: Sizes.textSize_18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isToday)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Sizes.paddingAll_12,
              vertical: Sizes.paddingAll_3,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Sizes.radius_10),
            ),
            child: Text(
              'اليوم',
              style: TextStyle(
                fontSize: Sizes.textSize_14,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.paddingAll_12,
            vertical: Sizes.paddingAll_3,
          ),
          decoration: BoxDecoration(
            color: getStatusColor(appointment.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(Sizes.radius_10),
          ),
          child: Text(
            getStatusText(appointment.status),
            style: TextStyle(
              fontSize: Sizes.textSize_14,
              color: getStatusColor(appointment.status),
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
        SizedBox(height: Sizes.height_8),
        Text(
          '${appointment.partner}:  ${dayFormatter.format(appointment.startTime)}, ${dayDateFormatter.format(appointment.startTime)}',
          style: TextStyle(fontSize: Sizes.textSize_16),
          overflow: TextOverflow.ellipsis, // To handle long text gracefully
        ),
        Text(
          ' ${timeFormatter.format(appointment.startTime)} إلى ${timeFormatter.format(appointment.endTime)}',
          style: TextStyle(fontSize: Sizes.textSize_16),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
