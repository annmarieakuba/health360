import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MotivationApiService {
  static const String _baseUrl = 'https://api.quotable.io';
  static const String _jokeUrl =
      'https://official-joke-api.appspot.com/random_joke';

  // SharedPreferences keys for local caching
  static const String _cachedQuotesKey = 'cached_motivational_quotes';
  static const String _cachedJokesKey = 'cached_motivational_jokes';
  static const String _lastUpdateKey = 'motivation_last_update';

  // Pre-defined motivational content for different emotions
  static const Map<String, List<String>> _predefinedContent = {
    'sad': [
      '💙 Remember, every storm passes. You are stronger than you think.',
      '🌟 Even on your darkest days, you are still shining.',
      '🌱 Growth often comes from difficult times. You\'re growing stronger.',
      '💪 You\'ve survived 100% of your bad days so far. You\'ve got this!',
      '🌈 After every storm comes a rainbow. Better days are ahead.',
    ],
    'angry': [
      '😌 Take a deep breath. You have the power to choose your response.',
      '🧘‍♀️ Anger is temporary. Your peace is permanent.',
      '💆‍♂️ You\'re allowed to feel angry, but don\'t let it control you.',
      '🌊 Like waves, emotions come and go. Ride them with grace.',
      '🕊️ Choose peace over anger. It\'s better for your soul.',
    ],
    'stressed': [
      '🌿 One step at a time. You don\'t have to figure everything out today.',
      '🧘‍♀️ Breathe in peace, breathe out stress.',
      '📝 Break big tasks into small steps. You\'ll get there.',
      '🌅 This moment is temporary. Tomorrow is a new day.',
      '💆‍♀️ You\'re doing better than you think. Give yourself credit.',
    ],
    'anxious': [
      '🦋 You are safe. You are loved. You are enough.',
      '🌙 Anxiety is just your mind being overprotective. You\'re okay.',
      '🧘‍♂️ Focus on what you can control. Let go of what you can\'t.',
      '💎 You are more resilient than your anxiety tells you.',
      '🌱 Growth happens outside your comfort zone. You\'re growing.',
    ],
    'frustrated': [
      '🔧 Frustration is just a sign that you care. Channel it into action.',
      '💡 Every obstacle is an opportunity to get creative.',
      '🚀 You\'re closer to a breakthrough than you think.',
      '🎯 Focus on solutions, not problems. You\'ve got this!',
      '🌟 Your persistence will pay off. Keep going!',
    ],
    'tired': [
      '😴 Rest is not a sign of weakness. It\'s a sign of wisdom.',
      '🌙 Your body is asking for care. Listen to it.',
      '💤 Sleep is your superpower. Honor your need for rest.',
      '🛏️ Tomorrow is a new day with new energy.',
      '🌅 Rest well, dream big, wake up stronger.',
    ],
    'lonely': [
      '🤗 You are never truly alone. You have yourself, and that\'s powerful.',
      '💝 Self-love is the best company you can keep.',
      '🌟 Your presence is a gift to the world.',
      '🌍 You are connected to everyone and everything.',
      '💫 You are worthy of love, starting with your own.',
    ],
    'overwhelmed': [
      '🌊 You don\'t have to do everything at once. One thing at a time.',
      '🧘‍♀️ Take a moment to breathe. You\'re doing great.',
      '📋 Break it down. Small steps lead to big changes.',
      '💪 You\'ve handled tough situations before. You can handle this.',
      '🌟 You are capable of more than you think.',
    ],
  };

  // Get motivational content with Firebase fallback
  Future<String> getMotivationalContent(String emotion) async {
    final emotionKey = emotion.toLowerCase();

    // First, try to get from local cache
    String? cachedContent = await _getCachedContent(emotionKey);
    if (cachedContent != null) {
      print('Using cached motivational content for $emotion');
      return cachedContent;
    }

    // Try to get from Firebase
    String? firebaseContent = await _getFirebaseContent(emotionKey);
    if (firebaseContent != null) {
      print('Using Firebase motivational content for $emotion');
      await _cacheContent(emotionKey, firebaseContent);
      return firebaseContent;
    }

    // Use predefined content as fallback
    String predefinedContent = _getPredefinedContent(emotionKey);
    print('Using predefined motivational content for $emotion');

    // Cache for future use
    await _cacheContent(emotionKey, predefinedContent);

    return predefinedContent;
  }

  // Get predefined content for an emotion
  String _getPredefinedContent(String emotion) {
    final contentList =
        _predefinedContent[emotion] ?? _predefinedContent['sad']!;
    final random = DateTime.now().millisecondsSinceEpoch % contentList.length;
    return contentList[random];
  }

  // Get cached content from SharedPreferences
  Future<String?> _getCachedContent(String emotion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cachedQuotesKey);
      if (cachedData != null) {
        final Map<String, dynamic> data = jsonDecode(cachedData);
        return data[emotion];
      }
    } catch (e) {
      print('Error getting cached content: $e');
    }
    return null;
  }

  // Cache content in SharedPreferences
  Future<void> _cacheContent(String emotion, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cachedQuotesKey);
      Map<String, dynamic> data = {};

      if (cachedData != null) {
        data = jsonDecode(cachedData);
      }

      data[emotion] = content;
      data['last_update'] = DateTime.now().toIso8601String();

      await prefs.setString(_cachedQuotesKey, jsonEncode(data));
      print('Cached motivational content for $emotion');
    } catch (e) {
      print('Error caching content: $e');
    }
  }

  // Get content from Firebase
  Future<String?> _getFirebaseContent(String emotion) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('motivational_content')
          .doc(emotion)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final contentList = List<String>.from(data['content'] ?? []);
        if (contentList.isNotEmpty) {
          final random =
              DateTime.now().millisecondsSinceEpoch % contentList.length;
          return contentList[random];
        }
      }
    } catch (e) {
      print('Error getting Firebase content: $e');
    }
    return null;
  }

  // Store content in Firebase
  Future<void> _storeContentInFirebase(
      String emotion, List<String> content) async {
    try {
      await FirebaseFirestore.instance
          .collection('motivational_content')
          .doc(emotion)
          .set({
        'content': content,
        'last_updated': FieldValue.serverTimestamp(),
      });
      print('Stored motivational content in Firebase for $emotion');
    } catch (e) {
      print('Error storing content in Firebase: $e');
    }
  }

  // Pre-populate Firebase with motivational content
  Future<void> prePopulateFirebase() async {
    print('Pre-populating Firebase with motivational content...');

    for (final entry in _predefinedContent.entries) {
      await _storeContentInFirebase(entry.key, entry.value);
    }

    print('Firebase pre-population completed');
  }

  // Legacy methods for API calls (kept for fallback)
  Future<String> getMotivationalQuote() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/random'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return '${data['content']} - ${data['author']}';
      }
    } catch (e) {
      print('Error fetching quote: $e');
    }

    return 'Every day is a new beginning. Take a deep breath and start again.';
  }

  Future<String> getJoke() async {
    try {
      final response = await http
          .get(Uri.parse(_jokeUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return '${data['setup']} ${data['punchline']}';
      }
    } catch (e) {
      print('Error fetching joke: $e');
    }

    return 'Why did the scarecrow win an award? Because he was outstanding in his field! 😄';
  }

  bool _isNegativeEmotion(String emotion) {
    final negativeEmotions = [
      'sad',
      'angry',
      'stressed',
      'anxious',
      'frustrated',
      'tired',
      'lonely',
      'overwhelmed'
    ];
    return negativeEmotions.contains(emotion.toLowerCase());
  }

  // Clear all cached content
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedQuotesKey);
      await prefs.remove(_cachedJokesKey);
      await prefs.remove(_lastUpdateKey);
      print('Cleared motivational content cache');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
