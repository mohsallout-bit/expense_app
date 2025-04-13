import 'package:hive/hive.dart';

part 'wallet.g.dart';

@HiveType(typeId: 0) // Wallet
class Wallet {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String currency;

  @HiveField(3)
  double balance; // ✅ لم يعد final

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final WalletType type;

  @HiveField(6)
  List<WalletTransaction> transactions; // ✅ لم يعد final

  Wallet({
    required this.id,
    required this.name,
    required this.currency,
    required this.balance,
    required this.type,
    DateTime? createdAt,
    List<WalletTransaction>? transactions,
  }) : createdAt = createdAt ?? DateTime.now(),
       transactions = transactions ?? [];

  Wallet copyWith({
    String? id,
    String? name,
    String? currency,
    double? balance,
    DateTime? createdAt,
    WalletType? type,
    List<WalletTransaction>? transactions,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      transactions:
          transactions ?? List<WalletTransaction>.from(this.transactions),
    );
  }
}

@HiveType(typeId: 1) // WalletType
enum WalletType {
  @HiveField(0)
  cash,
  @HiveField(1)
  bank,
  @HiveField(2)
  crypto,
  @HiveField(3)
  other,
}

@HiveType(typeId: 2) // WalletTransaction
class WalletTransaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final TransactionType type;

  @HiveField(5)
  final String? categoryId;

  @HiveField(6)
  final String? relatedWalletId;

  @HiveField(8) // Using field 8 since 7 might be used in the generated code
  final bool isOutgoingTransfer;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.type,
    this.categoryId,
    this.relatedWalletId,
    this.isOutgoingTransfer = true,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

@HiveType(typeId: 3) // TransactionType
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
  @HiveField(2)
  transfer,
}
