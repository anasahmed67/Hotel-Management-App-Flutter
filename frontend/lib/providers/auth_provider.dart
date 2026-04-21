import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  String name = "";
  String email = "";
  String password = "";
  String role = "";

  String phone = "";
  String joiningDate = "";
  String errorMessage = ""; // Added to track specific server errors

  bool isLoggedIn = false;


  // ================= LOAD USER =================
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    role = prefs.getString("role") ?? "";

    if (role.isEmpty) return;

    name = prefs.getString("${role}_name") ?? "";
    email = prefs.getString("${role}_email") ?? "";
    password = prefs.getString("${role}_password") ?? "";
    phone = prefs.getString("${role}_phone") ?? "";
    joiningDate = prefs.getString("${role}_joining") ?? "";

    isLoggedIn = email.isNotEmpty;

    notifyListeners();
  }

  // ================= SIGNUP =================
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    String phone = "",
  }) async {
    const defaultRole = "customer"; // Force customer role for public signups
    
    final response = await AuthService.signup(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: defaultRole,
    );

    if (response['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("role", defaultRole);
      await prefs.setString("${defaultRole}_name", name);
      await prefs.setString("${defaultRole}_email", email);
      await prefs.setString("${defaultRole}_password", password);
      await prefs.setString("${defaultRole}_phone", phone);
      await prefs.setString("${defaultRole}_joining", DateTime.now().toString());

      this.name = name;
      this.email = email;
      this.password = password;
      this.role = defaultRole;
      this.phone = phone;
      this.joiningDate = DateTime.now().toString();

      isLoggedIn = true;
      notifyListeners();
      return true;
    }

    return false;
  }

  // ================= LOGIN =================
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    errorMessage = ""; // Reset
    final response = await AuthService.login(
      email: email,
      password: password,
    );

    if (response['status'] == 'success') {
      final userData = response['user'];
      final serverRole = userData['role'] ?? "customer";
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("role", serverRole);
      await prefs.setString("${serverRole}_name", userData['name']);
      await prefs.setString("${serverRole}_email", userData['email']);
      await prefs.setString("${serverRole}_password", password);
      
      this.name = userData['name'];
      this.email = userData['email'];
      this.role = serverRole;
      this.phone = userData['phone'] ?? "";
      isLoggedIn = true;

      notifyListeners();
      return true;
    } else {
      errorMessage = response['message'] ?? "Unknown error occurred";
      notifyListeners();
    }

    return false;
  }


  // ================= CHANGE PASSWORD (API based) =================
  Future<bool> changePassword(String newPassword) async {
    final response = await AuthService.changePassword(
      email: email,
      password: newPassword,
    );

    if (response['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      password = newPassword;
      await prefs.setString("${role}_password", newPassword);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ================= UPDATE PROFILE =================
  Future<bool> updateProfile({
    required String newName,
    required String newPhone,
  }) async {
    final response = await AuthService.updateProfile(
      name: newName,
      email: email,
      phone: newPhone,
    );

    if (response['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      name = newName;
      phone = newPhone;
      await prefs.setString("${role}_name", newName);
      await prefs.setString("${role}_phone", newPhone);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ================= FORGOT PASSWORD =================
  Future<bool> forgotPassword({
    required String email,
    required String role,
  }) async {
    // This would typically involve an email service in a real app
    return true;
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("role");
    isLoggedIn = false;
    notifyListeners();
  }

  bool get isAdmin => role == "admin";
}