import 'package:dorry/router.dart';
import 'package:flutter/material.dart';
import 'package:dorry/model/store/store_details_model.dart';
import 'package:dorry/model/store/store_service_model.dart';
import 'package:dorry/model/store/booking_cart.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/const/api_uri.dart';

class StoreProvider with ChangeNotifier {
  StoreDetailsModel? storeDetails;
  Map<String, List<StoreServiceModel>> services = {};
  bool isLoading = true;
  final BookingCartModel _bookingCart = BookingCartModel();
  bool isFavorite = false;

  BookingCartModel get bookingCart => _bookingCart;

  Future<void> fetchStoreDetails(dynamic storeId) async {
    try {
      final response =
          await ApiService().getRequest('${ApiUri.store}/$storeId');
      if (response.statusCode == 200) {
        storeDetails = StoreDetailsModel.fromJson(response.data);
        await fetchStoreServices(storeId);
      } else {
        _showError();
      }
    } catch (e, s) {
      ApiService().logError(e, s);
      _showError();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStoreServices(dynamic storeId) async {
    try {
      final response =
          await ApiService().getRequest('${ApiUri.store}/$storeId/services');
      if (response.statusCode == 200) {
        final data = response.data['services'] as Map<String, dynamic>;
        services = data.map((key, value) {
          return MapEntry(
              key,
              (value as List)
                  .map((item) => StoreServiceModel.fromJson(item))
                  .toList());
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
    isLoading = false;
    notifyListeners();
  }

  void toggleCart(StoreServiceModel service) {
    if (_bookingCart.selectedServices.contains(service)) {
      _bookingCart.removeService(service);
    } else {
      if ((service.isStandalone == 1 &&
              _bookingCart.selectedServices.isNotEmpty) ||
          _bookingCart.hasStandalone) {
        return;
      }
      _bookingCart.addService(service);
      if (service.isStandalone == 1) {
        goToPartnerSelection();
      }
    }
    notifyListeners();
  }

  void goToPartnerSelection() {
    router.push(
      partnerSelectionPath,
      extra: {
        'storeId': storeDetails!.id,
        'bookingCart': bookingCart,
      },
    );
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }
}
