import 'package:dorry/model/store/store_model.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:flutter/material.dart';
import 'package:dorry/router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dorry/utils/sizes.dart';

class FavoriteStoresScreen extends StatefulWidget {
  const FavoriteStoresScreen({super.key});

  @override
  State<FavoriteStoresScreen> createState() => _FavoriteStoresScreenState();
}

class _FavoriteStoresScreenState extends State<FavoriteStoresScreen> {
  List<StoreModel> favoriteStores = [];
  bool isLoading = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchFavoriteStores();
  }

  Future<void> fetchFavoriteStores() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await ApiService().getRequest('/api/customer/favorites');
      if (response.statusCode == 200) {
        setState(() {
          favoriteStores = (response.data['favorite_stores'] as List)
              .map((store) => StoreModel.fromJson(store))
              .toList();
        });
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المتاجر المفضلة'),
        centerTitle: true,
      ),
      body: isLoading
          ? _buildLoadingState()
          : hasError
              ? _buildErrorState()
              : favoriteStores.isEmpty
                  ? _buildEmptyState()
                  : _buildFavoriteStoresList(),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.all(Sizes.paddingAll_8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: Sizes.height_80,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(Sizes.radius_8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: Sizes.iconSize_60),
          SizedBox(height: Sizes.height_16),
          Text(
            'فشل في تحميل المتاجر المفضلة.',
            style: TextStyle(fontSize: Sizes.textSize_18, color: Colors.red),
          ),
          SizedBox(height: Sizes.height_16),
          ElevatedButton(
            onPressed: fetchFavoriteStores,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: Sizes.iconSize_60, color: Colors.grey),
          SizedBox(height: Sizes.height_16),
          Text(
            'لا توجد متاجر مفضلة متاحة.',
            style: TextStyle(fontSize: Sizes.textSize_18),
          ),
          SizedBox(height: Sizes.height_16),
          ElevatedButton(
            onPressed: () {
              // Navigate to store discovery
            },
            child: const Text('اكتشف المتاجر'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteStoresList() {
    return ListView.builder(
      itemCount: favoriteStores.length,
      itemBuilder: (context, index) {
        final store = favoriteStores[index];
        return Card(
          margin: EdgeInsets.symmetric(
              horizontal: Sizes.horizontal_16, vertical: Sizes.vertical_5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radius_10),
          ),
          elevation: Sizes.elevation_1,
          child: InkWell(
            onTap: () {
              router.push(
                '/store/${store.id}',
              );
            },
            child: Padding(
              padding: EdgeInsets.all(Sizes.paddingAll_8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Sizes.radius_8),
                    child: store.image != null
                        ? Image.network(
                            store.image!,
                            width: Sizes.width_60,
                            height: Sizes.height_60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: Sizes.width_60,
                              height: Sizes.height_60,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: Sizes.iconSize_60,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : Icon(Icons.store,
                            size: Sizes.iconSize_60, color: Colors.grey),
                  ),
                  SizedBox(width: Sizes.width_15),
                  Expanded(
                    child: Text(
                      store.name,
                      style: TextStyle(
                        fontSize: Sizes.textSize_16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
