import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_data_provider.dart';
import '../models/nutrition.dart';
import '../settings/nutrition_api_service.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({Key? key}) : super(key: key);

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final foodController = TextEditingController();
  bool isLoadingNutrition = false;
  String nutritionTip = '';
  int dailyCalories = 0;
  final nutritionService = NutritionApiService();

  @override
  void initState() {
    super.initState();
    _calculateDailyCalories();
    _loadNutritionTip();
  }

  void _calculateDailyCalories() {
    final healthDataProvider =
        Provider.of<HealthDataProvider>(context, listen: false);
    final today = DateTime.now().toIso8601String().split('T')[0];

    dailyCalories = healthDataProvider.nutritionData
        .where((nutrition) => nutrition.date.startsWith(today))
        .fold(0, (sum, nutrition) => sum + nutrition.calories);//sums all calories 
  }

  Future<void> _loadNutritionTip() async {
    final tips = [
      '💡 Tip: Eat a rainbow of fruits and vegetables to get diverse nutrients!',
      '🥗 Remember: Half your plate should be fruits and vegetables.',
      '💧 Stay hydrated! Drink at least 8 glasses of water daily.',
      '🍎 Choose whole fruits over fruit juices for better fiber intake.',
      '🥜 Include healthy fats like nuts, seeds, and avocados in your diet.',
      '🐟 Aim for 2 servings of fish per week for omega-3 fatty acids.',
      '🌾 Choose whole grains over refined grains for better nutrition.',
      '🥛 Include calcium-rich foods for strong bones and teeth.',
    ];
    tips.shuffle();
    setState(() {
      nutritionTip = tips.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthDataProvider = Provider.of<HealthDataProvider>(context);
    _calculateDailyCalories(); // Recalculate when data changes

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A5A98), Color(0xFF4FC3F7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.restaurant,
                      color: Color(0xFF3A5A98), size: 32),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Nutrition',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Daily Calories Card
            _SectionHeader(title: 'Today\'s Calories'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_fire_department,
                            color: Colors.orange, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          '$dailyCalories',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'calories',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _CalorieProgressBar(calories: dailyCalories),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            _SectionHeader(title: 'Add Food'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: foodController,
                      decoration: InputDecoration(
                        labelText:
                            'Search for food (e.g., "1 apple", "100g chicken")',
                        hintText: 'Try: 1 banana, 2 slices bread, 200ml milk',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: foodController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    foodController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: isLoadingNutrition
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.add_circle, color: Colors.white),
                        label: Text(
                          isLoadingNutrition ? 'Adding...' : 'Add Food',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A5A98),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: foodController.text.isNotEmpty &&
                                !isLoadingNutrition
                            ? () => _addFood(healthDataProvider)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nutrition Tip Card
            if (nutritionTip.isNotEmpty) ...[
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 8,
                color: Colors.white,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.green[50]!, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb,
                                color: Colors.green[600], size: 28),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Nutrition Tip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _loadNutritionTip,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nutritionTip,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),
            _SectionHeader(title: 'Recent Foods'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: healthDataProvider.nutritionData.isEmpty
                    ? const Text('No nutrition data yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: healthDataProvider.nutritionData.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final nutrition =
                              healthDataProvider.nutritionData[index];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.restaurant,
                                  color: Colors.green, size: 24),
                            ),
                            title: Text(nutrition.foodItem,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(_formatDate(nutrition.date)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${nutrition.calories} cal',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _addFood(HealthDataProvider healthDataProvider) async {
    if (foodController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a food item'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoadingNutrition = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to add nutrition data'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoadingNutrition = false;
        });
        return;
      }

      print('Processing food: ${foodController.text}');

      // Get nutrition data - this will use fallback if API keys aren't configured
      Nutrition? nutrition;
      try {
        nutrition = await nutritionService
            .fetchNutritionData(foodController.text)
            .timeout(const Duration(seconds: 5)); // Reduced timeout further
      } catch (e) {
        print('API timeout or error, using fallback: $e');
        nutrition = null;
      }

      if (nutrition == null) {
        // Create fallback nutrition entry immediately
        print('Creating fallback nutrition entry');
        nutrition = Nutrition(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now().toIso8601String(),
          foodItem: foodController.text,
          calories: _estimateCaloriesFromText(foodController.text),
        );
      }

      print(
          'Adding nutrition data: ${nutrition.foodItem} - ${nutrition.calories} calories');

      // Check if user is authenticated
      if (authProvider.user == null) {
        throw Exception('User not authenticated');
      }

      await healthDataProvider.addNutritionData(
          nutrition, authProvider.user!.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Added ${nutrition.foodItem} (${nutrition.calories} calories)'),
          backgroundColor: Colors.green,
        ),
      );

      foodController.clear();

      // Load a new tip after adding food
      _loadNutritionTip();
    } catch (e) {
      print('Error adding food: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add food: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Always reset loading state
      if (mounted) {
        setState(() {
          isLoadingNutrition = false;
        });
      }
    }
  }

  int _estimateCaloriesFromText(String foodText) {
    final text = foodText.toLowerCase();

    // Extract numbers for serving sizes
    final RegExp numberRegex = RegExp(r'\d+');
    final matches = numberRegex.allMatches(text);
    int multiplier = 1;

    if (matches.isNotEmpty) {
      multiplier = int.tryParse(matches.first.group(0) ?? '1') ?? 1;
    }

    // Basic calorie estimates for common foods
    final calorieMap = {
      'apple': 95,
      'banana': 105,
      'orange': 62,
      'bread': 80,
      'slice': 80,
      'egg': 70,
      'chicken': 165,
      'rice': 130,
      'pasta': 220,
      'pizza': 285,
      'burger': 540,
      'salad': 35,
      'milk': 150,
      'water': 0,
      'coffee': 5,
      'tea': 2,
      'cookie': 50,
      'cake': 350,
      'chocolate': 150,
      'nuts': 200,
      'yogurt': 100,
      'cheese': 113,
      'avocado': 234,
      'salmon': 206,
      'tuna': 154,
      'beef': 250,
      'pork': 242,
      'potato': 161,
      'tomato': 18,
      'carrot': 25,
      'broccoli': 25,
      'spinach': 7,
    };

    // Find matching foods and estimate calories
    int estimatedCalories = 100; // Default fallback

    for (String food in calorieMap.keys) {
      if (text.contains(food)) {
        estimatedCalories = calorieMap[food]! * multiplier;
        break;
      }
    }

    // Adjust for common serving descriptors
    if (text.contains('cup') || text.contains('bowl')) {
      estimatedCalories = (estimatedCalories * 1.5).round();
    } else if (text.contains('small') || text.contains('mini')) {
      estimatedCalories = (estimatedCalories * 0.7).round();
    } else if (text.contains('large') || text.contains('big')) {
      estimatedCalories = (estimatedCalories * 1.5).round();
    }

    return estimatedCalories;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference == 1) {
        return 'Yesterday';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _CalorieProgressBar extends StatelessWidget {
  final int calories;
  const _CalorieProgressBar({required this.calories});

  @override
  Widget build(BuildContext context) {
    final targetCalories = 2000; // Default daily target
    final progress = (calories / targetCalories).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress', style: TextStyle(color: Colors.grey[600])),
            Text('$calories / $targetCalories cal',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(progress < 0.5
              ? Colors.red
              : progress < 0.8
                  ? Colors.orange
                  : Colors.green),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          _getCalorieMessage(calories, targetCalories),
          style: TextStyle(
            fontSize: 12,
            color: progress < 0.5
                ? Colors.red
                : progress < 0.8
                    ? Colors.orange
                    : Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getCalorieMessage(int current, int target) {
    if (current < target * 0.5) {        //1000
      return 'You need more calories for energy!';
    } else if (current < target * 0.8) {
      return 'Good progress! Keep eating healthy.';//1600
    } else if (current <= target) {
      return 'Perfect! You\'re meeting your daily goal.';
    } else {
      return 'Over target - consider lighter meals.';
    }
  }
}
