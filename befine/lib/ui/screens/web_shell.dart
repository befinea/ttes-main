import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class WebShell extends StatelessWidget {
  final Widget child;
  const WebShell({super.key, required this.child});

  int _calcIndex(String location) {
    if (location.startsWith('/inventory')) return 1;
    if (location.startsWith('/pos')) return 2;
    if (location.startsWith('/operations')) return 3;
    if (location.startsWith('/reports')) return 4;
    return 0; // dashboard
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _calcIndex(location);

    return Scaffold(
      body: Row(
        children: [
          // Custom Wide Sidebar for Web
          Container(
            width: 250, // Fixed wider width for Web
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo or App Name could go here
                Text(
                  'لوحة التحكم',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _buildNavItem(
                        context: context,
                        icon: Icons.dashboard_rounded,
                        label: 'الرئيسية',
                        isSelected: currentIndex == 0,
                        onTap: () => context.go('/dashboard'),
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        context: context,
                        icon: Icons.warehouse_rounded,
                        label: 'المخزون',
                        isSelected: currentIndex == 1,
                        onTap: () => context.go('/inventory'),
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        context: context,
                        icon: Icons.point_of_sale_rounded,
                        label: 'الكاشير',
                        isSelected: currentIndex == 2,
                        onTap: () => context.go('/pos'),
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        context: context,
                        icon: Icons.swap_horiz_rounded,
                        label: 'العمليات',
                        isSelected: currentIndex == 3,
                        onTap: () => context.go('/operations'),
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        context: context,
                        icon: Icons.analytics_rounded,
                        label: 'التقارير',
                        isSelected: currentIndex == 4,
                        onTap: () => context.go('/reports'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: FloatingActionButton.extended(
                    heroTag: 'barcode_fab_web',
                    onPressed: () => context.push('/scanner'),
                    backgroundColor: AppColors.primary,
                    elevation: 4,
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                    label: const Text('مسح باركود', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
