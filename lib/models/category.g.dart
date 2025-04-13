// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 4;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Category(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      color: fields[3] as CategoryColor,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryColorAdapter extends TypeAdapter<CategoryColor> {
  @override
  final int typeId = 9;

  @override
  CategoryColor read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CategoryColor.red;
      case 1:
        return CategoryColor.green;
      case 2:
        return CategoryColor.blue;
      case 3:
        return CategoryColor.yellow;
      case 4:
        return CategoryColor.purple;
      case 5:
        return CategoryColor.orange;
      default:
        return CategoryColor.red;
    }
  }

  @override
  void write(BinaryWriter writer, CategoryColor obj) {
    switch (obj) {
      case CategoryColor.red:
        writer.writeByte(0);
        break;
      case CategoryColor.green:
        writer.writeByte(1);
        break;
      case CategoryColor.blue:
        writer.writeByte(2);
        break;
      case CategoryColor.yellow:
        writer.writeByte(3);
        break;
      case CategoryColor.purple:
        writer.writeByte(4);
        break;
      case CategoryColor.orange:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
