import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '../providers/health_data_provider.dart';
import '../models/exercise.dart';
import '../settings/exercise_api_service.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String? selectedExerciseType;
  String? selectedSpecificExercise;
  int targetDuration = 30; // Default 30 minutes
  int actualDuration = 0;
  bool? achieved;
  String achievementMessage = '';
  bool isLoadingMotivation = false;
  List<Map<String, dynamic>> availableExercises = [];

  final exerciseService = ExerciseApiService();
  final notesController = TextEditingController();

  final List<Map<String, dynamic>> exerciseTypes = [
    {
      'name': 'Cardio',
      'value': 'cardio',
      'icon': '🏃‍♀️',
      'color': Colors.orange
    },
    {
      'name': 'Strength',
      'value': 'strength',
      'icon': '💪',
      'color': Colors.red
    },
    {
      'name': 'Flexibility',
      'value': 'flexibility',
      'icon': '🧘‍♀️',
      'color': Colors.purple
    },
    {'name': 'Yoga', 'value': 'yoga', 'icon': '🧘', 'color': Colors.indigo},
    {'name': 'Sports', 'value': 'sports', 'icon': '⚽', 'color': Colors.green},
    {'name': 'Balance', 'value': 'balance', 'icon': '⚖️', 'color': Colors.teal},
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.fitness_center,
                      color: Color(0xFF3A5A98), size: 32),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Exercise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _SectionHeader(title: 'Plan Your Workout'),
            const SizedBox(height: 12),
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
                    // Exercise Type Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Exercise Type',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: selectedExerciseType != null
                            ? Text(
                                exerciseTypes.firstWhere((e) =>
                                    e['value'] == selectedExerciseType)['icon'],
                                style: const TextStyle(fontSize: 24),
                              )
                            : const Icon(Icons.fitness_center),
                      ),
                      value: selectedExerciseType,
                      items: exerciseTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['value'],
                          child: Row(
                            children: [
                              Text(type['icon'],
                                  style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Text(type['name'],
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedExerciseType = value;
                          selectedSpecificExercise = null;
                          availableExercises = [];
                        });
                        if (value != null) {
                          _loadSpecificExercises(value);
                        }
                      },
                    ),
                    if (availableExercises.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Specific Exercise',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.directions_run),
                        ),
                        value: selectedSpecificExercise,
                        isExpanded: true,
                        itemHeight: 90, // Increased from 70 to 90
                        menuMaxHeight:
                            300, // Add maximum height for dropdown menu
                        items: availableExercises.map((exercise) {
                          return DropdownMenuItem<String>(
                            value: exercise['name'],
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 80,
                                maxHeight: 120,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0), // Increased padding
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        exercise['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                15), // Slightly larger font
                                        maxLines: 3, // Increased from 2 to 3
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(
                                        height: 4), // Increased spacing
                                    Flexible(
                                      child: Text(
                                        'Target: ${exercise['muscle']} • ${exercise['difficulty']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color:
                                                Colors.grey), // Slightly larger
                                        maxLines: 2, // Increased from 1 to 2
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSpecificExercise = value;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Duration Slider
                    Text('Target Duration: ${targetDuration} minutes',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: targetDuration.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      activeColor: selectedExerciseType != null
                          ? exerciseTypes.firstWhere((e) =>
                              e['value'] == selectedExerciseType)['color']
                          : const Color(0xFF3A5A98),
                      label: '${targetDuration}m',
                      onChanged: (value) {
                        setState(() {
                          targetDuration = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Exercise Info Card
                    if (selectedExerciseType != null)
                      _ExerciseInfoCard(exerciseType: selectedExerciseType!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Log Your Session'),
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
                    Text('How long did you actually exercise?',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _DurationButton(
                          duration: (targetDuration * 0.5).round(),
                          label: '50%',
                          onPressed: () => setState(() =>
                              actualDuration = (targetDuration * 0.5).round()),
                          isSelected:
                              actualDuration == (targetDuration * 0.5).round(),
                        ),
                        _DurationButton(
                          duration: (targetDuration * 0.75).round(),
                          label: '75%',
                          onPressed: () => setState(() =>
                              actualDuration = (targetDuration * 0.75).round()),
                          isSelected:
                              actualDuration == (targetDuration * 0.75).round(),
                        ),
                        _DurationButton(
                          duration: targetDuration,
                          label: '100%',
                          onPressed: () =>
                              setState(() => actualDuration = targetDuration),
                          isSelected: actualDuration == targetDuration,
                        ),
                        _DurationButton(
                          duration: (targetDuration * 1.25).round(),
                          label: '125%',
                          onPressed: () => setState(() =>
                              actualDuration = (targetDuration * 1.25).round()),
                          isSelected:
                              actualDuration == (targetDuration * 1.25).round(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Custom Duration: ${actualDuration} minutes',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: actualDuration.toDouble(),
                      min: 0,
                      max: (targetDuration * 1.5).toDouble(),
                      divisions: (targetDuration * 1.5).round(),
                      activeColor: _getAchievementColor(),
                      label: '${actualDuration}m',
                      onChanged: (value) {
                        setState(() {
                          actualDuration = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'How did it feel? Any observations?',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.note_alt),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle, color: Colors.white),
                        label: const Text('Log Exercise Session',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getAchievementColor(),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: selectedExerciseType != null
                            ? () => _logExercise(healthDataProvider)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (achievementMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              _AchievementCard(
                  message: achievementMessage, achieved: achieved ?? false),
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
            _SectionHeader(title: 'Recent Workouts'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: healthDataProvider.exerciseData.isEmpty
                    ? const Text('No exercise data yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: healthDataProvider.exerciseData.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final exercise =
                              healthDataProvider.exerciseData[index];
                          final typeData = exerciseTypes.firstWhere(
                            (e) => e['value'] == exercise.type.toLowerCase(),
                            orElse: () => {
                              'name': exercise.type,
                              'icon': '🏋️‍♀️',
                              'color': Colors.grey
                            },
                          );
                          return ListTile(
                            leading: Text(typeData['icon'],
                                style: const TextStyle(fontSize: 32)),
                            title: Text(
                              exercise.specificExercise ?? exercise.type,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Duration: ${exercise.formattedDuration}'),
                                if (exercise.targetDuration != null)
                                  Text(
                                      'Goal: ${exercise.targetDuration}m • ${(exercise.achievementPercentage * 100).round()}%'),
                                if (exercise.notes != null &&
                                    exercise.notes!.isNotEmpty)
                                  Text('Notes: ${exercise.notes}',
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic)),
                              ],
                            ),
                            trailing: exercise.achieved != null
                                ? Icon(
                                    exercise.achieved!
                                        ? Icons.check_circle
                                        : Icons.access_time,
                                    color: exercise.achieved!
                                        ? Colors.green
                                        : Colors.orange,
                                    size: 28,
                                  )
                                : null,
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

  Future<void> _loadSpecificExercises(String exerciseType) async {
    try {
      final exercises = await exerciseService.getExercisesByType(exerciseType);
      if (mounted) {
        setState(() {
          availableExercises = exercises;
        });
      }
    } catch (e) {
      print('Error loading specific exercises: $e');
      // Set fallback exercises even on error
      if (mounted) {
        setState(() {
          availableExercises = [
            {
              'name': 'General ${exerciseType.toLowerCase()} exercise',
              'muscle': 'full_body',
              'difficulty': 'beginner'
            }
          ];
        });
      }
    }
  }

  Color _getAchievementColor() {
    if (actualDuration >= targetDuration) return Colors.green;
    if (actualDuration >= targetDuration * 0.75) return Colors.orange;
    return Colors.red;
  }

  Future<void> _logExercise(HealthDataProvider healthDataProvider) async {
    if (selectedExerciseType == null) return;

    final wasAchieved = actualDuration >= targetDuration;

    final exercise = Exercise(
      id: DateTime.now().toString(),
      date: DateTime.now().toString(),
      type: selectedExerciseType!,
      duration: actualDuration,
      targetDuration: targetDuration,
      achieved: wasAchieved,
      specificExercise: selectedSpecificExercise,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );

    await healthDataProvider.addExerciseData(
      exercise,
      Provider.of<AuthProvider>(context, listen: false).user!.uid,
    );

    // Get achievement message
    setState(() {
      achieved = wasAchieved;
      isLoadingMotivation = true;
    });

    try {
      final message = exerciseService.getAchievementMessage(
          selectedExerciseType!, actualDuration, wasAchieved);
      setState(() {
        achievementMessage = message;
        isLoadingMotivation = false;
      });
    } catch (e) {
      setState(() {
        achievementMessage = wasAchieved
            ? '🎉 Great job completing your workout!'
            : '💪 Every effort counts!';
        isLoadingMotivation = false;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Exercise logged! ${wasAchieved ? "Goal achieved! 🎉" : "Keep it up! 💪"}'),
        backgroundColor: wasAchieved ? Colors.green : Colors.orange,
      ),
    );

    // Reset form
    setState(() {
      selectedExerciseType = null;
      selectedSpecificExercise = null;
      actualDuration = 0;
      targetDuration = 30;
      availableExercises = [];
    });
    notesController.clear();
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

class _ExerciseInfoCard extends StatelessWidget {
  final String exerciseType;
  const _ExerciseInfoCard({required this.exerciseType});

  @override
  Widget build(BuildContext context) {
    final exerciseService = ExerciseApiService();
    final info = exerciseService.getExerciseInfo(exerciseType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(info['icon'], style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                exerciseType.toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Benefits: ${info['benefits']}',
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text('Tip: ${info['tips']}',
              style:
                  const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _DurationButton extends StatelessWidget {
  final int duration;
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  const _DurationButton({
    required this.duration,
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? const Color(0xFF3A5A98) : Colors.grey[300],
            foregroundColor: isSelected ? Colors.white : Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text('${duration}m', style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String message;
  final bool achieved;
  const _AchievementCard({required this.message, required this.achieved});

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
            colors: achieved
                ? [Colors.green[50]!, Colors.teal[50]!]
                : [Colors.orange[50]!, Colors.amber[50]!],
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
                  Icon(
                    achieved ? Icons.emoji_events : Icons.favorite,
                    color: achieved ? Colors.green[600] : Colors.orange[600],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      achieved ? 'Achievement Unlocked!' : 'Keep Going!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            achieved ? Colors.green[800] : Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                message,
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
