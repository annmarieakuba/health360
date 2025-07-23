import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/nutrition.dart';
import '../models/exercise.dart';
import '../models/sleep.dart';
import '../models/mood.dart';

class LocalStorageService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'health_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Nutrition table
    await db.execute('''
      CREATE TABLE nutrition(
        id TEXT PRIMARY KEY,
        date TEXT,
        foodItem TEXT,
        calories INTEGER
      )
    ''');

    // Exercise table
    await db.execute('''
      CREATE TABLE exercise(
        id TEXT PRIMARY KEY,
        date TEXT,
        type TEXT,
        duration INTEGER,
        targetDuration INTEGER,
        achieved INTEGER,
        specificExercise TEXT,
        notes TEXT
      )
    ''');

    // Sleep table
    await db.execute('''
      CREATE TABLE sleep(
        id TEXT PRIMARY KEY,
        date TEXT,
        hours REAL
      )
    ''');

    // Mood table
    await db.execute('''
      CREATE TABLE mood(
        id TEXT PRIMARY KEY,
        date TEXT,
        mood TEXT
      )
    ''');
  }

  // Nutrition methods
  Future<void> saveNutritionData(List<Nutrition> nutritionList) async {
    final db = await database;
    final batch = db.batch();

    for (var nutrition in nutritionList) {
      batch.insert(
        'nutrition',
        {
          'id': nutrition.id,
          'date': nutrition.date,
          'foodItem': nutrition.foodItem,
          'calories': nutrition.calories,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<Nutrition>> getNutritionData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('nutrition');

    return List.generate(maps.length, (i) {
      return Nutrition(
        id: maps[i]['id'],
        date: maps[i]['date'],
        foodItem: maps[i]['foodItem'],
        calories: maps[i]['calories'],
      );
    });
  }

  // Exercise methods
  Future<void> saveExerciseData(List<Exercise> exerciseList) async {
    final db = await database;
    final batch = db.batch();

    for (var exercise in exerciseList) {
      batch.insert(
        'exercise',
        {
          'id': exercise.id,
          'date': exercise.date,
          'type': exercise.type,
          'duration': exercise.duration,
          'targetDuration': exercise.targetDuration,
          'achieved': exercise.achieved ? 1 : 0,
          'specificExercise': exercise.specificExercise,
          'notes': exercise.notes,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<Exercise>> getExerciseData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('exercise');

    return List.generate(maps.length, (i) {
      return Exercise(
        id: maps[i]['id'],
        date: maps[i]['date'],
        type: maps[i]['type'],
        duration: maps[i]['duration'],
        targetDuration: maps[i]['targetDuration'],
        achieved: maps[i]['achieved'] != null && maps[i]['achieved'] == 1,
        specificExercise: maps[i]['specificExercise'],
        notes: maps[i]['notes'],
      );
    });
  }

  // Sleep methods
  Future<void> saveSleepData(List<Sleep> sleepList) async {
    final db = await database;
    final batch = db.batch();

    for (var sleep in sleepList) {
      batch.insert(
        'sleep',
        {
          'id': sleep.id,
          'date': sleep.date,
          'hours': sleep.hours,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<Sleep>> getSleepData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sleep');

    return List.generate(maps.length, (i) {
      return Sleep(
        id: maps[i]['id'],
        date: maps[i]['date'],
        hours: maps[i]['hours'],
      );
    });
  }

  // Mood methods
  Future<void> saveMoodData(List<Mood> moodList) async {
    final db = await database;
    final batch = db.batch();

    for (var mood in moodList) {
      batch.insert(
        'mood',
        {
          'id': mood.id,
          'date': mood.date,
          'mood': mood.mood,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<Mood>> getMoodData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('mood');

    return List.generate(maps.length, (i) {
      return Mood(
        id: maps[i]['id'],
        date: maps[i]['date'],
        mood: maps[i]['mood'],
      );
    });
  }

  /// Clears all data from the local SQLite database
  /// This method removes all records from all health data tables:
  /// - nutrition: Food items and calorie tracking data
  /// - exercise: Workout sessions and fitness tracking data
  /// - sleep: Sleep duration and quality data
  /// - mood: Emotional state and mood tracking data
  ///
  /// This is a permanent deletion - data cannot be recovered after this operation
  Future<void> clearAllData() async {
    final db = await database;

    // Delete all records from each health data table
    // These operations are irreversible
    await db.delete('nutrition'); // Remove all food/calorie records
    await db.delete('exercise'); // Remove all workout records
    await db.delete('sleep'); // Remove all sleep records
    await db.delete('mood'); // Remove all mood records

    print('All local database tables cleared successfully');
  }

  // Check if local data exists
  Future<bool> hasLocalData() async {
    final db = await database;
    final nutritionCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM nutrition')) ??
        0;
    final exerciseCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM exercise')) ??
        0;
    final sleepCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM sleep')) ??
        0;
    final moodCount =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM mood')) ??
            0;

    return nutritionCount > 0 ||
        exerciseCount > 0 ||
        sleepCount > 0 ||
        moodCount > 0;
  }
}
