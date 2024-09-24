import 'package:dorry/const/api_uri.dart';
import 'package:dorry/model/store/available_slot_blocks.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:dorry/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:dorry/model/store/store_user_model.dart';
import 'package:dorry/model/store/booking_cart.dart';
import 'package:dorry/utils/api_service.dart';

class PartnerSelectionScreen extends StatefulWidget {
  final List<StorePartnerModel> partners;
  final BookingCartModel bookingCart;

  const PartnerSelectionScreen({
    super.key,
    required this.partners,
    required this.bookingCart,
  });

  @override
  _PartnerSelectionScreenState createState() => _PartnerSelectionScreenState();
}

class _PartnerSelectionScreenState extends State<PartnerSelectionScreen> {
  List<AvailableSlotBlock>? allTimeSlots;
  List<AvailableSlotBlock>? filteredTimeSlots;
  bool isLoading = false;
  StorePartnerModel? selectedPartner;
  DateTime selectedDate = DateTime.now();

  void _fetchAvailableTimeSlots() async {
    if (selectedPartner == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService().getRequest(
        ApiUri.availableTimeSlots,
        queryParameters: {
          'duration': widget.bookingCart.totalDuration,
          'partner_id': selectedPartner!.id,
        },
      );

      setState(() {
        allTimeSlots = (response.data['availableSlotBlocks'] as List)
            .map((json) => AvailableSlotBlock.fromJson(json))
            .toList();
        _filterTimeSlotsByDate(selectedDate);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      errorSnackBar('فشل في تحميل الوقت المتاح: $e');
    }
  }

  void _filterTimeSlotsByDate(DateTime date) {
    if (allTimeSlots == null) return;

    setState(() {
      filteredTimeSlots = allTimeSlots!.where((slotBlock) {
        return DateTime.parse(slotBlock.date).day == date.day &&
            DateTime.parse(slotBlock.date).month == date.month &&
            DateTime.parse(slotBlock.date).year == date.year;
      }).toList();
    });
  }

  Widget _buildUserList() {
    if (selectedPartner != null) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text(selectedPartner!.name[0]),
          ),
          title: Text(selectedPartner!.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.check_circle, color: Colors.green),
          onTap: () {
            setState(() {
              selectedPartner = null;
              filteredTimeSlots = null;
            });
          },
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: widget.partners.length,
      itemBuilder: (context, index) {
        final user = widget.partners[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPartner = user;
            });
            _fetchAvailableTimeSlots();
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Text(user.name[0],
                      style:
                          const TextStyle(fontSize: 24, color: Colors.white)),
                ),
                const SizedBox(height: 8),
                Text(user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    List<Widget> dateWidgets = [];

    allTimeSlots?.forEach((element) {
      DateTime date = DateTime.parse(element.date);
      dateWidgets.add(_buildDateItem(date, element.day));
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: dateWidgets,
      ),
    );
  }

  Widget _buildDateItem(DateTime date, String day) {
    bool isSelected = date.day == selectedDate.day &&
        date.month == selectedDate.month &&
        date.year == selectedDate.year;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
        _filterTimeSlotsByDate(date);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? Colors.purple : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.grey,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              dayFormatter.format(date),
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableSlots() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredTimeSlots == null || filteredTimeSlots!.isEmpty) {
      return const Center(
        child: Text(
          'لم يتم العثور على وقت متاحة.',
          style: TextStyle(fontSize: 16, color: Colors.redAccent),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => Divider(
          thickness: 2,
          color: Colors.purple.shade200,
        ),
        itemCount: filteredTimeSlots!.first.slots.length,
        itemBuilder: (context, index) {
          final slot = filteredTimeSlots!.first.slots[index];
          return ListTile(
            title: Text('من ${slot.start} إلى ${slot.end}',
                style: const TextStyle(fontSize: 16)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              router.replace('/confirm-booking', extra: {
                'selectedPartner': selectedPartner,
                'selectedSlot': slot,
                'bookingCart': widget.bookingCart,
              });
            },
            tileColor: Colors.purple.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.group, size: 24),
            SizedBox(width: 8),
            Text('اختر الزميل'),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildUserList(),
              if (selectedPartner != null) _buildDateSelector(),
              if (selectedPartner != null) _buildAvailableSlots(),
            ],
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
