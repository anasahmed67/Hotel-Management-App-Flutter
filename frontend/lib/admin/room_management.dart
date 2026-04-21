import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../core/premium_card.dart';
import '../providers/room_provider.dart';
import '../model/room_model.dart';






class RoomManagement extends StatefulWidget {
  const RoomManagement({super.key});

  @override
  State<RoomManagement> createState() => _RoomManagementState();
}

class _RoomManagementState extends State<RoomManagement> {
  final numCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final totalCtrl = TextEditingController();

  String selectedType = "Standard";
  File? imageFile;
  String? webImagePath;
  List<String> selectedAmenities = [];

  final List<String> types = ["Standard", "Deluxe", "Suite", "VIP"];
  final List<String> amenitiesList = [
    "WiFi", "AC", "TV", "Mini Bar", "Balcony", "Breakfast"
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<RoomProvider>(context, listen: false).fetchRooms();
    });
  }

  Future<void> pickImage(StateSetter setStateDialog) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        webImagePath = picked.path;
      } else {
        imageFile = File(picked.path);
      }
      setState(() {});
      setStateDialog(() {});
    }
  }

  void _showAddDialog() {
    numCtrl.clear();
    priceCtrl.clear();
    totalCtrl.clear();
    selectedAmenities.clear();
    imageFile = null;
    webImagePath = null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: const Color(0xff161b2a),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Add New Room",
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => pickImage(setStateDialog),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Center(child: _previewImage()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _field(numCtrl, "Room Number", Icons.door_front_door_rounded),
                    _field(priceCtrl, "Price per Night", Icons.attach_money_rounded, keyboardType: TextInputType.number),
                    _field(totalCtrl, "Inventory Count", Icons.numbers_rounded, keyboardType: TextInputType.number),
                    const SizedBox(height: 15),
                    DropdownButtonFormField(
                      value: selectedType,
                      dropdownColor: const Color(0xff161b2a),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Room Type", Icons.category_rounded),
                      items: types
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (v) => setStateDialog(() => selectedType = v!),
                    ),
                    const SizedBox(height: 20),
                    _amenitiesPicker(setStateDialog),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        if (numCtrl.text.isEmpty || priceCtrl.text.isEmpty || totalCtrl.text.isEmpty) return;


                        final imagePath = kIsWeb
                            ? (webImagePath ?? "assets/room1.jpg")
                            : (imageFile?.path ?? "assets/room1.jpg");

                        final room = RoomModel(
                          id: "",
                          roomNumber: numCtrl.text,
                          type: selectedType,
                          pricePerNight: double.parse(priceCtrl.text),
                          amenities: selectedAmenities,
                          image: imagePath,
                          isAvailable: true,
                          totalRooms: int.parse(totalCtrl.text),
                        );

                        await Provider.of<RoomProvider>(context, listen: false).addRoom(room);
                        Navigator.pop(context);
                      },
                      child: Text("CREATE ROOM", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _amenitiesPicker(StateSetter setStateDialog) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Amenities", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenitiesList.map((a) {
            final selected = selectedAmenities.contains(a);
            return GestureDetector(
              onTap: () => setStateDialog(() {
                selected ? selectedAmenities.remove(a) : selectedAmenities.add(a);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? AppColors.primary : Colors.white.withOpacity(0.05)),
                ),
                child: Text(a,
                    style: TextStyle(
                        color: selected ? Colors.black : Colors.white70,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(hint, icon),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.cyanAccent, width: 1)),
    );
  }

  Widget _previewImage() {
    if (kIsWeb && webImagePath != null) return ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(webImagePath!, fit: BoxFit.cover));
    if (!kIsWeb && imageFile != null) return ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(imageFile!, fit: BoxFit.cover));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo_rounded, color: Colors.cyanAccent, size: 30),
        const SizedBox(height: 8),
        Text("Upload Image", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoomProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff0b101b),
      appBar: AppBar(
        title: Text("Room Inventory", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.cyanAccent),
            onPressed: () => provider.fetchRooms(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.cyanAccent.withOpacity(0.15),
                foregroundColor: Colors.cyanAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text("NEW", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: _showAddDialog,
            ),
          ),
        ],
      ),
      body: _buildBody(provider),

    );
  }

  Widget _buildBody(RoomProvider provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
            const SizedBox(height: 15),
            Text("Something went wrong", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Text(provider.error!, style: const TextStyle(color: Colors.white38)),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => provider.fetchRooms(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
              child: const Text("Retry Connection"),
            )
          ],
        ),
      );
    }

    if (provider.rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hotel_outlined, color: Colors.white10, size: 100),
            const SizedBox(height: 15),
            Text("No rooms in inventory", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: provider.rooms.length,
      itemBuilder: (_, i) {
        final room = provider.rooms[i];
        return _roomListTile(room, provider);
      },
    );
  }

  Widget _roomListTile(RoomModel room, RoomProvider provider) {
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              width: 80,
              height: 80,
              child: _buildTileImage(room.image),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("No. ${room.roomNumber}", style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    _badge(room.type, AppColors.primary),
                  ],
                ),
                const SizedBox(height: 5),
                Text("Rs ${room.pricePerNight} / night", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 5),
                Text("Stock: ${room.totalRooms} rooms", style: GoogleFonts.outfit(color: AppColors.textDim, fontSize: 11)),

              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.pinkAccent, size: 22),
            onPressed: () async {
              HapticFeedback.heavyImpact();
              final ok = await _confirmDelete();
              if (ok) await provider.deleteRoom(room.id);
            },
          )

        ],
      ),
    );
  }

  Future<bool> _confirmDelete() async {
    return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff161b2a),
        title: Text("Delete Room?", style: GoogleFonts.outfit(color: Colors.white)),
        content: const Text("This action cannot be undone.", style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("DELETE", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    ) ?? false;
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTileImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        color: Colors.white.withOpacity(0.05),
        child: const Icon(Icons.hotel_rounded, color: AppColors.primary),
      );
    }
    return Image.network(
      path,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(color: Colors.white),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (path.startsWith("assets/")) return Image.asset(path, fit: BoxFit.cover);
        if (!kIsWeb) return Image.file(File(path), fit: BoxFit.cover);
        return Container(
          color: Colors.white.withOpacity(0.05),
          child: const Icon(Icons.broken_image_rounded, color: Colors.white24),
        );
      },
    );
  }
}