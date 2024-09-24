class AvailableSlotBlock {
  final String date;
  final String day;
  final List<SlotModel> slots;

  AvailableSlotBlock({
    required this.date,
    required this.day,
    required this.slots,
  });

  factory AvailableSlotBlock.fromJson(Map<String, dynamic> json) {
    return AvailableSlotBlock(
      date: json['date'],
      day: json['day'],
      slots: (json['slots'] as List)
          .map((slot) => SlotModel.fromJson(slot))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'slots': slots.map((slot) => slot.toJson()).toList(),
    };
  }
}

class SlotModel {
  final dynamic timeStamp;
  final String start;
  final String end;
  String? day;
  final String? date;

  SlotModel({
    required this.timeStamp,
    required this.start,
    required this.end,
    this.day,
    this.date,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      timeStamp: json['timeStamp'],
      start: json['start'],
      end: json['end'],
      day: json['day'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeStamp': timeStamp,
      'start': start,
      'end': end,
    };
  }
}
