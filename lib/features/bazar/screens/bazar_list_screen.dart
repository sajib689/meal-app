import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/bazar_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/date_range_picker.dart';
import 'package:intl/intl.dart';

class BazarListScreen extends StatefulWidget {
  const BazarListScreen({super.key});

  @override
  State<BazarListScreen> createState() => _BazarListScreenState();
}

class _BazarListScreenState extends State<BazarListScreen> {
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    context.read<BazarProvider>().fetchBazarHistory(
      startDate: _selectedRange?.start,
      endDate: _selectedRange?.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bazarProvider = context.watch<BazarProvider>();
    final bazars = bazarProvider.bazars;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bazar History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            color: Colors.white,
            child: Row(
              children: [
                PremiumDateRangePicker(
                  selectedRange: _selectedRange,
                  onRangeSelected: (range) {
                    setState(() => _selectedRange = range);
                    _fetchData();
                  },
                ),
                const Spacer(),
                if (bazars.isNotEmpty)
                  Text(
                    '${bazars.length} Items',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: bazarProvider.isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
                : bazars.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: bazars.length,
                        itemBuilder: (context, index) {
                          final bazar = bazars[index];
                          return _buildBazarCard(context, bazar);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBazarDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
        label: const Text('Add Bazar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddBazarDialog(BuildContext context) {
    final itemController = TextEditingController();
    final costController = TextEditingController();
    final dateController = TextEditingController(text: DateTime.now().toIso8601String().substring(0, 10));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Add Bazar Expense', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemController,
                decoration: const InputDecoration(
                  labelText: 'Items (e.g. Potato, Onion, Rice)',
                  prefixIcon: Icon(Icons.shopping_basket_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costController,
                decoration: const InputDecoration(
                  labelText: 'Total Cost (৳)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (itemController.text.isEmpty || costController.text.isEmpty) return;
              final success = await context.read<BazarProvider>().addBazar(
                itemController.text.split(',').map((e) => e.trim()).toList(),
                double.tryParse(costController.text) ?? 0,
                dateController.text,
                '',
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bazar entry added')));
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 48)),
            child: const Text('Save Entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.primary.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No records found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to log expenses.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBazarCard(BuildContext context, dynamic bazar) {
    final dateToken = DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(bazar.date));
    final isAdmin = context.read<AuthProvider>().user?.role == 'admin' || context.read<AuthProvider>().user?.role == 'superadmin';
    final bool isApproved = bazar.isApproved;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateToken,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isApproved ? AppColors.success.withOpacity(0.1) : AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isApproved ? 'APPROVED' : 'PENDING',
                  style: TextStyle(
                    color: isApproved ? AppColors.success : AppColors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                "Shopped by: ${bazar.userName}",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Items: ${bazar.items.join(', ')}",
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isAdmin && !isApproved)
                ElevatedButton.icon(
                  onPressed: () => context.read<BazarProvider>().approveBazar(bazar.id),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                  label: const Text('Approve', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success.withOpacity(0.1),
                    foregroundColor: AppColors.success,
                    minimumSize: const Size(100, 36),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              else if (isAdmin)
                IconButton(
                  onPressed: () => context.read<BazarProvider>().deleteBazar(bazar.id),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                )
              else
                const SizedBox(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text('Total: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    '৳${bazar.totalCost.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -0.5),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
