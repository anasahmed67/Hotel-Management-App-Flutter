// ONLY UI IMPROVED — LOGIC SAME

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Email required";
    return null;
  }

  String? validatePass(String? v) {
    if (v == null || v.trim().isEmpty) return "Password required";
    return null;
  }

  void login() async {
    if (!formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final ok = await auth.login(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    if (ok) {
      if (auth.isAdmin) {
        Navigator.pushReplacementNamed(context, "/admin_dashboard");
      } else {
        Navigator.pushReplacementNamed(context, "/customer_dashboard");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

  }

  Widget field(TextEditingController c, String hint,
      {bool obscure = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.email, color: Colors.cyanAccent),
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0b1220), Color(0xff1e293b)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                )
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hotel_rounded,
                      size: 70, color: Colors.cyanAccent),

                  const SizedBox(height: 10),

                  const Text(
                    "Grand Horizon Hotel",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Login to access your panel",
                    style: TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 25),

                  field(email, "Email Address", validator: validateEmail),
                  const SizedBox(height: 15),
                  field(password, "Password",
                      obscure: true, validator: validatePass),

                  const SizedBox(height: 25),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: login,
                    child: const Text("LOGIN",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, "/customer_forgot"),
                    child: const Text("Forgot Password?",
                        style: TextStyle(color: Colors.cyanAccent)),
                  ),

                  const Divider(color: Colors.white10, height: 30),

                  const Text("New user?", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, "/customer_signup"),
                    child: const Text("Create Account",
                        style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}