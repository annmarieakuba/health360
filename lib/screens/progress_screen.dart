import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_data_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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
          'Progress Tracker',
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
                'Your Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your journey to better health',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              // Overall Progress
              _SectionHeader(title: 'Overall Progress'),
              const SizedBox(height: 16),

              _OverallProgressCard(healthData: healthData),
              const SizedBox(height: 30),

              // Category Progress
              _SectionHeader(title: 'Category Progress'),
              const SizedBox(height: 16),

              _CategoryProgressCard(
                title: 'Nutrition',
                icon: Icons.restaurant,
                color: Colors.green,
                progress: _calculateNutritionProgress(healthData),
                current: _getCurrentNutrition(healthData),
                target: '2000',
                unit: 'calories',
                achievements: _getNutritionAchievements(healthData),
              ),
              const SizedBox(height: 16),

              _CategoryProgressCard(
                title: 'Exercise',
                icon: Icons.fitness_center,
                color: Colors.orange,
                progress: _calculateExerciseProgress(healthData),
                current: _getCurrentExercise(healthData),
                target: '150',
                unit: 'minutes',
                achievements: _getExerciseAchievements(healthData),
              ),
              const SizedBox(height: 16),

              _CategoryProgressCard(
                title: 'Sleep',
                icon: Icons.bedtime,
                color: Colors.indigo,
                progress: _calculateSleepProgress(healthData),
                current: _getCurrentSleep(healthData),
                target: '8.0',
                unit: 'hours',
                achievements: _getSleepAchievements(healthData),
              ),
              const SizedBox(height: 16),

              _CategoryProgressCard(
                title: 'Mood',
                icon: Icons.mood,
                color: Colors.purple,
                progress: _calculateMoodProgress(healthData),
                current: _getCurrentMood(healthData),
                target: '10',
                unit: 'score',
                achievements: _getMoodAchievements(healthData),
              ),
              const SizedBox(height: 30),

              // Achievements
              _SectionHeader(title: 'Recent Achievements'),
              const SizedBox(height: 16),

              ..._getRecentAchievements(healthData).map((achievement) => Column(
                    children: [
                      _AchievementCard(
                        icon: achievement['icon'],
                        title: achievement['title'],
                        description: achievement['description'],
                        date: achievement['date'],
                        color: achievement['color'],
                      ),
                      const SizedBox(height: 12),
                    ],
                  )),
              const SizedBox(height: 30),

              // Milestones
              _SectionHeader(title: 'Upcoming Milestones'),
              const SizedBox(height: 16),

              _MilestoneCard(
                icon: Icons.star,
                title: '30-Day Challenge',
                description: 'Complete 30 days of consistent health tracking',
                progress: _calculateTrackingProgress(healthData),
                remaining: _getTrackingRemaining(healthData),
                color: Colors.blue,
              ),
              const SizedBox(height: 12),

              _MilestoneCard(
                icon: Icons.trending_up,
                title: 'Fitness Goal',
                description: 'Reach 150 minutes of exercise per week',
                progress: _calculateFitnessMilestone(healthData),
                remaining: _getFitnessRemaining(healthData),
                color: Colors.green,
              ),
              const SizedBox(height: 12),

              _MilestoneCard(
                icon: Icons.speed,
                title: 'Consistency Award',
                description: 'Maintain 7 days of daily tracking',
                progress: _calculateConsistencyProgress(healthData),
                remaining: _getConsistencyRemaining(healthData),
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Progress calculation methods
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

  String _getCurrentNutrition(HealthDataProvider healthData) {
    if (healthData.nutritionData.isEmpty) return '0';
    final todayCalories = healthData.nutritionData
        .where((nutrition) => nutrition.date
            .startsWith(DateTime.now().toString().substring(0, 10)))
        .fold<int>(0, (sum, nutrition) => sum + nutrition.calories);
    return todayCalories.toString();
  }

  String _getCurrentExercise(HealthDataProvider healthData) {
    if (healthData.exerciseData.isEmpty) return '0';
    final weeklyMinutes = healthData.exerciseData.where((exercise) {
      final exerciseDate = DateTime.parse(exercise.date);
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      return exerciseDate.isAfter(weekAgo);
    }).fold<int>(0, (sum, exercise) => sum + exercise.duration);
    return weeklyMinutes.toString();
  }

  String _getCurrentSleep(HealthDataProvider healthData) {
    if (healthData.sleepData.isEmpty) return '0.0';
    return healthData.sleepData.last.hours.toStringAsFixed(1);
  }

  String _getCurrentMood(HealthDataProvider healthData) {
    if (healthData.moodData.isEmpty) return '0';
    final positiveMoodDays = _getPositiveMoodDays(healthData);
    return positiveMoodDays.toString();
  }

  List<String> _getNutritionAchievements(HealthDataProvider healthData) {
    final achievements = <String>[];
    if (healthData.nutritionData.isNotEmpty) {
      achievements.add('Started tracking');
    }
    if (healthData.nutritionData.length >= 7) {
      achievements.add('Week of tracking');
    }
    if (_calculateNutritionProgress(healthData) >= 0.8) {
      achievements.add('Near daily goal');
    }
    return achievements;
  }

  List<String> _getExerciseAchievements(HealthDataProvider healthData) {
    final achievements = <String>[];
    if (healthData.exerciseData.isNotEmpty) {
      achievements.add('Started exercising');
    }
    if (healthData.exerciseData.length >= 5) {
      achievements.add('Regular workouts');
    }
    if (_calculateExerciseProgress(healthData) >= 0.8) {
      achievements.add('Weekly goal met');
    }
    return achievements;
  }

  List<String> _getSleepAchievements(HealthDataProvider healthData) {
    final achievements = <String>[];
    if (healthData.sleepData.isNotEmpty) {
      achievements.add('Sleep tracking');
    }
    if (healthData.sleepData.length >= 7) {
      achievements.add('Week of data');
    }
    if (_calculateSleepProgress(healthData) >= 0.8) {
      achievements.add('Good sleep');
    }
    return achievements;
  }

  List<String> _getMoodAchievements(HealthDataProvider healthData) {
    final achievements = <String>[];
    if (healthData.moodData.isNotEmpty) {
      achievements.add('Mood awareness');
    }
    if (healthData.moodData.length >= 7) {
      achievements.add('Week of tracking');
    }
    if (_getPositiveMoodDays(healthData) >= 5) {
      achievements.add('Positive week');
    }
    return achievements;
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

  List<Map<String, dynamic>> _getRecentAchievements(
      HealthDataProvider healthData) {
    final achievements = <Map<String, dynamic>>[];

    if (healthData.nutritionData.isNotEmpty) {
      achievements.add({
        'icon': Icons.restaurant,
        'title': 'Nutrition Tracking Started',
        'description': 'You\'ve begun tracking your nutrition habits',
        'date': 'Today',
        'color': Colors.green,
      });
    }

    if (healthData.exerciseData.isNotEmpty) {
      achievements.add({
        'icon': Icons.fitness_center,
        'title': 'Exercise Logged',
        'description': 'You\'ve recorded your first exercise session',
        'date': 'Today',
        'color': Colors.orange,
      });
    }

    if (healthData.sleepData.isNotEmpty) {
      achievements.add({
        'icon': Icons.bedtime,
        'title': 'Sleep Tracking',
        'description': 'You\'ve started monitoring your sleep patterns',
        'date': 'Today',
        'color': Colors.indigo,
      });
    }

    if (healthData.moodData.isNotEmpty) {
      achievements.add({
        'icon': Icons.mood,
        'title': 'Mood Awareness',
        'description': 'You\'ve begun tracking your emotional well-being',
        'date': 'Today',
        'color': Colors.purple,
      });
    }

    return achievements;
  }

  double _calculateTrackingProgress(HealthDataProvider healthData) {
    final totalEntries = healthData.nutritionData.length +
        healthData.exerciseData.length +
        healthData.sleepData.length +
        healthData.moodData.length;
    return (totalEntries / 30).clamp(0.0, 1.0);
  }

  String _getTrackingRemaining(HealthDataProvider healthData) {
    final totalEntries = healthData.nutritionData.length +
        healthData.exerciseData.length +
        healthData.sleepData.length +
        healthData.moodData.length;
    final remaining = 30 - totalEntries;
    return remaining > 0 ? '$remaining entries left' : 'Completed!';
  }

  double _calculateFitnessMilestone(HealthDataProvider healthData) {
    if (healthData.exerciseData.isEmpty) return 0.0;
    final weeklyMinutes = int.parse(_getCurrentExercise(healthData));
    return (weeklyMinutes / 150).clamp(0.0, 1.0);
  }

  String _getFitnessRemaining(HealthDataProvider healthData) {
    if (healthData.exerciseData.isEmpty) return '150 minutes to go';
    final weeklyMinutes = int.parse(_getCurrentExercise(healthData));
    final remaining = 150 - weeklyMinutes;
    return remaining > 0 ? '$remaining minutes to go' : 'Goal achieved!';
  }

  double _calculateConsistencyProgress(HealthDataProvider healthData) {
    final totalEntries = healthData.nutritionData.length +
        healthData.exerciseData.length +
        healthData.sleepData.length +
        healthData.moodData.length;
    return (totalEntries / 7).clamp(0.0, 1.0);
  }

  String _getConsistencyRemaining(HealthDataProvider healthData) {
    final totalEntries = healthData.nutritionData.length +
        healthData.exerciseData.length +
        healthData.sleepData.length +
        healthData.moodData.length;
    final remaining = 7 - totalEntries;
    return remaining > 0 ? '$remaining days left' : 'Consistent!';
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

class _OverallProgressCard extends StatelessWidget {
  final HealthDataProvider healthData;

  const _OverallProgressCard({required this.healthData});

  @override
  Widget build(BuildContext context) {
    final overallProgress = _calculateOverallProgress();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.purple[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A5A98).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Color(0xFF3A5A98),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Health Score',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getProgressMessage(overallProgress),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(overallProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A5A98),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: overallProgress,
                backgroundColor: Colors.grey[200],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF3A5A98)),
                minHeight: 8,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start of week',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'End of week',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateOverallProgress() {
    final nutritionProgress = healthData.nutritionData.isNotEmpty ? 0.3 : 0.0;
    final exerciseProgress = healthData.exerciseData.isNotEmpty ? 0.3 : 0.0;
    final sleepProgress = healthData.sleepData.isNotEmpty ? 0.2 : 0.0;
    final moodProgress = healthData.moodData.isNotEmpty ? 0.2 : 0.0;

    return nutritionProgress + exerciseProgress + sleepProgress + moodProgress;
  }

  String _getProgressMessage(double progress) {
    if (progress >= 0.8) return 'Excellent progress this week!';
    if (progress >= 0.6) return 'Good progress, keep it up!';
    if (progress >= 0.4) return 'Making steady progress';
    if (progress >= 0.2) return 'Getting started';
    return 'Begin your health journey';
  }
}

class _CategoryProgressCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double progress;
  final String current;
  final String target;
  final String unit;
  final List<String> achievements;

  const _CategoryProgressCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.progress,
    required this.current,
    required this.target,
    required this.unit,
    required this.achievements,
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
                        '$current / $target $unit',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
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
            if (achievements.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: achievements.map((achievement) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      achievement,
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String date;
  final Color color;

  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
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
            Text(
              date,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final double progress;
  final String remaining;
  final Color color;

  const _MilestoneCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.remaining,
    required this.color,
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                Text(
                  remaining,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
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
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
