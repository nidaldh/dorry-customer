import 'package:flutter/material.dart';
 import 'package:dio/dio.dart';
import 'package:dorry/model/store/available_slot_blocks.dart';
import 'package:dorry/model/store/store_user_model.dart';
import 'package:dorry/model/store/booking_cart.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/const/api_uri.dart';

class PartnerSelectionProvider with ChangeNotifier {
  List<StorePartnerModel>? partners;
  List<AvailableSlotBlock>? allTimeSlots;
  List<AvailableSlotBlock>? filteredTimeSlots;
  bool isLoading = false;
  StorePartnerModel? selectedPartner;
  DateTime selectedDate = DateTime.now();
  String? error;

  Future<void> fetchPartners(
      dynamic storeId, BookingCartModel bookingCart) async {
    isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> servicesIds = prepareServicesData(bookingCart);

      final response = await ApiService().getRequest(
        "${ApiUri.store}/$storeId/available-partners",
        queryParameters: servicesIds,
      );
      partners = (response.data['partners'] as List)
          .map((json) => StorePartnerModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is DioException) {
        dynamic data = e.response?.data;
        error = data is Map
            ? data['message'] ?? data['error'] ?? 'Unknown error'
            : 'Unknown error';
        ApiService().handleError(e);
      } else {
        error = 'Failed to load partners: $e';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableTimeSlots(BookingCartModel bookingCart) async {
    if (selectedPartner == null) return;

    isLoading = true;
    notifyListeners();

    try {
      Map<dynamic, dynamic> servicesIds = prepareServicesData(bookingCart);

      Map<String, dynamic> data = {
        'duration': bookingCart.totalDuration,
        'partner_id': selectedPartner!.id,
        ...servicesIds,
      };

      final response = await ApiService().getRequest(
        ApiUri.availableTimeSlots,
        queryParameters: data,
      );

      allTimeSlots = (response.data['availableSlotBlocks'] as List)
          .map((json) => AvailableSlotBlock.fromJson(json))
          .toList();
      filterTimeSlotsByDate(selectedDate);
    } catch (e) {
      if (e is DioException) {
        ApiService().handleError(e);
      } else {
        error = 'Failed to load available time slots: $e';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterTimeSlotsByDate(DateTime date) {
    if (allTimeSlots == null) return;

    filteredTimeSlots = allTimeSlots!.where((slotBlock) {
      return DateTime.parse(slotBlock.date).day == date.day &&
          DateTime.parse(slotBlock.date).month == date.month &&
          DateTime.parse(slotBlock.date).year == date.year;
    }).toList();
    notifyListeners();
  }

  Map<String, dynamic> prepareServicesData(BookingCartModel bookingCart) {
    Map<String, dynamic> servicesIds = {};
    int i = 0;
    for (var service in bookingCart.selectedServices) {
      servicesIds.addAll({"services_ids[$i]": service.id});
      i++;
    }
    return servicesIds;
  }

  void selectPartner(StorePartnerModel partner) {
    selectedPartner = partner;
    filteredTimeSlots = null;
    notifyListeners();
  }

  void deselectPartner() {
    selectedPartner = null;
    filteredTimeSlots = null;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    filterTimeSlotsByDate(date);
    notifyListeners();
  }
}
