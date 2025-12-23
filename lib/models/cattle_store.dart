import 'package:flutter/foundation.dart';
import 'cattle.dart';
import 'event_log.dart';
import 'notification.dart';
import 'finance_entry.dart';
import 'report.dart';

class CattleStore {
  CattleStore._internal();
  static final CattleStore instance = CattleStore._internal();

  final ValueNotifier<List<Cattle>> cattleNotifier = ValueNotifier<List<Cattle>>([]);
  final ValueNotifier<List<FinanceEntry>> financeNotifier = ValueNotifier<List<FinanceEntry>>([]);
  final ValueNotifier<List<Report>> reportNotifier = ValueNotifier<List<Report>>([]);

  List<Cattle> get all => List.unmodifiable(cattleNotifier.value);

  void add(Cattle c) {
    final list = List<Cattle>.from(cattleNotifier.value)..add(c);
    cattleNotifier.value = list;
  }

  void update(String id, Cattle updated) {
    final list = cattleNotifier.value.map((c) => c.id == id ? updated : c).toList();
    cattleNotifier.value = list;
  }

  void remove(String id) {
    final list = cattleNotifier.value.where((c) => c.id != id).toList();
    cattleNotifier.value = list;
  }

  int countByBreed(String breed) {
    return cattleNotifier.value.where((c) => c.breed == breed).length;
  }

  List<Cattle> filterByBreed(String breed) {
    return cattleNotifier.value.where((c) => c.breed == breed).toList();
  }

  /// Filter cattle by event condition (e.g., 'Sick', 'Pregnant', 'Milking', 'Dry')
  List<Cattle> filterByCondition(String condition) {
    return cattleNotifier.value.where((cattle) {
      return cattle.events.any((event) {
        return EventLog.eventToCondition[event.eventType] == condition;
      });
    }).toList();
  }

  /// Count cattle by event condition
  int countByCondition(String condition) {
    return filterByCondition(condition).length;
  }

  /// Get the most recent event for a cattle
  EventLog? getLatestEvent(Cattle cattle) {
    if (cattle.events.isEmpty) return null;
    return cattle.events.reduce((prev, curr) => curr.date.isAfter(prev.date) ? curr : prev);
  }

  /// Get all notifications across all cattle
  List<TaskNotification> getAllNotifications() {
    final allNotifications = <TaskNotification>[];
    for (var cattle in cattleNotifier.value) {
      allNotifications.addAll(cattle.notifications);
    }
    return allNotifications;
  }

  /// Finance entries
  List<FinanceEntry> get allFinance => List.unmodifiable(financeNotifier.value);

  void addFinanceEntry(FinanceEntry e) {
    final list = List<FinanceEntry>.from(financeNotifier.value)..add(e);
    financeNotifier.value = list;
  }

  double totalIncome() {
    return financeNotifier.value.where((e) => e.type == 'income').fold(0.0, (s, e) => s + e.amount);
  }

  double totalExpense() {
    return financeNotifier.value.where((e) => e.type == 'expense').fold(0.0, (s, e) => s + e.amount);
  }

  List<FinanceEntry> getEntriesByType(String type) {
    return financeNotifier.value.where((e) => e.type == type).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Reports
  List<Report> get allReports => List.unmodifiable(reportNotifier.value);

  void addReport(Report r) {
    final list = List<Report>.from(reportNotifier.value)..add(r);
    reportNotifier.value = list;
  }

  /// Count non-completed notifications
  int countNotifications() {
    return getAllNotifications().where((n) => !n.completed).length;
  }

  /// Get all events across all cattle
  List<EventLog> getAllEvents() {
    final allEvents = <EventLog>[];
    for (var cattle in cattleNotifier.value) {
      allEvents.addAll(cattle.events);
    }
    // Sort by date descending (most recent first)
    allEvents.sort((a, b) => b.date.compareTo(a.date));
    return allEvents;
  }

  /// Count all events
  int countEvents() {
    return getAllEvents().length;
  }
}
