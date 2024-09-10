class AvailableSlotBlock {
  final String date;
  final String day;
  final List<Slot> slots;

  AvailableSlotBlock({
    required this.date,
    required this.day,
    required this.slots,
  });

  factory AvailableSlotBlock.fromJson(Map<String, dynamic> json) {
    return AvailableSlotBlock(
      date: json['date'],
      day: json['day'],
      slots:
          (json['slots'] as List).map((slot) => Slot.fromJson(slot)).toList(),
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

class Slot {
  final dynamic timeStamp;
  final String start;
  final String end;

  Slot({
    required this.timeStamp,
    required this.start,
    required this.end,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      timeStamp: json['timeStamp'],
      start: json['start'],
      end: json['end'],
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
