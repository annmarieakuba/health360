import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final goalController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
                controller: goalController,
                label: 'Set Goal',
                isPassword: false),
            ElevatedButton(
              onPressed: () {
                // Add goal logic
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Goal set')));
              },
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }
}
