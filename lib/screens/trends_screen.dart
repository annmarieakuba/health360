import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_data_provider.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({Key? key}) : super(key: key);

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'All',
      'value': 'all',
      'icon': Icons.analytics,
      'color': Colors.blue
    },
    {
      'name': 'Nutrition',
      'value': 'nutrition',
      'icon': Icons.restaurant,
      'color': Colors.green
    },
    {
      'name': 'Exercise',
      'value': 'exercise',
      'icon': Icons.fitness_center,
      'color': Colors.orange
    },
    {
      'name': 'Sleep',
      'value': 'sleep',
      'icon': Icons.bedtime,
      'color': Colors.indigo
    },
    {
      'name': 'Mood',
      'value': 'mood',
      'icon': Icons.mood,
      'color': Colors.purple
    },
  ];

  @override
  Widget build(BuildContext context) {
    final healthData = Provider.of<HealthDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Health Trends',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
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
              const SizedBox(height: 20),

              // Header
              const Text(
                'Your Health Trends',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your health patterns over time',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              // Category Selection
              _SectionHeader(title: 'Health Category'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Wrap(
                  spacing: 8,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category['value'];
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category['icon'],
                            size: 16,
                            color:
                                isSelected ? Colors.white : category['color'],
                          ),
                          const SizedBox(width: 4),
                          Text(category['name']),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: category['color'],
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category['value'];
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),

              // Summary Cards
              _SectionHeader(title: 'Health Summary'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Average Calories',
                      value: _getAverageCalories(healthData),
                      unit: 'kcal/day',
                      icon: Icons.restaurant,
                      color: Colors.green,
                      trend: _getCalorieTrend(healthData),
                      isPositive: _getCalorieTrend(healthData).startsWith('+'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Exercise Time',
                      value: _getAverageExerciseTime(healthData),
                      unit: 'min/day',
                      icon: Icons.fitness_center,
                      color: Colors.orange,
                      trend: _getExerciseTrend(healthData),
                      isPositive: _getExerciseTrend(healthData).startsWith('+'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Sleep Duration',
                      value: _getAverageSleepHours(healthData),
                      unit: 'hours',
                      icon: Icons.bedtime,
                      color: Colors.indigo,
                      trend: _getSleepTrend(healthData),
                      isPositive: _getSleepTrend(healthData).startsWith('+'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Mood Score',
                      value: _getAverageMoodScore(healthData),
                      unit: '/10',
                      icon: Icons.mood,
                      color: Colors.purple,
                      trend: _getMoodTrend(healthData),
                      isPositive: _getMoodTrend(healthData).startsWith('+'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Trend Charts
              _SectionHeader(title: 'Trend Analysis'),
              const SizedBox(height: 16),

              _TrendChart(
                title: 'Nutrition Trends',
                data: _getNutritionTrendData(healthData),
                labels: _getWeekLabels(),
                color: Colors.green,
                unit: 'kcal',
              ),
              const SizedBox(height: 20),

              _TrendChart(
                title: 'Exercise Trends',
                data: _getExerciseTrendData(healthData),
                labels: _getWeekLabels(),
                color: Colors.orange,
                unit: 'min',
              ),
              const SizedBox(height: 20),

              _TrendChart(
                title: 'Sleep Trends',
                data: _getSleepTrendData(healthData),
                labels: _getWeekLabels(),
                color: Colors.indigo,
                unit: 'hours',
              ),
              const SizedBox(height: 30),

              // Insights Section
              _SectionHeader(title: 'Health Insights'),
              const SizedBox(height: 16),

              _InsightCard(
                icon: Icons.trending_up,
                title: 'Nutrition Consistency',
                description: _getNutritionInsight(healthData),
                color: Colors.green,
                isPositive:
                    _getNutritionInsight(healthData).contains('improving'),
                onTap: () => _showNutritionDetails(context, healthData),
              ),
              const SizedBox(height: 12),

              _InsightCard(
                icon: Icons.fitness_center,
                title: 'Exercise Consistency',
                description: _getExerciseInsight(healthData),
                color: Colors.orange,
                isPositive: _getExerciseInsight(healthData).contains('Great'),
                onTap: () => _showExerciseDetails(context, healthData),
              ),
              const SizedBox(height: 12),

              _InsightCard(
                icon: Icons.bedtime,
                title: 'Sleep Pattern',
                description: _getSleepInsight(healthData),
                color: Colors.indigo,
                isPositive: _getSleepInsight(healthData).contains('Good'),
                onTap: () => _showSleepDetails(context, healthData),
              ),
              const SizedBox(height: 12),

              _InsightCard(
                icon: Icons.mood,
                title: 'Mood Improvement',
                description: _getMoodInsight(healthData),
                color: Colors.purple,
                isPositive: _getMoodInsight(healthData).contains('positive'),
                onTap: () => _showMoodDetails(context, healthData),
              ),
              const SizedBox(height: 30),

              // Recommendations
              _SectionHeader(title: 'Recommendations'),
              const SizedBox(height: 16),

              _RecommendationCard(
                icon: Icons.water_drop,
                title: 'Increase Water Intake',
                description:
                    'Try to drink 8 glasses of water daily for better hydration.',
                action: 'Set Reminder',
                onActionTap: () => _setWaterReminder(context),
              ),
              const SizedBox(height: 12),

              _RecommendationCard(
                icon: Icons.directions_walk,
                title: 'Add Walking',
                description:
                    'Include 10,000 steps daily to improve cardiovascular health.',
                action: 'View Tips',
                onActionTap: () => _showWalkingTips(context),
              ),
              const SizedBox(height: 12),

              _RecommendationCard(
                icon: Icons.self_improvement,
                title: 'Stress Management',
                description:
                    'Practice 10 minutes of meditation daily for better mental health.',
                action: 'Learn More',
                onActionTap: () => _showStressManagementInfo(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Data calculation methods
  String _getAverageCalories(HealthDataProvider healthData) {
    if (healthData.nutritionData.isEmpty) return '0';
    final totalCalories = healthData.nutritionData
        .fold<int>(0, (sum, nutrition) => sum + (nutrition.calories ?? 0));
    final average = totalCalories / healthData.nutritionData.length;
    return average.round().toString();
  }

  String _getAverageExerciseTime(HealthDataProvider healthData) {
    if (healthData.exerciseData.isEmpty) return '0';
    final totalMinutes = healthData.exerciseData
        .fold<int>(0, (sum, exercise) => sum + (exercise.duration ?? 0));
    final average = totalMinutes / healthData.exerciseData.length;
    return average.round().toString();
  }

  String _getAverageSleepHours(HealthDataProvider healthData) {
    if (healthData.sleepData.isEmpty) return '0';
    final totalHours = healthData.sleepData
        .fold<double>(0.0, (sum, sleep) => sum + (sleep.hours ?? 0.0));
    final average = totalHours / healthData.sleepData.length;
    return average.toStringAsFixed(1);
  }

  String _getAverageMoodScore(HealthDataProvider healthData) {
    if (healthData.moodData.isEmpty) return '0';
    final moodScores =
        healthData.moodData.map((mood) => _getMoodScore(mood.mood)).toList();
    final average = moodScores.reduce((a, b) => a + b) / moodScores.length;
    return average.toStringAsFixed(1);
  }

  int _getMoodScore(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return 9;
      case 'excited':
        return 10;
      case 'grateful':
        return 8;
      case 'relaxed':
        return 7;
      case 'sad':
        return 3;
      case 'angry':
        return 2;
      case 'stressed':
        return 4;
      case 'anxious':
        return 3;
      case 'frustrated':
        return 2;
      case 'tired':
        return 5;
      case 'lonely':
        return 3;
      case 'overwhelmed':
        return 2;
      default:
        return 5;
    }
  }

  String _getCalorieTrend(HealthDataProvider healthData) {
    if (healthData.nutritionData.length < 2) return '+0%';

    // Get recent entries (last 3) vs older entries (3 before that)
    final recentEntries = healthData.nutritionData.take(3).toList();
    final olderEntries = healthData.nutritionData.skip(3).take(3).toList();

    if (recentEntries.isEmpty || olderEntries.isEmpty) return '+0%';

    final recentTotal = recentEntries.fold<int>(
        0, (sum, nutrition) => sum + (nutrition.calories ?? 0));
    final olderTotal = olderEntries.fold<int>(
        0, (sum, nutrition) => sum + (nutrition.calories ?? 0));

    if (olderTotal == 0) return '+0%';

    final change = ((recentTotal - olderTotal) / olderTotal * 100).round();
    return change >= 0 ? '+$change%' : '$change%';
  }

  String _getExerciseTrend(HealthDataProvider healthData) {
    if (healthData.exerciseData.length < 2) return '+0%';

    // Get recent entries (last 3) vs older entries (3 before that)
    final recentEntries = healthData.exerciseData.take(3).toList();
    final olderEntries = healthData.exerciseData.skip(3).take(3).toList();

    if (recentEntries.isEmpty || olderEntries.isEmpty) return '+0%';

    final recentTotal = recentEntries.fold<int>(
        0, (sum, exercise) => sum + (exercise.duration ?? 0));
    final olderTotal = olderEntries.fold<int>(
        0, (sum, exercise) => sum + (exercise.duration ?? 0));

    if (olderTotal == 0) return '+0%';

    final change = ((recentTotal - olderTotal) / olderTotal * 100).round();
    return change >= 0 ? '+$change%' : '$change%';
  }

  String _getSleepTrend(HealthDataProvider healthData) {
    if (healthData.sleepData.length < 2) return '+0%';

    // Get recent entries (last 3) vs older entries (3 before that)
    final recentEntries = healthData.sleepData.take(3).toList();
    final olderEntries = healthData.sleepData.skip(3).take(3).toList();

    if (recentEntries.isEmpty || olderEntries.isEmpty) return '+0%';

    final recentTotal = recentEntries.fold<double>(
        0.0, (sum, sleep) => sum + (sleep.hours ?? 0.0));
    final olderTotal = olderEntries.fold<double>(
        0.0, (sum, sleep) => sum + (sleep.hours ?? 0.0));

    if (olderTotal == 0) return '+0%';

    final change = ((recentTotal - olderTotal) / olderTotal * 100).round();
    return change >= 0 ? '+$change%' : '$change%';
  }

  String _getMoodTrend(HealthDataProvider healthData) {
    if (healthData.moodData.length < 2) return '+0%';

    // Get recent entries (last 3) vs older entries (3 before that)
    final recentEntries = healthData.moodData.take(3).toList();
    final olderEntries = healthData.moodData.skip(3).take(3).toList();

    if (recentEntries.isEmpty || olderEntries.isEmpty) return '+0%';

    final recentTotal = recentEntries
        .map((mood) => _getMoodScore(mood.mood))
        .reduce((a, b) => a + b);
    final olderTotal = olderEntries
        .map((mood) => _getMoodScore(mood.mood))
        .reduce((a, b) => a + b);

    if (olderTotal == 0) return '+0%';

    final change = ((recentTotal - olderTotal) / olderTotal * 100).round();
    return change >= 0 ? '+$change%' : '$change%';
  }

  List<int> _getNutritionTrendData(HealthDataProvider healthData) {
    if (healthData.nutritionData.isEmpty) return List.filled(7, 0);

    final weekData = List.filled(7, 0);
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: 6 - i));
      final dateString = date.toString().substring(0, 10);

      final dayCalories = healthData.nutritionData
          .where((nutrition) => nutrition.date.startsWith(dateString))
          .fold<int>(0, (sum, nutrition) => sum + (nutrition.calories ?? 0));

      weekData[i] = dayCalories;
    }
    return weekData;
  }

  List<int> _getExerciseTrendData(HealthDataProvider healthData) {
    if (healthData.exerciseData.isEmpty) return List.filled(7, 0);

    final weekData = List.filled(7, 0);
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: 6 - i));
      final dateString = date.toString().substring(0, 10);

      final dayMinutes = healthData.exerciseData
          .where((exercise) => exercise.date.startsWith(dateString))
          .fold<int>(0, (sum, exercise) => sum + (exercise.duration ?? 0));

      weekData[i] = dayMinutes;
    }
    return weekData;
  }

  List<int> _getSleepTrendData(HealthDataProvider healthData) {
    if (healthData.sleepData.isEmpty) return List.filled(7, 0);

    final weekData = List.filled(7, 0);
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: 6 - i));
      final dateString = date.toString().substring(0, 10);

      final daySleep = healthData.sleepData
          .where((sleep) => sleep.date.startsWith(dateString))
          .fold<double>(0.0, (sum, sleep) => sum + (sleep.hours ?? 0.0));

      weekData[i] = daySleep.round();
    }
    return weekData;
  }

  List<String> _getWeekLabels() {
    final labels = <String>[];
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      labels.add(date.day.toString());
    }
    return labels;
  }

  String _getNutritionInsight(HealthDataProvider healthData) {
    if (healthData.nutritionData.isEmpty) {
      return 'Start tracking your nutrition to see insights. Add your first meal!';
    }

    final average = double.parse(_getAverageCalories(healthData));
    final totalEntries = healthData.nutritionData.length;

    if (average >= 1800 && average <= 2200) {
      return 'Great! Your average calorie intake (${average.round()} kcal) is well-balanced.';
    } else if (average < 1500) {
      return 'Your average intake (${average.round()} kcal) is low. Consider adding more nutritious meals.';
    } else if (average > 2500) {
      return 'Your average intake (${average.round()} kcal) is high. Focus on balanced portions.';
    } else {
      return 'You\'ve tracked $totalEntries nutrition entries. Keep up the consistency!';
    }
  }

  String _getExerciseInsight(HealthDataProvider healthData) {
    if (healthData.exerciseData.isEmpty) {
      return 'Start exercising to see your fitness trends. Log your first workout!';
    }

    final average = double.parse(_getAverageExerciseTime(healthData));
    final totalEntries = healthData.exerciseData.length;

    if (average >= 30) {
      return 'Excellent! You\'re averaging ${average.round()} minutes per session.';
    } else if (average >= 15) {
      return 'Good progress! Average ${average.round()} minutes. Try to increase gradually.';
    } else {
      return 'You\'ve logged $totalEntries workouts. Every bit counts!';
    }
  }

  String _getSleepInsight(HealthDataProvider healthData) {
    if (healthData.sleepData.isEmpty) {
      return 'Track your sleep to understand your patterns. Log your first night!';
    }

    final average = double.parse(_getAverageSleepHours(healthData));
    final totalEntries = healthData.sleepData.length;

    if (average >= 7 && average <= 9) {
      return 'Perfect! You\'re averaging ${average.toStringAsFixed(1)} hours of sleep.';
    } else if (average < 6) {
      return 'Your average (${average.toStringAsFixed(1)}h) is low. Aim for 7-9 hours.';
    } else if (average > 10) {
      return 'You might be oversleeping (${average.toStringAsFixed(1)}h). Aim for 7-9 hours.';
    } else {
      return 'You\'ve tracked $totalEntries sleep entries. Consistency is key!';
    }
  }

  String _getMoodInsight(HealthDataProvider healthData) {
    if (healthData.moodData.isEmpty) {
      return 'Track your mood to understand your emotional patterns. Log your first mood!';
    }

    final average = double.parse(_getAverageMoodScore(healthData));
    final totalEntries = healthData.moodData.length;

    if (average >= 7) {
      return 'Great! Your average mood score is ${average.toStringAsFixed(1)}/10.';
    } else if (average >= 5) {
      return 'Your mood is improving (${average.toStringAsFixed(1)}/10). Keep it up!';
    } else {
      return 'You\'ve tracked $totalEntries mood entries. Consider stress-reducing activities.';
    }
  }

  // Interactive functionality methods
  void _showNutritionDetails(
      BuildContext context, HealthDataProvider healthData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nutrition Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Entries: ${healthData.nutritionData.length}'),
            const SizedBox(height: 8),
            Text('Average Calories: ${_getAverageCalories(healthData)} kcal'),
            const SizedBox(height: 8),
            Text('Trend: ${_getCalorieTrend(healthData)}'),
            const SizedBox(height: 16),
            const Text(
              'Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Track all meals for accurate data'),
            const Text('• Aim for balanced nutrition'),
            const Text('• Stay hydrated throughout the day'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExerciseDetails(
      BuildContext context, HealthDataProvider healthData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Workouts: ${healthData.exerciseData.length}'),
            const SizedBox(height: 8),
            Text(
                'Average Duration: ${_getAverageExerciseTime(healthData)} minutes'),
            const SizedBox(height: 8),
            Text('Trend: ${_getExerciseTrend(healthData)}'),
            const SizedBox(height: 16),
            const Text(
              'Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Aim for 150 minutes per week'),
            const Text('• Mix cardio and strength training'),
            const Text('• Start with activities you enjoy'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSleepDetails(BuildContext context, HealthDataProvider healthData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Nights Tracked: ${healthData.sleepData.length}'),
            const SizedBox(height: 8),
            Text('Average Sleep: ${_getAverageSleepHours(healthData)} hours'),
            const SizedBox(height: 8),
            Text('Trend: ${_getSleepTrend(healthData)}'),
            const SizedBox(height: 16),
            const Text(
              'Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Aim for 7-9 hours per night'),
            const Text('• Maintain consistent bedtime'),
            const Text('• Create a relaxing bedtime routine'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMoodDetails(BuildContext context, HealthDataProvider healthData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mood Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Mood Entries: ${healthData.moodData.length}'),
            const SizedBox(height: 8),
            Text('Average Score: ${_getAverageMoodScore(healthData)}/10'),
            const SizedBox(height: 8),
            Text('Trend: ${_getMoodTrend(healthData)}'),
            const SizedBox(height: 16),
            const Text(
              'Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Track mood daily for patterns'),
            const Text('• Practice stress management'),
            const Text('• Stay connected with others'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _setWaterReminder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Water Reminder Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text('You\'ll receive reminders to drink water every 2 hours.'),
            SizedBox(height: 8),
            Text('Goal: 8 glasses (2 liters) per day'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWalkingTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Walking Tips'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '10,000 Steps Daily Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Take the stairs instead of elevator'),
            Text('• Park farther from your destination'),
            Text('• Walk during phone calls'),
            Text('• Take walking breaks at work'),
            Text('• Walk your dog or go for evening strolls'),
            SizedBox(height: 12),
            Text('Benefits:'),
            Text('• Improves cardiovascular health'),
            Text('• Burns calories'),
            Text('• Reduces stress'),
            Text('• Boosts mood'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showStressManagementInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stress Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '10-Minute Daily Meditation:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. Find a quiet, comfortable space'),
            Text('2. Sit with your back straight'),
            Text('3. Close your eyes and breathe deeply'),
            Text('4. Focus on your breath'),
            Text('5. Let thoughts pass without judgment'),
            SizedBox(height: 12),
            Text('Other Stress Relief Activities:'),
            Text('• Deep breathing exercises'),
            Text('• Progressive muscle relaxation'),
            Text('• Yoga or gentle stretching'),
            Text('• Spending time in nature'),
            Text('• Listening to calming music'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Start Today'),
          ),
        ],
      ),
    );
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
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final String title;
  final List<int> data;
  final List<String> labels;
  final Color color;
  final String unit;

  const _TrendChart({
    required this.title,
    required this.data,
    required this.labels,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    // Validate data to prevent rendering errors
    if (data.isEmpty || labels.isEmpty || data.length != labels.length) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Find max value for scaling (avoid division by zero)
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final maxDisplayValue = maxValue > 0 ? maxValue : 1;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.length, (index) {
                  final value = data[index];
                  final height = maxDisplayValue > 0
                      ? (value / maxDisplayValue * 80).clamp(0.0, 80.0)
                      : 0.0;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 20,
                          height: height,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels[index],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unit: $unit',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isPositive;
  final VoidCallback? onTap;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String action;
  final VoidCallback? onActionTap;

  const _RecommendationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.action,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3A5A98).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF3A5A98), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onActionTap,
              child: Text(
                action,
                style: const TextStyle(
                  color: Color(0xFF3A5A98),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
