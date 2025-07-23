import 'package:flutter/material.dart';

class HealthCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const HealthCard({Key? key, required this.title, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(title, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}