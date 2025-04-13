// lib/providers/categories_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';

// Provider لإدارة حالة التصنيفات
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
      return CategoriesNotifier();
    });

class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier() : super([]) {
    _loadCategories();
  }

  static const String _boxName = 'categories';

  Future<Box<Category>> _ensureBoxOpen() async {
    if (!Hive.isBoxOpen(_boxName)) {
      try {
        return await Hive.openBox<Category>(_boxName);
      } catch (e) {
        print('Error opening categories box: $e');
        rethrow;
      }
    }
    return Hive.box<Category>(_boxName);
  }

  Future<void> _loadCategories() async {
    try {
      final box = await _ensureBoxOpen();
      state = box.values.toList();
      print('Categories loaded successfully: ${state.length} categories');
    } catch (e) {
      print('Error loading categories: $e');
      state = [];
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      print(
        'Attempting to add category: ${category.name} with ID: ${category.id}',
      );
      final box = await _ensureBoxOpen();

      // التحقق من عدم وجود تصنيف بنفس الاسم
      if (state.any((c) => c.name == category.name)) {
        throw Exception('يوجد تصنيف آخر بهذا الاسم');
      }

      await box.put(category.id, category);
      state = [...state, category];
      print(
        'Category added successfully: ${category.name} with ID: ${category.id}',
      );
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  // تحديث تصنيف موجود
  Future<void> updateCategory(Category updatedCategory) async {
    try {
      print('Attempting to update category: ${updatedCategory.name}');
      final box = await _ensureBoxOpen();
      bool nameExists = state.any(
        (c) => c.name == updatedCategory.name && c.id != updatedCategory.id,
      );

      if (nameExists) {
        throw Exception('يوجد تصنيف آخر بهذا الاسم');
      }

      await box.put(updatedCategory.id, updatedCategory);
      state =
          state
              .map((c) => c.id == updatedCategory.id ? updatedCategory : c)
              .toList();
      print('Category updated successfully: ${updatedCategory.name}');
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  // حذف تصنيف
  Future<void> deleteCategory(String categoryId) async {
    try {
      print('Attempting to delete category with ID: $categoryId');
      final box = await _ensureBoxOpen();
      await box.delete(categoryId);
      state = state.where((c) => c.id != categoryId).toList();
      print('Category deleted successfully with ID: $categoryId');
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  // الحصول على تصنيف بواسطة ID
  Category getCategoryById(String categoryId) {
    return state.firstWhere(
      (category) => category.id == categoryId,
      orElse:
          () => Category(
            id: '',
            name: 'غير معروف',
            icon: 'help',
            color: CategoryColor.orange,
          ),
    );
  }

  // التحقق من وجود تصنيف بالاسم
  bool categoryExists(String categoryName) {
    return state.any((category) => category.name == categoryName);
  }

  // الحصول على جميع ألوان التصنيفات المستخدمة
  List<CategoryColor> getUsedColors() {
    return state.map((category) => category.color).toList();
  }

  // الحصول على جميع أيقونات التصنيفات المستخدمة
  List<String> getUsedIcons() {
    return state.map((category) => category.icon).toList();
  }
}

// Provider مساعد للحصول على تصنيف بواسطة ID
final categoryByIdProvider = Provider.family<Category, String>((
  ref,
  categoryId,
) {
  final categories = ref.watch(categoriesProvider);
  return categories.firstWhere(
    (category) => category.id == categoryId,
    orElse:
        () => Category(
          id: '',
          name: 'غير معروف',
          icon: 'help',
          color: CategoryColor.orange,
        ),
  );
});
