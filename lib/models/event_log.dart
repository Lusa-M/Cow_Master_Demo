class EventLog {
  String? id;
  DateTime date;
  String eventType; // 'Illness/Treatment', 'Weaned', 'Weighed', 'Vaccinated', 'Antiparasitic Treatment', 'Pregnant', 'Milking', 'Dry'
  String? details; // e.g., diagnosis, weight, vaccine name, etc.
  int? durationDays; // for Illness/Treatment
  String? notes;

  EventLog({
    this.id,
    required this.date,
    required this.eventType,
    this.details,
    this.durationDays,
    this.notes,
  }) {
    id ??= DateTime.now().millisecondsSinceEpoch.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'eventType': eventType,
      'details': details,
      'durationDays': durationDays,
      'notes': notes,
    };
  }

  factory EventLog.fromJson(Map<String, dynamic> json) {
    return EventLog(
      id: json['id'],
      date: DateTime.parse(json['date']),
      eventType: json['eventType'],
      details: json['details'],
      durationDays: json['durationDays'],
      notes: json['notes'],
    );
  }

  // Map event types to their display names and condition mapping
  static const Map<String, String> eventTypeDisplayNames = {
    'Illness/Treatment': 'Illness / Treatment',
    'Weaned': 'Weaned',
    'Weighed': 'Weighed',
    'Vaccinated': 'Vaccinated',
    'Antiparasitic Treatment': 'Antiparasitic Treatment',
    'Pregnant': 'Pregnant',
    'Milking': 'Milking',
    'Dry': 'Dry',
  };

  // Map event types to home page conditional summary
  static const Map<String, String> eventToCondition = {
    'Illness/Treatment': 'Sick',
    'Pregnant': 'Pregnant',
    'Milking': 'Milking',
    'Dry': 'Dry',
  };
}
