import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_data_provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();
  String _selectedCategory = 'nutrition';
  String _selectedTimeframe = 'daily';
  int _targetValue = 0;

  // List to store user goals
  final List<Map<String, dynamic>> _userGoals = [];

  final List<Map<String, dynamic>> _categories = [
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
      'color': Colors.blue
    },
    {
      'name': 'Mood',
      'value': 'mood',
      'icon': Icons.mood,
      'color': Colors.purple
    },
  ];

  final List<Map<String, dynamic>> _timeframes = [
    {'name': 'Daily', 'value': 'daily'},
    {'name': 'Weekly', 'value': 'weekly'},
    {'name': 'Monthly', 'value': 'monthly'},
  ];

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

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
          'Health Goals',
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
                'Your Health Goals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set and track your health objectives',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              // Current Goals Section
              _SectionHeader(title: 'Current Goals'),
              const SizedBox(height: 16),

              // Dynamic goals based on actual data
              _GoalCard(
                title: 'Daily Calorie Intake',
                category: 'Nutrition',
                target: '2000 calories',
                progress: _calculateNutritionProgress(healthData),
                color: Colors.green,
                icon: Icons.restaurant,
                current: healthData.nutritionData.isNotEmpty
                    ? '${healthData.nutritionData.last.calories} calories'
                    : '0 calories',
              ),
              const SizedBox(height: 12),

              _GoalCard(
                title: 'Weekly Exercise',
                category: 'Exercise',
                target: '150 minutes',
                progress: _calculateExerciseProgress(healthData),
                color: Colors.orange,
                icon: Icons.fitness_center,
                current: '${_getTotalExerciseMinutes(healthData)} minutes',
              ),
              const SizedBox(height: 12),

              _GoalCard(
                title: 'Sleep Duration',
                category: 'Sleep',
                target: '8 hours',
                progress: _calculateSleepProgress(healthData),
                color: Colors.blue,
                icon: Icons.bedtime,
                current: healthData.sleepData.isNotEmpty
                    ? '${healthData.sleepData.last.hours} hours'
                    : '0 hours',
              ),
              const SizedBox(height: 12),

              _GoalCard(
                title: 'Positive Mood Days',
                category: 'Mood',
                target: '7 days',
                progress: _calculateMoodProgress(healthData),
                color: Colors.purple,
                icon: Icons.mood,
                current: '${_getPositiveMoodDays(healthData)} days',
              ),
              const SizedBox(height: 30),

              // Add New Goal Section
              _SectionHeader(title: 'Add New Goal'),
              const SizedBox(height: 16),

              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Goal Title
                        TextFormField(
                          controller: _goalController,
                          decoration: const InputDecoration(
                            labelText: 'Goal Title',
                            hintText: 'e.g., Daily Water Intake',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a goal title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Category Selection
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _categories.map((category) {
                            final isSelected =
                                _selectedCategory == category['value'];
                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category['icon'],
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : category['color'],
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
                        const SizedBox(height: 20),

                        // Timeframe Selection
                        const Text(
                          'Timeframe',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _timeframes.map((timeframe) {
                            final isSelected =
                                _selectedTimeframe == timeframe['value'];
                            return ChoiceChip(
                              label: Text(timeframe['name']),
                              selected: isSelected,
                              selectedColor: const Color(0xFF3A5A98),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTimeframe = timeframe['value'];
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Target Value
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Target Value',
                            hintText: 'e.g., 2000, 30, 8',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _targetValue = int.tryParse(value) ?? 0;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a target value';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Add Goal Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addGoal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3A5A98),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Add Goal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Stored Goals Summary
              if (_userGoals.isNotEmpty) ...[
                _SectionHeader(title: 'Your Stored Goals'),
                const SizedBox(height: 16),
                ..._userGoals.map((goal) => _StoredGoalCard(
                      title: goal['title'],
                      category: goal['category'],
                      timeframe: goal['timeframe'],
                      target: goal['target'].toString(),
                      unit: _getUnitForCategory(goal['category']),
                      color: _getColorForCategory(goal['category']),
                      icon: _getIconForCategory(goal['category']),
                      onDelete: () => _deleteGoal(goal),
                    )),
                const SizedBox(height: 20),
              ],

              // Goals Summary
              _SectionHeader(title: 'Goals Summary'),
              const SizedBox(height: 16),

              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A5A98)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.flag,
                              color: Color(0xFF3A5A98),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Goals',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_userGoals.length} personal goals set',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_userGoals.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A5A98),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Goals by category
                      if (_userGoals.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _GoalSummaryItem(
                              icon: Icons.restaurant,
                              label: 'Nutrition',
                              count: _userGoals
                                  .where(
                                      (goal) => goal['category'] == 'nutrition')
                                  .length,
                              color: Colors.green,
                            ),
                            _GoalSummaryItem(
                              icon: Icons.fitness_center,
                              label: 'Exercise',
                              count: _userGoals
                                  .where(
                                      (goal) => goal['category'] == 'exercise')
                                  .length,
                              color: Colors.orange,
                            ),
                            _GoalSummaryItem(
                              icon: Icons.bedtime,
                              label: 'Sleep',
                              count: _userGoals
                                  .where((goal) => goal['category'] == 'sleep')
                                  .length,
                              color: Colors.blue,
                            ),
                            _GoalSummaryItem(
                              icon: Icons.mood,
                              label: 'Mood',
                              count: _userGoals
                                  .where((goal) => goal['category'] == 'mood')
                                  .length,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate progress based on actual data
  double _calculateNutritionProgress(HealthDataProvider healthData) {
    if (healthData.nutritionData.isEmpty) return 0.0;
    final todayCalories = healthData.nutritionData
        .where((nutrition) => nutrition.date
            .startsWith(DateTime.now().toString().substring(0, 10)))
        .fold<int>(0, (sum, nutrition) => sum + nutrition.calories);
    return (todayCalories / 2000).clamp(0.0, 1.0);
  }

  double _calculateExerciseProgress(HealthDataProvider healthData) {
    if (healthData.exerciseData.isEmpty) return 0.0;
    final weeklyMinutes = healthData.exerciseData.where((exercise) {
      final exerciseDate = DateTime.parse(exercise.date);
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      return exerciseDate.isAfter(weekAgo);
    }).fold<int>(0, (sum, exercise) => sum + exercise.duration);
    return (weeklyMinutes / 150).clamp(0.0, 1.0);
  }

  double _calculateSleepProgress(HealthDataProvider healthData) {
    if (healthData.sleepData.isEmpty) return 0.0;
    final latestSleep = healthData.sleepData.last.hours;
    return (latestSleep / 8).clamp(0.0, 1.0);
  }

  double _calculateMoodProgress(HealthDataProvider healthData) {
    if (healthData.moodData.isEmpty) return 0.0;
    final positiveMoodDays = _getPositiveMoodDays(healthData);
    return (positiveMoodDays / 7).clamp(0.0, 1.0);
  }

  int _getTotalExerciseMinutes(HealthDataProvider healthData) {
    if (healthData.exerciseData.isEmpty) return 0;
    return healthData.exerciseData.where((exercise) {
      final exerciseDate = DateTime.parse(exercise.date);
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      return exerciseDate.isAfter(weekAgo);
    }).fold<int>(0, (sum, exercise) => sum + exercise.duration);
  }

  int _getPositiveMoodDays(HealthDataProvider healthData) {
    if (healthData.moodData.isEmpty) return 0;
    final positiveMoods = ['happy', 'excited', 'grateful', 'relaxed'];
    return healthData.moodData.where((mood) {
      final moodDate = DateTime.parse(mood.date);
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      return moodDate.isAfter(weekAgo) &&
          positiveMoods.contains(mood.mood.toLowerCase());
    }).length;
  }

  void _addGoal() {
    if (_formKey.currentState!.validate()) {
      // Add goal to the list
      final newGoal = {
        'title': _goalController.text,
        'category': _selectedCategory,
        'timeframe': _selectedTimeframe,
        'target': _targetValue,
        'date': DateTime.now().toString(),
      };

      setState(() {
        _userGoals.add(newGoal);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Goal "${_goalController.text}" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _goalController.clear();
      setState(() {
        _selectedCategory = 'nutrition';
        _selectedTimeframe = 'daily';
        _targetValue = 0;
      });
    }
  }

  void _deleteGoal(Map<String, dynamic> goal) {
    setState(() {
      _userGoals.remove(goal);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goal "${goal['title']}" deleted'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _getUnitForCategory(String category) {
    switch (category) {
      case 'nutrition':
        return 'calories';
      case 'exercise':
        return 'minutes';
      case 'sleep':
        return 'hours';
      case 'mood':
        return 'score';
      default:
        return '';
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'nutrition':
        return Colors.green;
      case 'exercise':
        return Colors.orange;
      case 'sleep':
        return Colors.blue;
      case 'mood':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'nutrition':
        return Icons.restaurant;
      case 'exercise':
        return Icons.fitness_center;
      case 'sleep':
        return Icons.bedtime;
      case 'mood':
        return Icons.mood;
      default:
        return Icons.flag;
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
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String category;
  final String target;
  final double progress;
  final Color color;
  final IconData icon;
  final String current;

  const _GoalCard({
    required this.title,
    required this.category,
    required this.target,
    required this.progress,
    required this.color,
    required this.icon,
    required this.current,
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
                const SizedBox(width: 12),
                Expanded(
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
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      target,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      current,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% complete',
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

class _StoredGoalCard extends StatelessWidget {
  final String title;
  final String category;
  final String timeframe;
  final String target;
  final String unit;
  final Color color;
  final IconData icon;
  final VoidCallback onDelete;

  const _StoredGoalCard({
    required this.title,
    required this.category,
    required this.timeframe,
    required this.target,
    required this.unit,
    required this.color,
    required this.icon,
    required this.onDelete,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          timeframe,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Target: $target $unit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalSummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _GoalSummaryItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
