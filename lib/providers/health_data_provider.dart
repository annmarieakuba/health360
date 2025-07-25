import 'package:flutter/material.dart';
import '/settings/local_storage_service.dart';
import '/settings/shared_preferences_service.dart';
import '/settings/database_service.dart';
import '../models/nutrition.dart';
import '../models/exercise.dart';
import '../models/sleep.dart';
import '../models/mood.dart';

class HealthDataProvider with ChangeNotifier {
  final LocalStorageService _localStorageService = LocalStorageService();
  final SharedPreferencesService _sharedPrefsService =
      SharedPreferencesService();
  final DatabaseService _databaseService = DatabaseService();

  List<Nutrition> _nutritionData = [];//private 
  List<Exercise> _exerciseData = [];
  List<Sleep> _sleepData = [];
  List<Mood> _moodData = [];

  bool _isInitialized = false;
  bool _isLoading = false;//loading flag 

  List<Nutrition> get nutritionData => _nutritionData;
  List<Exercise> get exerciseData => _exerciseData;
  List<Sleep> get sleepData => _sleepData;
  List<Mood> get moodData => _moodData;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  // Initialize all data when app starts
  Future<void> initializeData(String userId) async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Load from local storage first
      await _loadAllDataFromLocal();

      // Then sync with Firebase
      await _loadAllDataFromFirebase(userId);

      // Save Firebase data to local storage
      await _saveAllDataToLocal();

