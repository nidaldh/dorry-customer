import 'package:dorry/widget/store/services_section.dart';
import 'package:dorry/widget/store/social_media_actions.dart';
import 'package:flutter/material.dart';
import 'package:dorry/providers/store_provider.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:provider/provider.dart';

class StoreDetailScreen extends StatefulWidget {
  final dynamic storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  _StoreDetailScreenState createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreProvider()..fetchStoreDetails(widget.storeId),
      child: Consumer<StoreProvider>(
        builder: (context, storeProvider, child) {
          if (storeProvider.isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('جارٍ التحميل...'),
                centerTitle: true,
              ),
              body: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            );
          }

          if (storeProvider.storeDetails == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('خطأ'),
                centerTitle: true,
              ),
              body: Center(
                child: Text(
                  'فشل في تحميل تفاصيل المتجر.',
                  style: TextStyle(
                    fontSize: Sizes.textSize_18,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          final storeDetails = storeProvider.storeDetails!;

          return Scaffold(
            body: Stack(
              children: [
                NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      expandedHeight: Sizes.height_200,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          storeDetails.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Sizes.textSize_16,
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.black,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        background: Hero(
                          tag: 'storeImage-${widget.storeId}',
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                storeDetails.image ??
                                    "https://static.vecteezy.com/system/resources/previews/010/071/559/non_2x/barbershop-logo-barber-shop-logo-template-vector.jpg",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.broken_image,
                                    size: Sizes.iconSize_100,
                                    color: Colors.grey,
                                  ),
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
                  ],
                  body: SingleChildScrollView(
                    padding: EdgeInsets.all(Sizes.paddingAll_16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Address
                        if (storeDetails.address != null ||
                            storeDetails.area != null)
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.grey),
                              SizedBox(width: Sizes.width_8),
                              Expanded(
                                child: Text(
                                  "${storeDetails.area ?? ''}, ${storeDetails.address ?? ''}",
                                  style: TextStyle(
                                    fontSize: Sizes.textSize_16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: Sizes.height_16),
                        _buildBioSection(storeDetails.bio ?? ''),
                        ServicesSection(
                          storeProvider: storeProvider,
                        ),
                        SocialMediaActions(
                          storeDetails: storeDetails,
                        ),
                        if (storeProvider
                            .bookingCart.selectedServices.isNotEmpty)
                          SizedBox(height: Sizes.height_60),
                      ],
                    ),
                  ),
                ),
                if (storeProvider.bookingCart.selectedServices.isNotEmpty)
                  Positioned(
                    bottom: Sizes.height_16,
                    left: Sizes.width_10,
                    right: Sizes.width_10,
                    child: ElevatedButton(
                      onPressed: () {
                        storeProvider.goToPartnerSelection();
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: Sizes.vertical_15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.radius_30),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        elevation: Sizes.elevation_8,
                      ),
                      child: const Text(
                        'اختر الزميل',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBioSection(String bio) {
    if (bio.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'من نحن',
          style: TextStyle(
            fontSize: Sizes.textSize_22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: Sizes.height_8),
        Text(
          bio,
          style: TextStyle(fontSize: Sizes.textSize_16),
        ),
      ],
    );
  }
}
