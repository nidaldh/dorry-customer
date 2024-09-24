import 'package:dorry/const/api_uri.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:dorry/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:dorry/model/store/store_user_model.dart';
import 'package:dorry/model/store/booking_cart.dart';
import 'package:dorry/model/store/available_slot_blocks.dart';
import 'package:dorry/utils/api_service.dart';

class ConfirmBookingScreen extends StatelessWidget {
  final StorePartnerModel selectedPartner;
  final SlotModel selectedSlot;
  final BookingCartModel bookingCart;

  const ConfirmBookingScreen({
    super.key,
    required this.selectedPartner,
    required this.selectedSlot,
    required this.bookingCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الحجز'),
        centerTitle: true,
        elevation: 0, // For a modern flat look
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingDetailsSection(),
                  const SizedBox(height: 20),
                  const Text(
                    'الخدمات المختارة:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSelectedServicesList(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: _buildConfirmButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('الزميل', selectedPartner.name),
            _buildDetailItem('التاريخ',
                '${dayFormatter.format(selectedSlot.date ?? DateTime.now())} - ${dayDateFormatter.format(selectedSlot.date ?? DateTime.now())}'),
            _buildDetailItem(
                'الوقت', '${selectedSlot.start}  ${(selectedSlot.end)}'),
            _buildDetailItem('المبلغ الإجمالي', '₪${bookingCart.totalAmount}'),
            _buildDetailItem(
                'المدة الإجمالية', '${bookingCart.totalDuration} دقيقة'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedServicesList() {
    return ListView.builder(
      itemCount: bookingCart.selectedServices.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final service = bookingCart.selectedServices[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              service.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              '₪${service.price} - ${service.duration} دقيقة',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await _confirmBooking(context);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.greenAccent.shade700,
          elevation: 5,
        ),
        child: const Text(
          'تأكيد الحجز',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmBooking(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      List<dynamic> selectedServices =
          bookingCart.selectedServices.map((e) => e.id).toList();

      final response = await ApiService().postRequest(
        ApiUri.bookTimeSlot,
        {
          'partner_id': selectedPartner.id,
          'start_timeStamp': selectedSlot.timeStamp,
          'selected_services': selectedServices,
        },
      );

      Navigator.of(context).pop(); // Close the loading dialog

      if (response.statusCode == 200) {
        successSnackBar('تم تأكيد الحجز بنجاح');
        popUntilPath(context, '/home');
      } else {
        errorSnackBar('فشل في تأكيد الحجز');
      }
    } catch (e) {
      errorSnackBar('فشل في تأكيد الحجز: $e');
    }
  }
}
