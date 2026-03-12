import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../ui/widgets/animated_glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text('الإعدادات', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),

              // --- Theme Toggle ---
              AnimatedGlassCard(
                padding: const EdgeInsets.all(4),
                child: SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.amber : Colors.indigo).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDark ? Colors.amber : Colors.indigo,
                    ),
                  ),
                  title: const Text('الوضع الليلي', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(isDark ? 'مفعّل' : 'معطّل', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  value: isDark,
                  activeColor: AppColors.primary,
                  onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                ),
              ),
              const SizedBox(height: 12),

              // --- Personal Info ---
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                color: AppColors.primary,
                title: 'المعلومات الشخصية',
                subtitle: 'عرض وتعديل بيانات الحساب',
                onTap: () => context.push('/settings/profile'),
              ),
              const SizedBox(height: 12),

              // --- Categories ---
              _SettingsTile(
                icon: Icons.category_rounded,
                color: Colors.teal,
                title: 'إدارة الأصناف',
                subtitle: 'إضافة وتعديل أصناف المنتجات',
                onTap: () => context.push('/settings/categories'),
              ),
              const SizedBox(height: 24),

              // Divider label
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('حساب', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
              ),

              // --- Logout ---
              _SettingsTile(
                icon: Icons.logout_rounded,
                color: AppColors.error,
                title: 'تسجيل الخروج',
                subtitle: 'الخروج من الحساب الحالي',
                onTap: () => _signOut(context),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) context.go('/auth');
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedGlassCard(
      padding: const EdgeInsets.all(4),
      onTap: onTap,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDestructive ? AppColors.error : null,
          ),
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDestructive ? AppColors.error : Colors.grey.shade400),
      ),
    );
  }
}
