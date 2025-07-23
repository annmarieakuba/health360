import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '/providers/auth_provider.dart';
import '../providers/health_data_provider.dart';
import '../models/mood.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({Key? key}) : super(key: key);

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String? selectedEmotion;
  String motivationalContent = '';
  bool isLoadingMotivation = false;

  final List<Map<String, dynamic>> emotions = [
    {'name': 'Happy', 'emoji': '😊', 'color': Colors.green},
    {'name': 'Excited', 'emoji': '🤩', 'color': Colors.orange},
    {'name': 'Grateful', 'emoji': '🙏', 'color': Colors.blue},
    {'name': 'Relaxed', 'emoji': '😌', 'color': Colors.teal},
    {'name': 'Sad', 'emoji': '😢', 'color': Colors.blue[800]},
    {'name': 'Angry', 'emoji': '😠', 'color': Colors.red},
    {'name': 'Stressed', 'emoji': '😰', 'color': Colors.orange[800]},
    {'name': 'Anxious', 'emoji': '😟', 'color': Colors.purple},
    {'name': 'Frustrated', 'emoji': '😤', 'color': Colors.red[700]},
    {'name': 'Tired', 'emoji': '😴', 'color': Colors.grey},
    {'name': 'Lonely', 'emoji': '😔', 'color': Colors.indigo},
    {'name': 'Overwhelmed', 'emoji': '😵', 'color': Colors.deepOrange},
  ];

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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.mood_rounded,
                      color: Color(0xFF3A5A98), size: 32),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Mood',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _SectionHeader(title: 'How are you feeling?'),
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
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select your emotion',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: selectedEmotion != null
                            ? Text(
                                emotions.firstWhere((e) =>
                                    e['name'] == selectedEmotion)['emoji'],
                                style: const TextStyle(fontSize: 24),
                              )
                            : const Icon(Icons.sentiment_satisfied),
                      ),
                      value: selectedEmotion,
                      items: emotions.map((emotion) {
                        return DropdownMenuItem<String>(
                          value: emotion['name'],
                          child: Row(
                            children: [
                              Text(emotion['emoji'],
                                  style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Text(emotion['name'],
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEmotion = value;
                          motivationalContent = '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add Mood',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedEmotion != null
                              ? emotions.firstWhere(
                                  (e) => e['name'] == selectedEmotion)['color']
                              : const Color(0xFF3A5A98),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: selectedEmotion != null
                            ? () => _addMood(healthDataProvider)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (motivationalContent.isNotEmpty) ...[
              const SizedBox(height: 20),
              _MotivationalCard(content: motivationalContent),
            ],
            if (isLoadingMotivation) ...[
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 8,
                color: Colors.white,
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
            const SizedBox(height: 30),
            _SectionHeader(title: 'Recent Mood'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: healthDataProvider.moodData.isEmpty
                    ? const Text('No mood data yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: healthDataProvider.moodData.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final mood = healthDataProvider.moodData[index];
                          final emotion = emotions.firstWhere(
                            (e) =>
                                e['name'].toLowerCase() ==
                                mood.mood.toLowerCase(),
                            orElse: () => {
                              'name': mood.mood,
                              'emoji': '😊',
                              'color': Colors.grey
                            },
                          );
                          return ListTile(
                            leading: Text(emotion['emoji'],
                                style: const TextStyle(fontSize: 32)),
                            title: Text(mood.mood,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(mood.date),
                            trailing: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: emotion['color'],
                                shape: BoxShape.circle,
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

  Future<void> _addMood(HealthDataProvider healthDataProvider) async {
    if (selectedEmotion == null) {
      print('No emotion selected');
      return;
    }

    print('Adding mood: $selectedEmotion');

    try {
      // Check if user is authenticated
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to add mood data'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final mood = Mood(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now().toIso8601String(),
        mood: selectedEmotion!,
      );

      print('Mood object created: ${mood.mood}');

      // Show loading state
      setState(() {
        isLoadingMotivation = true;
      });

      // Check if user is authenticated
      if (authProvider.user == null) {
        throw Exception('User not authenticated');
      }

      // Add mood data (this will update UI immediately and handle Firebase in background)
      await healthDataProvider.addMoodData(mood, authProvider.user!.uid);

      print('Mood data added successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mood "${selectedEmotion!}" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Check if we need to show motivational content
      if (_isNegativeEmotion(selectedEmotion!)) {
        print('Negative emotion detected, showing predefined content');

        // Use predefined motivational content instead of API call
        String content = _getPredefinedContent(selectedEmotion!);

        if (mounted) {
          setState(() {
            motivationalContent = content;
            isLoadingMotivation = false;
          });
        }
      } else {
        print('Positive emotion detected, no motivational content needed');
        if (mounted) {
          setState(() {
            isLoadingMotivation = false;
            motivationalContent = ''; // Clear any previous content
          });
        }
      }

      if (mounted) {
        setState(() {
          selectedEmotion = null;
        });
      }
    } catch (e) {
      print('Error adding mood: $e');
      if (mounted) {
        setState(() {
          isLoadingMotivation = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add mood: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Safety mechanism: always ensure loading state is reset
      if (mounted && isLoadingMotivation) {
        print('Safety reset of loading state');
        setState(() {
          isLoadingMotivation = false;
        });
      }
    }
  }

  bool _isNegativeEmotion(String emotion) {
    final negativeEmotions = [
      'sad',
      'angry',
      'stressed',
      'anxious',
      'frustrated',
      'depressed',
      'lonely',
      'overwhelmed',
      'tired'
    ];
    return negativeEmotions.contains(emotion.toLowerCase());
  }

  String _getPredefinedContent(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'sad':
        return '💙 It\'s okay to feel sad. Remember that this feeling is temporary and you\'re not alone. Take a moment to breathe and be kind to yourself.';
      case 'angry':
        return '🔥 Anger is a natural emotion. Try taking deep breaths or going for a walk to help calm your mind. You have the strength to handle this.';
      case 'stressed':
        return '😌 Stress can be overwhelming, but you\'re stronger than you think. Try breaking tasks into smaller steps and remember to take breaks.';
      case 'anxious':
        return '🫂 Anxiety can feel scary, but you\'re safe. Focus on your breathing - inhale for 4 counts, hold for 4, exhale for 4. You\'ve got this.';
      case 'frustrated':
        return '💪 Frustration is a sign that you care. Take a step back, maybe try a different approach. Every challenge makes you stronger.';
      case 'lonely':
        return '🤗 You are loved and valued, even if it doesn\'t feel like it right now. Reach out to someone you trust, or treat yourself with kindness.';
      case 'overwhelmed':
        return '🌊 When everything feels too much, remember: one step at a time. You don\'t have to figure everything out right now. Just breathe.';
      case 'tired':
        return '😴 Rest is not a sign of weakness, it\'s essential for your well-being. Listen to your body and give yourself permission to rest.';
      default:
        return '💙 Remember, every emotion is valid. Take care of yourself today.';
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

class _MotivationalCard extends StatelessWidget {
  final String content;
  const _MotivationalCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.pink[50]!, Colors.purple[50]!],
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
                  Icon(Icons.favorite, color: Colors.pink[400], size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Something to brighten your day',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
