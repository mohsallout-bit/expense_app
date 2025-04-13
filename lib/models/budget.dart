// lib/models/budget.dart
import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 12)
class Budget {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final DateTime endDate;

  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.startDate,
    required this.endDate,
  });
}
