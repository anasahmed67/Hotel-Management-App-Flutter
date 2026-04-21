import 'package:flutter/material.dart';
import '../model/room_model.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoomProvider extends ChangeNotifier {
  List<RoomModel> _rooms = [];

  List<RoomModel> get rooms => _rooms;

  List<String> _parseAmenities(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (raw is String) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return raw
        .toString()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String lastMessage = "";
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ================= FETCH ROOMS =================
  Future<void> fetchRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await http.get(Uri.parse("${ApiService.baseUrl}/rooms"));
      
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        _rooms = data.map<RoomModel>((e) {
          final price = double.tryParse(e['pricePerNight'].toString()) ?? 0.0;
          final totalRooms = int.tryParse(e['totalRooms'].toString()) ?? 0;

          return RoomModel(
            id: e['id'].toString(),
            roomNumber: e['roomNumber'].toString(),
            type: e['type']?.toString() ?? '',
            pricePerNight: price,
            amenities: _parseAmenities(e['amenities']),
            image: e['image']?.toString(),
            isAvailable: e['isAvailable'] == true || e['isAvailable'] == 1,
            totalRooms: totalRooms,
          );
        }).toList();
      } else {
        final decoded = jsonDecode(res.body);
        _error = decoded['error'] ?? "Failed to fetch rooms";
      }
    } catch (e) {
      _error = e.toString();
      print("Fetch Rooms Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= ADD ROOM =================
  Future<bool> addRoom(RoomModel room) async {
    final result = await ApiService.addRoom({
      "roomNumber": room.roomNumber,
      "type": room.type,
      "pricePerNight": room.pricePerNight,
      "amenities": room.amenities,
      "image": room.image,
      "isAvailable": room.isAvailable,
      "totalRooms": room.totalRooms,
    });

    lastMessage = result["message"] ?? (result["success"] ? "Room added" : "Failed to add room");
    if (result["success"]) {
      await fetchRooms();
    }
    notifyListeners();
    return result["success"];
  }

  // ================= DELETE ROOM =================
  Future<bool> deleteRoom(String id) async {
    final result = await ApiService.deleteRoom(id);

    lastMessage = result["message"] ?? (result["success"] ? "Room deleted" : "Failed to delete room");
    if (result["success"]) {
      _rooms.removeWhere((r) => r.id == id);
    }
    notifyListeners();
    return result["success"];
  }

  // ================= TOGGLE AVAILABILITY =================
  Future<void> toggleAvailability(RoomModel room) async {
    final updated = !room.isAvailable;

    final ok = await ApiService.updateRoom(room.id, {
      "isAvailable": updated,
    });

    if (ok) {
      room.isAvailable = updated;
      notifyListeners();
    }
  }
  // ================= STATS =================
  int get totalRoomInventory => _rooms.fold(0, (sum, r) => sum + r.totalRooms);
  int get availableRoomCount => _rooms.where((r) => r.isAvailable).length;
}
