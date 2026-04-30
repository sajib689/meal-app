import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../billing/providers/transaction_provider.dart';
import '../providers/member_provider.dart';
import '../../../shared/theme/app_theme.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().fetchMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final members = memberProvider.members;
    final isAdmin = context.watch<AuthProvider>().user?.role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mess Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => memberProvider.fetchMembers(),
          ),
        ],
      ),
      body: memberProvider.isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
          : members.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return _buildMemberCard(context, member);
                  },
                ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddMemberDialog(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.person_add_rounded, color: Colors.white),
              label: const Text('Add Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
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
            child: Icon(Icons.people_outline_rounded, size: 64, color: AppColors.primary.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No members found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          const Text(
            'Members will appear here once added.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, dynamic member) {
    final isAdmin = context.read<AuthProvider>().user?.role == 'admin';
    final bool isActive = member.status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              member.name[0].toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Balance: ৳${member.balance.toStringAsFixed(0)}',
            style: TextStyle(
              color: member.balance >= 0 ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            member.status.toUpperCase(),
            style: TextStyle(
              color: isActive ? AppColors.success : AppColors.error,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.email_outlined, member.email),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone_outlined, member.phone),
                if (isAdmin) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAdminAction(Icons.add_circle_outline_rounded, 'Deposit', AppColors.success, () => _showDepositDialog(context, member.id)),
                        _buildAdminAction(Icons.lock_reset_rounded, 'Reset', AppColors.blue, () => _showResetPasswordDialog(context, member.id)),
                        _buildAdminAction(isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded, isActive ? 'Disable' : 'Enable', AppColors.textSecondary, () => context.read<MemberProvider>().updateMemberStatus(member.id, isActive ? 'inactive' : 'active')),
                        _buildAdminAction(Icons.delete_outline_rounded, 'Delete', AppColors.error, () => _deleteMember(context, member)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _deleteMember(BuildContext context, dynamic member) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: const Text('Delete Member?'),
              content: Text('Are you sure you want to delete ${member.name}? This action cannot be undone.'),
              actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                          context.read<MemberProvider>().deleteUser(member.id);
                          Navigator.pop(context);
                      },
                      child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                  ),
              ],
          ),
      );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController(text: '123456');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Add New Member', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 16),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 16),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined))),
              const SizedBox(height: 16),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Default Password', prefixIcon: Icon(Icons.lock_outline)), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || emailController.text.isEmpty) return;
              final success = await context.read<MemberProvider>().createMember(
                nameController.text,
                emailController.text,
                passwordController.text,
                phoneController.text,
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member added successfully')));
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 48)),
            child: const Text('Add Member'),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context, String userId) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Deposit Balance', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount (৳)', prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
            keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) return;
              final success = await context.read<TransactionProvider>().deposit(userId, amount, 'Manual Deposit');
              if (success && context.mounted) {
                Navigator.pop(context);
                context.read<MemberProvider>().fetchMembers();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deposit successful')));
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 48)),
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, String userId) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
            controller: passController,
            decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock_outline)),
            obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (passController.text.length < 6) return;
              final success = await context.read<MemberProvider>().resetPassword(userId, passController.text);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successful')));
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 48)),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
