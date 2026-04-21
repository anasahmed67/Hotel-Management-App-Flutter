import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  static final String _baseUrl = "${ApiConfig.baseUrl}/auth";

  // 🟢 SIGNUP
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String phone = "",
    String role = 'customer',
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
          "role": role,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Connection failed: $e"};
    }
  }

  // 🔐 LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Connection failed: $e"};
    }
  }

  // 🔁 UPDATE PROFILE
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/update-profile"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Connection failed: $e"};
    }
  }

  // 🔑 CHANGE PASSWORD
  static Future<Map<String, dynamic>> changePassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/change-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Connection failed: $e"};
    }
  }

  // 🔁 RESET PASSWORD (Optional for now)
  static Future<bool> reset(String email) async {
    // Implement if needed
    return true;
  }
}