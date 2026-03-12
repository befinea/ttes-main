import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/widgets/animated_glass_card.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _supabase = Supabase.instance.client;
  final List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  double _total = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() { _searchResults = []; _isSearching = false; });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final data = await _supabase
          .from('products')
          .select()
          .ilike('name', '%$query%')
          .limit(5);
      
      if (mounted) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data);
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _addItem(Map<String, dynamic> product) {
    setState(() {
      final existing = _cartItems.indexWhere((item) => item['id'] == product['id']);
      if (existing != -1) {
        _cartItems[existing]['qty']++;
      } else {
        _cartItems.add({
          'id': product['id'],
          'name': product['name'],
          'price': (product['sale_price'] as num).toDouble(),
          'qty': 1,
        });
      }
      _recalcTotal();
      _searchCtrl.clear();
      _searchResults = [];
    });
  }

  void _updateQty(int index, int delta) {
    setState(() {
      _cartItems[index]['qty'] += delta;
      if (_cartItems[index]['qty'] <= 0) {
        _cartItems.removeAt(index);
      }
      _recalcTotal();
    });
  }

  void _recalcTotal() {
    _total = _cartItems.fold(0, (sum, item) => sum + (item['price'] as double) * (item['qty'] as int));
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
              theme.colorScheme.background.withOpacity(0.95),
              theme.colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(context),
            _buildSearchArea(context),
            Expanded(child: _buildCart(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('نقطة البيع', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('جلسة مبيعات نشطة', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchArea(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          AnimatedGlassCard(
            padding: EdgeInsets.zero,
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج بالاسم أو الباركود...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _isSearching ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onChanged: _searchProducts,
            ),
          ),
          if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AnimatedGlassCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: _searchResults.map((p) => ListTile(
                    title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${p['sale_price']} د'),
                    trailing: const Icon(Icons.add_circle, color: AppColors.primary),
                    onTap: () => _addItem(p),
                  )).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCart(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('سلة المشتريات (${_cartItems.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (_cartItems.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() { _cartItems.clear(); _total = 0; }),
                  child: const Text('إفراغ السلة', style: TextStyle(color: AppColors.error)),
                ),
            ],
          ),
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text('السلة فارغة حالياً', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (ctx, i) {
                      final item = _cartItems[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AnimatedGlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${item['price']} د', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _QtyBtn(icon: Icons.remove, onTap: () => _updateQty(i, -1)),
                                  SizedBox(width: 30, child: Center(child: Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold)))),
                                  _QtyBtn(icon: Icons.add, onTap: () => _updateQty(i, 1)),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Text('${(item['price'] * item['qty']).toStringAsFixed(1)} د', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildCheckoutArea(context),
        ],
      ),
    );
  }

  Widget _buildCheckoutArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي المبلغ', style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text('${_total.toStringAsFixed(2)} د', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _cartItems.isEmpty ? null : () async {
                  try {
                    // 1. Get current user's profile to find the company and current location.
                    // (Assuming operations happen at the user's primary assigned location for POS)
                    final user = _supabase.auth.currentUser;
                    if (user == null) throw Exception('المستخدم غير مسجل الدخول');

                    final profile = await _supabase.from('profiles').select('company_id').eq('id', user.id).single();
                    final companyId = profile['company_id'];
                    
                    final locations = await _supabase.from('profile_locations').select('location_id').eq('profile_id', user.id).limit(1);
                    
                    String? locationId;
                    if (locations.isNotEmpty) {
                      locationId = locations.first['location_id'];
                    } else {
                      // Fallback: Get any location (pos or warehouse) belonging to the company
                      final companyLocs = await _supabase.from('locations').select('id').eq('company_id', companyId).limit(1);
                      if (companyLocs.isEmpty) {
                         throw Exception('لا يوجد أي موقع أو نقطة بيع مرتبطة بالشركة. يرجى إضافة نقطة بيع أولاً.');
                      }
                      locationId = companyLocs.first['id'] as String;
                    }

                    // 2. Insert Transaction
                    final transRes = await _supabase.from('transactions').insert({
                      'company_id': companyId,
                      'location_id': locationId,
                      'performed_by': user.id,
                      'type': 'sale',
                      'status': 'completed',
                      'total_amount': _total,
                    }).select('id').single();

                    final transId = transRes['id'];

                    // 3. Insert Transaction Items
                    final itemsToInsert = _cartItems.map((item) => {
                      'transaction_id': transId,
                      'product_id': item['id'],
                      'quantity': item['qty'],
                      'unit_price': item['price'],
                    }).toList();

                    await _supabase.from('transaction_items').insert(itemsToInsert);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حفظ نقطة البيع بنجاح!'), backgroundColor: AppColors.success),
                      );
                      setState(() { _cartItems.clear(); _total = 0; });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('إتمام الدفع والطباعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: theme.colorScheme.onSurface),
      ),
    );
  }
}
