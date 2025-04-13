import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../providers/categories_provider.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التصنيفات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context, ref),
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
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد تصنيفات',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showAddCategoryDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة تصنيف جديد'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(
                          category.color,
                        ).withOpacity(0.2),
                        child: Icon(
                          _getIconData(category.icon),
                          color: _getCategoryColor(category.color),
                        ),
                      ),
                      title: Text(category.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => _showEditCategoryDialog(
                                  context,
                                  ref,
                                  category,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed:
                                () => _showDeleteConfirmation(
                                  context,
                                  ref,
                                  category,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    print('Opening Add Category Dialog');
    showDialog(
      context: context,
      builder:
          (context) => _CategoryDialog(
            onSave: (name, icon, color) {
              print(
                'Saving new category: Name=$name, Icon=$icon, Color=$color',
              );
              final category = Category(
                id: DateTime.now().toString(),
                name: name,
                icon: icon,
                color: color,
              );
              ref.read(categoriesProvider.notifier).addCategory(category);
              print('New category added successfully');
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    print('Opening Edit Category Dialog for ID=${category.id}');
    showDialog(
      context: context,
      builder:
          (context) => _CategoryDialog(
            initialName: category.name,
            initialIcon: category.icon,
            initialColor: category.color,
            onSave: (name, icon, color) {
              print(
                'Updating category: ID=${category.id}, Name=$name, Icon=$icon, Color=$color',
              );
              final updatedCategory = Category(
                id: category.id,
                name: name,
                icon: icon,
                color: color,
              );
              ref
                  .read(categoriesProvider.notifier)
                  .updateCategory(updatedCategory);
              print('Category updated successfully');
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    print('Opening Delete Confirmation Dialog for ID=${category.id}');
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد من حذف تصنيف "${category.name}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  print('Deleting category: ID=${category.id}');
                  ref
                      .read(categoriesProvider.notifier)
                      .deleteCategory(category.id);
                  print('Category deleted successfully');
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }

  Color _getCategoryColor(CategoryColor color) {
    switch (color) {
      case CategoryColor.red:
        return Colors.redAccent;
      case CategoryColor.green:
        return Colors.greenAccent;
      case CategoryColor.blue:
        return Colors.blueAccent;
      case CategoryColor.yellow:
        return Colors.amber;
      case CategoryColor.purple:
        return Colors.deepPurpleAccent;
      case CategoryColor.orange:
        return Colors.orangeAccent;
    }
  }

  IconData _getIconData(String iconName) {
    // تحقق إذا كان iconName هو رمز رقمي
    if (iconName.startsWith('0x')) {
      try {
        return IconData(int.parse(iconName), fontFamily: 'MaterialIcons');
      } catch (e) {
        print('Error parsing icon code: $e');
        return Icons.help;
      }
    }

    // إذا لم يكن رمزًا رقميًا، استخدم الأسماء النصية
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'local_mall':
        return Icons.local_mall;
      case 'movie':
        return Icons.movie;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.help;
    }
  }
}

class _CategoryDialog extends StatefulWidget {
  final String? initialName;
  final String? initialIcon;
  final CategoryColor? initialColor;
  final Function(String name, String icon, CategoryColor color) onSave;

  const _CategoryDialog({
    this.initialName,
    this.initialIcon,
    this.initialColor,
    required this.onSave,
  });

  @override
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late TextEditingController _nameController;
  late String _selectedIcon;
  late CategoryColor _selectedColor;

  final List<String> _availableIcons = [
    '0xe318', // shopping_cart
    '0xe3e7', // restaurant
    '0xe1d9', // directions_car
    '0xe0c0', // home
    '0xe0dd', // local_hospital
    '0xe0e0', // local_mall
    '0xe0f6', // movie
    '0xe25b', // fitness_center
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedIcon = widget.initialIcon ?? _availableIcons[0];
    _selectedColor = widget.initialColor ?? CategoryColor.blue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'إضافة تصنيف' : 'تعديل تصنيف'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم التصنيف'),
              ),
              const SizedBox(height: 16),
              const Text('الأيقونة'),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    return IconButton(
                      icon: Icon(
                        IconData(int.parse(icon), fontFamily: 'MaterialIcons'),
                        color:
                            _selectedIcon == icon
                                ? Theme.of(context).primaryColor
                                : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIcon = icon;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text('اللون'),
              SizedBox(
                height: 100,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: CategoryColor.values.length,
                  itemBuilder: (context, index) {
                    final color = CategoryColor.values[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getCategoryColor(color),
                          border: Border.all(
                            color:
                                _selectedColor == color
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            print('Save button pressed in dialog.');
            print(
              'Name: ${_nameController.text}, Icon: $_selectedIcon, Color: $_selectedColor',
            );
            widget.onSave(_nameController.text, _selectedIcon, _selectedColor);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  Color _getCategoryColor(CategoryColor color) {
    switch (color) {
      case CategoryColor.red:
        return Colors.redAccent;
      case CategoryColor.green:
        return Colors.greenAccent;
      case CategoryColor.blue:
        return Colors.blueAccent;
      case CategoryColor.yellow:
        return Colors.amber;
      case CategoryColor.purple:
        return Colors.deepPurpleAccent;
      case CategoryColor.orange:
        return Colors.orangeAccent;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class CategoryDialogResult {
  final String name;
  final String icon;
  final CategoryColor color;

  CategoryDialogResult({
    required this.name,
    required this.icon,
    required this.color,
  });
}
