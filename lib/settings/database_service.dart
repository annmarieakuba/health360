import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nutrition.dart';
import '../models/exercise.dart';
import '../models/sleep.dart';
import '../models/mood.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Nutrition>> getNutritionData(String userId) async {
    if (userId.isEmpty) {
      print('Error: User ID is empty for nutrition data');
      return [];
    }

    try {
      QuerySnapshot snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('nutrition')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Nutrition(
          id: doc.id,
          date: data['date'] ?? '',
          foodItem: data['foodItem'] ?? '',
          calories: data['calories'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error getting nutrition data: $e');
      return [];
    }
  }

  Future<void> addNutritionData(Nutrition nutrition, String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID is empty for nutrition data');
    }

    try {
      await _db.collection('users').doc(userId).collection('nutrition').add({
        'date': nutrition.date,
        'foodItem': nutrition.foodItem,
        'calories': nutrition.calories,
      });
    } catch (e) {
      print('Error adding nutrition data: $e');
      rethrow;
    }
  }

  Future<List<Exercise>> getExerciseData(String userId) async {
    if (userId.isEmpty) {
      print('Error: User ID is empty for exercise data');
      return [];
    }

    try {
      QuerySnapshot snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('exercise')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Exercise(
          id: doc.id,
          date: data['date'] ?? '',
          type: data['type'] ?? '',
          duration: data['duration'] ?? 0,
          targetDuration: data['targetDuration'] ?? 0,
          achieved: data['achieved'] ?? false,
          specificExercise: data['specificExercise'],
          notes: data['notes'],
        );
      }).toList();
    } catch (e) {
      print('Error getting exercise data: $e');
      return [];
    }
  }

  Future<void> addExerciseData(Exercise exercise, String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID is empty for exercise data');
    }

    try {
      await _db.collection('users').doc(userId).collection('exercise').add({
        'date': exercise.date,
        'type': exercise.type,
        'duration': exercise.duration,
        'targetDuration': exercise.targetDuration,
        'achieved': exercise.achieved,
        'specificExercise': exercise.specificExercise,
        'notes': exercise.notes,
      });
    } catch (e) {
      print('Error adding exercise data: $e');
      rethrow;
    }
  }

  Future<List<Sleep>> getSleepData(String userId) async {
    if (userId.isEmpty) {
      print('Error: User ID is empty for sleep data');
      return [];
    }

    try {
      QuerySnapshot snapshot =
          await _db.collection('users').doc(userId).collection('sleep').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Sleep(
          id: doc.id,
          date: data['date'] ?? '',
          hours: (data['hours'] ?? 0.0).toDouble(),
        );
      }).toList();
    } catch (e) {
      print('Error getting sleep data: $e');
      return [];
    }
  }

  Future<void> addSleepData(Sleep sleep, String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID is empty for sleep data');
    }

    print('=== DatabaseService.addSleepData ===');
    print('Adding sleep to Firebase: ${sleep.hours}h for user $userId');

    try {
      await _db.collection('users').doc(userId).collection('sleep').add({
        'date': sleep.date,
        'hours': sleep.hours,
      });
      print('Sleep data successfully added to Firebase');
    } catch (e) {
      print('ERROR adding sleep to Firebase: $e');
      rethrow;
    }
  }

  Future<List<Mood>> getMoodData(String userId) async {
    if (userId.isEmpty) {
      print('Error: User ID is empty for mood data');
      return [];
    }

    try {
      QuerySnapshot snapshot =
          await _db.collection('users').doc(userId).collection('mood').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Mood(
          id: doc.id,
          date: data['date'] ?? '',
          mood: data['mood'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting mood data: $e');
      return [];
    }
  }

  Future<void> addMoodData(Mood mood, String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID is empty for mood data');
    }

    try {
      await _db.collection('users').doc(userId).collection('mood').add({
        'date': mood.date,
        'mood': mood.mood,
      });
    } catch (e) {
      print('Error adding mood data: $e');
      rethrow;
    }
  }
}
