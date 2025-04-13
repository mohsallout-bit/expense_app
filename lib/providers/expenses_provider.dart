import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/expense.dart';
import '../models/wallet.dart';
import '../providers/wallets_provider.dart';

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>(
  (ref) => ExpensesNotifier(ref),
);

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  final Ref ref;

  ExpensesNotifier(this.ref) : super([]) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final box = Hive.box<Expense>('expenses');
    state = box.values.toList();
  }

  Future<void> addExpense(Expense expense) async {
    try {
      // حفظ المصروف في Hive
      final box = Hive.box<Expense>('expenses');
      await box.put(expense.id, expense);

      // تحديث الحالة
      state = [...state, expense];

      // إضافة العملية إلى المحفظة المرتبطة
      final walletNotifier = ref.read(walletsProvider.notifier);
      await walletNotifier.addTransaction(
        expense.walletId,
        WalletTransaction(
          id: 'trx_${DateTime.now().millisecondsSinceEpoch}',
          amount: expense.amount,
          description: expense.description,
          type: TransactionType.expense,
          categoryId: expense.categoryId,
          date: expense.date,
        ),
      );
    } catch (e, stack) {
      print('❌ Error in addExpense: $e');
      print('🔍 Stack trace:\n$stack');
      rethrow; // يعاد طرح الخطأ لتتم معالجته في الواجهة
    }
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    try {
      print('Updating expense with ID: ${updatedExpense.id}');
      final box = await _ensureBoxOpen();

      // الحصول على المصروف القديم
      final oldExpense = state.firstWhere(
        (expense) => expense.id == updatedExpense.id,
      );

      // تحديث المحفظة القديمة
      if (oldExpense.walletId != updatedExpense.walletId ||
          oldExpense.amount != updatedExpense.amount) {
        final walletNotifier = ref.read(walletsProvider.notifier);

        // إزالة المبلغ القديم من المحفظة القديمة
        await walletNotifier.addTransaction(
          oldExpense.walletId,
          WalletTransaction(
            id: 'trx_${DateTime.now().millisecondsSinceEpoch}',
            amount: -oldExpense.amount,
            description: 'تعديل المصروف',
            type: TransactionType.expense,
            categoryId: oldExpense.categoryId,
            date: DateTime.now(),
          ),
        );

        // إضافة المبلغ الجديد إلى المحفظة الجديدة
        await walletNotifier.addTransaction(
          updatedExpense.walletId,
          WalletTransaction(
            id: 'trx_${DateTime.now().millisecondsSinceEpoch}',
            amount: updatedExpense.amount,
            description: updatedExpense.description,
            type: TransactionType.expense,
            categoryId: updatedExpense.categoryId,
            date: updatedExpense.date,
          ),
        );
      }

      // تحديث المصروف في Hive
      await box.put(updatedExpense.id, updatedExpense);

      // تحديث الحالة
      state = [
        for (final expense in state)
          if (expense.id == updatedExpense.id) updatedExpense else expense,
      ];

      print('Expense updated successfully');
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      print('Deleting expense with ID: $expenseId');
      final box = await _ensureBoxOpen();

      // الحصول على المصروف المحذوف
      final deletedExpense = state.firstWhere(
        (expense) => expense.id == expenseId,
      );

      // تحديث المحفظة المرتبطة
      final walletNotifier = ref.read(walletsProvider.notifier);
      await walletNotifier.addTransaction(
        deletedExpense.walletId,
        WalletTransaction(
          id: 'trx_${DateTime.now().millisecondsSinceEpoch}',
          amount: -deletedExpense.amount,
          description: 'حذف المصروف',
          type: TransactionType.expense,
          categoryId: deletedExpense.categoryId,
          date: DateTime.now(),
        ),
      );

      // حذف المصروف من Hive
      await box.delete(expenseId);

      // تحديث الحالة
      state = state.where((expense) => expense.id != expenseId).toList();

      print('Expense deleted successfully');
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  Future<Box<Expense>> _ensureBoxOpen() async {
    const boxName = 'expenses';
    if (!Hive.isBoxOpen(boxName)) {
      try {
        return await Hive.openBox<Expense>(boxName);
      } catch (e) {
        print('Error opening expenses box: $e');
        rethrow;
      }
    }
    return Hive.box<Expense>(boxName);
  }
}

// ✅ مزود الفلترة
final expenseFilterProvider = StateProvider<ExpenseFilter>(
  (ref) => ExpenseFilter(),
);

// ✅ فلتر البيانات
class ExpenseFilter {
  final String? categoryId;
  final String? walletId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  ExpenseFilter({
    this.categoryId,
    this.walletId,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  ExpenseFilter copyWith({
    String? categoryId,
    String? walletId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return ExpenseFilter(
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// ✅ مزود المصروفات المفلترة
final filteredExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesProvider);
  final filter = ref.watch(expenseFilterProvider);

  return expenses.where((expense) {
    bool matches = true;

    if (filter.categoryId != null) {
      matches = matches && expense.categoryId == filter.categoryId;
    }

    if (filter.walletId != null) {
      matches = matches && expense.walletId == filter.walletId;
    }

    if (filter.startDate != null) {
      matches = matches && expense.date.isAfter(filter.startDate!);
    }

    if (filter.endDate != null) {
      matches = matches && expense.date.isBefore(filter.endDate!);
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      matches =
          matches &&
          expense.description.toLowerCase().contains(
            filter.searchQuery!.toLowerCase(),
          );
    }

    return matches;
  }).toList();
});
