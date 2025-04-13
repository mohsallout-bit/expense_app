import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../providers/wallets_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/main_wallet_provider.dart'; // استيراد mainWalletProvider
import '../shared/custom_button.dart';
import '../shared/custom_card.dart';
import '../../core/app_theme.dart';
import 'manage_categories_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final wallets = ref.watch(walletsProvider);
    final mainWalletId = ref.watch(mainWalletProvider);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60 + topPadding,
        title: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: const Text('الإعدادات'),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المحفظة الرئيسية',
                    style: AppTheme.headingStyle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value:
                        mainWalletId ??
                        (wallets.isNotEmpty ? wallets.first.id : null),
                    isExpanded: true,
                    items:
                        wallets.map((wallet) {
                          return DropdownMenuItem(
                            value: wallet.id,
                            child: Text(wallet.name, style: AppTheme.bodyStyle),
                          );
                        }).toList(),
                    onChanged: (value) {
                      ref
                          .read(mainWalletProvider.notifier)
                          .setMainWallet(value!);
                    },
                    decoration: InputDecoration(
                      labelText: 'اختر المحفظة الرئيسية',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(settingsProvider.notifier).saveSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ الإعدادات بنجاح!')),
                );
              },
              child: const Text('حفظ'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageCategoriesScreen(),
                  ),
                );
              },
              child: const Text('إدارة التصنيفات'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    String currentLanguage,
  ) {
    return Column(
      children: [
        CustomButton(
          text: 'العربية',
          onPressed: () {
            ref.read(settingsProvider.notifier).updateLanguage('ar');
            Navigator.pop(context);
          },
          variant:
              currentLanguage == 'ar'
                  ? CustomButtonVariant.primary
                  : CustomButtonVariant.outline,
          fullWidth: true,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'English',
          onPressed: () {
            ref.read(settingsProvider.notifier).updateLanguage('en');
            Navigator.pop(context);
          },
          variant:
              currentLanguage == 'en'
                  ? CustomButtonVariant.primary
                  : CustomButtonVariant.outline,
          fullWidth: true,
        ),
      ],
    );
  }

  void _showColorPickerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        Color selectedColor = ref.watch(settingsProvider).appColor;
        return AlertDialog(
          title: const Text('اختر لون التطبيق'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
            ),
          ),
          actions: [
            CustomButton(
              text: 'إلغاء',
              onPressed: () => Navigator.pop(context),
              variant: CustomButtonVariant.outline,
            ),
            CustomButton(
              text: 'موافق',
              onPressed: () {
                ref
                    .read(settingsProvider.notifier)
                    .updateAppColor(selectedColor);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
