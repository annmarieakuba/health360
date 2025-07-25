import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import 'home_screen.dart';
import 'nutrition_screen.dart';
import 'exercise_screen.dart';
import 'sleep_screen.dart';
import 'mood_screen.dart';
import 'goals_screen.dart';
import 'trends_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'sync_data_screen.dart';
import 'about_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0; //selected tab index

  static final List<Widget> _screens = [
    const HomeScreen(),
    const NutritionScreen(),
    const ExerciseScreen(),
    const SleepScreen(),
    const MoodScreen(),
    const GoalsScreen(),
    const TrendsScreen(),
    const ProgressScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthDataProvider>(
      //listen to changes
      builder: (context, healthDataProvider, child) {
        // Show loading screen while data is being initialized
        if (!healthDataProvider.isInitialized && healthDataProvider.isLoading) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3A5A98), Color(0xFF4FC3F7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 24),
                    Text(
                      'Loading your health data...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This may take a moment',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show main navigation once data is loaded
        return Scaffold(
          drawer: _ProfileDrawer(),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0, //no shadow
            leading: Builder(
              //menu button builder
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFF3A5A98)),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text(
              _getTitle(_selectedIndex),
              style: const TextStyle(
                color: Color(0xFF3A5A98),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: false,
            actions: [
              // Add refresh button
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF3A5A98)),
                onPressed: () async {
                  final authProvider = Provider.of<app_auth.AuthProvider>(
                      context,
                      listen: false);
                  if (authProvider.user != null) {
                    //user is loged in or not
                    await healthDataProvider //refresh all health data
                        .refreshAllData(authProvider.user!.uid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      //show a success message
                      const SnackBar(content: Text('Data refreshed!')),
                    );
                  }
                },
              ),
            ],
          ),
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF3A5A98),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant),
                label: 'Nutrition',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                label: 'Exercise',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bedtime),
                label: 'Sleep',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mood),
                label: 'Mood',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flag),
                label: 'Goals',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up),
                label: 'Trends',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                label: 'Progress',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Nutrition';
      case 2:
        return 'Exercise';
      case 3:
        return 'Sleep';
      case 4:
        return 'Mood';
      case 5:
        return 'Goals';
      case 6:
        return 'Trends';
      case 7:
        return 'Progress';
      case 8:
        return 'Settings';
      default:
        return '';
    }
  }
}

class _ProfileDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<app_auth.AuthProvider, HealthDataProvider>(
      builder: (context, authProvider, healthDataProvider, child) {
        final user = authProvider.user;

        return Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: const Color(0xFF3A5A98),
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 50, color: Color(0xFF3A5A98)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.displayName.isNotEmpty == true
                            ? user!.displayName
                            : user?.username ?? 'User',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'user@email.com',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_sync),
                  title: const Text('Sync Data'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SyncDataScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
                const Spacer(),
                const Divider(),
                ListTile(
                  leading:
                      const Icon(Icons.delete_forever, color: Colors.orange),
                  title: const Text('Clear All Data',
                      style: TextStyle(color: Colors.orange)),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _showClearDataDialog(context, healthDataProvider);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Log out',
                      style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _showLogoutDialog(
                        context, authProvider, healthDataProvider);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLogoutDialog(
      BuildContext context,
      app_auth.AuthProvider authProvider,
      HealthDataProvider healthDataProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
            'Are you sure you want to log out? Your data will remain saved in the cloud.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.signOut();
      // Navigation is handled by AuthWrapper
    }
  }

  Future<void> _showClearDataDialog(
      BuildContext context, HealthDataProvider healthDataProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
            'Are you sure you want to clear all your health data? This action cannot be undone and will remove all your nutrition, exercise, sleep, and mood records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All Data',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await healthDataProvider.clearAllData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
