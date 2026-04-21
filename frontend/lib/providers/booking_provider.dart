import 'package:flutter/material.dart';
import '../model/booking_model.dart';
import '../services/api_service.dart';

class BookingProvider extends ChangeNotifier {
  final List<BookingModel> _bookings = [];

  String lastMessage = "";
  bool hasNewNotification = false;

  List<BookingModel> get bookings => _bookings;

  String _dateOnly(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  /// ================= CREATE BOOKING =================
  Future<BookingModel?> createBooking(BookingModel draft) async {
    final result = await ApiService.createBooking({
      "userName": draft.userName,
      "phone": draft.phone,
      "nic": draft.nic,
      "roomId": draft.roomId,
      "checkIn": _dateOnly(draft.checkIn),
      "checkOut": _dateOnly(draft.checkOut),
      "roomCount": draft.roomCount,
      "persons": draft.persons,
      "totalAmount": draft.totalAmount,
      "status": draft.status,
    });

    if (result["success"] == true) {
      final bookingId = result["bookingId"];
      final created = draft.copyWith(bookingId: bookingId);
      _bookings.add(created);

      lastMessage = "Booking created successfully";
      hasNewNotification = true;
      notifyListeners();
      return created;
    } else {
      lastMessage = result["error"] ?? "Booking failed";
      notifyListeners();
      return null;
    }
  }

  /// ================= FETCH BOOKINGS =================
  Future<void> fetchAllBookings() async {
    try {
      final data = await ApiService.getAllBookings();

      _bookings
        ..clear()
        ..addAll(
          data.map<BookingModel>((item) {
            final roomCount = int.tryParse(item['roomCount'].toString()) ?? 0;
            final persons = int.tryParse(item['persons'].toString()) ?? 0;
            final totalAmount =
                double.tryParse(item['totalAmount'].toString()) ?? 0.0;

            return BookingModel(
              bookingId: item['bookingId'].toString(),
              userName: item['userName']?.toString() ?? '',
              phone: item['phone']?.toString() ?? '',
              nic: item['nic']?.toString() ?? "",
              roomId: item['roomId'].toString(),
              checkIn: DateTime.parse(item['checkIn'].toString()),
              checkOut: DateTime.parse(item['checkOut'].toString()),
              roomCount: roomCount,
              persons: persons,
              totalAmount: totalAmount,
              status: item['status']?.toString() ?? 'pending',
              assignedRoom: item['assignedRoom']?.toString(),
            );
          }).toList(),
        );

      notifyListeners();
    } catch (e) {
      print("Fetch all bookings error: $e");
    }
  }

  Future<void> fetchMyBookings(String phone) async {
    try {
      final data = await ApiService.getMyBookings(phone);

      _bookings
        ..clear()
        ..addAll(
          data.map<BookingModel>((item) {
            final roomCount = int.tryParse(item['roomCount'].toString()) ?? 0;
            final persons = int.tryParse(item['persons'].toString()) ?? 0;
            final totalAmount =
                double.tryParse(item['totalAmount'].toString()) ?? 0.0;

            return BookingModel(
              bookingId: item['bookingId'].toString(),
              userName: item['userName']?.toString() ?? '',
              phone: item['phone']?.toString() ?? '',
              nic: item['nic']?.toString() ?? "",
              roomId: item['roomId'].toString(),
              checkIn: DateTime.parse(item['checkIn'].toString()),
              checkOut: DateTime.parse(item['checkOut'].toString()),
              roomCount: roomCount,
              persons: persons,
              totalAmount: totalAmount,
              status: item['status']?.toString() ?? 'pending',
              assignedRoom: item['assignedRoom']?.toString(),
            );
          }).toList(),
        );

      lastMessage = "Bookings updated";
      hasNewNotification = true;

      notifyListeners();
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  /// ================= STATUS UPDATE =================
  void _updateStatus(String id, String status) {
    final index = _bookings.indexWhere((b) => b.bookingId == id);
    if (index == -1) return;

    _bookings[index] = _bookings[index].copyWith(status: status);

    lastMessage = "Status: $status";
    hasNewNotification = true;

    notifyListeners();
  }

  Future<void> markAsPaid(String id) async {
    _updateStatus(id, "paid");
    await ApiService.updateStatus(id, "paid");
  }

  Future<void> confirmBooking(String id) async {
    _updateStatus(id, "confirmed");
    await ApiService.updateStatus(id, "confirmed");
  }

  Future<void> cancelBooking(String id) async {
    _updateStatus(id, "cancelled");
    await ApiService.updateStatus(id, "cancelled");
  }

  Future<void> assignRoom(String id, String room) async {
    final index = _bookings.indexWhere((b) => b.bookingId == id);
    if (index == -1) return;

    _bookings[index] =
        _bookings[index].copyWith(status: "confirmed", assignedRoom: room);

    await ApiService.assignRoom(id, room);

    lastMessage = "Room assigned";
    hasNewNotification = true;

    notifyListeners();
  }

  void setStatusLocal(String id, String status) {
    _updateStatus(id, status);
  }

  void clearNotification() {
    hasNewNotification = false;
    notifyListeners();
  }

  /// ================= STATS =================
  int get totalBookings => _bookings.length;
  int get pending => _bookings.where((b) => b.status == "pending").length;
  int get confirmed => _bookings.where((b) => b.status == "confirmed").length;
  int get cancelled => _bookings.where((b) => b.status == "cancelled").length;
  int get paid => _bookings.where((b) => b.status == "paid").length;
  int get waiting => _bookings.where((b) => b.status == "waiting").length;

  double get revenue => _bookings
      .where((b) => b.status == "paid")
      .fold(0.0, (sum, b) => sum + b.totalAmount);

  List<BookingModel> get recentBookings =>
      _bookings.reversed.take(5).toList();
}
