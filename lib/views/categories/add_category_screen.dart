// lib/views/categories/add_category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/category.dart';
import '../../../../providers/categories_provider.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final Category? categoryToEdit;

  const AddCategoryScreen({super.key, this.categoryToEdit});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();

  CategoryColor _selectedColor = CategoryColor.red;

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.name;
      _iconController.text = widget.categoryToEdit!.icon;
      _selectedColor = widget.categoryToEdit!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryToEdit == null ? 'إضافة تصنيف جديد' : 'تعديل التصنيف',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // حقل الاسم
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم التصنيف',
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم التصنيف';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // حقل الأيقونة
              TextFormField(
                controller: _iconController,
                decoration: const InputDecoration(
                  labelText: 'اسم الأيقونة (من Material Icons)',
                  prefixIcon: Icon(Icons.emoji_objects),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الأيقونة';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // لون التصنيف
              DropdownButtonFormField<CategoryColor>(
                value: _selectedColor,
                decoration: const InputDecoration(
                  labelText: 'لون التصنيف',
                  prefixIcon: Icon(Icons.color_lens),
                ),
                items:
                    CategoryColor.values.map((color) {
                      return DropdownMenuItem<CategoryColor>(
                        value: color,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: _getColorValue(color),
                            ),
                            const SizedBox(width: 8),
                            Text(_getColorName(color)),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (color) {
                  if (color != null) {
                    setState(() {
                      _selectedColor = color;
                    });
                  }
                },
                isExpanded: true, // Ensure proper layout
              ),

              const SizedBox(height: 32),

              // زر الحفظ
              ElevatedButton(
                onPressed: _saveCategory,
                child: Text(
                  widget.categoryToEdit == null
                      ? 'إضافة تصنيف'
                      : 'حفظ التعديلات',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorValue(CategoryColor color) {
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

  String _getColorName(CategoryColor color) {
    switch (color) {
      case CategoryColor.red:
        return 'أحمر';
      case CategoryColor.green:
        return 'أخضر';
      case CategoryColor.blue:
        return 'أزرق';
      case CategoryColor.yellow:
        return 'أصفر';
      case CategoryColor.purple:
        return 'بنفسجي';
      case CategoryColor.orange:
        return 'برتقالي';
    }
  }

  void _saveCategory() {
    print('Save button pressed.');
    if (_formKey.currentState!.validate()) {
      print('Form validation passed. Preparing to save category.');

      final category = Category(
        id:
            widget.categoryToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        icon: _iconController.text,
        color: _selectedColor,
      );

      print(
        'Category created: ID=${category.id}, Name=${category.name}, Icon=${category.icon}, Color=${category.color}',
      );

      if (widget.categoryToEdit == null) {
        print('Adding new category: ${category.name}');
        try {
          ref.read(categoriesProvider.notifier).addCategory(category);
          print('New category added successfully.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة التصنيف بنجاح!')),
          );
        } catch (e) {
          print('Error while adding category: $e');
        }
      } else {
        print('Updating existing category: ${category.name}');
        try {
          ref.read(categoriesProvider.notifier).updateCategory(category);
          print('Category updated successfully.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث التصنيف بنجاح!')),
          );
        } catch (e) {
          print('Error while updating category: $e');
        }
      }

      print('Closing the screen.');
      Navigator.pop(context);
    } else {
      print('Form validation failed. Please check the inputs.');
    }
  }
}
