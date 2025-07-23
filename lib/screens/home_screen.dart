import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthData = Provider.of<HealthDataProvider>(context);
    final user = Provider.of<AuthProvider>(context, listen: true).user;
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
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 36, color: Color(0xFF3A5A98)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user != null
                            ? 'Welcome, ${user.displayName.isNotEmpty ? user.displayName : user.username}'
                            : 'Welcome!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your health at a glance',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _SectionHeader(title: 'Today'),
            const SizedBox(height: 12),
            _SummaryCard(
              icon: _getMoodIcon(healthData.moodData),
              color: _getMoodColor(healthData.moodData),
              title: 'Mood',
              value: _getMoodValue(healthData.moodData),
              subtitle: _getMoodSubtitle(healthData.moodData),
            ),
            const SizedBox(height: 18),
            _SummaryCard(
              icon: CupertinoIcons.bed_double_fill,
              color: Colors.indigo,
              title: 'Sleep',
              value: healthData.sleepData.isNotEmpty
                  ? '${healthData.sleepData.last.hours}h'
                  : '--',
              subtitle: 'Last night',
            ),
            const SizedBox(height: 18),
            _SummaryCard(
              icon: _getExerciseIcon(healthData.exerciseData),
              color: _getExerciseColor(healthData.exerciseData),
              title: 'Exercise',
              value: _getExerciseValue(healthData.exerciseData),
              subtitle: _getExerciseSubtitle(healthData.exerciseData),
            ),
            const SizedBox(height: 18),
            _SummaryCard(
              icon: Icons.eco,
              color: Colors.green,
              title: 'Nutrition',
              value: _getNutritionValue(healthData.nutritionData),
              subtitle: _getNutritionSubtitle(healthData.nutritionData),
            ),
            const SizedBox(height: 30),

            // Debug section to show actual data
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Debug Info',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Text('Mood Data Count: ${healthData.moodData.length}'),
                    if (healthData.moodData.isNotEmpty)
                      Text('Latest Mood: ${healthData.moodData.last.mood}'),
                    const SizedBox(height: 8),
                    Text('Sleep Data Count: ${healthData.sleepData.length}'),
                    if (healthData.sleepData.isNotEmpty)
                      Text('Latest Sleep: ${healthData.sleepData.last.hours}h'),
                    const SizedBox(height: 8),
                    Text(
                        'Exercise Data Count: ${healthData.exerciseData.length}'),
                    if (healthData.exerciseData.isNotEmpty)
                      Text(
                          'Latest Exercise: ${healthData.exerciseData.last.type}'),
                    const SizedBox(height: 8),
                    Text(
                        'Nutrition Data Count: ${healthData.nutritionData.length}'),
                    if (healthData.nutritionData.isNotEmpty)
                      Text(
                          'Latest Nutrition: ${healthData.nutritionData.last.foodItem}'),
                    const SizedBox(height: 12),
                    Text('Provider Initialized: ${healthData.isInitialized}'),
                    Text('Provider Loading: ${healthData.isLoading}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  IconData _getMoodIcon(List moodData) {
    if (moodData.isEmpty) return CupertinoIcons.heart_fill;

    final latestMood = moodData.last.mood.toLowerCase();
    switch (latestMood) {
      case 'happy':
      case 'excited':
      case 'grateful':
        return CupertinoIcons.smiley_fill;
      case 'relaxed':
        return CupertinoIcons.moon_fill;
      case 'sad':
      case 'lonely':
        return CupertinoIcons.heart_slash_fill;
      case 'angry':
      case 'frustrated':
        return CupertinoIcons.flame_fill;
      case 'stressed':
      case 'anxious':
      case 'overwhelmed':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'tired':
        return CupertinoIcons.zzz;
      default:
        return CupertinoIcons.heart_fill;
    }
  }

  Color _getMoodColor(List moodData) {
    if (moodData.isEmpty) return Colors.redAccent;

    final latestMood = moodData.last.mood.toLowerCase();
    switch (latestMood) {
      case 'happy':
      case 'excited':
      case 'grateful':
        return Colors.green;
      case 'relaxed':
        return Colors.teal;
      case 'sad':
      case 'lonely':
        return Colors.blue[800]!;
      case 'angry':
      case 'frustrated':
        return Colors.red;
      case 'stressed':
      case 'anxious':
        return Colors.orange[800]!;
      case 'overwhelmed':
        return Colors.deepOrange;
      case 'tired':
        return Colors.grey;
      default:
        return Colors.redAccent;
    }
  }

  String _getMoodValue(List moodData) {
    if (moodData.isEmpty) return '--';

    final latestMood = moodData.last.mood;
    final emoji = _getMoodEmoji(latestMood);
    return '$emoji $latestMood';
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'excited':
        return '🤩';
      case 'grateful':
        return '🙏';
      case 'relaxed':
        return '😌';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'stressed':
        return '😰';
      case 'anxious':
        return '😟';
      case 'frustrated':
        return '😤';
      case 'tired':
        return '😴';
      case 'lonely':
        return '😔';
      case 'overwhelmed':
        return '😵';
      default:
        return '😊';
    }
  }

  String _getMoodSubtitle(List moodData) {
    if (moodData.isEmpty) return 'No mood recorded';

    final latestMood = moodData.last.mood.toLowerCase();
    switch (latestMood) {
      case 'happy':
      case 'excited':
      case 'grateful':
        return 'Keep shining! ✨';
      case 'relaxed':
        return 'Stay peaceful 🌸';
      case 'sad':
      case 'lonely':
        return 'You\'re not alone 💙';
      case 'angry':
      case 'frustrated':
        return 'Take a deep breath 🌬️';
      case 'stressed':
      case 'anxious':
      case 'overwhelmed':
        return 'One step at a time 🌱';
      case 'tired':
        return 'Rest when you need 💤';
      default:
        return 'Latest mood';
    }
  }

  IconData _getExerciseIcon(List exerciseData) {
    if (exerciseData.isEmpty) return CupertinoIcons.flame_fill;

    final latestExercise = exerciseData.last.type.toLowerCase();
    switch (latestExercise) {
      case 'cardio':
        return CupertinoIcons.heart_fill;
      case 'strength':
        return CupertinoIcons.bolt_fill;
      case 'flexibility':
        return CupertinoIcons.hand_draw_fill;
      case 'balance':
        return CupertinoIcons.person_fill;
      default:
        return CupertinoIcons.flame_fill;
    }
  }

  Color _getExerciseColor(List exerciseData) {
    if (exerciseData.isEmpty) return Colors.orange;

    final latestExercise = exerciseData.last.type.toLowerCase();
    switch (latestExercise) {
      case 'cardio':
        return Colors.red;
      case 'strength':
        return Colors.blue;
      case 'flexibility':
        return Colors.purple;
      case 'balance':
        return Colors.teal;
      default:
        return Colors.orange;
    }
  }

  String _getExerciseValue(List exerciseData) {
    if (exerciseData.isEmpty) return '--';

    final latestExercise = exerciseData.last;
    final emoji = _getExerciseEmoji(latestExercise.type);
    return '$emoji ${latestExercise.formattedDuration}';
  }

  String _getExerciseEmoji(String exerciseType) {
    switch (exerciseType.toLowerCase()) {
      case 'cardio':
        return '🏃‍♀️';
      case 'strength':
        return '💪';
      case 'flexibility':
        return '🧘‍♀️';
      case 'yoga':
        return '🧘';
      case 'balance':
        return '⚖️';
      case 'sports':
        return '⚽';
      default:
        return '🏋️‍♀️';
    }
  }

  String _getExerciseSubtitle(List exerciseData) {
    if (exerciseData.isEmpty) return 'No exercise recorded';

    final latestExercise = exerciseData.last;
    if (latestExercise.achieved == true) {
      return 'Goal achieved! 🎉';
    } else if (latestExercise.achieved == false) {
      return 'Keep pushing! 💪';
    } else {
      return 'Latest session';
    }
  }

  String _getNutritionValue(List nutritionData) {
    if (nutritionData.isEmpty) return '--';

    final latestNutrition = nutritionData.last;
    return '${latestNutrition.calories} kcal';
  }

  String _getNutritionSubtitle(List nutritionData) {
    if (nutritionData.isEmpty) return 'No nutrition recorded';

    return 'Latest meal';
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

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 6),
                Text(value,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: color)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
