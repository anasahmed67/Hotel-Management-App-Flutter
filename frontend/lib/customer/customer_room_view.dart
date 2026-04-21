import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import 'booking_form_screen.dart';
import 'dart:io';

class CustomerRoomView extends StatefulWidget {
  const CustomerRoomView({super.key});

  @override
  State<CustomerRoomView> createState() => _CustomerRoomViewState();
}

class _CustomerRoomViewState extends State<CustomerRoomView> {

  @override
  void initState() {
    super.initState();

    // 🔥 IMPORTANT: fetch rooms
    Future.microtask(() {
      Provider.of<RoomProvider>(context, listen: false).fetchRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoomProvider>(context);

    final rooms = provider.rooms
        .where((r) => r.isAvailable)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xff0b1220),

      appBar: AppBar(
        title: const Text("Available Rooms"),
        centerTitle: true,
        backgroundColor: const Color(0xff0b1220),
      ),

      body: provider.rooms.isEmpty
          ? const Center(child: CircularProgressIndicator()) // 🔥 loading
          : rooms.isEmpty
              ? const Center(
                  child: Text(
                    "No Rooms Available",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: rooms.length,
                  itemBuilder: (_, i) {
                    final r = rooms[i];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xff1a2233),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        children: [

                          // IMAGE
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(20)),
                            child: _buildImage(r.image),
                          ),

                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    "Room ${r.roomNumber}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    r.type,
                                    style: const TextStyle(
                                        color: Colors.cyanAccent),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    "Rs ${r.pricePerNight}",
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    r.amenities.join(", "),
                                    style:
                                        const TextStyle(color: Colors.white38),
                                  ),

                                  const SizedBox(height: 10),

                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyanAccent,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              BookingFormScreen(room: r),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Book Now",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  // ✅ IMAGE HANDLER (FIXED)
  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return _placeholder();
    }

    if (path.startsWith("assets/")) {
      return Image.asset(
        path,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    try {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        );
      }
    } catch (_) {}

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.black26,
      child: const Icon(Icons.hotel, color: Colors.cyanAccent),
    );
  }
}