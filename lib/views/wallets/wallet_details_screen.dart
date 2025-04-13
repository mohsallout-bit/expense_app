import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../models/wallet.dart';
import '../../../providers/wallets_provider.dart';
import '../shared/custom_card.dart';
import '../shared/custom_button.dart';
import 'add_transaction_screen.dart';

class WalletDetailsScreen extends ConsumerWidget {
  final Wallet wallet;

  const WalletDetailsScreen({super.key, required this.wallet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    final updatedWallet = ref
        .watch(walletsProvider)
        .firstWhere((w) => w.id == wallet.id, orElse: () => wallet);

    final allWallets = ref.watch(walletsProvider);
    final sortedTransactions = [...updatedWallet.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    double runningBalance = updatedWallet.balance;
    final totalExpenses = updatedWallet.transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalIncome = updatedWallet.transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60 + topPadding,
        title: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: const Text('تفاصيل المحفظة'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(wallet: updatedWallet),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
      body: Column(
        children: [
          CustomCard(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildWalletInfo(updatedWallet),
                const SizedBox(height: 20),
                _buildSummaryCard(totalExpenses, totalIncome, updatedWallet),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الحركات الأخيرة',
                  style: AppTheme.headingStyle.copyWith(fontSize: 22),
                ),
                CustomButton(
                  text: '${sortedTransactions.length} حركة',
                  variant: CustomButtonVariant.text,
                  size: CustomButtonSize.small,
                  icon: Icons.history,
                  onPressed: null,
                ),
              ],
            ),
          ),
          Expanded(
            child:
                sortedTransactions.isEmpty
                    ? const _EmptyTransactions()
                    : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: sortedTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = sortedTransactions[index];
                        final previousBalance = runningBalance;

                        if (transaction.type == TransactionType.transfer) {
                          if (transaction.isOutgoingTransfer) {
                            runningBalance += transaction.amount;
                          } else {
                            runningBalance -= transaction.amount;
                          }
                        } else if (transaction.type ==
                            TransactionType.expense) {
                          runningBalance += transaction.amount;
                        } else {
                          runningBalance -= transaction.amount;
                        }

                        return _buildTransactionTile(
                          transaction,
                          allWallets,
                          updatedWallet.id,
                          previousBalance,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    double totalExpenses,
    double totalIncome,
    Wallet wallet,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryItem('المصروفات', totalExpenses, Colors.red),
          _buildDivider(),
          _buildSummaryItem('الإيرادات', totalIncome, Colors.green),
          _buildDivider(),
          _buildSummaryItem(
            'عدد الحركات',
            wallet.transactions.length.toDouble(),
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2));
  }

  Widget _buildSummaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.bodyStyle.copyWith(
            color: Colors.grey[600],
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.toStringAsFixed(2),
          style: AppTheme.headingStyle.copyWith(color: color, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildWalletInfo(Wallet wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: AppTheme.headingStyle.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  'النوع: ${_getWalletTypeName(wallet.type)}',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getWalletIcon(wallet.type),
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الرصيد الحالي',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${wallet.balance.toStringAsFixed(2)} ${wallet.currency}',
                    style: AppTheme.headingStyle.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              CustomButton(
                text: 'تحويل',
                onPressed: () {
                  // TODO: Navigate to transfer screen
                },
                variant: CustomButtonVariant.outline,
                size: CustomButtonSize.small,
                icon: Icons.swap_horiz,
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getWalletIcon(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return Icons.money;
      case WalletType.bank:
        return Icons.account_balance;
      case WalletType.crypto:
        return Icons.currency_bitcoin;
      case WalletType.other:
        return Icons.wallet;
    }
  }

  String _getWalletTypeName(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return 'نقدي';
      case WalletType.bank:
        return 'بنكي';
      case WalletType.crypto:
        return 'عملة رقمية';
      case WalletType.other:
        return 'أخرى';
    }
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
    String subtitle = '';

    if (isTransfer) {
      final relatedWallet = allWallets.firstWhere(
        (w) => w.id == transaction.relatedWalletId,
        orElse:
            () => Wallet(
              id: '',
              name: 'محفظة غير معروفة',
              currency: '',
              balance: 0,
              type: WalletType.other,
            ),
      );

      if (transaction.isOutgoingTransfer) {
        subtitle = 'تحويل صادر إلى ${relatedWallet.name}';
      } else {
        subtitle = 'تحويل وارد من ${relatedWallet.name}';
      }
    } else if (isExpense) {
      subtitle = 'مصروف: ${transaction.description}';
    } else if (isIncome) {
      subtitle = 'دخل: ${transaction.description}';
    }

    final isNegativeAmount =
        isExpense || (isTransfer && transaction.isOutgoingTransfer);
    final amountSign = isNegativeAmount ? '-' : '+';
    final amountColor = isNegativeAmount ? Colors.red : Colors.green;
    final backgroundColor =
        isNegativeAmount ? Colors.red[50] : Colors.green[50];

    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: backgroundColor,
                radius: 24,
                child: Icon(
                  isTransfer
                      ? Icons.swap_horiz
                      : (isExpense ? Icons.arrow_upward : Icons.arrow_downward),
                  color: amountColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodyStyle.copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountSign ${transaction.amount.toStringAsFixed(2)}',
                    style: AppTheme.bodyStyle.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الرصيد: ${previousBalance.toStringAsFixed(2)}',
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomCard(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد حركات بعد',
              style: AppTheme.headingStyle.copyWith(
                fontSize: 20,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة معاملات جديدة',
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'إضافة معاملة',
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}
