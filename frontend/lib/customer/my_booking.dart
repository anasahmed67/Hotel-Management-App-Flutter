import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/premium_card.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';
import '../model/booking_model.dart';


class MyBookings extends StatefulWidget {
  const MyBookings({super.key});

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  Timer? timer;
  String? lastStatus;
  final phoneCtrl = TextEditingController();
  String activePhone = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAutomated();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    phoneCtrl.dispose();
    super.dispose();
  }

  void _loadAutomated() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final phone = auth.phone;

    if (phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number not found in profile")),
      );
      return;
    }

    await _startPolling(phone);
  }

  Future<void> _startPolling(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter phone number")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("my_bookings_phone", cleaned);

    lastStatus = null;

    setState(() => activePhone = cleaned);

    final provider = Provider.of<BookingProvider>(context, listen: false);
    await provider.fetchMyBookings(cleaned);

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await provider.fetchMyBookings(cleaned);
    });
  }

  void _checkNotification(BookingModel b) {
    if (lastStatus == null) {
      lastStatus = b.status;
      return;
    }

    if (lastStatus != b.status) {
      lastStatus = b.status;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status updated: ${b.status}"),
            backgroundColor: Colors.cyanAccent,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff0b1220),

      appBar: AppBar(
        title: Text("My Reservations", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Column(
        children: [
          if (activePhone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Syncing bookings for $activePhone",
                        style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),
          Expanded(
            child: AnimationLimiter(
              child: p.bookings.isEmpty
                  ? Center(
                      child: Text(
                        "No bookings found yet.",
                        style: GoogleFonts.outfit(color: AppColors.textDim),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      itemCount: p.bookings.length,
                      itemBuilder: (_, i) {
                        final b = p.bookings[i];
                        _checkNotification(b);
                        return AnimationConfiguration.staggeredList(
                          position: i,
                          duration: const Duration(milliseconds: 600),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: _bookingCard(b)),
                          ),
                        );
                      },
                    ),
            ),
          ),

        ],
      ),
    );
  }

  // ================= BEAUTIFUL CARD =================
  Widget _bookingCard(BookingModel b) {
    final color = _statusColor(b.status);

    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                b.userName,
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _statusChip(b.status),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Colors.white10),
          ),

          // ================= ROOM =================
          Row(
            children: [
              const Icon(Icons.hotel_rounded, size: 16, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                "Suite ${b.assignedRoom ?? "unassigned"}",
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ================= DATE =================
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textDim),
              const SizedBox(width: 8),
              Text(
                "${_formatDate(b.checkIn)} → ${_formatDate(b.checkOut)}",
                style: GoogleFonts.outfit(color: AppColors.textDim, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ================= FOOTER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // STATUS ICON
              Row(
                children: [
                  Icon(_statusIcon(b.status), color: color, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    b.status.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // PRICE
              Text(
                "Rs ${b.totalAmount}",
                style: GoogleFonts.outfit(
                  color: AppColors.secondary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ================= STATUS CHIP =================
  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ================= DATE FORMAT =================
  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}";
  }

  // ================= STATUS ICON =================
  IconData _statusIcon(String status) {
    switch (status) {
      case "confirmed":
        return Icons.verified_rounded;
      case "cancelled":
        return Icons.cancel_rounded;
      case "paid":
        return Icons.payments_rounded;
      case "waiting":
        return Icons.hourglass_top_rounded;
      default:
        return Icons.pending_actions_rounded;
    }
  }

  // ================= STATUS COLOR =================
  Color _statusColor(String status) {
    switch (status) {
      case "confirmed":
        return Colors.tealAccent;
      case "cancelled":
        return Colors.pinkAccent;
      case "paid":
        return AppColors.secondary;
      case "waiting":
        return Colors.orangeAccent;
      default:
        return AppColors.textDim;
    }
  }
}
