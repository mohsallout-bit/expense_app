// lib/views/budgets/add_budget_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/budget.dart';
import '../../../../models/category.dart';
import '../../../../providers/budgets_provider.dart';
import '../../../../providers/categories_provider.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  Category? _selectedCategory;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة ميزانية جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // حقل المبلغ
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  prefixIcon: Icon(Icons.attach_money),
                ),
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

              // اختيار التصنيف
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    categories.map((category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Text(category.name),
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
              ),

              const SizedBox(height: 16),

              // تاريخ البدء
              InkWell(
                onTap: () => _selectDate(context, isStartDate: true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ البدء',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat.yMd().format(_startDate)),
                ),
              ),

              const SizedBox(height: 16),

              // تاريخ الانتهاء
              InkWell(
                onTap: () => _selectDate(context, isStartDate: false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الانتهاء',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat.yMd().format(_endDate)),
                ),
              ),

              const SizedBox(height: 32),

              // زر الحفظ
              ElevatedButton(
                onPressed: _saveBudget,
                child: const Text('حفظ الميزانية'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          if (pickedDate.isAfter(_startDate)) {
            _endDate = pickedDate;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تاريخ الانتهاء يجب أن يكون بعد تاريخ البدء'),
              ),
            );
          }
        }
      });
    }
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final budget = Budget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: _selectedCategory!.id,
        amount: double.parse(_amountController.text),
        startDate: _startDate,
        endDate: _endDate,
      );

      ref.read(budgetsProvider.notifier).addBudget(budget);

      Navigator.pop(context);
    }
  }
}
