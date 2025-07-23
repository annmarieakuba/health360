import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_data_provider.dart';
import '../settings/database_service.dart';

class SyncDataScreen extends StatefulWidget {
  const SyncDataScreen({Key? key}) : super(key: key);

  @override
  State<SyncDataScreen> createState() => _SyncDataScreenState();
}

class _SyncDataScreenState extends State<SyncDataScreen> {
  bool _isSyncing = false;
  String _syncStatus = 'Ready to sync';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Data'),
        backgroundColor: const Color(0xFF3A5A98),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A5A98), Color(0xFF4FC3F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer2<AuthProvider, HealthDataProvider>(
          builder: (context, authProvider, healthDataProvider, child) {
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 20),

                  // Sync Status Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            'Sync Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A5A98),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(
                                healthDataProvider.isInitialized
                                    ? Icons.cloud_done
                                    : Icons.cloud_off,
                                color: healthDataProvider.isInitialized
                                    ? Colors.green
                                    : Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      healthDataProvider.isInitialized
                                          ? 'Connected to Cloud'
                                          : 'Not Connected',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _syncStatus,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sync Actions Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sync Actions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A5A98),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _SyncActionItem(
                            icon: Icons.cloud_upload,
                            title: 'Upload to Cloud',
                            subtitle: 'Upload local data to Firebase',
                            onTap: _isSyncing
                                ? null
                                : () => _uploadToCloud(
                                    context, authProvider, healthDataProvider),
                            isLoading: _isSyncing,
                          ),
                          const Divider(),
                          _SyncActionItem(
                            icon: Icons.cloud_download,
                            title: 'Download from Cloud',
                            subtitle: 'Download data from Firebase',
                            onTap: _isSyncing
                                ? null
                                : () => _downloadFromCloud(
                                    context, authProvider, healthDataProvider),
                            isLoading: _isSyncing,
                          ),
                          const Divider(),
                          _SyncActionItem(
                            icon: Icons.sync,
                            title: 'Full Sync',
                            subtitle: 'Sync all data bidirectionally',
                            onTap: _isSyncing
                                ? null
                                : () => _fullSync(
                                    context, authProvider, healthDataProvider),
                            isLoading: _isSyncing,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Data Summary Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Local Data Summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A5A98),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _DataSummaryItem(
                            icon: Icons.restaurant,
                            title: 'Nutrition',
                            count: healthDataProvider.nutritionData.length,
                            color: Colors.green,
                          ),
                          const Divider(),
                          _DataSummaryItem(
                            icon: Icons.fitness_center,
                            title: 'Exercise',
                            count: healthDataProvider.exerciseData.length,
                            color: Colors.orange,
                          ),
                          const Divider(),
                          _DataSummaryItem(
                            icon: Icons.bedtime,
                            title: 'Sleep',
                            count: healthDataProvider.sleepData.length,
                            color: Colors.indigo,
                          ),
                          const Divider(),
                          _DataSummaryItem(
                            icon: Icons.mood,
                            title: 'Mood',
                            count: healthDataProvider.moodData.length,
                            color: Colors.pink,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sync Settings Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sync Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A5A98),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _SettingsItem(
                            icon: Icons.auto_awesome,
                            title: 'Auto Sync',
                            subtitle: 'Automatically sync data in background',
                            trailing: Switch(
                              value: false, // TODO: Implement auto sync setting
                              onChanged: (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Auto sync will be implemented in a future update.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.wifi,
                            title: 'Sync on WiFi Only',
                            subtitle: 'Only sync when connected to WiFi',
                            trailing: Switch(
                              value: true, // TODO: Implement WiFi-only setting
                              onChanged: (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'WiFi-only sync will be implemented in a future update.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _uploadToCloud(BuildContext context, AuthProvider authProvider,
      HealthDataProvider healthDataProvider) async {
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to sync data.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncStatus = 'Uploading data to Firebase...';
    });

    try {
      final userId = authProvider.user!.uid;
      final databaseService = DatabaseService();

      // Upload nutrition data
      setState(() {
        _syncStatus = 'Uploading nutrition data...';
      });
      for (final nutrition in healthDataProvider.nutritionData) {
        await databaseService.addNutritionData(nutrition, userId);
      }

      // Upload exercise data
      setState(() {
        _syncStatus = 'Uploading exercise data...';
      });
      for (final exercise in healthDataProvider.exerciseData) {
        await databaseService.addExerciseData(exercise, userId);
      }

      // Upload sleep data
      setState(() {
        _syncStatus = 'Uploading sleep data...';
      });
      for (final sleep in healthDataProvider.sleepData) {
        await databaseService.addSleepData(sleep, userId);
      }

      // Upload mood data
      setState(() {
        _syncStatus = 'Uploading mood data...';
      });
      for (final mood in healthDataProvider.moodData) {
        await databaseService.addMoodData(mood, userId);
      }

      setState(() {
        _syncStatus = 'Upload completed successfully!';
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Data uploaded successfully! Total records: ${healthDataProvider.nutritionData.length + healthDataProvider.exerciseData.length + healthDataProvider.sleepData.length + healthDataProvider.moodData.length}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _syncStatus = 'Upload failed: $e';
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _downloadFromCloud(BuildContext context,
      AuthProvider authProvider, HealthDataProvider healthDataProvider) async {
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to sync data.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncStatus = 'Downloading data from Firebase...';
    });

    try {
      final userId = authProvider.user!.uid;

      // Download all data from Firebase
      setState(() {
        _syncStatus = 'Downloading nutrition data...';
      });
      await healthDataProvider.fetchNutritionData(userId);

      setState(() {
        _syncStatus = 'Downloading exercise data...';
      });
      await healthDataProvider.fetchExerciseData(userId);

      setState(() {
        _syncStatus = 'Downloading sleep data...';
      });
      await healthDataProvider.fetchSleepData(userId);

      setState(() {
        _syncStatus = 'Downloading mood data...';
      });
      await healthDataProvider.fetchMoodData(userId);

      setState(() {
        _syncStatus = 'Download completed successfully!';
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Data downloaded successfully! Total records: ${healthDataProvider.nutritionData.length + healthDataProvider.exerciseData.length + healthDataProvider.sleepData.length + healthDataProvider.moodData.length}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _syncStatus = 'Download failed: $e';
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _fullSync(BuildContext context, AuthProvider authProvider,
      HealthDataProvider healthDataProvider) async {
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to sync data.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncStatus = 'Performing full sync...';
    });

    try {
      final userId = authProvider.user!.uid;
      final databaseService = DatabaseService();

      // Step 1: Download all data from Firebase
      setState(() {
        _syncStatus = 'Downloading data from Firebase...';
      });
      await healthDataProvider.refreshAllData(userId);

      // Step 2: Upload all local data to Firebase
      setState(() {
        _syncStatus = 'Uploading data to Firebase...';
      });

      // Upload nutrition data
      for (final nutrition in healthDataProvider.nutritionData) {
        await databaseService.addNutritionData(nutrition, userId);
      }

      // Upload exercise data
      for (final exercise in healthDataProvider.exerciseData) {
        await databaseService.addExerciseData(exercise, userId);
      }

      // Upload sleep data
      for (final sleep in healthDataProvider.sleepData) {
        await databaseService.addSleepData(sleep, userId);
      }

      // Upload mood data
      for (final mood in healthDataProvider.moodData) {
        await databaseService.addMoodData(mood, userId);
      }

      // Step 3: Save all data to local storage
      setState(() {
        _syncStatus = 'Saving to local storage...';
      });
      await healthDataProvider.syncWithFirebase(userId);

      setState(() {
        _syncStatus = 'Full sync completed successfully!';
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Full sync completed successfully! Total records: ${healthDataProvider.nutritionData.length + healthDataProvider.exerciseData.length + healthDataProvider.sleepData.length + healthDataProvider.moodData.length}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _syncStatus = 'Full sync failed: $e';
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Full sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }
}

class _SyncActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;

  const _SyncActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: isLoading
          ? const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, color: const Color(0xFF3A5A98), size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
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

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3A5A98), size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}
