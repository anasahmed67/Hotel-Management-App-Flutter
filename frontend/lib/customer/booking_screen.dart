import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';

class MyBookings extends StatelessWidget {
  const MyBookings({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      appBar: AppBar(title: const Text("My Bookings")),

      body: ListView.builder(
        itemCount: p.bookings.length,
        itemBuilder: (_, i) {
          final b = p.bookings[i];

          return Card(
            color: const Color(0xff1a2233),
            child: ListTile(
              title: Text(b.userName, style: const TextStyle(color: Colors.white)),
              subtitle: Text("Status: ${b.status}",
                  style: const TextStyle(color: Colors.cyanAccent)),
            ),
          );
        },
      ),
    );
  }
}