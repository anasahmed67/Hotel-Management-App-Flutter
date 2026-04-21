import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/theme.dart';
import '../core/premium_card.dart';
import '../model/booking_model.dart';




class ReceiptScreen extends StatelessWidget {
  final BookingModel booking;
  final String method;
  final String account;

  const ReceiptScreen({
    super.key,
    required this.booking,
    required this.method,
    required this.account,
  });

  // ================= PROFESSIONAL PDF =================
  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              // ================= HEADER =================
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("HOTEL INVOICE",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      )),

                  pw.Text(
                    "Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                  )
                ],
              ),

              pw.Divider(),

              pw.SizedBox(height: 10),

              // ================= CUSTOMER =================
              pw.Text("Customer Details",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 5),

              pw.Text("Name: ${booking.userName}"),
              pw.Text("Phone: ${booking.phone}"),

              pw.SizedBox(height: 15),

              // ================= BOOKING =================
              pw.Text("Booking Details",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 5),

              pw.Text("Room ID: ${booking.roomId}"),
              pw.Text("Check-In: ${booking.checkIn}"),
              pw.Text("Check-Out: ${booking.checkOut}"),
              pw.Text("Rooms: ${booking.roomCount}"),
              pw.Text("Persons: ${booking.persons}"),

              pw.SizedBox(height: 15),

              // ================= PAYMENT =================
              pw.Text("Payment Details",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 5),

              pw.Text("Method: $method"),
              pw.Text("Account: $account"),

              pw.SizedBox(height: 20),

              pw.Divider(),

              // ================= TOTAL =================
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TOTAL",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Text("Rs ${booking.totalAmount}",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ],
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "STATUS: PAID",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.Spacer(),

              // ================= FOOTER =================
              pw.Center(
                child: pw.Text(
                  "Thank you for choosing our hotel!",
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // ================= MODERN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invoice", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),


        child: Column(
          children: [

            PremiumCard(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              borderRadius: 32,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        size: 48, color: AppColors.primary),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Reservation Confirmed",
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Rs ${booking.totalAmount}",
                    style: GoogleFonts.outfit(
                      color: AppColors.secondary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(height: 1, color: Colors.white10),
                  ),

                  _row("Registered Guest", booking.userName),
                  _row("Contact Reference", booking.phone),
                  _row("Suite Assignment", "No. ${booking.roomId}"),
                  _row("Settlement Mode", method),

                  const SizedBox(height: 32),

                  _statusChip(),
                ],
              ),
            ),


            const SizedBox(height: 30),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                final pdf = await _generatePdf();
                await Printing.layoutPdf(
                  onLayout: (format) async => pdf.save(),
                );
              },
              icon: const Icon(Icons.file_download_rounded, color: Colors.black),
              label: Text(
                "PRINT OFFICIAL RECEIPT",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  // ================= ROW =================
  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.outfit(color: AppColors.textDim, fontSize: 13)),
          Text(value,
              style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }


  // ================= STATUS =================
  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.tealAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.2)),
      ),
      child: Text(
        "BOOKING VERIFIED",
        style: GoogleFonts.outfit(
          color: Colors.tealAccent,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }

}