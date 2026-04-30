import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/meal_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/date_range_picker.dart';

class MyMealsScreen extends StatefulWidget {
  const MyMealsScreen({super.key});

  @override
  State<MyMealsScreen> createState() => _MyMealsScreenState();
}

class _MyMealsScreenState extends State<MyMealsScreen> {
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final isAdmin = context.read<AuthProvider>().user?.role == 'admin';
    if (isAdmin) {
      context.read<MealProvider>().fetchAllMeals(
        startDate: _selectedRange?.start,
        endDate: _selectedRange?.end,
      );
    } else {
      context.read<MealProvider>().fetchMyMeals(
        startDate: _selectedRange?.start,
        endDate: _selectedRange?.end,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    final meals = mealProvider.meals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meal Management'),
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
                if (meals.isNotEmpty)
                  Text(
                    '${meals.length} Records',
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
            child: mealProvider.isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
                : meals.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: meals.length,
                        itemBuilder: (context, index) {
                          final meal = meals[index];
                          return _buildMealCard(meal);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogMealDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Meal', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showLogMealDialog(BuildContext context) {
    final dateController = TextEditingController(text: DateTime.now().toIso8601String().substring(0, 10));
    final breakfastController = TextEditingController(text: '0');
    final lunchController = TextEditingController(text: '1');
    final dinnerController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Daily Meal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: breakfastController, decoration: const InputDecoration(labelText: 'Breakfast'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: lunchController, decoration: const InputDecoration(labelText: 'Lunch'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: dinnerController, decoration: const InputDecoration(labelText: 'Dinner'), keyboardType: TextInputType.number)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<MealProvider>().addOrUpdateMeal(
                dateController.text,
                double.tryParse(breakfastController.text) ?? 0,
                double.tryParse(lunchController.text) ?? 0,
                double.tryParse(dinnerController.text) ?? 0,
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal logged successfully')));
              }
            },
            child: const Text('Save'),
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
          Icon(Icons.restaurant_menu, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No meal records found.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Check back later or contact your admin.'),
        ],
      ),
    );
  }

  Widget _buildMealCard(dynamic meal) {
    // Assuming meal is a MealModel
    final dateToken = DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(meal.date));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateToken, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: meal.isLocked ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    meal.isLocked ? 'Locked' : 'Active',
                    style: TextStyle(
                      color: meal.isLocked ? Colors.red : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMealStat('Breakfast', meal.breakfast),
                _buildMealStat('Lunch', meal.lunch),
                _buildMealStat('Dinner', meal.dinner),
                _buildMealStat('Total', meal.breakfast + meal.lunch + meal.dinner, isTotal: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealStat(String label, double value, {bool isTotal = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.textMain,
          ),
        ),
      ],
    );
  }
}
