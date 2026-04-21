import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme.dart';
import '../core/premium_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'my_booking.dart';
import 'customer_profile_screen.dart';




class HomeDashboard extends StatefulWidget {
  final String userName;

  const HomeDashboard({super.key, required this.userName});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int selectedIndex = 0;
  String? lastMessage;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomePage(userName: widget.userName),
      const MyBookings(),
      const CustomerProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, p, _) {

        // 🔔 REAL-TIME SNACKBAR
        if (p.lastMessage.isNotEmpty && lastMessage != p.lastMessage) {
          lastMessage = p.lastMessage;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.cyanAccent,
                content: Text(
                  p.lastMessage,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            );
          });
        }

        return Scaffold(
          extendBody: true,


          // ================= APP BAR =================
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0b1220), Color(0xff1a2233)],
                ),
              ),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome,",
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textDim),
                    ),
                    Text(
                      widget.userName,
                      style: GoogleFonts.outfit(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),

                actions: const [
                   SizedBox(width: 8),
                 ],

              ),
            ),
          ),

          // ================= BODY =================
          body: IndexedStack(
            index: selectedIndex,
            children: _screens,
          ),

          // ================= BOTTOM NAV =================
          bottomNavigationBar: _bottomNav(),
        );
      },
    );
  }

  // ================= HOME CONTENT =================
  Widget _homeContent(BookingProvider p) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          // 👋 Greeting Card
          _card(
            "Hello ${widget.userName}",
            "Welcome back to your dashboard",
            Icons.person,
            Colors.cyanAccent,
          ),

          // 📅 My Bookings
          _card(
            "My Bookings",
            "View your current bookings",
            Icons.book,
            Colors.orangeAccent,
          ),

          // 💳 Payments
          _card(
            "Payments",
            "Manage your payments",
            Icons.payment,
            Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _card(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            const Color(0xff1a2233),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 35),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white70)),
            ],
          )
        ],
      ),
    );
  }

  // ================= BOTTOM NAV =================
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
            _nav(Icons.confirmation_num_rounded, 1),
            _nav(Icons.person_rounded, 2),
          ],
        ),
      ),
    );
  }


  Widget _nav(IconData icon, int i) {
    final active = selectedIndex == i;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => selectedIndex = i);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutExpo,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

}