import 'store_service_model.dart';

class BookingCartModel {
  final List<StoreServiceModel> _selectedServices = [];

  void addService(StoreServiceModel service) {
    _selectedServices.add(service);
  }

  void removeService(StoreServiceModel service) {
    _selectedServices.remove(service);
  }

  int get totalServices => _selectedServices.length;

  num get totalAmount =>
      _selectedServices.fold(0, (sum, service) => sum + service.price);

  int get totalDuration =>
      _selectedServices.fold(0, (sum, service) => sum + service.duration);

  List<StoreServiceModel> get selectedServices =>
      List.unmodifiable(_selectedServices);
}
