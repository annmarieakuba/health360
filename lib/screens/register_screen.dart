import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final usernameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(controller: usernameController, label: 'Username', isPassword: false),
            CustomTextField(controller: emailController, label: 'Email', isPassword: false),
            CustomTextField(controller: passwordController, label: 'Password', isPassword: true),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Provider.of<AuthProvider>(context, listen: false).signUp(
                    emailController.text,
                    passwordController.text,
                    usernameController.text,
                  );
                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}