import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/payment_provider.dart';
import 'receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final accCtrl = TextEditingController();
  final pinCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    accCtrl.dispose();
    pinCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      appBar: AppBar(
        title: const Text("Secure Payment"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// ===== AMOUNT CARD =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff22c55e), Color(0xff06b6d4)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rs ${widget.booking.totalAmount}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ===== PAYMENT METHODS =====
            _methodCard("JazzCash", Icons.account_balance_wallet),
            _methodCard("EasyPaisa", Icons.phone_android),
            _methodCard("HBL", Icons.account_balance),

            const SizedBox(height: 20),

            /// ===== INPUTS =====
            _inputField(nameCtrl, "Account Title", Icons.person),
            const SizedBox(height: 12),
            _inputField(accCtrl, "Account Number", Icons.credit_card),
            const SizedBox(height: 12),
            _inputField(pinCtrl, "PIN", Icons.lock, isPassword: true),

            const SizedBox(height: 30),

            /// ===== PAY BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        if (paymentProvider.method.isEmpty) {
                          _msg("Select payment method");
                          return;
                        }

                        if (nameCtrl.text.isEmpty ||
                            accCtrl.text.isEmpty ||
                            pinCtrl.text.isEmpty) {
                          _msg("Fill all fields");
                          return;
                        }

                        if (pinCtrl.text.length < 4) {
                          _msg("Invalid PIN");
                          return;
                        }

                        setState(() => isLoading = true);

                        /// ✅ CALL PROVIDER (FIXED)
                        final ok = await paymentProvider.makePayment(
                          bookingId: widget.booking.bookingId,
                          accountNumber: accCtrl.text,
                          accountTitle: nameCtrl.text,
                          amount: widget.booking.totalAmount,
                        );

                        setState(() => isLoading = false);

                        if (!ok) {
                          _msg("Payment failed");
                          return;
                        }

                        /// ❌ markAsPaid REMOVE (backend already karta hai)

                        Provider.of<BookingProvider>(context, listen: false)
                            .setStatusLocal(widget.booking.bookingId, "paid");

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReceiptScreen(
                              booking: widget.booking,
                              method: paymentProvider.method,
                              account: accCtrl.text,
                            ),
                          ),
                        );
                      },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff6366f1), Color(0xff8b5cf6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "PAY NOW",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ===== INPUT FIELD =====
  Widget _inputField(
      TextEditingController ctrl, String hint, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xff1e293b),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// ===== METHOD CARD =====
  Widget _methodCard(String title, IconData icon) {
    final p = Provider.of<PaymentProvider>(context);
    final isSelected = p.method == title;

    return GestureDetector(
      onTap: () => p.setMethod(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.indigo.withOpacity(0.25)
              : const Color(0xff1e293b),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.greenAccent)
          ],
        ),
      ),
    );
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }
}
