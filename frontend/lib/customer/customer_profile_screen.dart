import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/premium_card.dart';
import '../providers/auth_provider.dart';



class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Update Security",
              style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(newPass, "New Password", isPass: true),
              const SizedBox(height: 10),
              _input(confirmPass, "Confirm Password", isPass: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),

              onPressed: () async {
                if (newPass.text.isEmpty || confirmPass.text.isEmpty) {
                  _msg("Fields cannot be empty");
                  return;
                }
                if (newPass.text != confirmPass.text) {
                  _msg("Passwords do not match");
                  return;
                }

                final ok = await auth.changePassword(newPass.text);

                if (ok) {
                  Navigator.pop(context);
                  _msg("Password Updated Successfully");
                } else {
                  _msg("Failed to update password");
                }
              },
              child: const Text("Update", style: TextStyle(color: Colors.black)),
            )
          ],
        );
      },
    );
  }

  void _editProfileDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nameController = TextEditingController(text: auth.name);
    final phoneController = TextEditingController(text: auth.phone);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Personal Details",
              style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(nameController, "Full Name"),
              const SizedBox(height: 10),
              _input(phoneController, "Phone Number"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),

              onPressed: () async {
                if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                  _msg("Fields cannot be empty");
                  return;
                }

                final ok = await auth.updateProfile(
                  newName: nameController.text.trim(),
                  newPhone: phoneController.text.trim(),
                );

                if (ok) {
                  Navigator.pop(context);
                  _msg("Profile Updated Successfully");
                } else {
                  _msg("Failed to update profile");
                }
              },
              child: const Text("Save Changes", style: TextStyle(color: Colors.black)),
            )
          ],
        );
      },
    );
  }

  Widget _input(TextEditingController c, String hint, {bool isPass = false}) {
    return TextField(
      controller: c,
      obscureText: isPass,
      style: GoogleFonts.outfit(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: AppColors.textDim),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

            // 🔥 HEADER
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
                      border: Border.all(color: AppColors.secondary.withOpacity(0.5), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: AppColors.secondary.withOpacity(0.1),
                      child: const Icon(Icons.person_rounded, size: 50, color: AppColors.secondary),
                    ),
                  ),
                  const SizedBox(height: 15),
                   Text(
                    auth.name.isEmpty ? "Hotel Guest" : auth.name,
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(auth.email,
                      style: GoogleFonts.outfit(color: AppColors.textDim)),
                ],
              ),
            ),


            const SizedBox(height: 20),

            // 🔥 INFO CARD
            _card([
              _info(Icons.person, "Role", "Customer"),
              _info(Icons.phone, "Phone", auth.phone),
              _info(Icons.calendar_today, "Joining", auth.joiningDate),
            ]),

            const SizedBox(height: 15),

            // 🔥 SETTINGS
            _card([
              _tile(Icons.edit, "Edit Profile", _editProfileDialog),
              _tile(Icons.lock, "Change Password", _changePasswordDialog),
              _tile(Icons.settings, "Settings", () {}),
            ]),

            const SizedBox(height: 15),

            // 🔥 LANGUAGE
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

            // 🔥 LOGOUT
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
                child: const Text("END SESSION"),
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