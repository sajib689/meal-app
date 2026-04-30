import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildProfileHeader(context, user?.name ?? 'User', user?.email ?? '', user?.role ?? 'Member'),
          const SizedBox(height: 32),
          _buildProfileOption(context, Icons.person_outline, 'Edit Profile'),
          _buildProfileOption(context, Icons.lock_outline, 'Change Password'),
          _buildProfileOption(context, Icons.notifications_none, 'Notification Settings'),
          _buildProfileOption(context, Icons.help_outline, 'Help & Support'),
          _buildProfileOption(context, Icons.info_outline, 'About MealMaster'),
          const SizedBox(height: 32),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email, String role) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            name.isNotEmpty ? name[0] : 'U',
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
        Text(email, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            role.toUpperCase(),
            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () {
          // TODO: Navigate to specific option screen
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<AuthProvider>().logout();
        context.go('/login');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.withOpacity(0.1),
        foregroundColor: Colors.red,
        elevation: 0,
      ),
      child: const Text('Sign Out'),
    );
  }
}
