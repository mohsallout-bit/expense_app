import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet.dart';
import '../services/database_service.dart';
import 'package:hive/hive.dart';

// قائمة المحافظ
final walletsProvider = StateNotifierProvider<WalletsNotifier, List<Wallet>>(
  (ref) => WalletsNotifier(),
);

class WalletsNotifier extends StateNotifier<List<Wallet>> {
  WalletsNotifier() : super([]) {
    loadWallets();
  }

  Future<void> loadWallets() async {
    try {
      final box = await Hive.openBox<Wallet>(DatabaseService.walletsBoxName);
      state = box.values.toList();
    } catch (e) {
      print('❌ خطأ في تحميل المحافظ: $e');
      state = [];
    }
  }

  Future<void> addWallet(Wallet wallet) async {
    try {
      final box = await Hive.openBox<Wallet>(DatabaseService.walletsBoxName);
      await box.put(wallet.id, wallet);
      state = [...state, wallet];
    } catch (e) {
      print('❌ خطأ في إضافة المحفظة: $e');
      rethrow;
    }
  }

  Future<void> updateWallet(Wallet updatedWallet) async {
    try {
      final box = await Hive.openBox<Wallet>(DatabaseService.walletsBoxName);
      await box.put(updatedWallet.id, updatedWallet);
      state =
          state
              .map(
                (wallet) =>
                    wallet.id == updatedWallet.id ? updatedWallet : wallet,
              )
              .toList();
    } catch (e) {
      print('❌ خطأ في تحديث المحفظة: $e');
      rethrow;
    }
  }

  Future<void> deleteWallet(String walletId) async {
    try {
      final box = await Hive.openBox<Wallet>(DatabaseService.walletsBoxName);
      await box.delete(walletId);
      state = state.where((wallet) => wallet.id != walletId).toList();
    } catch (e) {
      print('❌ خطأ في حذف المحفظة: $e');
      rethrow;
    }
  }

  Future<void> addTransaction(
    String walletId,
    WalletTransaction transaction,
  ) async {
    try {
      final wallet = state.firstWhere((w) => w.id == walletId);
      double updatedBalance = wallet.balance;

      if (transaction.type == TransactionType.expense) {
        updatedBalance -= transaction.amount;
      } else if (transaction.type == TransactionType.income) {
        updatedBalance += transaction.amount;
      } else if (transaction.type == TransactionType.transfer) {
        if (transaction.isOutgoingTransfer) {
          updatedBalance -= transaction.amount;
        } else {
          updatedBalance += transaction.amount;
        }
      }

      final updatedWallet = wallet.copyWith(
        balance: updatedBalance,
        transactions: [...wallet.transactions, transaction],
      );

      await updateWallet(updatedWallet);
    } catch (e) {
      print('❌ خطأ في إضافة العملية: $e');
      rethrow;
    }
  }
}
