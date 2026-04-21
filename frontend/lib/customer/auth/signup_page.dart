import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Email required";
    if (!v.contains("@")) return "Invalid email";
    return null;
  }

  String? passValidator(String? v) {
    if (v == null || v.isEmpty) return "Password required";
    if (v.length < 6) return "Min 6 characters";
    return null;
  }

  String? nameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Name required";
    if (v.length < 3) return "Too short name";
    return null;
  }

  String? phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Phone required";
    if (v.length < 10) return "Invalid phone number";
    return null;
  }

  void signup() async {
    if (!formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final ok = await auth.signup(
      name: name.text.trim(),
      email: email.text.trim(),
      password: password.text.trim(),
      phone: phone.text.trim(),
    );

    if (ok) {
      _msg("Account created! Please login.");
      Navigator.pushReplacementNamed(context, "/customer_login");
    } else {
      _msg("User already exists or signup failed");
    }
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  // 🔥 NEW BEAUTIFUL INPUT FIELD
  Widget field(
    TextEditingController c,
    String hint,
    IconData icon, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.cyanAccent),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                      Icons.person_add_rounded,
                      size: 70,
                      color: Colors.cyanAccent,
                    ),

                    const SizedBox(height: 10),

                    // 🔥 TITLE
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Create an account to book rooms",
                      style: TextStyle(color: Colors.white54),
                    ),

                    const SizedBox(height: 25),

                    // 🔥 FIELDS
                    field(name, "Full Name", Icons.person,
                        validator: nameValidator),

                    field(email, "Email Address", Icons.email,
                        validator: emailValidator),

                    field(phone, "Phone Number", Icons.phone,
                        validator: phoneValidator),

                    field(password, "Password", Icons.lock,
                        obscure: true, validator: passValidator),

                    const SizedBox(height: 10),

                    // 🔥 BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: signup,
                        child: const Text(
                          "SIGN UP",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔥 LOGIN LINK
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/customer_login");
                      },
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(color: Colors.white70),
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