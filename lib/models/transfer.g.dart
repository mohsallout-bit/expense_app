// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransferAdapter extends TypeAdapter<Transfer> {
  @override
  final int typeId = 13;

  @override
  Transfer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transfer(
      id: fields[0] as String,
      fromWalletId: fields[1] as String,
      toWalletId: fields[2] as String,
      amount: fields[3] as double,
      description: fields[4] as String,
      date: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Transfer obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fromWalletId)
      ..writeByte(2)
      ..write(obj.toWalletId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
