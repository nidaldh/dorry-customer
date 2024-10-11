import 'package:dorry/router.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/model/store/store_details_model.dart';
import 'package:dorry/model/store/store_service_model.dart';
import 'package:dorry/model/store/booking_cart.dart';
import 'package:dorry/utils/sizes.dart';

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
    errorSnackBar('فشل في تحميل تفاصيل المتجر.');
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: Sizes.height_16),
                  Text(
                    'جارٍ تحميل تفاصيل المتجر...',
                    style: TextStyle(fontSize: Sizes.textSize_16),
                  ),
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
                            expandedHeight: Sizes.height_200,
                            pinned: true,
                            flexibleSpace: FlexibleSpaceBar(
                              title: Text(
                                storeDetails!.name,
                                style: TextStyle(
                                  // color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Sizes.textSize_16,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              background: Hero(
                                tag: 'storeImage-${widget.storeId}',
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      storeDetails!.image ??
                                          "https://static.vecteezy.com/system/resources/previews/010/071/559/non_2x/barbershop-logo-barber-shop-logo-template-vector.jpg",
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                        Icons.store,
                                        size: Sizes.iconSize_50,
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
                              padding: EdgeInsets.all(Sizes.paddingAll_16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (storeDetails!.address != null ||
                                      storeDetails!.area != null) ...[
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            color: Colors.grey),
                                        SizedBox(width: Sizes.width_8),
                                        Expanded(
                                          child: Text(
                                            "${storeDetails!.area ?? ''}, ${storeDetails!.address ?? ''}",
                                            style: TextStyle(
                                                fontSize: Sizes.textSize_16,
                                                color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  _buildServicesSection(),
                                  SizedBox(height: Sizes.height_30),
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
              : Center(
                  child: Padding(
                    padding: EdgeInsets.all(Sizes.paddingAll_16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error,
                            size: Sizes.iconSize_60, color: Colors.red),
                        SizedBox(height: Sizes.height_16),
                        Text(
                          'فشل في تحميل تفاصيل المتجر.',
                          style: TextStyle(fontSize: Sizes.textSize_18),
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
      margin: EdgeInsets.symmetric(vertical: Sizes.vertical_5),
      elevation: isSelected ? Sizes.elevation_8 : Sizes.elevation_4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radius_15),
      ),
      color: isSelected ? Colors.blue[50] : Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.all(Sizes.paddingAll_16),
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.circle,
          color: isSelected ? Colors.green : Colors.grey,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Sizes.textSize_16,
            color: isSelected ? Colors.blueAccent : Colors.black,
          ),
        ),
        subtitle: Text(
          price,
          style: TextStyle(fontSize: Sizes.textSize_14),
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
          router.push(
            '/partner-selection',
            extra: {
              'partners': storeDetails!.partners,
              'bookingCart': _bookingCart,
            },
          );
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: Sizes.vertical_15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radius_30),
          ),
          backgroundColor: Colors.blueAccent,
          shadowColor: Colors.blueAccent.withOpacity(0.5),
          elevation: Sizes.elevation_8,
        ),
        child: Text(
          'اختر الزميل',
          style: TextStyle(fontSize: Sizes.textSize_18, color: Colors.white),
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
          style: TextStyle(
            fontSize: Sizes.textSize_22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: Sizes.height_8),
        child,
      ],
    );
  }
}
