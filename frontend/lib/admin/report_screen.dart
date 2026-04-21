import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/booking_provider.dart';
import '../model/booking_model.dart';
import '../customer/receipt_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff0b1220),

      appBar: AppBar(
        title: const Text("Reports Dashboard"),
        backgroundColor: const Color(0xff0b1220),
        elevation: 0,
      ),

      body: FadeTransition(
        opacity: _controller,
        child: Column(
          children: [

            // ================= SUMMARY CARDS =================
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _summaryCard("Total", p.totalBookings, Icons.book),
                  _summaryCard("Paid", p.paid, Icons.payment),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _summaryCard("Pending", p.pending, Icons.timelapse),
                  _summaryCard("Revenue", p.revenue.toInt(), Icons.attach_money),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ================= TITLE =================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bookings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ================= LIST =================
            Expanded(
              child: ListView.builder(
                itemCount: p.bookings.length,
                itemBuilder: (_, i) {
                  final b = p.bookings[i];

                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 300 + (i * 80)),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: _bookingCard(context, i + 1, b),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget _summaryCard(String title, num value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xff1e293b), Color(0xff0f172a)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.15),
              blurRadius: 15,
            )
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.cyanAccent),
            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 5),

            Text(
              "$value",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BOOKING CARD =================
  Widget _bookingCard(BuildContext context, int index, BookingModel b) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xff1a2233),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 🔹 TOP ROW
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.cyanAccent,
                child: Text(
                  "$index",
                  style: const TextStyle(color: Colors.black),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  b.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              _statusBadge(b.status),
            ],
          ),

          const SizedBox(height: 10),

          // 🔹 DATES
          Row(
            children: [
              _info("Check-In", _formatDate(b.checkIn)),
              const SizedBox(width: 10),
              _info("Check-Out", _formatDate(b.checkOut)),
            ],
          ),

          const SizedBox(height: 10),

          // 🔹 ACTION
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.receipt, color: Colors.cyanAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReceiptScreen(
                      booking: b,
                      method: "N/A",
                      account: b.phone,
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // ================= INFO BOX =================
  Widget _info(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ================= STATUS BADGE =================
  Widget _statusBadge(String s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _statusColor(s).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        s.toUpperCase(),
        style: TextStyle(
          color: _statusColor(s),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= DATE FORMAT =================
  String _formatDate(DateTime d) {
    return "${d.day}/${d.month} ${d.hour}:${d.minute}";
  }

  // ================= STATUS COLOR =================
  Color _statusColor(String s) {
    switch (s) {
      case "paid":
        return Colors.green;
      case "confirmed":
        return Colors.blue;
      case "pending":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.white;
    }
  }
}