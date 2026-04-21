import 'package:flutter/material.dart';

class AdminProfileProvider with ChangeNotifier {
  String _name = "Admin User";
  String _email = "admin@hotel.com";
  String _role = "Hotel Manager"; // Default role

  // Getters
  String get name => _name;
  String get email => _email;
  String get role => _role;

  // Signup ya Profile Update ke waqt ye call karein
  void updateAdminProfile({required String newName, required String newEmail, String? newRole}) {
    _name = newName;
    _email = newEmail;
    if (newRole != null) _role = newRole;
    
    notifyListeners(); // Ye screen ko refresh karega
  }

  // Logout ke waqt data reset karne ke liye
  void resetAdmin() {
    _name = "";
    _email = "";
    _role = "";
    notifyListeners();
  }
}