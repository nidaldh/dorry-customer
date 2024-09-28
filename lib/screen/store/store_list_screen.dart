import 'package:dorry/router.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/model/store/store_model.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  _StoreListScreenState createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  List<StoreModel> stores = [];
  List<StoreModel> filteredStores = [];
  bool isLoading = true;
  bool hasError = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStores();
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

  void _filterStores() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredStores = stores;
      });
      return;
    }
    setState(() {
      filteredStores = stores.where((store) {
        return store.storeName.toLowerCase().contains(query);
      }).toList();
    });
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'بحث بالاسم',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'فشل في تحميل الصالونات.',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchStores,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
                : filteredStores.isEmpty
                ? const Center(
              child: Text(
                'لا توجد صالونات متاحة.',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 16.0),
              itemCount: filteredStores.length,
              itemBuilder: (context, index) {
                final store = filteredStores[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        'https://static.vecteezy.com/system/resources/previews/010/071/559/non_2x/barbershop-logo-barber-shop-logo-template-vector.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.store,
                            size: 50, color: Colors.grey),
                      ),
                    ),
                    title: Text(
                      store.storeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => router.push('/store/${store.id}'),
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