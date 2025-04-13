import 'package:hive/hive.dart';

part 'category.g.dart'; // ✅ تم التصحيح

@HiveType(typeId: 4)
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String icon;

  @HiveField(3)
  final CategoryColor color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

@HiveType(typeId: 9)
enum CategoryColor {
  @HiveField(0)
  red,

  @HiveField(1)
  green,

  @HiveField(2)
  blue,

  @HiveField(3)
  yellow,

  @HiveField(4)
  purple,

  @HiveField(5)
  orange,
}