      print('Data initialized from Firebase and local storage');
    } catch (e) {
      print('Failed to load from Firebase, using local data: $e');
      // If Firebase fails, just use local data
      await _loadAllDataFromLocal();
    }

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // Load all data from local storage simultaneously 
  Future<void> _loadAllDataFromLocal() async {
    try {
      final futures = await Future.wait([
        _localStorageService.getNutritionData(),
        _localStorageService.getExerciseData(),
        _localStorageService.getSleepData(),
        _localStorageService.getMoodData(),
      ]);

      _nutritionData = futures[0] as List<Nutrition>;
      _exerciseData = futures[1] as List<Exercise>;
      _sleepData = futures[2] as List<Sleep>;
      _moodData = futures[3] as List<Mood>;

      // Sort all data by date to ensure most recent is last
      _sortAllDataByDate();
    } catch (e) {
      print('Error loading from local storage: $e');
      // Initialize with empty lists if local storage fails
      _nutritionData = [];
      _exerciseData = [];
      _sleepData = [];
      _moodData = [];
    }
  }

  // Load all data from Firebase
  Future<void> _loadAllDataFromFirebase(String userId) async {
    if (userId.isEmpty) {
      print('Error: User ID is empty');
      return;
    }

    try {
      final futures = await Future.wait([
        _databaseService.getNutritionData(userId),
        _databaseService.getExerciseData(userId),
        _databaseService.getSleepData(userId),
        _databaseService.getMoodData(userId),
      ]);

      _nutritionData = futures[0] as List<Nutrition>;
      _exerciseData = futures[1] as List<Exercise>;
      _sleepData = futures[2] as List<Sleep>;
      _moodData = futures[3] as List<Mood>;

      // Sort all data by date to ensure most recent is last
      _sortAllDataByDate();
    } catch (e) {
      print('Error loading from Firebase: $e');
      // If Firebase fails, keep local data
    }
  }

  // Save all data to local storage
  Future<void> _saveAllDataToLocal() async {
    try {
      await Future.wait([
        _localStorageService.saveNutritionData(_nutritionData),
        _localStorageService.saveExerciseData(_exerciseData),
        _localStorageService.saveSleepData(_sleepData),
        _localStorageService.saveMoodData(_moodData),
      ]);
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }

  // Sort all data arrays by date (oldest to newest)
  void _sortAllDataByDate() {
    try {
      _nutritionData.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
      _exerciseData.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
      _sleepData.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
      _moodData.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    } catch (e) {
      print('Error sorting data by date: $e');
    }
  }

  // Individual data fetch methods 
  Future<void> fetchNutritionData(String userId) async {
    try {
      _nutritionData = await _databaseService.getNutritionData(userId);
      _nutritionData.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    } catch (e) {
      print('Failed to fetch nutrition data from Firebase: $e');
      _nutritionData = [];
    }
    notifyListeners();
  }

  Future<void> addNutritionData(Nutrition nutrition, String userId) async {
    if (userId.isEmpty) {
      print('Error: User ID is empty for nutrition data');
      return;
    }

    print(
        'Adding nutrition data: ${nutrition.foodItem} - ${nutrition.calories} calories');

    // Save to SharedPreferences immediately for instant UI updates
    await _sharedPrefsService.saveLatestNutrition(
        nutrition.foodItem, nutrition.calories, nutrition.date);

    // Add to local list immediately
    _nutritionData.add(nutrition);
    _nutritionData.sort(
        (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

    // Update data counts in SharedPreferences
    await _sharedPrefsService.saveDataCounts(_moodData.length,
        _sleepData.length, _exerciseData.length, _nutritionData.length);

    // Notify listeners immediately for real-time UI updates
    notifyListeners();

    // Save to local storage
    await _localStorageService.saveNutritionData(_nutritionData);

    // Save to Firebase in background
    try {
      await _databaseService.addNutritionData(nutrition, userId);
      print('Nutrition data saved to Firebase');
    } catch (e) {
      print('Failed to save nutrition data to Firebase: $e');
    }
  }

  Future<void> fetchExerciseData(String userId) async {
    try {
      _exerciseData = await _databaseService.getExerciseData(userId);
      _exerciseData.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    } catch (e) {
      print('Failed to fetch exercise data from Firebase: $e');
      _exerciseData = [];
    }
    notifyListeners();
  }

  Future<void> addExerciseData(Exercise exercise, String userId) async {
    if (userId.isEmpty) {
      print('Error: User ID is empty for exercise data');
      return;
    }

    print(
        'Adding exercise data: ${exercise.type} - ${exercise.duration} minutes');

    // Save to SharedPreferences immediately for instant UI updates
    await _sharedPrefsService.saveLatestExercise(exercise.type,
        exercise.duration, exercise.specificExercise, exercise.achieved);

    // Add to local list immediately
    _exerciseData.add(exercise);
    _exerciseData.sort(
        (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

    // Update data counts in SharedPreferences
    await _sharedPrefsService.saveDataCounts(_moodData.length,
        _sleepData.length, _exerciseData.length, _nutritionData.length);

    // Notify listeners immediately for real-time UI updates
    notifyListeners();

    // Save to local storage
    await _localStorageService.saveExerciseData(_exerciseData);

    // Save to Firebase in background
    try {
      await _databaseService.addExerciseData(exercise, userId);
      print('Exercise data saved to Firebase');
    } catch (e) {
      print('Failed to save exercise data to Firebase: $e');
    }
  }

  Future<void> fetchSleepData(String userId) async {
    try {
      _sleepData = await _databaseService.getSleepData(userId);
      _sleepData.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    } catch (e) {
      print('Failed to fetch sleep data from Firebase: $e');
      _sleepData = [];
    }
    notifyListeners();
  }

  Future<void> addSleepData(Sleep sleep, String userId) async {
    if (userId.isEmpty) {
      print('Error: User ID is empty for sleep data');
      return;
    }

    print('=== HealthDataProvider.addSleepData ===');
    print('Sleep ID: ${sleep.id}');
    print('Sleep hours: ${sleep.hours}');
    print('Sleep date: ${sleep.date}');
    print('User ID: $userId');

    // Save to SharedPreferences immediately for instant UI updates
    await _sharedPrefsService.saveLatestSleep(sleep.hours, sleep.date);

    // Add to local list immediately
    _sleepData.add(sleep);
    _sleepData.sort(
        (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    print('Sleep data added to local list. New count: ${_sleepData.length}');

    // Update data counts in SharedPreferences
    await _sharedPrefsService.saveDataCounts(_moodData.length,
        _sleepData.length, _exerciseData.length, _nutritionData.length);

    // Notify listeners immediately for real-time UI updates
    notifyListeners();
    print('Listeners notified immediately');

    // Save to local storage
    await _localStorageService.saveSleepData(_sleepData);
    print('Sleep data saved to local storage');

    // Save to Firebase in background
    try {
      await _databaseService.addSleepData(sleep, userId);
      print('Sleep data saved to Firebase');
    } catch (e) {
      print('Failed to save sleep data to Firebase: $e');
    }
    print('=== addSleepData completed ===');
  }

  Future<void> fetchMoodData(String userId) async {
    try {
      _moodData = await _databaseService.getMoodData(userId);
      _moodData.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    } catch (e) {
      print('Failed to fetch mood data from Firebase: $e');
      _moodData = [];
    }
    notifyListeners();
  }

  Future<void> addMoodData(Mood mood, String userId) async {
    if (userId.isEmpty) {
      print('Error: User ID is empty for mood data');
      return;
    }

    print('Adding mood data: ${mood.mood}');

    // Save to SharedPreferences immediately for instant UI updates
    await _sharedPrefsService.saveLatestMood(mood.mood, mood.date);

    // Add to local list immediately
    _moodData.add(mood);
    _moodData.sort(
        (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

    // Update data counts in SharedPreferences
    await _sharedPrefsService.saveDataCounts(_moodData.length,
        _sleepData.length, _exerciseData.length, _nutritionData.length);

    // Notify listeners immediately for real-time UI updates
    notifyListeners();

    // Save to local storage
    await _localStorageService.saveMoodData(_moodData);

    // Save to Firebase in background
    try {
      await _databaseService.addMoodData(mood, userId);
      print('Mood data saved to Firebase');
    } catch (e) {
      print('Failed to save mood data to Firebase: $e');
    }
  }

  // Refresh all data from Firebase
  Future<void> refreshAllData(String userId) async {
    try {
      await _loadAllDataFromFirebase(userId);
      await _saveAllDataToLocal();
      notifyListeners();
      print('All data refreshed from Firebase');
    } catch (e) {
      print('Failed to refresh data from Firebase: $e');
    }
  }

  // Sync local data with Firebase
  Future<void> syncWithFirebase(String userId) async {
    try {
      await _saveAllDataToLocal();
      print('Local data synced with Firebase');
    } catch (e) {
      print('Failed to sync with Firebase: $e');
    }
  }

 
  Future<void> clearAllData() async {
    try {
      
      // This removes all records from nutrition, exercise, sleep, and mood tables
      await _localStorageService.clearAllData();

      
      // This ensures the UI immediately reflects the cleared state
      _nutritionData = [];
      _exerciseData = [];
      _sleepData = [];
      _moodData = [];

     
      // This triggers UI updates to show empty states
      notifyListeners();

      print('All health data cleared successfully');
    } catch (e) {
      print('Failed to clear data: $e');
      // Even if clearing fails, we still clear the in-memory data
      // to ensure the UI shows the correct state
    }
  }

  // Export all data
  Future<String> exportAllData() async {
    try {
      final nutritionJson = _nutritionData
          .map((n) => {
                'id': n.id,
                'date': n.date,
                'foodItem': n.foodItem,
                'calories': n.calories,
              })
          .toList();

      final exerciseJson = _exerciseData
          .map((e) => {
                'id': e.id,
                'date': e.date,
                'type': e.type,
                'duration': e.duration,
                'targetDuration': e.targetDuration,
                'achieved': e.achieved,
                'specificExercise': e.specificExercise,
                'notes': e.notes,
              })
          .toList();

      final sleepJson = _sleepData
          .map((s) => {
                'id': s.id,
                'date': s.date,
                'hours': s.hours,
              })
          .toList();

      final moodJson = _moodData
          .map((m) => {
                'id': m.id,
                'date': m.date,
                'mood': m.mood,
              })
          .toList();

      final exportData = {
        'nutrition': nutritionJson,
        'exercise': exerciseJson,
        'sleep': sleepJson,
        'mood': moodJson,
        'exported_at': DateTime.now().toIso8601String(),
      };

      return exportData.toString();
    } catch (e) {
      print('Failed to export data: $e');
      return '{}';
    }
  }

  // Debug method to add test data
  Future<void> addTestData(String userId) async {
    print('Adding test data...');

    // Test mood data
    final testMood = Mood(
      id: 'test_mood_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now().toString(),
      mood: 'Happy',
    );
    await addMoodData(testMood, userId);

    // Test exercise data
    final testExercise = Exercise(
      id: 'test_exercise_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now().toString(),
      type: 'cardio',
      duration: 30,
      targetDuration: 30,
      achieved: true,
      specificExercise: 'Running',
      notes: 'Test exercise',
    );
    await addExerciseData(testExercise, userId);

    // Test sleep data
    final testSleep = Sleep(
      id: 'test_sleep_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now().toIso8601String(),
      hours: 8,
    );
    await addSleepData(testSleep, userId);

    // Test nutrition data
    final testNutrition = Nutrition(
      id: 'test_nutrition_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now().toString(),
      foodItem: 'Apple',
      calories: 95,
    );
    await addNutritionData(testNutrition, userId);

    print('Test data added successfully');
  }
}
