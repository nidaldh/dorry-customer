import 'package:dorry/const/api_uri.dart';
import 'package:dorry/model/store/booking_cart.dart';
import 'package:dorry/model/store/store_details_model.dart';
import 'package:dorry/model/store/store_service_model.dart';
import 'package:dorry/model/store/user_selection_screen.dart';
import 'package:dorry/utils/api_serice.dart';
import 'package:flutter/material.dart';

class SalonDetailScreen extends StatefulWidget {
  final dynamic storeId;

  const SalonDetailScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  _SalonDetailScreenState createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  StoreDetailsModel? storeDetails;
  bool isLoading = true;
  final BookingCartModel _bookingCart = BookingCartModel();

  @override
  void initState() {
    super.initState();
    fetchStoreDetails(widget.storeId);
  }

  void fetchStoreDetails(dynamic storeId) async {
    try {
      final response =
          await ApiService().getRequest('${ApiUri.store}/$storeId');
      if (response.statusCode == 200) {
        setState(() {
          storeDetails = StoreDetailsModel.fromJson(response.data);
          isLoading = false;
        });
      }
    } catch (e, s) {
      ApiService().logError(e, s);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addToCart(StoreServiceModel service) {
    if (!_bookingCart.selectedServices.contains(service)) {
      setState(() {
        _bookingCart.addService(service);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : storeDetails != null
              ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 250.0,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(storeDetails!.name),
                        background: const Stack(
                          fit: StackFit.expand,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black54, Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildServicesSection(),
                            const SizedBox(height: 20),
                            _buildBookingSummary(),
                            const SizedBox(height: 20),
                            _buildBookButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(child: Text('فشل في تحميل تفاصيل المتجر')),
    );
  }

  Widget _buildServicesSection() {
    return _buildSection(
      title: 'الخدمات',
      child: Column(
        children: storeDetails!.services
            .map((service) => _buildServiceItem(
                  service.name,
                  '₪${service.price} - ${service.duration} دقيقة ',
                  service,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildServiceItem(
      String name, String price, StoreServiceModel service) {
    return ListTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(price),
      trailing: ElevatedButton(
        onPressed: () => _addToCart(service),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('احجز'),
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملخص الحجز',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('عدد الخدمات: ${_bookingCart.totalServices}'),
                Text('المبلغ الإجمالي: ₪${_bookingCart.totalAmount}'),
                Text('المدة الإجمالية: ${_bookingCart.totalDuration} دقيقة'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final selectedUser = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserSelectionScreen(
                users: storeDetails!.users,
                bookingCart: _bookingCart,
              ),
            ),
          );
          if (selectedUser != null) {
            // Handle the selected user
            print('Selected User: ${selectedUser.name}');
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text('احجز', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ],
    );
  }
}
