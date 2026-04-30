import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../reports/providers/report_provider.dart';
import '../../../shared/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchDashboardStats();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final reportProvider = context.watch<ReportProvider>();
    final stats = reportProvider.dashboardStats;
    
    // Extracting flat values from backend JSON
    final double myBalance = (stats['myBalance'] ?? 0).toDouble();
    final int myMeals = (stats['myMeals'] ?? 0).toInt();
    final double mealRate = (stats['mealRate'] ?? 0).toDouble();
    final double totalBazar = (stats['totalBazarCost'] ?? 0).toDouble();
    final double myCost = myMeals * mealRate;

    if (reportProvider.isLoading && stats.isEmpty) {
      return _buildLoadingState();
    }

    return FadeTransition(
      opacity: _fadeIn,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildPremiumHeader(context, user?.name ?? 'User'),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(context, myBalance),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Personal Overview'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Meals',
                          myMeals.toString(),
                          Icons.restaurant_rounded,
                          AppColors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Monthly Cost',
                          '৳${myCost.toStringAsFixed(0)}',
                          Icons.account_balance_wallet_rounded,
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Mess Summary'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Meal Rate',
                          '৳${mealRate.toStringAsFixed(2)}',
                          Icons.analytics_rounded,
                          AppColors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Bazar',
                          '৳${totalBazar.toStringAsFixed(0)}',
                          Icons.shopping_bag_rounded,
                          AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Balance',
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    '৳',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  balance.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMain,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionTile(context, 'Bazar', Icons.add_shopping_cart_rounded, AppColors.orange, '/bazar'),
        _buildActionTile(context, 'Meals', Icons.restaurant_rounded, AppColors.success, '/meals'),
        _buildActionTile(context, 'Deposit', Icons.account_balance_wallet_rounded, AppColors.blue, '/members'),
        _buildActionTile(context, 'Notice', Icons.notifications_active_rounded, AppColors.purple, '/notices'),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, String label, IconData icon, Color color, String route) {
    return Column(
      children: [
        InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
          SizedBox(height: 16),
          Text('Loading Dashboard...', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
