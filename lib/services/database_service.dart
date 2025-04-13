// lib/services/database_service.dart
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/wallet.dart';
import '../models/category.dart'
    as expense_category; // Aliasing the Category model
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/transfer.dart';

class DatabaseService {
  static const String _walletsBoxName = 'wallets';
  static const String _categoriesBoxName = 'categories';
  static const String _expensesBoxName = 'expenses';
  static const String _budgetsBoxName = 'budgets';
  static const String _transfersBoxName = 'transfers';
  static const String _settingsBoxName = 'settings';

  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // تسجيل المحولات مع التحقق من التسجيل المسبق
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(WalletAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(WalletTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(WalletTransactionAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(TransactionTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(expense_category.CategoryAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(expense_category.CategoryColorAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(ExpenseAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(BudgetAdapter());
      }
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(TransferAdapter());
      }

      // فتح الصناديق
      await Future.wait([
        Hive.openBox<Wallet>(_walletsBoxName),
        Hive.openBox<expense_category.Category>(_categoriesBoxName),
        Hive.openBox<Expense>(_expensesBoxName),
        Hive.openBox<Budget>(_budgetsBoxName),
        Hive.openBox<Transfer>(_transfersBoxName),
        Hive.openBox(_settingsBoxName),
      ]);

      // إضافة بيانات تجريبية في وضع التطوير
      if (kDebugMode) {
        await _addSampleData();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في تهيئة قاعدة البيانات: $e');
      }
      rethrow;
    }
  }

  static Future<void> _addSampleData() async {
    try {
      final walletsBox = Hive.box<Wallet>(_walletsBoxName);

      // إضافة محفظة تجريبية فقط إذا كان الصندوق فارغاً
      if (walletsBox.isEmpty) {
        final wallet = Wallet(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'محفظتي',
          currency: 'ر.س',
          balance: 1000,
          type: WalletType.cash,
        );
        await walletsBox.put(wallet.id, wallet);
      }

      final categoriesBox = Hive.box<expense_category.Category>(
        _categoriesBoxName,
      );

      // إضافة تصنيفات تجريبية
      if (categoriesBox.isEmpty) {
        final sampleCategories = [
          expense_category.Category(
            id: 'food',
            name: 'طعام ومشروبات',
            icon: 'restaurant',
            color: expense_category.CategoryColor.green,
          ),
          expense_category.Category(
            id: 'transport',
            name: 'مواصلات',
            icon: 'directions_car',
            color: expense_category.CategoryColor.blue,
          ),
          expense_category.Category(
            id: 'shopping',
            name: 'تسوق',
            icon: 'shopping_cart',
            color: expense_category.CategoryColor.red,
          ),
        ];

        for (final category in sampleCategories) {
          await categoriesBox.put(category.id, category);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في إدخال البيانات التجريبية: $e');
      }
      rethrow;
    }
  }

  static String get walletsBoxName => _walletsBoxName;
  static String get categoriesBoxName => _categoriesBoxName;
  static String get expensesBoxName => _expensesBoxName;
  static String get budgetsBoxName => _budgetsBoxName;
  static String get transfersBoxName => _transfersBoxName;
  static String get settingsBoxName => _settingsBoxName;
}
