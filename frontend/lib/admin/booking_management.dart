import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../core/theme.dart';
import '../core/premium_card.dart';
import '../providers/booking_provider.dart';
import '../providers/room_provider.dart';
import '../model/booking_model.dart';



class BookingManagement extends StatefulWidget {
  const BookingManagement({super.key});

  @override
  State<BookingManagement> createState() => _BookingManagementState();
}

class _BookingManagementState extends State<BookingManagement> {
  String selectedFilter = "all";

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookingProvider, RoomProvider>(
      builder: (context, bookingP, roomP, _) {
        final filteredBookings = bookingP.bookings.where((b) {
          if (selectedFilter == "all") return true;
          return b.status == selectedFilter;
        }).toList();

        return Scaffold(
          body: Column(
            children: [
              _filterBar(),
              Expanded(
                child: AnimationLimiter(
                  child: filteredBookings.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: filteredBookings.length,
                          itemBuilder: (_, i) {
                            final b = filteredBookings[i];
                            return AnimationConfiguration.staggeredList(
                              position: i,
                              duration: const Duration(milliseconds: 500),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: _bookingCard(b, bookingP, roomP),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterBar() {
    final filters = ["all", "pending", "confirmed", "paid", "cancelled"];
    return Container(
      height: 45,
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final f = filters[i];
          final active = selectedFilter == f;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => selectedFilter = f);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? AppColors.primary : Colors.white.withOpacity(0.05),
                ),
                boxShadow: active ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Text(
                f.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: active ? Colors.black : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bookingCard(BookingModel b, BookingProvider p, RoomProvider roomP) {
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.userName,
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      b.phone,
                      style: GoogleFonts.outfit(color: AppColors.textDim, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _statusBadge(b.status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Colors.white10),
          ),
          Row(
            children: [
              _infoTile(Icons.door_front_door_rounded, "Room", b.assignedRoom ?? "Not Assigned"),
              _infoTile(Icons.calendar_month_rounded, "Stay", "${b.checkIn.day}/${b.checkIn.month} - ${b.checkOut.day}/${b.checkOut.month}"),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rs ${b.totalAmount}",
                style: GoogleFonts.outfit(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${b.roomCount} Rooms • ${b.persons} Persons",
                style: GoogleFonts.outfit(color: AppColors.textDim, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _actionButtons(b, p, roomP),
        ],
      ),
    );
  }


  Widget _infoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white24, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(BookingModel b, BookingProvider p, RoomProvider roomP) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (b.status == 'pending') _subBtn("CONFIRM", Colors.cyanAccent, () => p.confirmBooking(b.bookingId)),
        if (b.status != 'paid' && b.status != 'cancelled') _subBtn("MARK PAID", Colors.tealAccent, () => p.markAsPaid(b.bookingId)),
        if (b.status != 'cancelled') _subBtn("ASSIGN ROOM", Colors.orangeAccent, () => _showAssignDialog(b, p, roomP)),
        if (b.status != 'cancelled' && b.status != 'paid') _subBtn("CANCEL", Colors.pinkAccent, () => p.cancelBooking(b.bookingId)),
      ],
    );
  }

  Widget _subBtn(String label, Color color, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showAssignDialog(BookingModel b, BookingProvider p, RoomProvider roomP) {
    // Get unique available room numbers from room inventory
    final availableRooms = roomP.rooms
        .where((r) => r.isAvailable)
        .map((r) => r.roomNumber)
        .toSet() // 🔥 CRITICAL: Prevent Dropdown crash if duplicate room numbers exist
        .toList();

    // Pre-select current room if it's still available, or pick the first available one
    String? selectedRoom = (b.assignedRoom != null && availableRooms.contains(b.assignedRoom))
        ? b.assignedRoom
        : (availableRooms.isNotEmpty ? availableRooms.first : null);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xff161b2a),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Assign Room", style: GoogleFonts.outfit(color: Colors.white)),
            content: availableRooms.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("No available rooms found in inventory. Please add rooms first.",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  )
                : DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xff161b2a),
                    value: selectedRoom,
                    hint: const Text("Select Room Number", style: TextStyle(color: Colors.white38)),
                    style: const TextStyle(color: Colors.white),
                    items: availableRooms.map((r) => DropdownMenuItem(value: r, child: Text("Room $r"))).toList(),
                    onChanged: (v) => setDialogState(() => selectedRoom = v),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                onPressed: selectedRoom == null
                    ? null
                    : () {
                        p.assignRoom(b.bookingId, selectedRoom!);
                        Navigator.pop(context);
                      },
                child: const Text("ASSIGN", style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusBadge(String s) {
    Color color;
    switch (s) {
      case "paid": color = Colors.tealAccent; break;
      case "confirmed": color = Colors.cyanAccent; break;
      case "pending": color = Colors.orangeAccent; break;
      case "cancelled": color = Colors.pinkAccent; break;
      default: color = Colors.white54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(s.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, color: Colors.white10, size: 100),
          const SizedBox(height: 15),
          Text("No bookings found", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }
}