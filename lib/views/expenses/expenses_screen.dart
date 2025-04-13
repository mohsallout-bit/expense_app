import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../models/expense.dart';
import '../../models/category.dart';
import '../../models/wallet.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/wallets_provider.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(filteredExpensesProvider); // ✅ مصروفات مفلترة
    final categories = ref.watch(categoriesProvider);
    final wallets = ref.watch(walletsProvider);

    final filter = ref.watch(expenseFilterProvider);
    final filterNotifier = ref.read(expenseFilterProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سجل المصروفات',
          style: AppTheme.headingStyle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary, // تغيير اللون إلى اللون الرئيسي
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة مصروف',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: filter.walletId,
                    decoration: InputDecoration(
                      labelText: 'المحفظة',
                      labelStyle: TextStyle(color: AppColors.primary),
                      prefixIcon: Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('الكل')),
                      ...wallets.map(
                        (wallet) => DropdownMenuItem(
                          value: wallet.id,
                          child: Text(wallet.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      filterNotifier.state = filter.copyWith(walletId: value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: filter.categoryId,
                    decoration: InputDecoration(
                      labelText: 'التصنيف',
                      labelStyle: TextStyle(color: AppColors.primary),
                      prefixIcon: Icon(
                        Icons.category,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('الكل')),
                      ...categories.map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      filterNotifier.state = filter.copyWith(categoryId: value);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                expenses.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                      itemCount: expenses.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        final category = categories.firstWhere(
                          (c) => c.id == expense.categoryId,
                          orElse:
                              () => Category(
                                id: '',
                                name: 'غير معروف',
                                icon: 'help',
                                color: CategoryColor.orange,
                              ),
                        );
                        final wallet = wallets.firstWhere(
                          (w) => w.id == expense.walletId,
                          orElse:
                              () => Wallet(
                                id: '',
                                name: 'غير معروف',
                                currency: '--',
                                balance: 0,
                                type: WalletType.other,
                              ),
                        );

                        return ExpenseListItem(
                          expense: expense,
                          category: category,
                          wallet: wallet,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'لا توجد مصروفات مطابقة للفلاتر',
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final Category category;
  final Wallet wallet;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.category,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3, // إضافة تأثير الظلال
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              _getCategoryIcon(category.icon),
              color: AppColors.primary,
            ),
          ),
          title: Text(
            expense.description.isEmpty ? category.name : expense.description,
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '${wallet.name} • ${DateFormat.yMd().add_jm().format(expense.date)}',
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          trailing: Text(
            '${expense.amount.toStringAsFixed(2)} ${wallet.currency}',
            style: AppTheme.bodyStyle.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
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
        return Icons.help_outline;
    }
  }
}
