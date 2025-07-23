import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'nutrition_screen.dart';
import 'exercise_screen.dart';
import 'sleep_screen.dart';
import 'mood_screen.dart';
import 'goals_screen.dart';
import 'trends_screen.dart';
import 'settings_screen.dart';
import '/widgets/health_card.dart';
import '/screens/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthTrack360'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          HealthCard(
              title: 'Nutrition',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NutritionScreen()))),
          HealthCard(
              title: 'Exercise',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ExerciseScreen()))),
          HealthCard(
              title: 'Sleep',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SleepScreen()))),
          HealthCard(
              title: 'Mood',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MoodScreen()))),
          HealthCard(
              title: 'Goals',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GoalsScreen()))),
          HealthCard(
              title: 'Trends',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TrendsScreen()))),
          HealthCard(
              title: 'Settings',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ],
      ),
    );
  }
}
