import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../reports/providers/report_provider.dart';
import '../../auth/screens/profile_screen.dart';
import '../../meals/screens/my_meals_screen.dart';
import '../../members/screens/member_list_screen.dart';
import '../../bazar/screens/bazar_list_screen.dart';
import '../../notices/screens/notice_list_screen.dart';
import '../../billing/screens/billing_screen.dart';
import 'home_screen.dart';
import '../../../shared/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchDashboardStats();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      context.read<ReportProvider>().fetchDashboardStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.role == 'admin' || user?.role == 'superadmin';

    return Scaffold(
      extendBodyBehindAppBar: _selectedIndex == 0,
      appBar: _selectedIndex == 0 
        ? null 
        : AppBar(
            title: Text(_getPageTitle(_selectedIndex)),
            elevation: 0,
          ),
      drawer: isAdmin ? _buildAdminDrawer(context) : null,
      body: _buildContent(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppColors.primary.withOpacity(0.1),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined, color: AppColors.textSecondary),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.restaurant_outlined, color: AppColors.textSecondary),
                  selectedIcon: Icon(Icons.restaurant_rounded, color: AppColors.primary),
                  label: 'Meals',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_bag_outlined, color: AppColors.textSecondary),
                  selectedIcon: Icon(Icons.shopping_bag_rounded, color: AppColors.primary),
                  label: 'Bazar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                  selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0 && isAdmin
        ? FloatingActionButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            backgroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
          )
        : null,
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 1: return 'Meal Management';
      case 2: return 'Bazar Expenses';
      case 3: return 'Your Profile';
      default: return 'MealMaster';
    }
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Admin Panel',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDrawerItem(context, Icons.people_alt_rounded, 'Member Management', () => const MemberListScreen()),
          _buildDrawerItem(context, Icons.account_balance_rounded, 'Billing & Deposits', () => const BillingScreen()),
          _buildDrawerItem(context, Icons.campaign_rounded, 'Broadcast Notice', () => const NoticeListScreen()),
          const Spacer(),
          const Divider(indent: 24, endIndent: 24),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'MealMaster v1.0.0',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget Function() screen) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 15),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen()));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0: return const HomeScreen();
      case 1: return const MyMealsScreen();
      case 2: return const BazarListScreen();
      case 3: return const ProfileScreen();
      default: return const HomeScreen();
    }
  }
}
