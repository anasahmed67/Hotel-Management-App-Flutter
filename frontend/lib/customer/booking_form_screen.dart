import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/model/booking_model.dart';
import 'package:frontend/model/room_model.dart';
import 'package:frontend/providers/booking_provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/customer/payment_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final RoomModel room;

  const BookingFormScreen({super.key, required this.room});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final nicCtrl = TextEditingController();

  DateTime? checkIn;
  DateTime? checkOut;

  int rooms = 1;
  int persons = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      nameCtrl.text = auth.name;
      phoneCtrl.text = auth.phone;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      appBar: AppBar(title: const Text("Booking Form")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔹 ROOM CARD
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.room.type,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 5),
                  Text("Rs ${widget.room.pricePerNight} / night",
                      style: const TextStyle(color: Colors.cyanAccent)),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 USER INFO
            _card(
              child: Column(
                children: [
                  _field(nameCtrl, "Full Name"),
                  _field(phoneCtrl, "Phone"),
                  _field(nicCtrl, "CNIC"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 DATES
            _card(
              child: Column(
                children: [
                  _dateBox("Check In", checkIn,
                      (v) => setState(() => checkIn = v)),
                  _dateBox("Check Out", checkOut,
                      (v) => setState(() => checkOut = v)),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 COUNTERS
            _card(
              child: Column(
                children: [
                  _counter("Persons", persons,
                      (v) => setState(() => persons = v)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔥 BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.white, // ✅ TEXT WHITE
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: () async {
                if (nameCtrl.text.isEmpty ||
                    phoneCtrl.text.isEmpty ||
                    nicCtrl.text.isEmpty ||
                    checkIn == null ||
                    checkOut == null) {
                  _msg("Fill all fields");
                  return;
                }

                if (checkOut!.isBefore(checkIn!)) {
                  _msg("Invalid dates");
                  return;
                }

                final price = widget.room.pricePerNight.toDouble();
                final days =
                    checkOut!.difference(checkIn!).inDays.clamp(1, 999);

                final total = days * rooms * price;

                final booking = BookingModel(
                  bookingId: "",
                  userName: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  nic: nicCtrl.text.trim(),
                  roomId: widget.room.id.toString(),
                  checkIn: checkIn!,
                  checkOut: checkOut!,
                  roomCount: rooms,
                  persons: persons,
                  totalAmount: total,
                  status: "pending",
                );

                final created = await provider.createBooking(booking);
                if (created == null) {
                  _msg(provider.lastMessage);
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PaymentScreen(booking: created),
                  ),
                );
              },

              child: const Text(
                "BOOK NOW",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 CARD UI
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xff1a2233),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  // 🔹 INPUT FIELD
  Widget _field(TextEditingController c, String h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: h,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 🔹 DATE PICKER
  Widget _dateBox(String label, DateTime? date, Function(DateTime) onPick) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (d == null) return;

        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (t == null) return;

        onPick(DateTime(d.year, d.month, d.day, t.hour, t.minute));
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          date == null ? "$label (Tap)" : "$label\n$date",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // 🔹 COUNTER
  Widget _counter(String t, int v, Function(int) onChange) {
    return Row(
      children: [
        Text(t, style: const TextStyle(color: Colors.white)),
        const Spacer(),
        IconButton(
          onPressed: () => onChange(v + 1),
          icon: const Icon(Icons.add, color: Colors.cyanAccent),
        ),
        Text("$v", style: const TextStyle(color: Colors.white)),
        IconButton(
          onPressed: () {
            if (v > 1) onChange(v - 1);
          },
          icon: const Icon(Icons.remove, color: Colors.cyanAccent),
        ),
      ],
    );
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }
}
