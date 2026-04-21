import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {

  static Future<void> generateInvoice(Map<String, dynamic> booking) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(10),

            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,

              children: [

                // ================= HEADER =================
                pw.Center(
                  child: pw.Text(
                    "HOTEL RECEIPT",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 10),
                pw.Divider(),

                // ================= DETAILS =================
                pw.Text("Customer Name: ${booking["name"] ?? ""}"),
                pw.Text("Room: ${booking["room"] ?? ""}"),
                pw.Text("Check-in: ${(booking["start"] ?? "").toString().split(" ")[0]}"),
                pw.Text("Check-out: ${(booking["end"] ?? "").toString().split(" ")[0]}"),
                pw.Text("Guests: ${booking["guests"] ?? 0}"),

                pw.SizedBox(height: 10),
                pw.Divider(),

                // ================= PRICE =================
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Total:",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      "Rs ${booking["price"] ?? 0}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // ================= PAID STATUS =================
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.green, width: 2),
                    ),
                    child: pw.Text(
                      "PAID",
                      style: pw.TextStyle(
                        color: PdfColors.green,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                // ================= FOOTER =================
                pw.Center(
                  child: pw.Text(
                    "Thank you for staying with us!",
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // ================= PRINT / SAVE =================
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}