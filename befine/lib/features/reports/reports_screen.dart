import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/widgets/animated_glass_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.background,
            theme.colorScheme.background.withOpacity(0.9),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text('التقارير والتحليلات', style: theme.textTheme.titleLarge),
            actions: [
              IconButton(icon: const Icon(Icons.date_range), onPressed: () {}, tooltip: 'تصفية حسب التاريخ'),
              IconButton(icon: const Icon(Icons.download), onPressed: () {}, tooltip: 'تصدير'),
            ],
            bottom: TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.primary.withOpacity(0.1),
              ),
              tabs: const [
                Tab(text: 'المبيعات'),
                Tab(text: 'المخزون'),
                Tab(text: 'الأرباح'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _SalesReport(),
              _StockReport(),
              _ProfitReport(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SalesReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryGrid(),
          const SizedBox(height: 24),
          _buildMainChart(context),
          const SizedBox(height: 24),
          Text('أكثر المنتجات مبيعاً', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildTopProductsList(),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _ReportCard(title: 'اليوم', value: '1,250 د', change: '+12%', isPositive: true, icon: Icons.today_rounded, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(child: _ReportCard(title: 'هذا الأسبوع', value: '8,400 د', change: '+5%', isPositive: true, icon: Icons.calendar_view_week, color: AppColors.secondary)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ReportCard(title: 'هذا الشهر', value: '24,500 د', change: '-3%', isPositive: false, icon: Icons.calendar_month, color: AppColors.error)),
          const SizedBox(width: 12),
          Expanded(child: _ReportCard(title: 'إجمالي الطلبات', value: '342', change: '+8%', isPositive: true, icon: Icons.shopping_bag_rounded, color: AppColors.success)),
        ]),
      ],
    );
  }

  Widget _buildMainChart(BuildContext context) {
    return AnimatedGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('أداء المبيعات الأسبوعي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const days = ['سب', 'أح', 'إث', 'ثل', 'أر', 'خم', 'جم'];
                        if (val.toInt() >= 0 && val.toInt() < days.length) {
                          return Text(days[val.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroup(0, 12, AppColors.primary),
                  _makeGroup(1, 15, AppColors.secondary),
                  _makeGroup(2, 8, AppColors.primary),
                  _makeGroup(3, 18, AppColors.success),
                  _makeGroup(4, 10, AppColors.primary),
                  _makeGroup(5, 14, AppColors.primary),
                  _makeGroup(6, 17, AppColors.secondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 20, color: color.withOpacity(0.05)),
        ),
      ],
    );
  }

  Widget _buildTopProductsList() {
    return Column(
      children: List.generate(5, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AnimatedGlassCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('منتج عالي المبيعات ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${(100 - i * 15)} عملية بيع', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Text('${(100 - i * 15) * 50} د', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.success)),
            ],
          ),
        ),
      )),
    );
  }
}

class _StockReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: _ReportCard(title: 'إجمالي المنتجات', value: '1,245', change: '', isPositive: true, icon: Icons.inventory_2_rounded, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: _ReportCard(title: 'مخزون منخفض', value: '23', change: 'تنبيه!', isPositive: false, icon: Icons.warning_amber_rounded, color: Colors.orange)),
          ]),
          const SizedBox(height: 24),
          _buildStockPieChart(context),
          const SizedBox(height: 24),
          const Text('منتجات بمخزون منخفض', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(3, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnimatedGlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: (i == 0 ? AppColors.error : Colors.orange).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.warning_amber, color: i == 0 ? AppColors.error : Colors.orange, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('منتج حرج ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text('المخزن الرئيسي', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: (i == 0 ? AppColors.error : Colors.orange).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text('${i + 1} متبق', style: TextStyle(fontWeight: FontWeight.bold, color: i == 0 ? AppColors.error : Colors.orange)),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStockPieChart(BuildContext context) {
    return AnimatedGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('توزيع المخزون حسب التصنيف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(color: AppColors.primary, value: 45, title: 'غذائية', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(color: AppColors.secondary, value: 25, title: 'منظفات', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(color: AppColors.success, value: 15, title: 'أدوات', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(color: Colors.grey, value: 15, title: 'أخرى', radius: 35, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfitReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: _ReportCard(title: 'الإيرادات', value: '24,500 د', change: '+12%', isPositive: true, icon: Icons.trending_up, color: AppColors.success)),
            const SizedBox(width: 12),
            Expanded(child: _ReportCard(title: 'إجمالي الربح', value: '8,300 د', change: '+18%', isPositive: true, icon: Icons.attach_money, color: AppColors.primary)),
          ]),
          const SizedBox(height: 24),
          _buildProfitLineChart(context),
          const SizedBox(height: 24),
          _buildFinancialBreakdown(context),
        ],
      ),
    );
  }

  Widget _buildProfitLineChart(BuildContext context) {
    return AnimatedGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('تحليل الإيرادات والربح', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), FlSpot(4, 4), FlSpot(5, 6), FlSpot(6, 5.5)],
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.success.withOpacity(0.1)),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.2), FlSpot(3, 2), FlSpot(4, 1.8), FlSpot(5, 2.5), FlSpot(6, 2.2)],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('الإيرادات', AppColors.success),
              const SizedBox(width: 24),
              _buildLegendItem('الربح', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFinancialBreakdown(BuildContext context) {
    return AnimatedGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('تفاصيل النسبة المئوية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...['تكلفة البضاعة', 'المصاريف التشغيلية', 'صافي الربح'].asMap().entries.map((e) {
            final colors = [Colors.orange, AppColors.secondary, AppColors.success];
            final values = [0.65, 0.15, 0.20];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.value, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('${(values[e.key] * 100).toInt()}%', style: TextStyle(color: colors[e.key], fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: values[e.key],
                      minHeight: 6,
                      backgroundColor: colors[e.key].withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(colors[e.key]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title, value, change;
  final bool isPositive;
  final IconData icon;
  final Color color;
  const _ReportCard({
    required this.title, required this.value, required this.change,
    required this.isPositive, required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedGlassCard(
      padding: const EdgeInsets.all(14),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              if (change.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.success : AppColors.error).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
