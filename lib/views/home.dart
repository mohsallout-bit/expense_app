import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../models/wallet.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../providers/wallets_provider.dart';
import '../providers/main_wallet_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/categories_provider.dart';
import 'analytics/analytics_screen.dart';
import 'expenses/add_expense_screen.dart';
import 'expenses/expenses_screen.dart';
import 'transfers/transfers_screen.dart';
import 'wallets/wallets_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    _HomeContent(),
    ExpensesScreen(),
    AnalyticsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60 + topPadding,
        title: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Text('تطبيق المصاريف', style: AppTheme.headingStyle),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(12, topPadding, 12, 0),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(bottom: false, child: _screens[_selectedIndex]),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                  );
                },
                child: const Icon(Icons.add, size: 28),
              )
              : null,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey.shade600,
      backgroundColor: Colors.white,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'المصاريف'),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'التحليلات',
        ),
      ],
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);
    final mainWalletId = ref.watch(mainWalletProvider);
    final expenses = ref.watch(expensesProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);

    final dailyExpenses = expenses.where((e) => e.date.isAfter(today)).toList();
    final monthlyExpenses =
        expenses.where((e) => e.date.isAfter(startOfMonth)).toList();

    final dailyTotal = dailyExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final monthlyTotal = monthlyExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final recentExpenses =
        expenses.where((e) => e.date.isAfter(startOfMonth)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final mainWallet = wallets.firstWhere(
      (w) => w.id == mainWalletId,
      orElse:
          () => Wallet(
            id: '',
            name: 'غير محددة',
            currency: '',
            balance: 0,
            type: WalletType.other,
          ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBalanceCard(context, mainWallet),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildExpenseSummary(
            context,
            dailyTotal,
            monthlyTotal,
            mainWallet.currency,
          ),
          const SizedBox(height: 24),
          _buildRecentExpensesHeader(context),
          const SizedBox(height: 12),
          _buildRecentExpensesList(context, recentExpenses, ref),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, Wallet wallet) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.9),
            AppTheme.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            wallet.id.isEmpty
                ? 'لم يتم تعيين محفظة رئيسية'
                : 'رصيد ${wallet.name}',
            style: AppTheme.labelStyle.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            wallet.id.isEmpty
                ? '--'
                : NumberFormat.currency(
                  symbol: wallet.currency,
                ).format(wallet.balance),
            style: AppTheme.headingStyle.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickAction(
          context,
          Icons.account_balance_wallet,
          'المحافظ',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WalletsScreen()),
          ),
        ),
        _buildQuickAction(
          context,
          Icons.add,
          'مصروف',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          ),
        ),
        _buildQuickAction(
          context,
          Icons.swap_horiz,
          'تحويل',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransferScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 30, color: AppTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: AppTheme.bodyStyle.copyWith(fontSize: 14)),
      ],
    );
  }

  Widget _buildExpenseSummary(
    BuildContext context,
    double dailyTotal,
    double monthlyTotal,
    String currency,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مصروفات اليوم',
                  style: TextStyle(fontSize: 14, color: Colors.orange),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(symbol: currency).format(dailyTotal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مصروفات الشهر',
                  style: TextStyle(fontSize: 14, color: Colors.purple),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(symbol: currency).format(monthlyTotal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExpensesHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('آخر المصاريف', style: AppTheme.headingStyle),
        TextButton(onPressed: () {}, child: const Text('عرض الكل')),
      ],
    );
  }

  IconData _resolveIcon(String iconName) {
    // تحقق إذا كان iconName هو رمز رقمي
    if (iconName.startsWith('0x')) {
      try {
        return IconData(int.parse(iconName), fontFamily: 'MaterialIcons');
      } catch (e) {
        print('Error parsing icon code: $e');
        return Icons.help;
      }
    }

    // إذا لم يكن رمزًا رقميًا، استخدم الأسماء النصية
    final iconMap = {
      'shopping_cart': Icons.shopping_cart,
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'help': Icons.help,
      // Add more mappings as needed
    };
    return iconMap[iconName] ?? Icons.help;
  }

  Widget _buildRecentExpensesList(
    BuildContext context,
    List<Expense> expenses,
    WidgetRef ref,
  ) {
    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'لا توجد مصاريف بعد',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final categories = ref.watch(categoriesProvider);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length > 5 ? 5 : expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final category = categories.firstWhere(
          (c) => c.id == expense.categoryId,
          orElse:
              () => Category(
                id: '',
                name: 'غير معروف',
                icon: 'help',
                color: CategoryColor.orange,
              ),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(
                category.color,
              ).withOpacity(0.2),
              child: Icon(
                _resolveIcon(category.icon),
                color: _getCategoryColor(category.color),
              ),
            ),
            title: Text(expense.description),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name),
                Text(
                  DateFormat('yyyy-MM-dd').format(expense.date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  NumberFormat.currency(
                    symbol:
                        ref
                            .read(walletsProvider)
                            .firstWhere(
                              (w) => w.id == expense.walletId,
                              orElse:
                                  () => Wallet(
                                    id: '',
                                    name: '',
                                    currency: 'ر.س',
                                    balance: 0,
                                    type: WalletType.other,
                                  ),
                            )
                            .currency,
                  ).format(expense.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditExpenseDialog(context, expense, ref);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditExpenseDialog(
    BuildContext context,
    Expense expense,
    WidgetRef ref,
  ) {
    final descriptionController = TextEditingController(
      text: expense.description,
    );
    final amountController = TextEditingController(
      text: expense.amount.toString(),
    );
    DateTime selectedDate = expense.date;
    String selectedCategoryId = expense.categoryId;
    final categories = ref.read(categoriesProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل المصروف'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  items:
                      categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedCategoryId = value;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('التاريخ: '),
                    TextButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          selectedDate = pickedDate;
                        }
                      },
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                ref.read(expensesProvider.notifier).deleteExpense(expense.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('حذف'),
            ),
            TextButton(
              onPressed: () {
                final updatedExpense = expense.copyWith(
                  description: descriptionController.text,
                  amount:
                      double.tryParse(amountController.text) ?? expense.amount,
                  categoryId: selectedCategoryId,
                  date: selectedDate,
                );
                ref
                    .read(expensesProvider.notifier)
                    .updateExpense(updatedExpense);
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(CategoryColor color) {
    switch (color) {
      case CategoryColor.red:
        return Colors.redAccent;
      case CategoryColor.green:
        return Colors.greenAccent;
      case CategoryColor.blue:
        return Colors.blueAccent;
      case CategoryColor.yellow:
        return Colors.amber;
      case CategoryColor.purple:
        return Colors.deepPurpleAccent;
      case CategoryColor.orange:
        return Colors.orangeAccent;
    }
  }
}
