import 'package:flutter/material.dart';
import 'package:dorry/model/store/store_service_model.dart';
import 'package:dorry/providers/store_provider.dart';
import 'package:dorry/utils/sizes.dart';

class ServicesSection extends StatefulWidget {
  final StoreProvider storeProvider;

  const ServicesSection({
    super.key,
    required this.storeProvider,
  });

  @override
  State<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<ServicesSection> {
  Map<int, bool> expandedServices = {};

  onExpansionChanged(int id, bool expanded) {
    setState(() {
      expandedServices[id] = expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.storeProvider.services.entries.map((entry) {
        return _buildSection(
          title: entry.key.isEmpty ? 'خدمات أخرى' : entry.key,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entry.value.length,
            itemBuilder: (context, index) {
              final service = entry.value[index];
              return _buildServiceItem(service, widget.storeProvider);
            },
          ),
        );
      }).toList(),
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

  Widget _buildServiceItem(
      StoreServiceModel service, StoreProvider storeProvider) {
    final isSelected =
        storeProvider.bookingCart.selectedServices.contains(service);
    final isExpanded = expandedServices[service.id] ?? false;

    return Card(
      margin: EdgeInsets.symmetric(vertical: Sizes.vertical_5),
      elevation: isSelected ? Sizes.elevation_8 : Sizes.elevation_4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radius_15),
      ),
      color: isSelected ? Colors.blue[50] : Colors.white,
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radius_15),
        ),
        key: PageStorageKey<int>(service.id),
        initiallyExpanded: service.description != null && isExpanded,
        onExpansionChanged: (expanded) {
          if (service.description != null) {
            onExpansionChanged(service.id, expanded);
          }
        },
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? Colors.green : Colors.grey,
        ),
        title: Text(
          service.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Sizes.textSize_16,
            color: isSelected ? Colors.blueAccent : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.discountPrice != null)
              Row(
                children: [
                  Text(
                    '${service.discountPrice} شيكل',
                    style: TextStyle(
                      fontSize: Sizes.textSize_14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: Sizes.width_8),
                  Text(
                    '${service.price} شيكل',
                    style: TextStyle(
                      fontSize: Sizes.textSize_10,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              )
            else
              Text(
                '${service.price} شيكل',
                style: TextStyle(fontSize: Sizes.textSize_14),
              ),
            Text(
              'المدة: ${service.duration} دقيقة',
              style: TextStyle(fontSize: Sizes.textSize_14),
            ),
          ],
        ),
        trailing: IconButton(
          disabledColor: Colors.grey,
          icon: Icon(
            isSelected ? Icons.remove_circle : Icons.add_circle,
            color: ((service.isStandalone == 1 &&
                        storeProvider.bookingCart.selectedServices.isNotEmpty &&
                        !isSelected) ||
                    (storeProvider.bookingCart.hasStandalone &&
                        service.isStandalone == 0))
                ? Colors.grey
                : (isSelected ? Colors.red : Colors.green),
          ),
          onPressed: () => storeProvider.toggleCart(service),
        ),
        children: [
          if (service.description != null)
            Padding(
              padding: EdgeInsets.all(Sizes.paddingAll_16),
              child: Text(
                service.description!,
                style: TextStyle(
                  fontSize: Sizes.textSize_14,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
