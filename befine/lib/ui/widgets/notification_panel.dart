import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'animated_glass_card.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const NotificationPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('التنبيهات', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.all(20),
                itemCount: 4,
                itemBuilder: (context, i) {
                  final titles = [
                    'تنبيه: مخزون منخفض',
                    'عملية استلام جديدة',
                    'تنبيه: مخزون منخفض',
                    'مهمة مكتملة'
                  ];
                  final subtitles = [
                    'منتج الزيت النباتي (5لتر) وصل إلى 5 قطع فقط في المخزن الرئيسي.',
                    'تم تأكيد استلام شحنة المنظفات في مخزن الشرق.',
                    'منتج الأرز البسمتي وصل إلى الحد الأدنى (10 قطع).',
                    'تم الانتهاء من جرد متجر أ بنجاح.'
                  ];
                  final icons = [
                    Icons.warning_amber_rounded,
                    Icons.download_done_rounded,
                    Icons.warning_amber_rounded,
                    Icons.check_circle_outline_rounded
                  ];
                  final colors = [
                    AppColors.error,
                    Colors.blue,
                    AppColors.error,
                    AppColors.success
                  ];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnimatedGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors[i].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icons[i], color: colors[i], size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(titles[i], style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  subtitles[i],
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
