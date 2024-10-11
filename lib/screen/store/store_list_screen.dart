import 'package:dorry/router.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:flutter/material.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/model/store/store_model.dart';
import 'package:dorry/model/address/area_model.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  _StoreListScreenState createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  List<StoreModel> stores = [];
  List<StoreModel> filteredStores = [];
  List<AreaModel> areas = [];
  bool isLoading = true;
  bool hasError = false;
  final TextEditingController searchController = TextEditingController();
  int? _selectedAreaId;

  @override
  void initState() {
    super.initState();
    fetchStores();
    fetchAreas();
    searchController.addListener(_filterStores);
  }

  void fetchStores() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await ApiService().getRequest(ApiUri.store);
      if (response.statusCode == 200) {
        var storeList = (response.data['stores'] as List)
            .map((store) => StoreModel.fromJson(store))
            .toList();
        setState(() {
          stores = storeList;
          filteredStores = storeList;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load stores');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      errorSnackBar('فشل في تحميل الصالونات: $e');
    }
  }

  void fetchAreas() async {
    try {
      final response =
          await ApiService().getRequest('/api/address/areas-for-filter');
      if (response.statusCode == 200) {
        var areaList = (response.data['areas'] as List)
            .map((area) => AreaModel.fromJson(area))
            .toList();
        setState(() {
          areas = areaList;
        });
      } else {
        throw Exception('Failed to load areas');
      }
    } catch (e) {
      errorSnackBar('فشل في تحميل المناطق: $e');
    }
  }

  void _filterStores() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredStores = query.isEmpty
          ? stores
          : stores
              .where((store) => store.storeName.toLowerCase().contains(query))
              .toList();
    });
  }

  void _filterStoresByArea(dynamic area) {
    if (area == null || _selectedAreaId == area) {
      setState(() {
        filteredStores = stores;
        _selectedAreaId = null;
      });
    } else {
      setState(() {
        filteredStores = stores.where((store) => store.areaId == area).toList();
        _selectedAreaId = area;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Sizes.horizontal_16, vertical: Sizes.vertical_5),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'بحث بالاسم',
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => searchController.clear(),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.radius_10),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor),
                          ),
                          SizedBox(height: Sizes.height_16),
                          const Text('جار تحميل الصالونات...'),
                        ],
                      ),
                    )
                  : hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error,
                                  color: Colors.red, size: Sizes.iconSize_54),
                              SizedBox(height: Sizes.height_16),
                              Text(
                                'فشل في تحميل الصالونات.',
                                style: TextStyle(
                                    fontSize: Sizes.textSize_18,
                                    color: Colors.red),
                              ),
                              SizedBox(height: Sizes.height_16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                onPressed: fetchStores,
                                label: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        )
                      : filteredStores.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.store,
                                      size: Sizes.iconSize_65,
                                      color: Colors.grey),
                                  SizedBox(height: Sizes.height_16),
                                  Text(
                                    'لا توجد صالونات متاحة.',
                                    style:
                                        TextStyle(fontSize: Sizes.textSize_18),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Sizes.horizontal_16),
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: Sizes.size_16,
                                  mainAxisSpacing: Sizes.size_16,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: filteredStores.length,
                                itemBuilder: (context, index) {
                                  final store = filteredStores[index];
                                  return GestureDetector(
                                    onTap: () {
                                      router.push('/store/${store.id}');
                                    },
                                    child: Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Sizes.radius_16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(
                                                  Sizes.radius_16),
                                            ),
                                            child: Image.network(
                                              store.image ??
                                                  'https://static.vecteezy.com/system/resources/previews/010/071/559/non_2x/barbershop-logo-barber-shop-logo-template-vector.jpg',
                                              height: Sizes.height_100,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Icon(Icons.store,
                                                      size: Sizes.iconSize_100,
                                                      color: Colors.grey),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              start: Sizes.paddingAll_3,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  store.storeName,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: Sizes.textSize_12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (store.area != null) ...[
                                                  Text(
                                                    store.area!,
                                                    style: TextStyle(
                                                      fontSize:
                                                          Sizes.textSize_12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                                if (store.address != null) ...[
                                                  SizedBox(
                                                    height: Sizes.height_3,
                                                  ),
                                                  Text(
                                                    store.address!,
                                                    style: TextStyle(
                                                      fontSize:
                                                          Sizes.textSize_10,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ]
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final selectedArea = await showModalBottomSheet<AreaModel>(
              context: context,
              builder: (context) {
                return ListView(
                  padding: EdgeInsets.all(Sizes.paddingAll_16),
                  children: areas.map((area) {
                    return ListTile(
                      title: Text(area.name),
                      trailing: _selectedAreaId == area.id
                          ? Icon(Icons.check,
                              color: Theme.of(context).primaryColor)
                          : null,
                      onTap: () => Navigator.pop(context, area),
                    );
                  }).toList(),
                );
              },
            );
            _filterStoresByArea(selectedArea?.id);
          },
          child: const Icon(Icons.filter_list),
        ),
      ),
    );
  }
}
