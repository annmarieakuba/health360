import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesService {
  static const String _latestMoodKey = 'latest_mood';
  static const String _latestSleepKey = 'latest_sleep';
  static const String _latestExerciseKey = 'latest_exercise';
  static const String _latestNutritionKey = 'latest_nutrition';
  static const String _dataCountsKey = 'data_counts';
  static const String _userInfoKey = 'user_info';
  static const String _authStateKey = 'auth_state';

  // Save latest mood data for instant home screen updates
  Future<void> saveLatestMood(String mood, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final moodData = {
      'mood': mood,
      'date': date,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_latestMoodKey, json.encode(moodData));
  }

  // Save latest sleep data for instant home screen updates
  Future<void> saveLatestSleep(double hours, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final sleepData = {
      'hours': hours,
      'date': date,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_latestSleepKey, json.encode(sleepData));
  }

  // Save latest exercise data for instant home screen updates
  Future<void> saveLatestExercise(String type, int duration,
      String? specificExercise, bool? achieved) async {
    final prefs = await SharedPreferences.getInstance();
    final exerciseData = {
      'type': type,
      'duration': duration,
      'specificExercise': specificExercise,
      'achieved': achieved,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_latestExerciseKey, json.encode(exerciseData));
  }

  // Save latest nutrition data for instant home screen updates
  Future<void> saveLatestNutrition(
      String foodItem, int calories, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final nutritionData = {
      'foodItem': foodItem,
      'calories': calories,
      'date': date,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_latestNutritionKey, json.encode(nutritionData));
  }

  // Save data counts for debug info
  Future<void> saveDataCounts(int moodCount, int sleepCount, int exerciseCount,
      int nutritionCount) async {
    final prefs = await SharedPreferences.getInstance();
    final counts = {
      'mood': moodCount,
      'sleep': sleepCount,
      'exercise': exerciseCount,
      'nutrition': nutritionCount,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_dataCountsKey, json.encode(counts));
  }

  // Get latest mood data
  Future<Map<String, dynamic>?> getLatestMood() async {
    final prefs = await SharedPreferences.getInstance();
    final moodJson = prefs.getString(_latestMoodKey);
    if (moodJson != null) {
      return json.decode(moodJson);
    }
    return null;
  }

  // Get latest sleep data
  Future<Map<String, dynamic>?> getLatestSleep() async {
    final prefs = await SharedPreferences.getInstance();
    final sleepJson = prefs.getString(_latestSleepKey);
    if (sleepJson != null) {
      return json.decode(sleepJson);
    }
    return null;
  }

  // Get latest exercise data
  Future<Map<String, dynamic>?> getLatestExercise() async {
    final prefs = await SharedPreferences.getInstance();
    final exerciseJson = prefs.getString(_latestExerciseKey);
    if (exerciseJson != null) {
      return json.decode(exerciseJson);
    }
    return null;
  }

  // Get latest nutrition data
  Future<Map<String, dynamic>?> getLatestNutrition() async {
    final prefs = await SharedPreferences.getInstance();
    final nutritionJson = prefs.getString(_latestNutritionKey);
    if (nutritionJson != null) {
      return json.decode(nutritionJson);
    }
    return null;
  }

  // Get data counts
  Future<Map<String, dynamic>?> getDataCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final countsJson = prefs.getString(_dataCountsKey);
    if (countsJson != null) {
      return json.decode(countsJson);
    }
    return null;
  }

  // Save user information for persistence
  Future<void> saveUserInfo(
      String uid, String email, String username, String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_userInfoKey, json.encode(userData));
  }

  // Get user information
  Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userInfoKey);
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  // Save authentication state
  Future<void> saveAuthState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authStateKey, isLoggedIn);
  }

  // Get authentication state
  Future<bool> getAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_authStateKey) ?? false;
  }

  // Clear all cached data (for logout and account deletion)
  Future<void> clearAllCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latestMoodKey);
    await prefs.remove(_latestSleepKey);
    await prefs.remove(_latestExerciseKey);
    await prefs.remove(_latestNutritionKey);
    await prefs.remove(_dataCountsKey);
    await prefs.remove(_userInfoKey);
    await prefs.remove(_authStateKey);
    print('All SharedPreferences data cleared successfully');
  }

  // Clear only health data but keep user info (for data reset)
  Future<void> clearHealthDataOnly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latestMoodKey);
    await prefs.remove(_latestSleepKey);
    await prefs.remove(_latestExerciseKey);
    await prefs.remove(_latestNutritionKey);
    await prefs.remove(_dataCountsKey);
    print('Health data cleared from SharedPreferences');
  }
}
