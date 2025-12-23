class FinanceEntry {
  final String id;
  final DateTime date;
  final String type; // 'income' or 'expense'
  final double amount;
  final String title;
  final String? notes;

  FinanceEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.title,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type,
        'amount': amount,
        'title': title,
        'notes': notes,
      };

  static FinanceEntry fromJson(Map<String, dynamic> json) => FinanceEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        title: json['title'] as String,
        notes: json['notes'] as String?,
      );
}
