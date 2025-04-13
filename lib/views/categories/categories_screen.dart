// lib/views/categories/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/category.dart';
import '../../../../providers/categories_provider.dart';
import '../shared/custom_button.dart';
import '../shared/custom_card.dart';
import '../../core/app_theme.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60 + topPadding,
        title: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: const Text('إدارة التصنيفات'),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: topPadding, left: 8, right: 8),
            child: CustomButton(
              text: 'إضافة',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
                );
              },
              variant: CustomButtonVariant.text,
              icon: Icons.add,
              size: CustomButtonSize.small,
            ),
          ),
        ],
      ),
      body:
          categories.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد تصنيفات مسجلة',
                      style: AppTheme.headingStyle.copyWith(
                        color: Colors.grey[600],
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'إضافة تصنيف جديد',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddCategoryScreen(),
                          ),
                        );
                      },
                      icon: Icons.add,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryListItem(category: category);
                },
              ),
    );
  }
}

class CategoryListItem extends ConsumerWidget {
  final Category category;

  const CategoryListItem({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(category.color).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getCategoryIcon(category.icon),
            color: _getCategoryColor(category.color),
            size: 24,
          ),
        ),
        title: Text(
          category.name,
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              text: 'تعديل',
              onPressed: () => _editCategory(context, category),
              variant: CustomButtonVariant.outline,
              size: CustomButtonSize.small,
              icon: Icons.edit,
            ),
            const SizedBox(width: 8),
            CustomButton(
              text: 'حذف',
              onPressed: () => _showDeleteConfirmation(context, ref, category),
              variant: CustomButtonVariant.outline,
              size: CustomButtonSize.small,
              icon: Icons.delete,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(CategoryColor color) {
    switch (color) {
      case CategoryColor.red:
        return Colors.red;
      case CategoryColor.green:
        return Colors.green;
      case CategoryColor.blue:
        return Colors.blue;
      case CategoryColor.yellow:
        return Colors.yellow;
      case CategoryColor.purple:
        return Colors.purple;
      case CategoryColor.orange:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'subscriptions':
        return Icons.subscriptions;
      default:
        return Icons.category;
    }
  }

  void _editCategory(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCategoryScreen(categoryToEdit: category),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف التصنيف'),
            content: Text('هل أنت متأكد من حذف تصنيف "${category.name}"؟'),
            actions: [
              CustomButton(
                text: 'إلغاء',
                onPressed: () => Navigator.pop(context),
                variant: CustomButtonVariant.outline,
              ),
              CustomButton(
                text: 'حذف',
                onPressed: () {
                  ref
                      .read(categoriesProvider.notifier)
                      .deleteCategory(category.id);
                  Navigator.pop(context);
                },
                variant: CustomButtonVariant.text,
                icon: Icons.delete,
              ),
            ],
          ),
    );
  }
}
