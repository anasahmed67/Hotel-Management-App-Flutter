import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class CustomerForgotPassword extends StatefulWidget {
  const CustomerForgotPassword({super.key});

  @override
  State<CustomerForgotPassword> createState() =>
      _CustomerForgotPasswordState();
}

class _CustomerForgotPasswordState
    extends State<CustomerForgotPassword> {
  final email = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Email required";
    if (!v.contains("@")) return "Enter valid email";
    return null;
  }

  void reset() async {
    if (!formKey.currentState!.validate()) return;

    final auth =
        Provider.of<AuthProvider>(context, listen: false);

    final ok = await auth.forgotPassword(
      email: email.text.trim(),
      role: "customer",
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

  // 🔥 BEAUTIFUL INPUT FIELD
  Widget inputField() {
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
          contentPadding:
              EdgeInsets.symmetric(vertical: 18),
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),

              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // 🔥 ICON
                    const Icon(
                      Icons.lock_reset,
                      size: 70,
                      color: Colors.cyanAccent,
                    ),

                    const SizedBox(height: 10),

                    // 🔥 TITLE
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Enter your email to reset password",
                      style: TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 25),

                    // 🔥 FIELD
                    inputField(),

                    const SizedBox(height: 10),

                    // 🔥 BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: reset,
                        child: const Text(
                          "RESET PASSWORD",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔥 BACK TO LOGIN
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Back to Login",
                        style:
                            TextStyle(color: Colors.white70),
                      ),
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