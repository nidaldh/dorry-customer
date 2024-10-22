import 'package:flutter/material.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/model/store/store_model.dart';
import 'package:dorry/model/address/area_model.dart';
import 'package:dorry/utils/app_snack_bar.dart';

class StoreListProvider extends ChangeNotifier {
  List<StoreModel> stores = [];
  List<StoreModel> filteredStores = [];
  List<AreaModel> areas = [];
  bool isLoading = true;
  bool hasError = false;
  int? selectedAreaId;

  StoreListProvider() {
    fetchStores();
    fetchAreas();
  }

  void fetchStores() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final response = await ApiService().getRequest(ApiUri.store, queryParameters: {
        "gender": "male",
      });
      if (response.statusCode == 200) {
        var storeList = (response.data['stores'] as List)
            .map((store) => StoreModel.fromJson(store))
            .toList();
        stores = storeList;
        filteredStores = storeList;
        isLoading = false;
      } else {
        throw Exception('Failed to load stores');
      }
    } catch (e) {
      isLoading = false;
      hasError = true;
      errorSnackBar('فشل في تحميل الصالونات: $e');
    }
    notifyListeners();
  }

  void fetchAreas() async {
    try {
      final response = await ApiService().getRequest(ApiUri.areas);
      if (response.statusCode == 200) {
        areas = (response.data['areas'] as List)
            .map((area) => AreaModel.fromJson(area))
            .toList();
      } else {
        throw Exception('Failed to load areas');
      }
    } catch (e) {
      errorSnackBar('فشل في تحميل المناطق: $e');
    }
    notifyListeners();
  }

  void filterStores(String query) {
    query = query.toLowerCase();
    filteredStores = query.isEmpty
        ? stores
        : stores.where((store) => store.name.toLowerCase().contains(query)).toList();
    notifyListeners();
  }

  void filterStoresByArea(dynamic area) {
    if (area == null || selectedAreaId == area) {
      filteredStores = stores;
      selectedAreaId = null;
    } else {
      filteredStores = stores.where((store) => store.areaId == area).toList();
      selectedAreaId = area;
    }
    notifyListeners();
  }
}