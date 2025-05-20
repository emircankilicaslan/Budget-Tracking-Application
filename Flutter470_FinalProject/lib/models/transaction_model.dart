import 'package:uuid/uuid.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String description;
  final DateTime date;

  TransactionModel({
    String? id,
    required this.amount,
    required this.description,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  // Convert TransactionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  // Create TransactionModel from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }

  // Create a copy of TransactionModel with optional new values
  TransactionModel copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
