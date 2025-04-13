import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/wallet.dart';
import '../../../../providers/wallets_provider.dart';
import '../../../../providers/hive_provider.dart';
import '../../../../providers/main_wallet_provider.dart';
import 'add_wallet_screen.dart';
import 'wallet_details_screen.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiveInit = ref.watch(hiveReadyProvider);

    return hiveInit.when(
      data: (_) {
        final wallets = ref.watch(walletsProvider);
        final mainWalletId = ref.watch(mainWalletProvider);

        final totalBalance = wallets.fold(
          0.0,
          (sum, wallet) => sum + wallet.balance,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'إدارة المحافظ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddWalletScreen()),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'الرصيد الإجمالي',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(symbol: 'ر.س').format(totalBalance),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = wallets[index];
                    final isMain = wallet.id == mainWalletId;
                    return WalletListItem(wallet: wallet, isMain: isMain);
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) =>
              Scaffold(body: Center(child: Text('خطأ في تحميل البيانات: $e'))),
    );
  }
}

class WalletListItem extends ConsumerWidget {
  final Wallet wallet;
  final bool isMain;

  const WalletListItem({super.key, required this.wallet, this.isMain = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(_getWalletIcon(wallet.type)),
        title: Row(
          children: [
            Text(wallet.name),
            if (isMain)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.star, color: Colors.orange, size: 18),
              ),
          ],
        ),
        subtitle: Text(
          '${wallet.balance.toStringAsFixed(2)} ${wallet.currency}',
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'details', child: Text('تفاصيل')),
                const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                const PopupMenuItem(value: 'delete', child: Text('حذف')),
                const PopupMenuItem(
                  value: 'set_main',
                  child: Text('تعيين كمحفظة رئيسية'),
                ),
              ],
          onSelected: (value) {
            if (value == 'details') {
              _viewWalletDetails(context);
            } else if (value == 'edit') {
              _editWallet(context);
            } else if (value == 'delete') {
              _deleteWallet(ref);
            } else if (value == 'set_main') {
              ref.read(mainWalletProvider.notifier).setMainWallet(wallet.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تعيين المحفظة الرئيسية')),
              );
            }
          },
        ),
      ),
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

  void _editWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddWalletScreen(walletToEdit: wallet)),
    );
  }

  void _deleteWallet(WidgetRef ref) {
    ref.read(walletsProvider.notifier).deleteWallet(wallet.id);
  }

  void _viewWalletDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WalletDetailsScreen(wallet: wallet)),
    );
  }
}
