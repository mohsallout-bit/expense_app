import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/transfer.dart';
import '../models/wallet.dart';
import '../providers/wallets_provider.dart';

final transfersProvider =
    StateNotifierProvider<TransfersNotifier, List<Transfer>>((ref) {
      return TransfersNotifier(ref);
    });

class TransfersNotifier extends StateNotifier<List<Transfer>> {
  final Ref ref;

  TransfersNotifier(this.ref) : super([]) {
    _loadTransfers();
  }

  Future<void> _loadTransfers() async {
    final box = Hive.box<Transfer>('transfers');
    state = box.values.toList();
  }

  Future<void> addTransfer(Transfer transfer) async {
    final box = Hive.box<Transfer>('transfers');
    await box.put(transfer.id, transfer);
    state = [...state, transfer];

    await _updateWalletBalancesAndTransactions(transfer);
  }

  Future<void> _updateWalletBalancesAndTransactions(Transfer transfer) async {
    final walletsNotifier = ref.read(walletsProvider.notifier);

    // من المحفظة المصدر (خصم)
    final fromTransaction = WalletTransaction(
      id: 't_out_${transfer.id}',
      amount: transfer.amount,
      description: transfer.description,
      type: TransactionType.transfer,
      relatedWalletId: transfer.toWalletId,
      date: transfer.date,
      isOutgoingTransfer: true, // إشارة إلى أنه تحويل صادر
    );

    // إلى المحفظة المستقبلة (إضافة)
    final toTransaction = WalletTransaction(
      id: 't_in_${transfer.id}',
      amount: transfer.amount,
      description: transfer.description,
      type: TransactionType.transfer,
      relatedWalletId: transfer.fromWalletId,
      date: transfer.date,
      isOutgoingTransfer: false, // إشارة إلى أنه تحويل وارد
    );

    // تحديث المحفظة المصدر (خصم)
    await walletsNotifier.addTransaction(
      transfer.fromWalletId,
      fromTransaction,
    );

    // تحديث المحفظة المستقبلة (إضافة)
    await walletsNotifier.addTransaction(transfer.toWalletId, toTransaction);
  }
}
