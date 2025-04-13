import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 11)
class Expense {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String walletId;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final DateTime date;

  Expense({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.description,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Expense copyWith({
    String? id,
    String? walletId,
    String? categoryId,
    double? amount,
    String? description,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
