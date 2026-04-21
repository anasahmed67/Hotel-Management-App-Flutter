import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme.dart';
import '../core/premium_card.dart';
import 'package:frontend/providers/room_provider.dart';
import 'package:frontend/customer/booking_form_screen.dart';
import 'package:google_fonts/google_fonts.dart';



class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String search = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomProvider>(context, listen: false).fetchRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);

    final rooms = roomProvider.rooms.where((room) {
      final name = room.roomNumber.toString().toLowerCase();
      final type = room.type.toString().toLowerCase();

      return name.contains(search.toLowerCase()) ||
          type.contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xff0b1220),

      // ================= BODY =================
      body: AnimationLimiter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 100),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 500),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [

                const SizedBox(height: 40),

                Text(
                  "Experience Luxury,",
                  style: GoogleFonts.outfit(
                    color: AppColors.textDim,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Find Your Sanctuary",
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                const SizedBox(height: 20),

                // ================= SEARCH =================
                TextField(
                  onChanged: (v) => setState(() => search = v),
                  style: GoogleFonts.outfit(color: AppColors.textPrimary),

                  decoration: InputDecoration(
                    hintText: "Search suites or numbers...",
                    hintStyle: GoogleFonts.outfit(color: AppColors.textDim),

                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.secondary),

                    filled: true,
                    fillColor: Colors.white.withOpacity(0.03),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ================= FEATURED =================
                Text(
                  "Curated Selections 🔥",
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),


                const SizedBox(height: 15),

                // ================= CARDS =================
                roomProvider.isLoading
                    ? _buildShimmerGrid()
                    : roomProvider.error != null
                        ? _errorState(roomProvider.error!)
                        : rooms.isEmpty
                            ? _emptyState()
                            : SizedBox(
                                height: 320,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: rooms.length,
                                  padding: const EdgeInsets.only(bottom: 20),
                                  itemBuilder: (context, i) {
                                    final room = rooms[i];
                                    return AnimationConfiguration.staggeredList(
                                      position: i,
                                      duration: const Duration(milliseconds: 600),
                                      child: SlideAnimation(
                                        horizontalOffset: 80.0,
                                        child: FadeInAnimation(
                                          child: _roomCard(room),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= ROOM CARD DESIGN =================
  Widget _roomCard(dynamic room) {
    return PremiumCard(
      width: 240,
      margin: const EdgeInsets.only(right: 20),
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE AREA
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: room.image != null && room.image.isNotEmpty
                    ? Image.network(room.image, fit: BoxFit.cover, width: double.infinity)
                    : const Center(
                        child: Icon(Icons.hotel_rounded, size: 50, color: AppColors.primary),
                      ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Room ${room.roomNumber}",
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      room.type,
                      style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Rs ${room.pricePerNight}",
                  style: GoogleFonts.outfit(
                    color: AppColors.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingFormScreen(room: room),
                      ),
                    );
                  },
                  child: Text("VIEW SUITE", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            width: 240,
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          ),
        ),
      ),
    );
  }

  Widget _errorState(String msg) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Text(msg, style: const TextStyle(color: Colors.pinkAccent)),
    );
  }

  Widget _emptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Text("No suites matched your search.", style: GoogleFonts.outfit(color: AppColors.textDim)),
    );
  }
}