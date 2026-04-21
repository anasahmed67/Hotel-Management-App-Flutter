import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/booking_provider.dart';
import '../providers/room_provider.dart';
import 'report_screen.dart';

class AdminReportPage extends StatelessWidget {
  const AdminReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final room = Provider.of<RoomProvider>(context);
    final booking = Provider.of<BookingProvider>(context);

    final totalRooms = room.totalRoomInventory;

    return Scaffold(
      backgroundColor: const Color(0xff0b101b),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Analytics Overview", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart_rounded, color: Colors.cyanAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hotel Performance",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Real-time data synchronization with your database",
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 30),

            // ================= STATS BOXES =================
            _statsGrid(booking),

            const SizedBox(height: 30),

            // ================= INVENTORY CARD =================
            _inventoryCard(totalRooms),

            const SizedBox(height: 40),

            // ================= ACTION BUTTON =================
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportScreen()),
                  );
                },
                icon: const Icon(Icons.analytics_rounded),
                label: Text(
                  "VIEW FULL DETAILED REPORT",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statsGrid(BookingProvider b) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _reportCard("Total Bookings", b.totalBookings.toString(), Icons.book_rounded, Colors.cyanAccent)),
            const SizedBox(width: 15),
            Expanded(child: _reportCard("Paid Orders", b.paid.toString(), Icons.check_circle_rounded, Colors.tealAccent)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _reportCard("Pending", b.pending.toString(), Icons.pending_actions_rounded, Colors.orangeAccent)),
            const SizedBox(width: 15),
            Expanded(child: _reportCard("Cancelled", b.cancelled.toString(), Icons.cancel_rounded, Colors.pinkAccent)),
          ],
        ),
      ],
    );
  }

  Widget _reportCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff161b2a),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 15),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inventoryCard(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xff161b2a), const Color(0xff161b2a).withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.inventory_2_rounded, color: Colors.orangeAccent),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Inventory",
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
              ),
              Text(
                "$count Rooms",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}