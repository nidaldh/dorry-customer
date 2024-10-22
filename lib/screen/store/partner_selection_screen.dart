import 'package:dio/dio.dart';
import 'package:dorry/app_theme.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/model/store/available_slot_blocks.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:dorry/utils/formatter.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:dorry/model/store/store_user_model.dart';
import 'package:dorry/model/store/booking_cart.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:get/get.dart';
import 'package:dorry/controller/common_controller.dart';

class PartnerSelectionScreen extends StatefulWidget {
  final BookingCartModel bookingCart;
  final dynamic storeId;

  const PartnerSelectionScreen({
    super.key,
    required this.storeId,
    required this.bookingCart,
  });

  @override
  _PartnerSelectionScreenState createState() => _PartnerSelectionScreenState();
}

class _PartnerSelectionScreenState extends State<PartnerSelectionScreen> {
  List<StorePartnerModel>? partners;
  List<AvailableSlotBlock>? allTimeSlots;
  List<AvailableSlotBlock>? filteredTimeSlots;
  bool isLoading = false;
  StorePartnerModel? selectedPartner;
  DateTime selectedDate = DateTime.now();
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPartners();
  }

  void _fetchPartners() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> servicesIds = prepareServicesData();

      final response = await ApiService().getRequest(
        "${ApiUri.store}/${widget.storeId}/available-partners",
        queryParameters: servicesIds,
      );
      setState(() {
        partners = (response.data['partners'] as List)
            .map((json) => StorePartnerModel.fromJson(json))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      if (e is DioException) {
        dynamic data = e.response?.data;
        if (data is Map) {
          error = data['message'] ?? data['error'] ?? 'خطأ غير معروف';
        } else {
          error = 'خطأ غير معروف';
        }
        ApiService().handleError(e);
        return;
      }
      errorSnackBar('Failed to load partners: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _fetchAvailableTimeSlots() async {
    if (selectedPartner == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // send services ids
      Map<dynamic, dynamic> servicesIds = prepareServicesData();

      Map<String, dynamic> data = {
        'duration': widget.bookingCart.totalDuration,
        'partner_id': selectedPartner!.id,
        ...servicesIds,
      };

      final response = await ApiService().getRequest(
        ApiUri.availableTimeSlots,
        queryParameters: data,
      );

      setState(() {
        allTimeSlots = (response.data['availableSlotBlocks'] as List)
            .map((json) => AvailableSlotBlock.fromJson(json))
            .toList();
        _filterTimeSlotsByDate(selectedDate);
        isLoading = false;
      });
    } catch (e, s) {
      if (e is DioException) {
        ApiService().handleError(e);
        return;
      }
      errorSnackBar('فشل في تحميل الوقت المتاح: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> prepareServicesData() {
    Map<String, dynamic> servicesIds = {};
    int i = 0;
    for (var service in widget.bookingCart.selectedServices) {
      servicesIds.addAll({"services_ids[$i]": service.id});
      i++;
    }
    return servicesIds;
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
            backgroundColor: kSecondaryColor,
            child: Text(selectedPartner!.name[0]),
          ),
          title: Text(selectedPartner!.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.check_circle, color: kSecondaryColor),
          onTap: () {
            setState(() {
              selectedPartner = null;
              filteredTimeSlots = null;
            });
          },
        ),
      );
    }

    if (partners == null && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(
          error!,
          style: const TextStyle(fontSize: 16, color: Colors.redAccent),
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
      itemCount: partners!.length,
      itemBuilder: (context, index) {
        final user = partners![index];
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
                color: isSelected ? kPrimaryColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kPrimaryColor : Colors.grey,
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
          thickness: 1,
          // color: Colors.purple.shade200,
        ),
        itemCount: filteredTimeSlots!.first.slots.length,
        itemBuilder: (context, index) {
          final slot = filteredTimeSlots!.first.slots[index];
          return ListTile(
            title: Text('من ${slot.start} إلى ${slot.end}',
                style: const TextStyle(fontSize: 16)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () async {
              final customer = CustomerManager.user;
              if (customer == null) {
                _showLoginDialog(context, slot);
                return;
              }
              router.replace('/confirm-booking', extra: {
                'selectedPartner': selectedPartner,
                'selectedSlot': slot,
                'bookingCart': widget.bookingCart,
              });
            },
            tileColor: kPrimaryColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  void _showLoginDialog(
    BuildContext context,
    slot,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('لاكمال الحجز يجب تسجيل الدخول'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              redirectPath = '/confirm-booking';
              redirectExtra = {
                'selectedPartner': selectedPartner,
                'selectedSlot': slot,
                'bookingCart': widget.bookingCart,
              };

              router.replace('/login');
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommonController>(
      id: 'partner_selection',
      builder: (controller) {
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
      },
    );
  }
}
