// lib/views/budgets/budgets_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/budget.dart';
import '../../../../models/category.dart';
import '../../../../providers/budgets_provider.dart';
import '../../../../providers/categories_provider.dart';
import 'add_budget_screen.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الميزانية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
              );
            },
          ),
        ],
      ),
      body:
          budgets.isEmpty
              ? const Center(child: Text('لا توجد ميزانيات مسجلة'))
              : ListView.builder(
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final budget = budgets[index];
                  final category = categories.firstWhere(
                    (c) => c.id == budget.categoryId,
                    orElse:
                        () => Category(
                          id: '',
                          name: 'غير معروف',
                          icon: 'help',
                          color: CategoryColor.orange,
                        ),
                  );

                  return BudgetListItem(budget: budget, category: category);
                },
              ),
    );
  }
}

class BudgetListItem extends StatelessWidget {
  final Budget budget;
  final Category category;

  const BudgetListItem({
    super.key,
    required this.budget,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getCategoryColor(category.color),
            shape: BoxShape.circle,
          ),
          child: Icon(_getCategoryIcon(category.icon), color: Colors.white),
        ),
        title: Text(category.name),
        subtitle: Text(
          '${DateFormat.yMd().format(budget.startDate)} - ${DateFormat.yMd().format(budget.endDate)}',
        ),
        trailing: Text(
          NumberFormat.currency(symbol: 'ر.س').format(budget.amount),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
}
