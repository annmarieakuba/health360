import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition.dart';

class NutritionApiService {
  static const String apiId =
      'your_nutritionix_app_id'; // Replace with your Nutritionix API ID
  static const String apiKey =
      'your_nutritionix_api_key'; // Replace with your Nutritionix API Key
  static const String baseUrl =
      'https://trackapi.nutritionix.com/v2/natural/nutrients';

  Future<Nutrition?> fetchNutritionData(String foodQuery) async {
    print('Fetching nutrition data for: $foodQuery');

    // Check if API keys are configured
    if (apiId == 'your_nutritionix_app_id' ||
        apiKey == 'your_nutritionix_api_key') {
      print('API keys not configured, using fallback nutrition data');
      return _getFallbackNutritionData(foodQuery);
    }

    try {
      print('Attempting API call to Nutritionix...');
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-app-id': apiId,
              'x-app-key': apiKey,
            },
            body: jsonEncode({'query': foodQuery}),
          )
          .timeout(const Duration(seconds: 5)); // Reduced timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['foods'] != null && data['foods'].isNotEmpty) {
          final food = data['foods'][0];
          print('API call successful, got data from Nutritionix');
          return Nutrition(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            date: DateTime.now().toIso8601String(),
            foodItem: food['food_name'],
            calories: food['nf_calories'].round(),
          );
        } else {
          print('API returned empty food data, using fallback');
          return _getFallbackNutritionData(foodQuery);
        }
      } else {
        print('API request failed with status: ${response.statusCode}');
        return _getFallbackNutritionData(foodQuery);
      }
    } catch (e) {
      print('Error fetching nutrition data from API: $e');
      return _getFallbackNutritionData(foodQuery);
    }
  }

  Nutrition _getFallbackNutritionData(String foodQuery) {
    print('Generating fallback nutrition data for: $foodQuery');
    // Smart calorie estimation based on common foods
    final calories = _estimateCalories(foodQuery.toLowerCase());
    print('Estimated calories: $calories');

    return Nutrition(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now().toIso8601String(),
      foodItem: foodQuery,
      calories: calories,
    );
  }

  int _estimateCalories(String foodQuery) {
    // Extract quantity if present
    final quantityMatch = RegExp(r'(\d+)').firstMatch(foodQuery);
    int quantity = 1;
    if (quantityMatch != null) {
      quantity = int.tryParse(quantityMatch.group(1)!) ?? 1;
    }

    // Common food calorie estimates (per unit/serving)
    final foodCalories = <String, int>{
      // Fruits
      'apple': 80,
      'banana': 105,
      'orange': 60,
      'grape': 60,
      'strawberry': 4,
      'blueberry': 1,

      // Vegetables
      'carrot': 25,
      'broccoli': 25,
      'spinach': 7,
      'tomato': 20,

      // Grains & Bread
      'bread': 80,
      'rice': 200,
      'pasta': 200,
      'oats': 150,
      'cereal': 100,

      // Proteins
      'chicken': 165,
      'beef': 250,
      'fish': 150,
      'egg': 70,
      'salmon': 200,

      // Dairy
      'milk': 150,
      'cheese': 100,
      'yogurt': 100,
      'butter': 100,

      // Nuts & Seeds
      'almonds': 160,
      'peanuts': 160,
      'walnut': 185,

      // Beverages
      'coffee': 2,
      'tea': 2,
      'juice': 110,
      'soda': 140,
      'water': 0,

      // Snacks
      'chips': 150,
      'chocolate': 150,
      'cookie': 50,
      'cake': 300,
    };

    // Find matching food
    for (final entry in foodCalories.entries) {
      if (foodQuery.contains(entry.key)) {
        return (entry.value * quantity).round();
      }
    }

    // Default calorie estimation based on food type keywords
    if (foodQuery.contains('salad')) return 50 * quantity;
    if (foodQuery.contains('soup')) return 100 * quantity;
    if (foodQuery.contains('sandwich')) return 300 * quantity;
    if (foodQuery.contains('pizza')) return 285 * quantity;
    if (foodQuery.contains('burger')) return 540 * quantity;

    // Weight-based estimation (if grams are mentioned)
    final gramsMatch = RegExp(r'(\d+)g').firstMatch(foodQuery);
    if (gramsMatch != null) {
      final grams = int.tryParse(gramsMatch.group(1)!) ?? 100;
      return (grams * 2.5).round(); // Rough estimate: 2.5 calories per gram
    }

    // Default fallback
    return 100 * quantity;
  }
}
