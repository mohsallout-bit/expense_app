// lib/providers/budgets_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/budget.dart';

final budgetsProvider = StateNotifierProvider<BudgetsNotifier, List<Budget>>((
  ref,
) {
  return BudgetsNotifier();
});

class BudgetsNotifier extends StateNotifier<List<Budget>> {
  BudgetsNotifier() : super([]) {
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final box = Hive.box<Budget>('budgets');
    state = box.values.toList();
  }

  Future<void> addBudget(Budget budget) async {
    final box = Hive.box<Budget>('budgets');
    await box.put(budget.id, budget);
    state = [...state, budget];
  }

  Future<void> updateBudget(Budget updatedBudget) async {
    final box = Hive.box<Budget>('budgets');
    await box.put(updatedBudget.id, updatedBudget);
    state =
        state.map((b) => b.id == updatedBudget.id ? updatedBudget : b).toList();
  }

  Future<void> deleteBudget(String budgetId) async {
    final box = Hive.box<Budget>('budgets');
    await box.delete(budgetId);
    state = state.where((b) => b.id != budgetId).toList();
  }
}
