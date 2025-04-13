import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/wallet.dart';
import '../../../providers/wallets_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final Wallet wallet;

  const AddTransactionScreen({super.key, required this.wallet});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  Wallet? _toWallet;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allWallets = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة حركة جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وصف الحركة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'نوع الحركة',
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    TransactionType.values.map((type) {
                      return DropdownMenuItem<TransactionType>(
                        value: type,
                        child: Text(_getTransactionTypeName(type)),
                      );
                    }).toList(),
                onChanged: (type) {
                  if (type != null) {
                    setState(() {
                      _selectedType = type;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedType == TransactionType.transfer)
                DropdownButtonFormField<Wallet>(
                  value: _toWallet,
                  decoration: const InputDecoration(
                    labelText: 'التحويل إلى',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                  items:
                      allWallets.where((w) => w.id != widget.wallet.id).map((
                        wallet,
                      ) {
                        return DropdownMenuItem<Wallet>(
                          value: wallet,
                          child: Text(wallet.name),
                        );
                      }).toList(),
                  onChanged: (wallet) {
                    setState(() {
                      _toWallet = wallet;
                    });
                  },
                  validator: (value) {
                    if (_selectedType == TransactionType.transfer &&
                        value == null) {
                      return 'الرجاء اختيار المحفظة المستهدفة';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: const Text('إضافة الحركة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTransactionTypeName(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return 'مصروف';
      case TransactionType.income:
        return 'دخل';
      case TransactionType.transfer:
        return 'تحويل';
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == TransactionType.transfer && _toWallet == null) {
        return;
      }

      final transaction = WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        type: _selectedType,
        date: DateTime.now(),
        relatedWalletId:
            _selectedType == TransactionType.transfer ? _toWallet?.id : null,
        isOutgoingTransfer: _selectedType == TransactionType.transfer,
      );

      if (_selectedType == TransactionType.transfer && _toWallet != null) {
        // إنشاء المعاملة المقابلة في المحفظة المستهدفة
        final relatedTransaction = WalletTransaction(
          id: 't_in_${transaction.id}',
          description: transaction.description,
          amount: transaction.amount,
          type: TransactionType.transfer,
          date: transaction.date,
          relatedWalletId: widget.wallet.id,
          isOutgoingTransfer: false, // تحويل وارد
        );

        // إضافة المعاملتين
        final walletsNotifier = ref.read(walletsProvider.notifier);
        walletsNotifier.addTransaction(widget.wallet.id, transaction);
        walletsNotifier.addTransaction(_toWallet!.id, relatedTransaction);
      } else {
        // معاملة عادية (مصروف أو دخل)
        ref
            .read(walletsProvider.notifier)
            .addTransaction(widget.wallet.id, transaction);
      }

      Navigator.pop(context);
    }
  }
}
