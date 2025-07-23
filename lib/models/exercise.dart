class Exercise {
  final String id;
  final String date;
  final String type;
  final int duration;
  final int targetDuration;
  final bool achieved;
  final String? specificExercise;
  final String? notes;

  Exercise({
    required this.id,
    required this.date,
    required this.type,
    required this.duration,
    required this.targetDuration,
    required this.achieved,
    this.specificExercise,
    this.notes,
  });

  // Helper method to check if goal was achieved
  bool get wasGoalAchieved => achieved;

  // Helper method to get achievement percentage
  double get achievementPercentage {
    if (targetDuration == null || targetDuration == 0) return 1.0;
    return (duration / targetDuration!).clamp(0.0, 1.0);
  }

  // Helper method to format duration
  String get formattedDuration {
    if (duration < 60) {
      return '${duration}m';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }
}
