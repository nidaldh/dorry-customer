import 'package:dio/dio.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/model/store/available_slot_blocks.dart';
import 'package:flutter/material.dart';
import 'package:dorry/model/store/store_user_model.dart';
import 'package:dorry/model/store/booking_cart.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:get/get.dart';

class UserSelectionScreen extends StatefulWidget {
  final List<StoreUserModel> users;
  final BookingCartModel bookingCart;

  const UserSelectionScreen({
    super.key,
    required this.users,
    required this.bookingCart,
  });

  @override
  _UserSelectionScreenState createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  List<AvailableSlotBlock>? allTimeSlots;
  List<AvailableSlotBlock>? filteredTimeSlots;
  bool isLoading = false;
  StoreUserModel? selectedUser;
  DateTime selectedDate = DateTime.now();

  void _fetchAvailableTimeSlots() async {
    if (selectedUser == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService().getRequest(
        ApiUri.availableTimeSlots,
        queryParameters: {
          'duration': widget.bookingCart.totalDuration,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل الفتحات المتاحة: $e')),
      );
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

  Widget _buildBookingCartSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الحجز',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const Divider(),
            ...widget.bookingCart.selectedServices.map((service) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(service.name),
                    Text('${service.duration} دقيقة'),
                    Text('₪${service.price}'),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المبلغ الإجمالي:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('₪${widget.bookingCart.totalAmount}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المدة الإجمالية:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${widget.bookingCart.totalDuration} دقيقة'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.users.length,
      itemBuilder: (context, index) {
        final user = widget.users[index];
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
              backgroundColor:
                  selectedUser == user ? Colors.green : Colors.grey,
              child: Text(user.name[0]),
            ),
            title: Text(user.name,
                style: TextStyle(
                    fontWeight: selectedUser == user
                        ? FontWeight.bold
                        : FontWeight.normal)),
            subtitle: Text(user.mobileNumber),
            trailing: selectedUser == user
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () {
              setState(() {
                selectedUser = user;
              });
              _fetchAvailableTimeSlots();
            },
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
              day,
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
          'لم يتم العثور على فتحات متاحة.',
          style: TextStyle(fontSize: 16, color: Colors.redAccent),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredTimeSlots!.first.slots.length,
        itemBuilder: (context, index) {
          final slot = filteredTimeSlots!.first.slots[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text('من ${slot.start} إلى ${slot.end}'),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                _showConfirmationDialog(slot);
              },
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
        title: const Text('اختر المستخدم'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildBookingCartSummary(),
              _buildUserList(),
              _buildDateSelector(),
              if (selectedUser != null) _buildAvailableSlots(),
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

  void _showConfirmationDialog(Slot slot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'تأكيد الحجز',
            style: TextStyle(color: Colors.black),
          ),
          content: Text('هل تريد حجز الفترة من ${slot.start} إلى ${slot.end}؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _bookTimeSlot(slot);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  void _bookTimeSlot(Slot slot) async {
    setState(() {
      isLoading = true;
    });
    try {
      List<dynamic> selectedServices =
          widget.bookingCart.selectedServices.map((e) => e.id).toList();

      final response = await ApiService().postRequest(
        ApiUri.bookTimeSlot,
        {
          'user_id': selectedUser!.id,
          'start_timeStamp': slot.timeStamp,
          'selected_services': selectedServices,
        },
      );
      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحجز بنجاح')),
        );
        Get.back();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل الحجز')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e is DioException) {
        print(e.response?.data);
      }
      ApiService().logError(e, StackTrace.current);
    }
  }
}
