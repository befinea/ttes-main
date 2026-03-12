import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../ui/widgets/atoms.dart';
import '../../../ui/widgets/animated_glass_card.dart';
import '../../../ui/widgets/notification_panel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);
    
    // Background Gradient for a very premium look
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                title: Text('لوحة التحكم', style: theme.textTheme.titleLarge),
                floating: true,
                actions: [
                  AnimatedGlassCard(
                    padding: const EdgeInsets.all(8),
                    color: theme.colorScheme.surface,
                    onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: anim,
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        key: ValueKey(isDark),
                        color: isDark ? Colors.amber : Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedGlassCard(
                    padding: const EdgeInsets.all(8),
                    color: theme.colorScheme.surface,
                    onTap: () => NotificationPanel.show(context),
                    child: Icon(Icons.notifications_outlined, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(width: 8),
                  AnimatedGlassCard(
                    padding: const EdgeInsets.all(8),
                    color: AppColors.primary,
                    onTap: () => context.push('/profile'),
                    child: const Icon(Icons.person, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText('مساء الخير، المدير', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      AppText('إليك نظرة عامة على النشاط', style: theme.textTheme.bodyMedium, color: AppColors.textSecondaryDark),
                      const SizedBox(height: 24),

                      // Stats Grid using AnimatedGlassCard
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.4,
                        children: [
                          _StatCard(title: 'إجمالي المبيعات', value: '24,500 د', icon: Icons.attach_money, color: AppColors.primary),
                          _StatCard(title: 'المنتجات', value: '1,245', icon: Icons.inventory_2, color: AppColors.secondary),
                          _StatCard(title: 'مخزون منخفض', value: '23', icon: Icons.warning_amber, color: AppColors.error),
                          _StatCard(title: 'مهام معلقة', value: '8', icon: Icons.task_alt, color: AppColors.success),
                        ],
                      ),

                      const SizedBox(height: 32),

                      AppText('إجراءات سريعة', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: [
                          _QuickAction(icon: Icons.add_box_rounded, label: 'إضافة مورد', color: AppColors.primary, onTap: () => context.push('/operations/suppliers/create')),
                          _QuickAction(icon: Icons.point_of_sale, label: 'بيع', color: AppColors.success, onTap: () => context.go('/pos')),
                          _QuickAction(icon: Icons.download_rounded, label: 'وارد', color: Colors.blue, onTap: () => context.push('/operations/transaction/create?type=import')),
                          _QuickAction(icon: Icons.upload_rounded, label: 'صادر', color: Colors.orange, onTap: () => context.push('/operations/transaction/create?type=export')),
                          _QuickAction(icon: Icons.swap_horiz, label: 'نقل', color: Colors.purple, onTap: () => context.push('/operations/transaction/create?type=transfer')),
                          _QuickAction(icon: Icons.people_alt, label: 'موردون', color: Colors.teal, onTap: () => context.go('/operations?tab=suppliers')),
                          _QuickAction(icon: Icons.print_rounded, label: 'طباعة BC', color: Colors.indigo, onTap: () => context.push('/barcode-print')),
                          _QuickAction(icon: Icons.analytics_rounded, label: 'تقارير', color: Colors.brown, onTap: () => context.go('/reports')),
                        ],
                      ),

                      const SizedBox(height: 32),

                      AppText('آخر النشاطات', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      ...List.generate(5, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AnimatedGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          onTap: () {},
                          child: _ActivityTile(
                            title: i % 2 == 0 ? 'بيعية #${1000 + i}' : 'وارد #${500 + i}',
                            subtitle: i % 2 == 0 ? 'متجر أ • ${i + 3} منتجات' : 'المخزن الرئيسي • ${(i + 1) * 12} وحدة',
                            amount: i % 2 == 0 ? '${(i + 1) * 45} د' : '+${(i + 1) * 20} وحدة',
                            icon: i % 2 == 0 ? Icons.shopping_cart : Icons.download,
                            color: i % 2 == 0 ? AppColors.success : Colors.blue,
                          ),
                        ),
                      )),

                      const SizedBox(height: 100), // FAB spacing
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedGlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(Icons.arrow_outward_rounded, color: Colors.grey.withOpacity(0.5), size: 18),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedGlassCard(
      padding: const EdgeInsets.all(8),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14)
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title, subtitle, amount;
  final IconData icon;
  final Color color;
  const _ActivityTile({required this.title, required this.subtitle, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            ],
          ),
        ),
        Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }
}
