import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notice_provider.dart';
import '../../../shared/theme/app_theme.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeProvider>().fetchNotices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final noticeProvider = context.watch<NoticeProvider>();
    final notices = noticeProvider.notices;
    final isAdmin = context.watch<AuthProvider>().user?.role == 'admin' || context.watch<AuthProvider>().user?.role == 'superadmin';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Important Notices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => noticeProvider.fetchNotices(),
          ),
        ],
      ),
      body: noticeProvider.isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
          : notices.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    return _buildNoticeCard(context, notice);
                  },
                ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateNoticeDialog(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.campaign_rounded, color: Colors.white),
              label: const Text('Post Notice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  void _showCreateNoticeDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('New Broadcast', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title_rounded)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Message Body', prefixIcon: Icon(Icons.description_rounded)),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              final success = await context.read<NoticeProvider>().createNotice(titleController.text, contentController.text);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notice broadcasted')));
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 48)),
            child: const Text('Broadcast'),
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
            child: Icon(Icons.campaign_rounded, size: 64, color: AppColors.primary.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notices yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stay tuned for important mess updates.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(BuildContext context, dynamic notice) {
    final isAdmin = context.read<AuthProvider>().user?.role == 'admin' || context.read<AuthProvider>().user?.role == 'superadmin';
    final dateToken = DateFormat('MMM d, yyyy').format(notice.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'BROADCAST',
                  style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              if (isAdmin)
                IconButton(
                  onPressed: () => context.read<NoticeProvider>().deleteNotice(notice.id),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notice.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textMain, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          Text(
            notice.content,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(notice.creatorName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(dateToken, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
