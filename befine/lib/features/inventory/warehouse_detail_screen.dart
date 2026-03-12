import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/widgets/animated_glass_card.dart';

class WarehouseDetailScreen extends StatefulWidget {
  final String warehouseId;
  final String warehouseName;

  const WarehouseDetailScreen({super.key, required this.warehouseId, required this.warehouseName});

  @override
  State<WarehouseDetailScreen> createState() => _WarehouseDetailScreenState();
}

class _WarehouseDetailScreenState extends State<WarehouseDetailScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _stores = [];

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  Future<void> _fetchStores() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('locations')
          .select()
          .eq('parent_id', widget.warehouseId)
          .eq('type', 'store')
          .order('created_at');

      if (mounted) {
        setState(() {
          _stores = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching stores: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addStore(String name) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final profile = await _supabase.from('profiles').select('company_id').eq('id', user.id).single();
      
      await _supabase.from('locations').insert({
        'company_id': profile['company_id'],
        'name': name,
        'type': 'store',
        'parent_id': widget.warehouseId,
      });

      _fetchStores();
    } catch (e) {
      debugPrint('Error adding store: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}'), backgroundColor: AppColors.error));
      }
    }
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة متجر جديد'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المتجر (مثال: متجر الأدوات الإلكترونية)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                _addStore(nameCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                title: Text('مخزن: ${widget.warehouseName}', style: theme.textTheme.titleMedium),
                floating: true,
                actions: [
                  IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _showAddDialog),
                ],
              ),
              if (_isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (_stores.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text('لا يوجد متاجر في هذا المخزن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _showAddDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة متجر'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final store = _stores[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AnimatedGlassCard(
                            padding: const EdgeInsets.all(16),
                            onTap: () => context.push('/inventory/store/${store['id']}', extra: store['name']),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.store_rounded, color: Colors.orange, size: 26),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(store['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                                      Text('متجر نشط', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _stores.length,
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
