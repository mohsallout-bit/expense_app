import 'package:hive/hive.dart';

part 'transfer.g.dart';

@HiveType(typeId: 13)
class Transfer {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fromWalletId;

  @HiveField(2)
  final String toWalletId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final DateTime date;

  Transfer({
    required this.id,
    required this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    required this.description,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}
