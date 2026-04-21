import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminForgotPassword extends StatefulWidget {
  const AdminForgotPassword({super.key});

  @override
  State<AdminForgotPassword> createState() =>
      _AdminForgotPasswordState();
}

class _AdminForgotPasswordState
    extends State<AdminForgotPassword> {
  final email = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Email required";
    return null;
  }

  void reset() async {
    if (!formKey.currentState!.validate()) return;

    final auth =
        Provider.of<AuthProvider>(context, listen: false);

    final ok = await auth.forgotPassword(
      email: email.text.trim(),
      role: "admin",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            ok ? Colors.cyanAccent : Colors.redAccent,
        content: Text(
          ok ? "Password reset to 123456" : "Email not found",
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );

    if (ok) Navigator.pop(context);
  }

  Widget field() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: TextFormField(
        controller: email,
        validator: emailValidator,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          prefixIcon:
              Icon(Icons.email, color: Colors.cyanAccent),
          hintText: "Enter your email",
          hintStyle: TextStyle(color: Colors.white38),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0b1220), Color(0xff111b2e)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white24),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const Icon(Icons.lock_reset,
                        size: 70, color: Colors.cyanAccent),
                    const SizedBox(height: 10),
                    const Text("Reset Admin Password",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),

                    const SizedBox(height: 25),

                    field(),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        minimumSize:
                            const Size(double.infinity, 50),
                      ),
                      onPressed: reset,
                      child: const Text("RESET PASSWORD",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}