import 'event_log.dart';
import 'notification.dart';

class Cattle {
  String? id;
  String name;
  String earTag;
  String gender; // 'Male' or 'Female'
  DateTime birthDate;
  String breed;
  String damEarTag;
  String sireName;
  String notes;
  List<EventLog> events;
  List<TaskNotification> notifications;

  Cattle({
    this.id,
    required this.name,
    required this.earTag,
    required this.gender,
    required this.birthDate,
    this.breed = '',
    this.damEarTag = '',
    this.sireName = '',
    this.notes = '',
    this.events = const [],
    this.notifications = const [],
  }) {
    id ??= earTag;
  }

  // Calculate age from birth date
  String getAge() {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
      final previousMonth = DateTime(now.year, now.month, 0);
      days += previousMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return '${years}y ${months}m';
  }

  // Get latest pregnancy event
  EventLog? getLatestPregnancyEvent() {
    try {
      return events
          .where((e) => e.eventType == 'Pregnant')
          .reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    } catch (e) {
      return null;
    }
  }

  // Calculate days pregnant from latest pregnancy event
  String getPregnancyDuration() {
    final pregnancyEvent = getLatestPregnancyEvent();
    if (pregnancyEvent == null) return 'Not pregnant';
    
    final now = DateTime.now();
    final daysPassed = now.difference(pregnancyEvent.date).inDays;
    return '$daysPassed days pregnant';
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'earTag': earTag,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'breed': breed,
      'damEarTag': damEarTag,
      'sireName': sireName,
      'notes': notes,
      'events': events.map((e) => e.toJson()).toList(),
      'notifications': notifications.map((n) => n.toJson()).toList(),
    };
  }

  // Create from JSON
  factory Cattle.fromJson(Map<String, dynamic> json) {
    final eventList = (json['events'] as List?)
        ?.map((e) => EventLog.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    final notificationList = (json['notifications'] as List?)
        ?.map((n) => TaskNotification.fromJson(n as Map<String, dynamic>))
        .toList() ?? [];
    return Cattle(
      id: json['id'],
      name: json['name'],
      earTag: json['earTag'],
      gender: json['gender'],
      birthDate: DateTime.parse(json['birthDate']),
      breed: json['breed'] ?? '',
      damEarTag: json['damEarTag'] ?? '',
      sireName: json['sireName'] ?? '',
      notes: json['notes'] ?? '',
      events: eventList,
      notifications: notificationList,
    );
  }

}