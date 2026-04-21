import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/premium_card.dart';
import '../providers/auth_provider.dart';



class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String selectedLang = "English";

  void _changePasswordDialog() {
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text("Change Password",
              style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(newPass, "New Password"),
              const SizedBox(height: 10),
              _input(confirmPass, "Confirm Password"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (newPass.text != confirmPass.text) {
                  _msg("Passwords do not match");
                  return;
                }

                await auth.changePassword(newPass.text);

                Navigator.pop(context);
                _msg("Password Updated");
              },
              child: const Text("Update"),
            )
          ],
        );
      },
    );
  }

  Widget _input(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      obscureText: true,
      style: GoogleFonts.outfit(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: AppColors.textDim),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.background, AppColors.cardBackground],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          size: 50, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(auth.name,
                      style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text(auth.email,
                      style: GoogleFonts.outfit(color: AppColors.textDim)),
                ],
              ),
            ),


            const SizedBox(height: 20),

            _card([
              _info(Icons.security, "Role", "Admin"),
              _info(Icons.phone, "Phone", auth.phone),
              _info(Icons.calendar_today, "Joining", auth.joiningDate),
            ]),

            const SizedBox(height: 15),

            _card([
              _tile(Icons.lock, "Change Password", _changePasswordDialog),
              _tile(Icons.settings, "Settings", () {}),
            ]),

            const SizedBox(height: 15),

            _card([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Language",
                      style: TextStyle(color: Colors.white)),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xff1a2233),
                    value: selectedLang,
                    items: const [
                      DropdownMenuItem(
                          value: "English", child: Text("English")),
                      DropdownMenuItem(value: "Urdu", child: Text("Urdu")),
                    ],
                    onChanged: (v) => setState(() => selectedLang = v!),
                  ),
                ],
              )
            ]),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent.withOpacity(0.1),
                  foregroundColor: Colors.pinkAccent,
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: Colors.pinkAccent, width: 1),
                ),
                onPressed: () {
                  auth.logout();
                  Navigator.pushReplacementNamed(
                      context, "/customer_login");
                },
                child: const Text("LOGOUT SESSION"),
              ),
            ),


            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PremiumCard(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }


  Widget _info(IconData icon, String t, String v) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(t, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
      trailing: Text(v,
          style: GoogleFonts.outfit(
              color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }


  Widget _tile(IconData icon, String t, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondary, size: 20),
      title: Text(t, style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textDim),
      onTap: onTap,
    );
  }


  void _msg(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }
}