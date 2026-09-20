import 'dart:convert';

// Enum to clearly distinguish transaction types
enum TransactionType { expense, income }

class TransactionModel {
  final String id;
  final String accountId;   // Links transaction to a specific Account
  final String categoryId;  // Links transaction to a specific Category
  final double amount;
  final TransactionType type;
  final String? title;       // Optional note/description (e.g., "Dinner with friends")
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.title,
    required this.date,
  });

  // 1. Convert instance to Map for local storage / SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'categoryId': categoryId,
      'amount': amount,
      'type': type.name, // Saves enum as string ('expense' or 'income')
      'title': title,
      'date': date.toIso8601String(), // Saves DateTime as ISO8601 string
    };
  }

  // 2. Construct instance from Map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      accountId: map['accountId'],
      categoryId: map['categoryId'],
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      title: map['title'],
      date: DateTime.parse(map['date']),
    );
  }

  // 3. JSON serialization helpers for SharedPreferences
  String toJson() => jsonEncode(toMap());

  factory TransactionModel.fromJson(String source) =>
      TransactionModel.fromMap(jsonDecode(source));
}