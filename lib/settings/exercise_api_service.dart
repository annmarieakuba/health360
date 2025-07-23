import 'dart:convert';
import 'package:http/http.dart' as http;

class ExerciseApiService {
  // Free Exercise API - no API key required
  static const String exerciseUrl = 'https://api.api-ninjas.com/v1/exercises';
  static const String fitnessQuotesUrl =
      'https://api.quotable.io/random?tags=fitness|motivational|success';

  // API Ninjas key (free tier) - you can get this from https://api.api-ninjas.com/
  static const String apiKey = 'YOUR_API_NINJAS_KEY'; // Replace with actual key

  Future<List<Map<String, dynamic>>> getExercisesByType(
      String exerciseType) async {
    try {
      final response = await http.get(
        Uri.parse('$exerciseUrl?type=$exerciseType'),
        headers: {
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching exercises: $e');
    }

    // Fallback exercise data
    return _getFallbackExercises(exerciseType);
  }

  Future<String> getMotivationalQuote() async {
    try {
      final response = await http.get(Uri.parse(fitnessQuotesUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return '"${data['content']}" - ${data['author']}';
      }
    } catch (e) {
      print('Error fetching fitness quote: $e');
    }

    // Fallback fitness quotes
    final fallbackQuotes = [
      '"The only bad workout is the one that didn\'t happen." - Unknown',
      '"Your body can do it. It\'s your mind you need to convince." - Unknown',
      '"Fitness is not about being better than someone else. It\'s about being better than you used to be." - Unknown',
      '"The groundwork for all happiness is good health." - Leigh Hunt',
      '"Take care of your body. It\'s the only place you have to live." - Jim Rohn',
    ];
    fallbackQuotes.shuffle();
    return fallbackQuotes.first;
  }

  String getAchievementMessage(
      String exerciseType, int duration, bool achieved) {
    if (achieved) {
      final successMessages = [
        '🎉 Amazing work! You crushed that $exerciseType session!',
        '💪 You\'re unstoppable! Great job completing your $exerciseType!',
        '🔥 That\'s what I call dedication! $exerciseType completed!',
        '⭐ You\'re a fitness champion! Keep up the great work!',
        '🏆 Goal achieved! You\'re building stronger habits every day!',
      ];
      successMessages.shuffle();
      return successMessages.first;
    } else {
      final encouragementMessages = [
        '💙 Every step counts! You showed up and that\'s what matters.',
        '🌱 Progress, not perfection! You\'re still moving forward.',
        '💫 Tomorrow is a new opportunity to crush your goals!',
        '🤗 Be kind to yourself. Recovery and rest are part of fitness too.',
        '🎯 You tried, and that\'s already a victory. Keep going!',
      ];
      encouragementMessages.shuffle();
      return encouragementMessages.first;
    }
  }

  Map<String, dynamic> getExerciseInfo(String exerciseType) {
    final exerciseData = {
      'cardio': {
        'icon': '🏃‍♀️',
        'color': 'orange',
        'benefits': 'Improves heart health and endurance',
        'tips': 'Start slow and gradually increase intensity',
      },
      'strength': {
        'icon': '💪',
        'color': 'red',
        'benefits': 'Builds muscle mass and bone density',
        'tips': 'Focus on proper form over heavy weights',
      },
      'flexibility': {
        'icon': '🧘‍♀️',
        'color': 'purple',
        'benefits': 'Improves range of motion and reduces injury risk',
        'tips': 'Hold stretches for 15-30 seconds',
      },
      'balance': {
        'icon': '⚖️',
        'color': 'teal',
        'benefits': 'Enhances stability and coordination',
        'tips': 'Practice on different surfaces for better results',
      },
      'sports': {
        'icon': '⚽',
        'color': 'green',
        'benefits': 'Combines fitness with fun and social interaction',
        'tips': 'Focus on technique and enjoy the game',
      },
      'yoga': {
        'icon': '🧘',
        'color': 'indigo',
        'benefits': 'Combines strength, flexibility, and mindfulness',
        'tips': 'Listen to your body and breathe deeply',
      },
    };

    return exerciseData[exerciseType.toLowerCase()] ??
        {
          'icon': '🏋️‍♀️',
          'color': 'blue',
          'benefits': 'Improves overall fitness and health',
          'tips': 'Stay consistent and listen to your body',
        };
  }

  List<Map<String, dynamic>> _getFallbackExercises(String type) {
    final fallbackData = {
      'cardio': [
        {
          'name': 'Running',
          'muscle': 'cardiovascular',
          'difficulty': 'intermediate'
        },
        {
          'name': 'Jump Rope',
          'muscle': 'cardiovascular',
          'difficulty': 'beginner'
        },
        {
          'name': 'Cycling',
          'muscle': 'cardiovascular',
          'difficulty': 'beginner'
        },
        {
          'name': 'Swimming',
          'muscle': 'cardiovascular',
          'difficulty': 'intermediate'
        },
        {
          'name': 'Dancing',
          'muscle': 'cardiovascular',
          'difficulty': 'beginner'
        },
      ],
      'strength': [
        {'name': 'Push-ups', 'muscle': 'chest', 'difficulty': 'beginner'},
        {'name': 'Squats', 'muscle': 'quadriceps', 'difficulty': 'beginner'},
        {'name': 'Pull-ups', 'muscle': 'lats', 'difficulty': 'expert'},
        {
          'name': 'Deadlifts',
          'muscle': 'hamstrings',
          'difficulty': 'intermediate'
        },
        {'name': 'Planks', 'muscle': 'abdominals', 'difficulty': 'beginner'},
      ],
      'flexibility': [
        {
          'name': 'Forward Fold',
          'muscle': 'hamstrings',
          'difficulty': 'beginner'
        },
        {
          'name': 'Cat-Cow Stretch',
          'muscle': 'spine',
          'difficulty': 'beginner'
        },
        {
          'name': 'Pigeon Pose',
          'muscle': 'hip_flexors',
          'difficulty': 'intermediate'
        },
        {
          'name': 'Shoulder Rolls',
          'muscle': 'shoulders',
          'difficulty': 'beginner'
        },
        {'name': 'Spinal Twist', 'muscle': 'spine', 'difficulty': 'beginner'},
      ],
      'yoga': [
        {
          'name': 'Downward Dog',
          'muscle': 'full_body',
          'difficulty': 'beginner'
        },
        {'name': 'Warrior I', 'muscle': 'legs', 'difficulty': 'beginner'},
        {'name': 'Tree Pose', 'muscle': 'core', 'difficulty': 'intermediate'},
        {'name': 'Child\'s Pose', 'muscle': 'back', 'difficulty': 'beginner'},
        {
          'name': 'Sun Salutation',
          'muscle': 'full_body',
          'difficulty': 'intermediate'
        },
      ],
    };

    return fallbackData[type.toLowerCase()] ??
        [
          {
            'name': 'General Exercise',
            'muscle': 'full_body',
            'difficulty': 'beginner'
          },
        ];
  }
}
