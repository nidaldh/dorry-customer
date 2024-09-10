import 'package:flutter/material.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/utils/api_serice.dart';
import 'package:dorry/model/store/store_model.dart';
import 'package:dorry/model/store/store_details_model.dart';
import 'package:dorry/screen/store/store_details_screen.dart';
import 'package:get/get.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  _StoreListScreenState createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  List<StoreModel> stores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  void fetchStores() async {
    try {
      final response = await ApiService().getRequest(ApiUri.store);
      if (response.statusCode == 200) {
        var storeList = (response.data['stores'] as List)
            .map((store) => StoreModel.fromJson(store))
            .toList();
        setState(() {
          stores = storeList;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch stores: $e')),
      );
    }
  }

  void fetchStoreDetails(dynamic storeId) async {
    try {
      final response =
          await ApiService().getRequest('${ApiUri.store}/$storeId');
      if (response.statusCode == 200) {
        final storeDetails = StoreDetailsModel.fromJson(response.data);
      }
    } catch (e, s) {
      ApiService().logError(e, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stores List'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final store = stores[index];
                return Card(
                  child: ListTile(
                    title: Text(store.storeName),
                    onTap: () =>
                        Get.to(() => SalonDetailScreen(storeId: store.id)),
                  ),
                );
              },
            ),
    );
  }
}
