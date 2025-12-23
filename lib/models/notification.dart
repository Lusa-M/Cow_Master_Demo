class TaskNotification {
  String? id;
  String cattleEarTag; // Reference to cattle
  String title;
  String notes;
  DateTime dueDate;
  bool completed;

  TaskNotification({
    this.id,
    required this.cattleEarTag,
    required this.title,
    required this.notes,
    required this.dueDate,
    this.completed = false,
  }) {
    id ??= DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cattleEarTag': cattleEarTag,
      'title': title,
      'notes': notes,
      'dueDate': dueDate.toIso8601String(),
      'completed': completed,
    };
  }

  // Create from JSON
  factory TaskNotification.fromJson(Map<String, dynamic> json) {
    return TaskNotification(
      id: json['id'],
      cattleEarTag: json['cattleEarTag'],
      title: json['title'],
      notes: json['notes'],
      dueDate: DateTime.parse(json['dueDate']),
      completed: json['completed'] ?? false,
    );
  }
}
