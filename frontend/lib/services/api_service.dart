import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  // ===========================
  // PAYMENT API
  // ===========================

  static Future<Map<String, dynamic>> makePayment({
    required String bookingId,
    required String method,
    required String accountNumber,
    required String accountTitle,
    required double amount,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/payment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "bookingId": bookingId,
          "method": method,
          "accountNumber": accountNumber,
          "accountTitle": accountTitle,
          "amount": amount,
        }),
      );

      final decoded = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {"success": true, "message": decoded["message"]};
      } else {
        return {"success": false, "message": decoded["error"] ?? "Payment failed"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ===========================
  // ROOM APIs
  // ===========================

  static Future<Map<String, dynamic>> addRoom(Map<String, dynamic> room) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/rooms"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(room),
      );

      final decoded = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {"success": true, "message": decoded["message"]};
      } else {
        return {"success": false, "message": decoded["error"] ?? "Failed to add room"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<List<dynamic>> getRooms() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/rooms"));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Get Rooms Error: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> deleteRoom(String id) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/rooms/$id"),
      );

      final decoded = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return {"success": true, "message": decoded["message"]};
      } else {
        return {"success": false, "message": decoded["error"] ?? "Failed to delete room"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<bool> updateRoom(String id, Map<String, dynamic> room) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/rooms/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(room),
      );

      return res.statusCode == 200;
    } catch (e) {
      print("Update Room Error: $e");
      return false;
    }
  }

  // ===========================
  // BOOKING APIs
  // ===========================

  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/booking"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      final decoded = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {"bookingId": decoded["bookingId"].toString(), "success": true};
      } else {
        return {"success": false, "error": decoded["error"] ?? "Booking failed"};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<List<dynamic>> getMyBookings(String phone) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/bookings/$phone"),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Get Booking Error: $e");
      return [];
    }
  }

  static Future<List<dynamic>> getAllBookings() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/bookings"));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Get All Bookings Error: $e");
      return [];
    }
  }

  static Future<bool> updateStatus(String bookingId, String status) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/booking/status"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "bookingId": bookingId,
          "status": status,
        }),
      );

      return res.statusCode == 200;
    } catch (e) {
      print("Update Status Error: $e");
      return false;
    }
  }

  static Future<bool> assignRoom(String bookingId, String room) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/booking/assign"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "bookingId": bookingId,
          "room": room,
        }),
      );

      return res.statusCode == 200;
    } catch (e) {
      print("Assign Room Error: $e");
      return false;
    }
  }
}
