import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
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
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 20),

              // App Logo and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 60,
                        color: Color(0xFF3A5A98),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'HealthTrack360',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your Comprehensive Health Companion',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // App Description Card
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
                        'About HealthTrack360',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A5A98),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'HealthTrack360 is your comprehensive health companion designed to help you track and manage your daily health activities. '
                        'With seamless cloud synchronization, offline access, and a user-friendly interface, '
                        'you can always stay on top of your health journey.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Features Card
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
                        'Key Features',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A5A98),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FeatureItem(
                        icon: Icons.restaurant,
                        title: 'Nutrition Tracking',
                        description:
                            'Log your daily meals and track calorie intake',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _FeatureItem(
                        icon: Icons.fitness_center,
                        title: 'Exercise Monitoring',
                        description: 'Record workouts and track fitness goals',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _FeatureItem(
                        icon: Icons.bedtime,
                        title: 'Sleep Analysis',
                        description: 'Monitor sleep patterns and quality',
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 12),
                      _FeatureItem(
                        icon: Icons.mood,
                        title: 'Mood Tracking',
                        description: 'Track your emotional well-being',
                        color: Colors.pink,
                      ),
                      const SizedBox(height: 12),
                      _FeatureItem(
                        icon: Icons.cloud_sync,
                        title: 'Cloud Sync',
                        description: 'Secure data backup and synchronization',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _FeatureItem(
                        icon: Icons.offline_pin,
                        title: 'Offline Access',
                        description: 'Use the app without internet connection',
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Privacy & Security Card
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
                        'Privacy & Security',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A5A98),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your privacy is our top priority. We collect and process your health data '
                        'to provide you with personalized health insights and ensure the security '
                        'of your data. All data is encrypted and stored securely in the cloud. '
                        'We do not share your data with third parties without your explicit consent.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Contact & Support Card
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
                        'Contact & Support',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A5A98),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ContactItem(
                        icon: Icons.email,
                        title: 'Email Support',
                        subtitle: 'support@healthtrack360.com',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Email support will be available soon!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      _ContactItem(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        subtitle: 'Get help with using the app',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Help center will be available soon!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      _ContactItem(
                        icon: Icons.bug_report,
                        title: 'Report a Bug',
                        subtitle: 'Help us improve by reporting issues',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Bug reporting will be available soon!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Legal Information Card
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
                        'Legal Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A5A98),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LegalItem(
                        title: 'Privacy Policy',
                        onTap: () {
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
                        },
                      ),
                      const Divider(),
                      _LegalItem(
                        title: 'Terms of Service',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Terms of Service'),
                              content: const Text(
                                'By using HealthTrack360, you agree to our terms of service. '
                                'The app is provided "as is" without warranties. '
                                'We are not responsible for any health decisions made based on the app data.',
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
                      _LegalItem(
                        title: 'Data Usage',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Data Usage'),
                              content: const Text(
                                'Your health data is used to provide personalized insights and improve the app. '
                                'Data is stored locally and optionally synced to the cloud. '
                                'You can delete your data at any time through the settings.',
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Copyright Card
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
                        '© 2024 HealthTrack360',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3A5A98),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'All rights reserved',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
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
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3A5A98), size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}

class _LegalItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _LegalItem({
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
