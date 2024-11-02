import 'package:dorry/app_theme.dart';
import 'package:dorry/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dorry/providers/partner_selection_provider.dart';
import 'package:dorry/model/store/booking_cart.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:dorry/router.dart';
import 'package:get/get.dart';
import 'package:dorry/controller/common_controller.dart';
import 'package:dorry/utils/sizes.dart';

class PartnerSelectionScreen extends StatelessWidget {
  final BookingCartModel bookingCart;
  final dynamic storeId;

  const PartnerSelectionScreen({
    super.key,
    required this.storeId,
    required this.bookingCart,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          PartnerSelectionProvider()..fetchPartners(storeId, bookingCart),
      child: GetBuilder<CommonController>(
        id: 'partner_selection',
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  const Icon(Icons.group, size: 24),
                  SizedBox(width: Sizes.size_8),
                  const Text('اختر الزميل'),
                ],
              ),
              centerTitle: true,
            ),
            body: Consumer<PartnerSelectionProvider>(
              builder: (context, provider, child) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        _buildUserList(provider),
                        if (provider.selectedPartner != null)
                          _buildDateSelector(provider),
                        if (provider.selectedPartner != null)
                          _buildAvailableSlots(provider),
                      ],
                    ),
                    if (provider.isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserList(PartnerSelectionProvider provider) {
    if (provider.selectedPartner != null) {
      return Card(
        elevation: Sizes.elevation_3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radius_15),
        ),
        margin: EdgeInsets.symmetric(vertical: Sizes.vertical_5),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
              vertical: Sizes.vertical_10, horizontal: Sizes.horizontal_16),
          leading: CircleAvatar(
            backgroundColor: kSecondaryColor,
            child: provider.selectedPartner!.profileImage != null
                ? Image.network(provider.selectedPartner!.profileImage!)
                : Text(provider.selectedPartner!.name[0]),
          ),
          title: Text(provider.selectedPartner!.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.check_circle, color: kSecondaryColor),
          onTap: () {
            provider.deselectPartner();
          },
        ),
      );
    }

    if (provider.partners == null && provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style:
              TextStyle(fontSize: Sizes.textSize_16, color: Colors.redAccent),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(Sizes.paddingAll_16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: Sizes.size_16,
        mainAxisSpacing: Sizes.size_16,
      ),
      itemCount: provider.partners!.length,
      itemBuilder: (context, index) {
        final user = provider.partners![index];
        return GestureDetector(
          onTap: () {
            provider.selectPartner(user);
            provider.fetchAvailableTimeSlots(bookingCart);
          },
          child: Card(
            elevation: Sizes.elevation_1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.radius_15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: Sizes.radius_60,
                  backgroundColor: Colors.grey,
                  child: user.profileImage != null
                      ? Image.network(user.profileImage!)
                      : Text(
                          user.name[0],
                          style: TextStyle(
                              fontSize: Sizes.textSize_24, color: Colors.white),
                        ),
                ),
                SizedBox(height: Sizes.height_8),
                Text(user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector(PartnerSelectionProvider provider) {
    List<Widget> dateWidgets = [];

    provider.allTimeSlots?.forEach((element) {
      DateTime date = DateTime.parse(element.date);
      dateWidgets.add(_buildDateItem(provider, date, element.day));
    });

    return Container(
      padding: EdgeInsets.symmetric(vertical: Sizes.vertical_10),
      height: Sizes.height_100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: dateWidgets,
      ),
    );
  }

  Widget _buildDateItem(
      PartnerSelectionProvider provider, DateTime date, String day) {
    bool isSelected = date.day == provider.selectedDate.day &&
        date.month == provider.selectedDate.month &&
        date.year == provider.selectedDate.year;

    return GestureDetector(
      onTap: () {
        provider.selectDate(date);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.horizontal_5),
        child: Column(
          children: [
            Container(
              width: Sizes.width_50,
              height: Sizes.height_50,
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kPrimaryColor : Colors.grey,
                  width: Sizes.size_1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: Sizes.textSize_18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: Sizes.height_5),
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

  Widget _buildAvailableSlots(PartnerSelectionProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.filteredTimeSlots == null ||
        provider.filteredTimeSlots!.isEmpty) {
      return Center(
        child: Text(
          'لم يتم العثور على وقت متاحة.',
          style:
              TextStyle(fontSize: Sizes.textSize_16, color: Colors.redAccent),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.all(Sizes.paddingAll_16),
        separatorBuilder: (context, index) =>
            Divider(thickness: Sizes.size_1, color: Colors.grey),
        itemCount: provider.filteredTimeSlots!.first.slots.length,
        itemBuilder: (context, index) {
          final slot = provider.filteredTimeSlots!.first.slots[index];
          return ListTile(
            title: Text('من ${slot.start} إلى ${slot.end}',
                style: TextStyle(fontSize: Sizes.textSize_16)),
            trailing: Icon(Icons.arrow_forward_ios, size: Sizes.iconSize_20),
            onTap: () async {
              final customer = CustomerManager.user;
              if (customer == null) {
                _showLoginDialog(context, slot, provider);
                return;
              }
              router.replace('/confirm-booking', extra: {
                'selectedPartner': provider.selectedPartner,
                'selectedSlot': slot,
                'bookingCart': bookingCart,
              });
            },
            tileColor: kPrimaryColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.radius_10),
            ),
          );
        },
      ),
    );
  }

  void _showLoginDialog(
      BuildContext context, slot, PartnerSelectionProvider provider) {
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
                'selectedPartner': provider.selectedPartner,
                'selectedSlot': slot,
                'bookingCart': bookingCart,
              };

              router.replace('/login');
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }
}
