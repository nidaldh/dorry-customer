enum StoreType {
  barbershop,
  carWash,
}

extension StoreTypeExtension on StoreType {
  String get displayName {
    switch (this) {
      case StoreType.barbershop:
        return 'Barbershop';
      case StoreType.carWash:
        return 'Car Wash';
      default:
        return '';
    }
  }

  String get id {
    switch (this) {
      case StoreType.barbershop:
        return 'barbershop';
      case StoreType.carWash:
        return 'carWash';
      default:
        return '';
    }
  }

  static StoreType fromId(String id) {
    switch (id) {
      case 'barbershop':
        return StoreType.barbershop;
      case 'carWash':
        return StoreType.carWash;
      default:
        return StoreType.carWash;
    }
  }
}
