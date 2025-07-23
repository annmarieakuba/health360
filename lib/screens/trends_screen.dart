import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final healthDataProvider = Provider.of<HealthDataProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Trends')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Nutrition Trends', style: TextStyle(fontSize: 18)),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: healthDataProvider.nutritionData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.calories.toDouble()))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}