import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;

  const CustomTextField({Key? key, required this.controller, required this.label, required this.isPassword}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,//hides text 
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) { //validation function 
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}