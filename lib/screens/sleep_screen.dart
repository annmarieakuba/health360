import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../models/sleep.dart';
import '../providers/auth_provider.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  double sleepHours = 8.0;
  String sleepTip = '';
  bool showTip = false;

  @override
  void initState() {
    super.initState();
    _updateSleepTip();
  }

  void _updateSleepTip() {
    if (sleepHours < 8) {
      final tips = [
        '😴 Adults need 7-9 hours of sleep for optimal health and cognitive function.',
        '🧠 Sleep helps consolidate memories and process information from the day.',
        '💪 During sleep, your body repairs tissues and strengthens your immune system.',
        '⚡ Quality sleep improves focus, decision-making, and reaction times.',
        '❤️ Regular sleep helps regulate blood pressure and reduces heart disease risk.',
        '🏃‍♀️ Well-rested people have more energy for physical activities and exercise.',
        '😊 Adequate sleep helps regulate emotions and reduces stress levels.',
        '🍎 Sleep affects hormones that control hunger - lack of sleep can lead to weight gain.',
        '🌙 Try to maintain a consistent bedtime routine for better sleep quality.',
        '📱 Avoid screens 1 hour before bedtime to improve sleep onset.',
      ];
      tips.shuffle();
      setState(() {
        sleepTip = tips.first;
        showTip = true;
      });
    } else {
      setState(() {
        showTip = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthDataProvider = Provider.of<HealthDataProvider>(context);

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
                  child: const Icon(Icons.bedtime,
                      color: Color(0xFF3A5A98), size: 32),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Sleep',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Sleep Hours Input Card
            _SectionHeader(title: 'Log Your Sleep'),
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
                    // Sleep Hours Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.nightlight_round,
                          color: _getSleepColor(sleepHours),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${sleepHours.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _getSleepColor(sleepHours),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'hours',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Sleep Hours Slider
                    Text(
                      'How many hours did you sleep?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _getSleepColor(sleepHours),
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: _getSleepColor(sleepHours),
                        overlayColor:
                            _getSleepColor(sleepHours).withValues(alpha: 0.2),
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 12),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: sleepHours,
                        min: 0,
                        max: 12,
                        divisions: 24,
                        label: '${sleepHours.toStringAsFixed(1)} hours',
                        onChanged: (value) {
                          setState(() {
                            sleepHours = value;
                          });
                          _updateSleepTip();
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Sleep Quality Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SleepIndicator('0h', Colors.red),
                        _SleepIndicator('4h', Colors.orange),
                        _SleepIndicator('8h', Colors.green),
                        _SleepIndicator('12h', Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Sleep Quality Message
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            _getSleepColor(sleepHours).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _getSleepColor(sleepHours)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _getSleepQualityMessage(sleepHours),
                        style: TextStyle(
                          color: _getSleepColor(sleepHours),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add Sleep Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle, color: Colors.white),
                        label: const Text('Log Sleep',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getSleepColor(sleepHours),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _addSleep(healthDataProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Debug section
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text('Debug Sleep Info',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Text(
                        'Current Sleep Hours: ${sleepHours.toStringAsFixed(1)}'),
                    Text(
                        'Total Sleep Records: ${healthDataProvider.sleepData.length}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        print('Manual test sleep button pressed');
                        await _addSleep(healthDataProvider);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: const Text('Manual Test Sleep Log',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),

            // Sleep Tip Card (shown when sleep < 8 hours)
            if (showTip && sleepTip.isNotEmpty) ...[
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
                      colors: [Colors.indigo[50]!, Colors.purple[50]!],
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
                                color: Colors.indigo[600], size: 28),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Sleep Tip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _updateSleepTip,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          sleepTip,
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
            _SectionHeader(title: 'Recent Sleep'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: healthDataProvider.sleepData.isEmpty
                    ? const Text('No sleep data yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: healthDataProvider.sleepData.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final sleep = healthDataProvider.sleepData[index];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getSleepColor(sleep.hours.toDouble())
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.bedtime,
                                color: _getSleepColor(sleep.hours.toDouble()),
                                size: 24,
                              ),
                            ),
                            title: Text(
                              '${sleep.hours} hours',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(_formatDate(sleep.date)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getSleepColor(sleep.hours.toDouble()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getSleepRating(sleep.hours),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
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

  Future<void> _addSleep(HealthDataProvider healthDataProvider) async {
    print('=== Sleep Button Clicked ===');
    print('Sleep hours: $sleepHours');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('Auth provider: ${authProvider.user?.uid}');

      if (authProvider.user == null) {
        print('ERROR: User not authenticated');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to add sleep data'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('Creating sleep object...');
      final sleep = Sleep(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now().toIso8601String(),
        hours: sleepHours,
      );

      print(
          'Sleep object created: ${sleep.id}, ${sleep.hours}h, ${sleep.date}');
      print('Adding sleep data to provider...');

      // Check if user is authenticated
      if (authProvider.user == null) {
        throw Exception('User not authenticated');
      }

      await healthDataProvider.addSleepData(sleep, authProvider.user!.uid);

      print('Sleep data added successfully!');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sleep logged: ${sleepHours.toStringAsFixed(1)} hours'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset to default
      setState(() {
        sleepHours = 8.0;
      });
      _updateSleepTip();

      print('Sleep logging completed successfully');
    } catch (e) {
      print('ERROR in _addSleep: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log sleep: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getSleepColor(double hours) {
    if (hours < 4) return Colors.red;
    if (hours < 6) return Colors.orange;
    if (hours < 7) return Colors.yellow[700]!;
    if (hours <= 9) return Colors.green;
    if (hours <= 10) return Colors.blue;
    return Colors.purple;
  }

  String _getSleepQualityMessage(double hours) {
    if (hours < 4)
      return '🚨 Severely sleep deprived - This can seriously impact your health!';
    if (hours < 6)
      return '😴 Not enough sleep - You need more rest for optimal function.';
    if (hours < 7)
      return '⚠️ Below recommended - Try to get at least 7-8 hours.';
    if (hours <= 9)
      return '✅ Great! You\'re getting the recommended amount of sleep.';
    if (hours <= 10)
      return '😌 Well rested - Perfect for recovery and performance.';
    return '🛌 Lots of sleep - Make sure you\'re not oversleeping regularly.';
  }

  String _getSleepRating(double hours) {
    if (hours < 4) return 'Poor';
    if (hours < 6) return 'Low';
    if (hours < 7) return 'Fair';
    if (hours <= 9) return 'Good';
    if (hours <= 10) return 'Great';
    return 'Long';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Last night';
      } else if (difference == 1) {
        return 'Previous night';
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

class _SleepIndicator extends StatelessWidget {
  final String label;
  final Color color;
  const _SleepIndicator(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
