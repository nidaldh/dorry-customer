import 'package:dorry/model/store/store_model.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StoreItemCard extends StatelessWidget {
  final StoreModel store;

  const StoreItemCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        router.push('/store/${store.id}');
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radius_16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoreImage(),
            _buildStoreDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreImage() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(Sizes.radius_16),
      ),
      child: Hero(
        tag: 'storeImage-${store.id}',
        child: store.image != null && store.image!.isNotEmpty
            ? Image.network(
                store.image!,
                height: Sizes.height_120,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.black,
                      child: Container(
                        height: Sizes.height_120,
                        color: Colors.grey.shade200,
                      ),
                    );
                  }
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: Sizes.height_120,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: Sizes.iconSize_100,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : Image.asset(
                'assets/image/icon.png',
                height: Sizes.height_120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildStoreDetails() {
    return Padding(
      padding: EdgeInsets.all(Sizes.paddingAll_8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStoreName(),
          SizedBox(height: Sizes.height_3),
          _buildStoreArea(),
          SizedBox(height: Sizes.height_3),
          _buildStoreAddress(),
        ],
      ),
    );
  }

  Widget _buildStoreName() {
    return Text(
      store.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: Sizes.textSize_14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStoreArea() {
    if (store.area != null && store.area!.isNotEmpty) {
      return Text(
        store.area!,
        style: TextStyle(
          fontSize: Sizes.textSize_12,
          color: Colors.grey.shade600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildStoreAddress() {
    if (store.address != null && store.address!.isNotEmpty) {
      return Text(
        store.address!,
        style: TextStyle(
          fontSize: Sizes.textSize_12,
          color: Colors.grey.shade600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
