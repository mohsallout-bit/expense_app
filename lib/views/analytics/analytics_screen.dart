import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../models/expense.dart';
import '../../models/category.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/categories_provider.dart';
import '../shared/custom_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);
    final categories = ref.watch(categoriesProvider);

    final categoryExpenses = _calculateCategoryExpenses(expenses, categories);
    final monthlyExpenses = _calculateMonthlyExpenses(expenses);
    
    // حساب المصاريف اليومية والأسبوعية والشهرية
    final dailyTotal = _calculateDailyExpenses(expenses);
    final weeklyTotal = _calculateWeeklyExpenses(expenses);
    final monthlyTotal = _calculateMonthlyExpenses(expenses).values.lastOrNull ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('التحليلات'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildExpenseSummaryCards(context, dailyTotal, weeklyTotal, monthlyTotal),
            const SizedBox(height: 20),
            _buildPieChartCard(context, categoryExpenses, categories),
            const SizedBox(height: 20),
            _buildBarChartCard(context, categoryExpenses, categories),
            const SizedBox(height: 20),
            _buildMonthlyTrendsCard(context, monthlyExpenses),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseSummaryCards(
    BuildContext context,
    double dailyTotal,
    double weeklyTotal,
    double monthlyTotal,
  ) {
    return Row(
      children: [
        Expanded(
          child: CustomCard(
            child: Column(
              children: [
                const Text('اليوم', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  '${dailyTotal.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomCard(
            child: Column(
              children: [
                const Text('الأسبوع', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  '${weeklyTotal.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomCard(
            child: Column(
              children: [
                const Text('الشهر', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  '${monthlyTotal.toStringAsFixed(2)} ر.س',
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

  double _calculateDailyExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return expenses
        .where((expense) => expense.date.isAfter(today))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateWeeklyExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    return expenses
        .where((expense) => expense.date.isAfter(startOfWeekDate))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // دالة مساعدة لحساب المصروفات حسب التصنيف
  Map<String, double> _calculateCategoryExpenses(
    List<Expense> expenses,
    List<Category> categories,
  ) {
    final result = <String, double>{};
    for (final expense in expenses) {
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
      result.update(
        category.name,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return result;
  }

  // دالة مساعدة لحساب المصروفات الشهرية
  Map<String, double> _calculateMonthlyExpenses(List<Expense> expenses) {
    final result = <String, double>{};
    for (final expense in expenses) {
      final monthKey = DateFormat('yyyy-MM').format(expense.date);
      result.update(
        monthKey,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return result;
  }

  // بطاقة الرسم الدائري
  Widget _buildPieChartCard(
    BuildContext context,
    Map<String, double> categoryExpenses,
    List<Category> categories,
  ) {
    return CustomCard(
      child: Column(
        children: [
          Text(
            'توزيع المصروفات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: _buildPieChartSections(categoryExpenses, categories),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // تفاعل عند اللمس
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء أقسام الرسم الدائري
  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> categoryExpenses,
    List<Category> categories,
  ) {
    return categoryExpenses.entries.map((entry) {
      final color = _getCategoryColor(entry.key, categories);
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.value.toStringAsFixed(2)}\nر.س',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        ),
      );
    }).toList();
  }

  // بطاقة الرسم العمودي
  Widget _buildBarChartCard(
    BuildContext context,
    Map<String, double> categoryExpenses,
    List<Category> categories,
  ) {
    return CustomCard(
      child: Column(
        children: [
          Text(
            'المصاريف حسب التصنيف',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: _buildBarChartGroups(categoryExpenses, categories),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget:
                          (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              categoryExpenses.keys.elementAt(value.toInt()),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget:
                          (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء مجموعات الرسم العمودي
  List<BarChartGroupData> _buildBarChartGroups(
    Map<String, double> categoryExpenses,
    List<Category> categories,
  ) {
    return List.generate(categoryExpenses.length, (index) {
      final entry = categoryExpenses.entries.elementAt(index);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: _getCategoryColor(entry.key, categories),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  // بطاقة الاتجاهات الشهرية
  Widget _buildMonthlyTrendsCard(
    BuildContext context,
    Map<String, double> monthlyExpenses,
  ) {
    return CustomCard(
      child: Column(
        children: [
          Text(
            'الاتجاهات الشهرية',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        monthlyExpenses.entries.map((entry) {
                          final date = DateFormat('yyyy-MM').parse(entry.key);
                          return FlSpot(date.month.toDouble(), entry.value);
                        }).toList(),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final month = value.toInt();
                        return Text(
                          DateFormat('MMM').format(DateTime(2023, month)),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // الحصول على لون التصنيف
  Color _getCategoryColor(String categoryName, List<Category> categories) {
    final category = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse:
          () => Category(
            id: '',
            name: categoryName,
            icon: 'help',
            color: CategoryColor.orange,
          ),
    );

    switch (category.color) {
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
