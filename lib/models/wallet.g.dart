// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 0;

  @override
  Wallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallet(
      id: fields[0] as String,
      name: fields[1] as String,
      currency: fields[2] as String,
      balance: fields[3] as double,
      type: fields[5] as WalletType,
      createdAt: fields[4] as DateTime?,
      transactions: (fields[6] as List?)?.cast<WalletTransaction>(),
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.currency)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.transactions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalletTransactionAdapter extends TypeAdapter<WalletTransaction> {
  @override
  final int typeId = 2;

  @override
  WalletTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletTransaction(
      id: fields[0] as String,
      amount: fields[1] as double,
      description: fields[2] as String,
      type: fields[4] as TransactionType,
      categoryId: fields[5] as String?,
      relatedWalletId: fields[6] as String?,
      isOutgoingTransfer: fields[8] as bool,
      date: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WalletTransaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.categoryId)
      ..writeByte(6)
      ..write(obj.relatedWalletId)
      ..writeByte(8)
      ..write(obj.isOutgoingTransfer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalletTypeAdapter extends TypeAdapter<WalletType> {
  @override
  final int typeId = 1;

  @override
  WalletType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WalletType.cash;
      case 1:
        return WalletType.bank;
      case 2:
        return WalletType.crypto;
      case 3:
        return WalletType.other;
      default:
        return WalletType.cash;
    }
  }

  @override
  void write(BinaryWriter writer, WalletType obj) {
    switch (obj) {
      case WalletType.cash:
        writer.writeByte(0);
        break;
      case WalletType.bank:
        writer.writeByte(1);
        break;
      case WalletType.crypto:
        writer.writeByte(2);
        break;
      case WalletType.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 3;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      case 2:
        return TransactionType.transfer;
      default:
        return TransactionType.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
      case TransactionType.transfer:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
