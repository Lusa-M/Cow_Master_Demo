class Report {
  final String id;
  final DateTime date;
  final String title;
  final String? notes;

  Report({required this.id, required this.date, required this.title, this.notes});

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'notes': notes,
      };

  static Report fromJson(Map<String, dynamic> json) => Report(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        title: json['title'] as String,
        notes: json['notes'] as String?,
      );
}
