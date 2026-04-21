import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';
import '../core/premium_card.dart';
import '../model/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/room_provider.dart';
import 'booking_management.dart';
import 'room_management.dart';
import 'admin_report_page.dart';
import 'admin_profile _screen.dart';





class AdminDashboard extends StatefulWidget {
  final String adminName;

  const AdminDashboard({super.key, required this.adminName});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  int index = 0;
  BookingModel? lastBooking;
  Timer? _pollTimer;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);

      bookingProvider.fetchAllBookings();
      roomProvider.fetchRooms();

      _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
        await bookingProvider.fetchAllBookings();
        await roomProvider.fetchRooms();
      });
    });

    pages = [
      HomeContent(onNavigate: (i) => setState(() => index = i)),
      const AdminReportPage(),
      const RoomManagement(),
      const BookingManagement(),
      const AdminProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookingProvider, RoomProvider>(
      builder: (context, bookingP, roomP, _) {
        // 🔥 REAL TIME BOOKING ALERT
        if (bookingP.bookings.isNotEmpty) {
          final latest = bookingP.bookings.last;

          if (lastBooking == null ||
              lastBooking!.bookingId != latest.bookingId) {
            lastBooking = latest;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSnack(latest);
            });
          }
        }

        return Scaffold(
          extendBody: true,

          // ================= APP BAR =================
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
                Text(
                  widget.adminName,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            actions: const [
               SizedBox(width: 8),
             ],
           ),


          // ================= BODY =================
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: (index == 0) ? HomeContent(onNavigate: (i) => setState(() => index = i)) : pages[index],
          ),

          // ================= NAV =================
          bottomNavigationBar: _bottomNav(),
        );
      },
    );
  }

  Widget _topAction(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70, size: 20),
        onPressed: () {
          HapticFeedback.lightImpact();
          onTap();
        },
      ),
    );
  }

  // ================= NAV =================
  Widget _bottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _nav(Icons.grid_view_rounded, 0),
            _nav(Icons.analytics_rounded, 1),
            _nav(Icons.meeting_room_rounded, 2),
            _nav(Icons.receipt_long_rounded, 3),
            _nav(Icons.person_rounded, 4),
          ],
        ),
      ),
    );
  }

  Widget _nav(IconData icon, int i) {
    final active = index == i;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => index = i);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutExpo,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: active ? AppColors.primary : Colors.white24,
            ),
            if (active) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }


  // ================= SNACK =================
  void _showSnack(BookingModel b) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.cyanAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(15),
        content: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.black),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "New Booking Alert: ${b.userName} just booked!",
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final Function(int) onNavigate;
  const HomeContent({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final bookingP = Provider.of<BookingProvider>(context);
    final roomP = Provider.of<RoomProvider>(context);
    final currency = NumberFormat.simpleCurrency(name: 'PKR', decimalDigits: 0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
      children: [
        // 🔹 STATS GRID
        Row(
          children: [
            Expanded(
              child: _statCard(
                "Total Revenue",
                currency.format(bookingP.revenue),
                Icons.account_balance_wallet_rounded,
                Colors.tealAccent,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _statCard(
                "Total Bookings",
                bookingP.totalBookings.toString(),
                Icons.book_online_rounded,
                Colors.cyanAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _statCard(
                "Available Status",
                "${roomP.availableRoomCount} / ${roomP.totalRoomInventory}",
                Icons.hotel_rounded,
                Colors.orangeAccent,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _statCard(
                "Pending Task",
                bookingP.pending.toString(),
                Icons.assignment_late_rounded,
                Colors.pinkAccent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // 🔹 QUICK ACTIONS
        _sectionTitle("Quick Actions"),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _quickAction("Add\nRoom", Icons.add_home_work_rounded, Colors.cyanAccent, 2),
            _quickAction("Reports", Icons.bar_chart_rounded, Colors.orangeAccent, 1),
            _quickAction("Bookings", Icons.receipt_long_rounded, Colors.tealAccent, 3),
            _quickAction("Profile", Icons.manage_accounts_rounded, Colors.pinkAccent, 4),
          ],
        ),

        const SizedBox(height: 30),

        // 🔹 CHART SECTION
        _sectionTitle("Booking Trends"),
        const SizedBox(height: 15),
        _chartContainer(),

        const SizedBox(height: 30),

        // 🔹 RECENT BOOKINGS
        _sectionTitle("Recent Bookings"),
        const SizedBox(height: 10),
        if (bookingP.recentBookings.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("No recent activity", style: TextStyle(color: Colors.white38))),
          )
        else
          ...bookingP.recentBookings.map((b) => _recentBookingItem(b)).toList(),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(Icons.trending_up_rounded, color: color.withOpacity(0.4), size: 16),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: AppColors.textDim,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, Color color, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onNavigate(index);
      },
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _chartContainer() {
    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  const FlSpot(0, 3),
                  const FlSpot(2, 5),
                  const FlSpot(4, 4),
                  const FlSpot(6, 8),
                  const FlSpot(8, 6),
                  const FlSpot(10, 9),
                ],
                isCurved: true,
                color: AppColors.primary,
                barWidth: 4,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.primary.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _recentBookingItem(BookingModel b) {
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.userName,
                  style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${b.phone} • Room #${b.roomId}",
                  style: GoogleFonts.outfit(color: AppColors.textDim, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(b.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              b.status.toUpperCase(),
              style: GoogleFonts.outfit(
                color: _statusColor(b.status),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Color _statusColor(String s) {
    switch (s) {
      case "paid": return Colors.tealAccent;
      case "confirmed": return Colors.cyanAccent;
      case "pending": return Colors.orangeAccent;
      case "cancelled": return Colors.pinkAccent;
      default: return Colors.white54;
    }
  }
}
