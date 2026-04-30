import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/date_range_picker.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    context.read<TransactionProvider>().fetchTransactions(
      startDate: _selectedRange?.start,
      endDate: _selectedRange?.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final transactions = txProvider.transactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Billing & Transactions'),
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
                if (transactions.isNotEmpty)
                  Text(
                    '${transactions.length} Txns',
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
            child: txProvider.isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
                : transactions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return _buildTransactionCard(tx);
                        },
                      ),
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
          Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No transactions found.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Your deposit and deduction history will appear here.'),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(dynamic tx) {
    final dateToken = DateFormat('MMM d, yyyy • h:mm a').format(tx.date);
    final isDeposit = tx.type == 'deposit';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isDeposit ? Colors.green : Colors.red).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isDeposit ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          isDeposit ? 'Deposit' : 'Deduction',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateToken, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            if (tx.description != null)
              Text(tx.description!, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Text(
          '${isDeposit ? "+" : "-"}৳${tx.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDeposit ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
