import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/wallet.dart';
import '../../../../models/transfer.dart';
import '../../../../providers/wallets_provider.dart';
import '../../../../providers/transfers_provider.dart';
import '../shared/custom_button.dart';
import '../shared/custom_text_field.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Wallet? _fromWallet;
  Wallet? _toWallet;
  bool _isTransferring = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60 + topPadding,
        title: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: const Text('تحويل بين المحافظ'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _amountController,
                label: 'المبلغ',
                prefixIcon: Icons.attach_money,
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
              CustomTextField(
                controller: _descriptionController,
                label: 'الوصف (اختياري)',
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 16),
              _buildWalletDropdown(wallets, 'من المحفظة', _fromWallet, (
                wallet,
              ) {
                setState(() {
                  _fromWallet = wallet;
                  if (_toWallet == wallet) {
                    _toWallet = null;
                  }
                });
              }, 'الرجاء اختيار محفظة المصدر'),
              const SizedBox(height: 16),
              _buildWalletDropdown(
                wallets.where((w) => w != _fromWallet).toList(),
                'إلى المحفظة',
                _toWallet,
                (wallet) {
                  setState(() {
                    _toWallet = wallet;
                  });
                },
                'الرجاء اختيار محفظة الوجهة',
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'إتمام التحويل',
                onPressed: _transferAmount,
                isLoading: _isTransferring,
                fullWidth: true,
                size: CustomButtonSize.large,
                icon: Icons.swap_horiz,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'إلغاء',
                onPressed: () => Navigator.pop(context),
                variant: CustomButtonVariant.outline,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletDropdown(
    List<Wallet> wallets,
    String label,
    Wallet? value,
    void Function(Wallet?) onChanged,
    String validationMessage,
  ) {
    return DropdownButtonFormField<Wallet>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.account_balance_wallet),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          wallets.map((wallet) {
            return DropdownMenuItem<Wallet>(
              value: wallet,
              child: Text(
                '${wallet.name} (${wallet.balance.toStringAsFixed(2)} ${wallet.currency})',
              ),
            );
          }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Future<void> _transferAmount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isTransferring = true);

      try {
        final amount = double.parse(_amountController.text);

        if (_fromWallet!.balance < amount) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الرصيد غير كافي في المحفظة المصدر')),
          );
          return;
        }

        final transfer = Transfer(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fromWalletId: _fromWallet!.id,
          toWalletId: _toWallet!.id,
          amount: amount,
          description: _descriptionController.text,
        );

        await Future.delayed(
          const Duration(milliseconds: 300),
        ); // تأخير بسيط للتحميل
        ref.read(transfersProvider.notifier).addTransfer(transfer);
        Navigator.pop(context);
      } finally {
        setState(() => _isTransferring = false);
      }
    }
  }
}
