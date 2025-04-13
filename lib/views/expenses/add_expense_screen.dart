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
import '../shared/custom_card.dart';
import '../shared/custom_text_field.dart';
import '../shared/custom_button.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  Wallet? _selectedWallet;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final categories = ref.watch(categoriesProvider);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60 + topPadding,
        title: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: const Text('إضافة مصروف جديد'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _amountController,
                      label: 'المبلغ',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال المبلغ';
                        }
                        if (double.tryParse(value) == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'الوصف',
                      prefixIcon: Icons.description,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomCard(
                child: Column(
                  children: [
                    _buildWalletDropdown(wallets),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(categories),
                    const SizedBox(height: 16),
                    _buildDatePicker(context),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'حفظ المصروف',
                      onPressed: _saveExpense,
                      isLoading: _isSaving,
                      size: CustomButtonSize.large,
                      icon: Icons.save,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'إلغاء',
                      onPressed: () => Navigator.pop(context),
                      variant: CustomButtonVariant.outline,
                      size: CustomButtonSize.large,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletDropdown(List<Wallet> wallets) {
    return DropdownButtonFormField<Wallet>(
      value: _selectedWallet,
      decoration: InputDecoration(
        labelText: 'المحفظة',
        prefixIcon: const Icon(
          Icons.account_balance_wallet,
          color: AppColors.primary,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          wallets.map((wallet) {
            return DropdownMenuItem<Wallet>(
              value: wallet,
              child: Text(
                '${wallet.name} (${wallet.balance.toStringAsFixed(2)} ${wallet.currency})',
                style: AppTheme.bodyStyle,
              ),
            );
          }).toList(),
      onChanged: (wallet) {
        setState(() {
          _selectedWallet = wallet;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'الرجاء اختيار محفظة';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown(List<Category> categories) {
    return DropdownButtonFormField<Category>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'التصنيف',
        prefixIcon: const Icon(Icons.category, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          categories.map((category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Row(
                children: [
                  Icon(_getCategoryIcon(category.icon), size: 20),
                  const SizedBox(width: 8),
                  Text(category.name, style: AppTheme.bodyStyle),
                ],
              ),
            );
          }).toList(),
      onChanged: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'الرجاء اختيار تصنيف';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'التاريخ',
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: AppColors.primary,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat.yMd().format(_selectedDate),
              style: AppTheme.bodyStyle,
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          ],
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
        return Icons.category;
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        final amount = double.parse(_amountController.text);

        if (_selectedWallet!.balance < amount) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الرصيد غير كافي في المحفظة'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final expense = Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: amount,
          description: _descriptionController.text,
          categoryId: _selectedCategory!.id,
          walletId: _selectedWallet!.id,
          date: _selectedDate,
        );

        await Future.delayed(const Duration(milliseconds: 300));
        ref.read(expensesProvider.notifier).addExpense(expense);
        Navigator.pop(context);
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }
}
