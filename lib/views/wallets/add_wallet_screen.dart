// lib/views/wallets/add_wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/wallet.dart';
import '../../../../providers/wallets_provider.dart';
import '../shared/custom_button.dart';
import '../shared/custom_text_field.dart';
import '../../core/app_theme.dart';

class AddWalletScreen extends ConsumerStatefulWidget {
  final Wallet? walletToEdit;

  const AddWalletScreen({super.key, this.walletToEdit});

  @override
  ConsumerState<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends ConsumerState<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _currencyController = TextEditingController();
  bool _isSaving = false;

  WalletType _selectedType = WalletType.cash;

  @override
  void initState() {
    super.initState();
    if (widget.walletToEdit != null) {
      _nameController.text = widget.walletToEdit!.name;
      _balanceController.text = widget.walletToEdit!.balance.toString();
      _currencyController.text = widget.walletToEdit!.currency;
      _selectedType = widget.walletToEdit!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60 + topPadding,
        title: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Text(
            widget.walletToEdit == null ? 'إضافة محفظة جديدة' : 'تعديل المحفظة',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'اسم المحفظة',
                prefixIcon: Icons.account_balance_wallet,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المحفظة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _balanceController,
                label: 'الرصيد الحالي',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الرصيد';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _currencyController,
                label: 'العملة',
                prefixIcon: Icons.currency_exchange,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال العملة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'نوع المحفظة',
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildWalletTypeSelector(),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text:
                          widget.walletToEdit == null
                              ? 'إضافة محفظة'
                              : 'حفظ التعديلات',
                      onPressed: _saveWallet,
                      isLoading: _isSaving,
                      size: CustomButtonSize.large,
                      icon:
                          widget.walletToEdit == null ? Icons.add : Icons.save,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'إلغاء',
                      onPressed: () => Navigator.pop(context),
                      variant: CustomButtonVariant.outline,
                      size: CustomButtonSize.large,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children:
            WalletType.values.map((type) {
              return RadioListTile<WalletType>(
                value: type,
                groupValue: _selectedType,
                title: Text(_getWalletTypeName(type)),
                secondary: Icon(_getWalletIcon(type)),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              );
            }).toList(),
      ),
    );
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

  Future<void> _saveWallet() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        final wallet = Wallet(
          id:
              widget.walletToEdit?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          currency: _currencyController.text,
          balance: double.parse(_balanceController.text),
          type: _selectedType,
        );

        await Future.delayed(
          const Duration(milliseconds: 300),
        ); // تأخير بسيط للتحميل

        if (widget.walletToEdit == null) {
          ref.read(walletsProvider.notifier).addWallet(wallet);
        } else {
          ref.read(walletsProvider.notifier).updateWallet(wallet);
        }

        Navigator.pop(context);
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }
}
