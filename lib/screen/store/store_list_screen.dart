import 'package:dorry/router.dart';
import 'package:dorry/utils/app_snack_bar.dart';
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
  int _filterCount = 0;
  final TextEditingController searchController = TextEditingController();

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
    if (area == null) {
      setState(() {
        filteredStores = stores;
        _filterCount = 0;
      });
    } else {
      setState(() {
        filteredStores = stores.where((store) => store.areaId == area).toList();
        _filterCount = 1; // Assuming only one filter is applied for simplicity
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الصالونات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
                label: Text(
                  '$_filterCount',
                  style: TextStyle(color: Colors.white),
                ),
                child: const Icon(Icons.filter_list)),
            onPressed: () async {
              final selectedArea = await showModalBottomSheet<AreaModel>(
                context: context,
                builder: (context) {
                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: areas.map((area) {
                      return ListTile(
                        title: Text(area.name),
                        onTap: () => Navigator.pop(context, area),
                      );
                    }).toList(),
                  );
                },
              );
              _filterStoresByArea(selectedArea?.id);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced search bar with clear button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'بحث بالاسم',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => searchController.clear(),
                )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          // Body of the screen
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
                  const SizedBox(height: 16),
                  const Text('جار تحميل الصالونات...'),
                ],
              ),
            )
                : hasError
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'فشل في تحميل الصالونات.',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
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
                  Icon(Icons.store, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد صالونات متاحة.',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 16.0),
              itemCount: filteredStores.length,
              itemBuilder: (context, index) {
                final store = filteredStores[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin:
                  const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        'https://static.vecteezy.com/system/resources/previews/010/071/559/non_2x/barbershop-logo-barber-shop-logo-template-vector.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                        const Icon(Icons.store,
                            size: 60,
                            color: Colors.grey),
                      ),
                    ),
                    title: Text(
                      store.storeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        if (store.area != null)
                          Text('المنطقة: ${store.area}',
                              style:
                              const TextStyle(fontSize: 16)),
                        if (store.address != null)
                          Text('العنوان: ${store.address}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16),
                    onTap: () =>
                        router.push('/store/${store.id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}