import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/wallet.dart';
import '../../providers/wallets_provider.dart';

class WalletDetailsScreen extends ConsumerWidget {
  final Wallet wallet;

  const WalletDetailsScreen({super.key, required this.wallet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);
    final currentWallet = wallets.firstWhere(
      (w) => w.id == wallet.id,
      orElse: () => wallet,
    );

    final transactions = [...currentWallet.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: Text(currentWallet.name)),
      body: Column(
        children: [
          ListTile(
            title: const Text('الرصيد الحالي'),
            trailing: Text(
              '${currentWallet.balance.toStringAsFixed(2)} ${currentWallet.currency}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child:
                transactions.isEmpty
                    ? const Center(child: Text('لا توجد حركات'))
                    : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        final previousBalance = _calculatePreviousBalance(
                          transactions,
                          index,
                          currentWallet.balance,
                        );
                        return _buildTransactionTile(
                          transaction,
                          wallets,
                          currentWallet.id,
                          previousBalance,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(
    WalletTransaction transaction,
    List<Wallet> allWallets,
    String currentWalletId,
    double previousBalance,
  ) {
    final isExpense = transaction.type == TransactionType.expense;
    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.type == TransactionType.transfer;

    String label = '';
    bool isOutgoingTransfer = false;

    if (isTransfer) {
      final other = allWallets.firstWhere(
        (w) => w.id == transaction.relatedWalletId,
        orElse:
            () => Wallet(
              id: '',
              name: 'غير معروفة',
              currency: '',
              balance: 0,
              type: WalletType.other,
            ),
      );

      // التحقق من اتجاه التحويل بناءً على المحفظة المرتبطة
      if (transaction.relatedWalletId == currentWalletId) {
        // إذا كانت المحفظة المرتبطة هي المحفظة الحالية، فهذا يعني أنه تحويل وارد
        isOutgoingTransfer = false;
        label = 'تحويل وارد من ${other.name}';
      } else {
        // غير ذلك، فهو تحويل صادر
        isOutgoingTransfer = true;
        label = 'تحويل صادر إلى ${other.name}';
      }
    } else {
      if (isExpense) label = 'مصروف';
      if (isIncome) label = 'دخل';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor:
              isExpense || (isTransfer && isOutgoingTransfer)
                  ? Colors.red[100]
                  : Colors.green[100],
          child: Icon(
            isTransfer
                ? Icons.swap_horiz
                : (isExpense ? Icons.arrow_upward : Icons.arrow_downward),
            color:
                isExpense || (isTransfer && isOutgoingTransfer)
                    ? Colors.red
                    : Colors.green,
          ),
        ),
        title: Text(
          transaction.description.isNotEmpty ? transaction.description : label,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.yMd().add_jm().format(transaction.date),
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              'الرصيد قبل العملية: ${previousBalance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: Text(
          '${isExpense || (isTransfer && isOutgoingTransfer) ? '-' : '+'} ${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color:
                isExpense || (isTransfer && isOutgoingTransfer)
                    ? Colors.red
                    : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  double _calculatePreviousBalance(
    List<WalletTransaction> transactions,
    int index,
    double currentBalance,
  ) {
    double balance = currentBalance;
    for (int i = 0; i < index; i++) {
      final t = transactions[i];
      switch (t.type) {
        case TransactionType.expense:
          balance += t.amount;
          break;
        case TransactionType.income:
          balance -= t.amount;
          break;
        case TransactionType.transfer:
          if (t.relatedWalletId != null &&
              t.relatedWalletId != transactions[i].id) {
            balance += t.amount;
          } else {
            balance -= t.amount;
          }
          break;
      }
    }
    return balance;
  }
}
