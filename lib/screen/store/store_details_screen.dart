import 'package:flutter/material.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/model/store/store_details_model.dart';
import 'package:dorry/model/store/store_service_model.dart';
import 'package:dorry/model/store/booking_cart.dart';
import 'package:dorry/screen/store/partner_selection_screen.dart';

class SalonDetailScreen extends StatefulWidget {
  final dynamic storeId;

  const SalonDetailScreen({super.key, required this.storeId});

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
      } else {
        _showError();
      }
    } catch (e, s) {
      ApiService().logError(e, s);
      _showError();
    }
  }

  void _showError() {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('فشل في تحميل تفاصيل المتجر.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _toggleCart(StoreServiceModel service) {
    setState(() {
      if (_bookingCart.selectedServices.contains(service)) {
        _bookingCart.removeService(service);
      } else {
        _bookingCart.addService(service);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جارٍ تحميل تفاصيل المتجر...',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : storeDetails != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            expandedHeight: 250.0,
                            pinned: true,
                            flexibleSpace: FlexibleSpaceBar(
                              title: Text(
                                storeDetails!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.black,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              background: Hero(
                                tag: 'storeImage-${widget.storeId}',
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      "https://static.vecteezy.com/system/resources/previews/010/071/559/non_2x/barbershop-logo-barber-shop-logo-template-vector.jpg",
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.store,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black54,
                                            Colors.transparent
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildBookButton(),
                  ],
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 80, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'فشل في تحميل تفاصيل المتجر.',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildServicesSection() {
    return _buildSection(
      title: 'الخدمات',
      child: Column(
        children: storeDetails!.services
            .map((service) => _buildServiceItem(
                  service.name,
                  '₪${service.price} - ${service.duration} دقيقة',
                  service,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildServiceItem(
      String name, String price, StoreServiceModel service) {
    final isSelected = _bookingCart.selectedServices.contains(service);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: isSelected ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: isSelected ? Colors.blue[50] : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.circle,
          color: isSelected ? Colors.green : Colors.grey,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isSelected ? Colors.blueAccent : Colors.black,
          ),
        ),
        subtitle: Text(
          price,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: IconButton(
          icon: Icon(
            isSelected ? Icons.remove : Icons.add,
            color: isSelected ? Colors.red : Colors.green,
          ),
          onPressed: () => _toggleCart(service),
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    if (_bookingCart.selectedServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PartnerSelectionScreen(
                partners: storeDetails!.partners,
                bookingCart: _bookingCart,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.blueAccent,
          shadowColor: Colors.blueAccent.withOpacity(0.5),
          elevation: 10,
        ),
        child: const Text(
          'اختر الزميل',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
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
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
