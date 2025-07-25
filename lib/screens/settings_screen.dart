import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_data_provider.dart';
import '../models/sleep.dart';
import '../models/mood.dart';
import '../models/exercise.dart';
import '../models/nutrition.dart';
import '../settings/database_service.dart';
import '../settings/shared_preferences_service.dart';
import 'splash_login_screen.dart';
import 'profile_screen.dart';
import 'sync_data_screen.dart';
import 'about_screen.dart';
import 'main_navigation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {  //after frame is built 
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),//goes back 
        ),
        title: const Text(
          'Settings',
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
          child: Consumer2<AuthProvider, HealthDataProvider>(
            builder: (context, authProvider, healthDataProvider, child) {
              // Force rebuild when auth provider changes
              final user = authProvider.user;
              return ListView(
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
                        child: const Icon(Icons.settings,
                            color: Color(0xFF3A5A98), size: 32),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _SectionHeader(title: 'Data Management'),
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
                          _SettingsItem(
                            icon: Icons.sync,
                            title: 'Sync Status',
                            subtitle: healthDataProvider.isInitialized
                                ? 'Data synchronized'
                                : 'Synchronizing...',
                            trailing: healthDataProvider.isInitialized
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : const CircularProgressIndicator(),
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.cloud_sync,
                            title: 'Sync with Cloud',
                            subtitle: 'Upload and download data from Firebase',
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              if (authProvider.user != null) {
                                try {
                                  // Show loading dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const AlertDialog(
                                      title: Text('Syncing with Cloud'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 16),//creating space 
                                          Text('Syncing data with Firebase...'),
                                        ],
                                      ),
                                    ),
                                  );

                                  final userId = authProvider.user!.uid;
                                  final databaseService = DatabaseService();

                                  //  Download all data from Firebase
                                  await healthDataProvider
                                      .refreshAllData(userId);

                                  //  Upload all local data to Firebase
                                  for (final nutrition
                                      in healthDataProvider.nutritionData) {
                                    await databaseService.addNutritionData(
                                        nutrition, userId);
                                  } //loop through exercise 
                                  for (final exercise
                                      in healthDataProvider.exerciseData) {
                                    await databaseService.addExerciseData(
                                        exercise, userId);
                                  }
                                  for (final sleep
                                      in healthDataProvider.sleepData) {
                                    await databaseService.addSleepData(
                                        sleep, userId);
                                  }
                                  for (final mood
                                      in healthDataProvider.moodData) {
                                    await databaseService.addMoodData(
                                        mood, userId);
                                  }

                                  // Save to local storage
                                  await healthDataProvider
                                      .syncWithFirebase(userId);

                                  // Close loading dialog
                                  if (context.mounted) {
                                    Navigator.pop(context);

                                    final totalRecords = healthDataProvider
                                            .nutritionData.length +
                                        healthDataProvider.exerciseData.length +
                                        healthDataProvider.sleepData.length +
                                        healthDataProvider.moodData.length;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Data synced successfully! Total records: $totalRecords'),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // Close loading dialog
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Sync failed: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please log in to sync data.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.sync,
                            title: 'Sync Data',
                            subtitle: 'Manage data synchronization',
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SyncDataScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.storage,
                            title: 'Local Storage',
                            subtitle: 'Data stored locally for offline access',
                            trailing: const Icon(Icons.info_outline),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Local Storage'),
                                  content: const Text(
                                    'Your health data is automatically saved locally on your device for offline access. '
                                    'This ensures you can view and add data even without an internet connection.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.bug_report,
                            title: 'Add Test Data',
                            subtitle: 'Add sample data for testing',
                            trailing: const Icon(Icons.add_circle),
                            onTap: () async {
                              if (authProvider.user != null) {
                                try {
                                  await healthDataProvider
                                      .addTestData(authProvider.user!.uid);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Test data added successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to add test data: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.science,
                            title: 'Test Individual Functions',
                            subtitle: 'Test each data type separately',
                            trailing: const Icon(Icons.play_arrow),
                            onTap: () async {
                              if (authProvider.user != null) {
                                await _testIndividualFunctions(
                                    authProvider.user!.uid, healthDataProvider);
                              }
                            },
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.backup,
                            title: 'Create Backup',
                            subtitle: 'Save all data to database and cloud',
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              if (authProvider.user != null) {
                                await _createBackup(
                                    authProvider.user!.uid, healthDataProvider);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please log in to create a backup'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _SectionHeader(title: 'Data Summary'),
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
                          _DataSummaryItem(
                            icon: Icons.restaurant,
                            title: 'Nutrition Entries',
                            count: healthDataProvider.nutritionData.length,
                            color: Colors.green,
                          ),
                          const Divider(),
                          _DataSummaryItem(
                            icon: Icons.fitness_center,
                            title: 'Exercise Sessions',
                            count: healthDataProvider.exerciseData.length,
                            color: Colors.orange,
                          ),
                          const Divider(),
                          _DataSummaryItem(
                            icon: Icons.bedtime,
                            title: 'Sleep Records',
                            count: healthDataProvider.sleepData.length,
                            color: Colors.indigo,
                          ),
                          const Divider(),
                          _DataSummaryItem(
                            icon: Icons.mood,
                            title: 'Mood Entries',
                            count: healthDataProvider.moodData.length,
                            color: Colors.pink,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _SectionHeader(title: 'Account'),
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
                          _SettingsItem(
                            icon: Icons.person,
                            title: 'Profile',
                            subtitle: user?.email ?? 'Not logged in',
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.delete_forever,
                            title: 'Clear All Data',
                            subtitle: 'Delete all local data permanently',
                            trailing:
                                const Icon(Icons.delete, color: Colors.orange),
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Clear All Data'),
                                  content: const Text(
                                    'Are you sure you want to clear all local data? This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.orange),
                                      child: const Text('Clear Data'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                try {
                                  await healthDataProvider.clearAllData();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'All data cleared successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to clear data: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.logout,
                            title: 'Sign Out',
                            subtitle: 'Log out and clear local data',
                            trailing: const Icon(Icons.exit_to_app,
                                color: Colors.red),
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Sign Out'),
                                  content: const Text(
                                    'Are you sure you want to sign out? Your data will remain saved in the cloud.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Sign Out'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await authProvider.signOut();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const SplashLoginScreen()),
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _SectionHeader(title: 'Navigation'),
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
                          _SettingsItem(
                            icon: Icons.home,
                            title: 'Back to Main',
                            subtitle: 'Return to the main dashboard',
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Navigate back to the main navigation screen
                              // This will take you to the home screen (index 0)
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MainNavigationScreen(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _SectionHeader(title: 'App Information'),
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
                          _SettingsItem(
                            icon: Icons.info_outline,
                            title: 'About HealthTrack360',
                            subtitle: 'Your comprehensive health companion',
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.star,
                            title: 'Version',
                            subtitle: '1.0.0',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Latest',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.privacy_tip,
                            title: 'Privacy Policy',
                            subtitle: 'How we protect your data',
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _showPrivacyDialog(context),
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            subtitle: 'Get help with using the app',
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _showHelpDialog(context),
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.favorite,
                            title: 'Rate App',
                            subtitle: 'Help us improve with your feedback',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                  5,
                                  (index) => Icon(Icons.star,
                                      color: Colors.amber, size: 16)),
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Thank you for your feedback! ⭐'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'Your privacy is our top priority. We collect and process your health data '
          'to provide you with personalized health insights and ensure the security '
          'of your data. All data is encrypted and stored securely in the cloud. '
          'We do not share your data with third parties without your explicit consent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'If you need assistance or have questions about HealthTrack360, '
          'please feel free to contact our support team. '
          'We are here to help you make the most out of your health tracking experience.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _testIndividualFunctions(
      String userId, HealthDataProvider healthDataProvider) async {
    print('=== Testing Individual Functions ===');

    try {
      // Test sleep data
      print('Testing sleep data...');
      final testSleep = Sleep(
        id: 'test_sleep_individual_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now().toIso8601String(),
        hours: 7,
      );
      await healthDataProvider.addSleepData(testSleep, userId);
      print('Sleep data test completed');

      // Test mood data
      print('Testing mood data...');
      final testMood = Mood(
        id: 'test_mood_individual_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now().toIso8601String(),
        mood: 'Excited',
      );
      await healthDataProvider.addMoodData(testMood, userId);
      print('Mood data test completed');

      // Test exercise data
      print('Testing exercise data...');
      final testExercise = Exercise(
        id: 'test_exercise_individual_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now().toIso8601String(),
        type: 'strength',
        duration: 45,
        targetDuration: 30,
        achieved: true,
        specificExercise: 'Push-ups',
        notes: 'Individual test',
      );
      await healthDataProvider.addExerciseData(testExercise, userId);
      print('Exercise data test completed');

      // Test nutrition data
      print('Testing nutrition data...');
      final testNutrition = Nutrition(
        id: 'test_nutrition_individual_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now().toIso8601String(),
        foodItem: 'Test Apple',
        calories: 80,
      );
      await healthDataProvider.addNutritionData(testNutrition, userId);
      print('Nutrition data test completed');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'All individual function tests completed! Check console for details.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('Error in individual function test: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Individual function test failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Creates a comprehensive backup of all user data
  /// This method saves all health data to both local database and Firestore
  /// It provides detailed feedback about the backup process
  Future<void> _createBackup(
      String userId, HealthDataProvider healthDataProvider) async {
    print('=== Creating Backup ===');
    print('User ID: $userId');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Creating Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Saving all data to database and cloud...'),
          ],
        ),
      ),
    );

    try {
      // Step 1: Save all current data to local database
      print('Step 1: Saving to local database...');
      await healthDataProvider.syncWithFirebase(userId);
      print('✓ Local database backup completed');

      // Step 2: Save all data to Firestore
      print('Step 2: Saving to Firestore...');
      await _saveAllDataToFirestore(userId, healthDataProvider);
      print('✓ Firestore backup completed');

      // Step 3: Update shared preferences with latest data
      print('Step 3: Updating cached data...');
      await _updateSharedPreferences(healthDataProvider);
      print('✓ Shared preferences updated');

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);

        // Show success message with backup summary
        final totalRecords = healthDataProvider.nutritionData.length +
            healthDataProvider.exerciseData.length +
            healthDataProvider.sleepData.length +
            healthDataProvider.moodData.length;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Backup completed successfully!\n'
              'Total records saved: $totalRecords',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      print('=== Backup completed successfully ===');
    } catch (e) {
      print('Error creating backup: $e');

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Saves all health data to Firestore
  /// This method handles each data type separately and provides detailed logging
  Future<void> _saveAllDataToFirestore(
      String userId, HealthDataProvider healthDataProvider) async {
    final databaseService = DatabaseService();

    try {
      // Save nutrition data
      print(
          'Saving ${healthDataProvider.nutritionData.length} nutrition records...');
      for (final nutrition in healthDataProvider.nutritionData) {
        await databaseService.addNutritionData(nutrition, userId);
      }
      print('✓ Nutrition data saved to Firestore');

      // Save exercise data
      print(
          'Saving ${healthDataProvider.exerciseData.length} exercise records...');
      for (final exercise in healthDataProvider.exerciseData) {
        await databaseService.addExerciseData(exercise, userId);
      }
      print('✓ Exercise data saved to Firestore');

      // Save sleep data
      print('Saving ${healthDataProvider.sleepData.length} sleep records...');
      for (final sleep in healthDataProvider.sleepData) {
        await databaseService.addSleepData(sleep, userId);
      }
      print('✓ Sleep data saved to Firestore');

      // Save mood data
      print('Saving ${healthDataProvider.moodData.length} mood records...');
      for (final mood in healthDataProvider.moodData) {
        await databaseService.addMoodData(mood, userId);
      }
      print('✓ Mood data saved to Firestore');
    } catch (e) {
      print('Error saving to Firestore: $e');
      rethrow;
    }
  }

  /// Updates shared preferences with the latest data for quick access
  Future<void> _updateSharedPreferences(
      HealthDataProvider healthDataProvider) async {
    final sharedPrefsService = SharedPreferencesService();

    try {
      // Update latest nutrition data
      if (healthDataProvider.nutritionData.isNotEmpty) {
        final latestNutrition = healthDataProvider.nutritionData.last;
        await sharedPrefsService.saveLatestNutrition(
          latestNutrition.foodItem,
          latestNutrition.calories,
          latestNutrition.date,
        );
      }

      // Update latest exercise data
      if (healthDataProvider.exerciseData.isNotEmpty) {
        final latestExercise = healthDataProvider.exerciseData.last;
        await sharedPrefsService.saveLatestExercise(
          latestExercise.type,
          latestExercise.duration,
          latestExercise.specificExercise,
          latestExercise.achieved,
        );
      }

      // Update latest sleep data
      if (healthDataProvider.sleepData.isNotEmpty) {
        final latestSleep = healthDataProvider.sleepData.last;
        await sharedPrefsService.saveLatestSleep(
          latestSleep.hours,
          latestSleep.date,
        );
      }

      // Update latest mood data
      if (healthDataProvider.moodData.isNotEmpty) {
        final latestMood = healthDataProvider.moodData.last;
        await sharedPrefsService.saveLatestMood(
          latestMood.mood,
          latestMood.date,
        );
      }

      // Update data counts
      await sharedPrefsService.saveDataCounts(
        healthDataProvider.moodData.length,
        healthDataProvider.sleepData.length,
        healthDataProvider.exerciseData.length,
        healthDataProvider.nutritionData.length,
      );
    } catch (e) {
      print('Error updating shared preferences: $e');
      // Don't rethrow - this is not critical for backup
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

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3A5A98), size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _DataSummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;

  const _DataSummaryItem({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
