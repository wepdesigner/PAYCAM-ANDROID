import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailOrPhone = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome Back to PAYCAM",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // Email / Phone
            TextField(
              controller: emailOrPhone,
              decoration: const InputDecoration(
                labelText: "Email or Phone Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // Password
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            // Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/register");
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Login"),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/register"),
              child: const Text("Don't have an account? Create account"),
            ),
          ],
        ),
      ),
    );
  }
}
