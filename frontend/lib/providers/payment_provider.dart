import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentProvider extends ChangeNotifier {
  String method = "";

  void setMethod(String m) {
    method = m;
    notifyListeners();
  }

  Future<bool> makePayment({
    required String bookingId,
    required String accountNumber,
    required String accountTitle,
    required double amount,
  }) async {
    final result = await ApiService.makePayment(
      bookingId: bookingId,
      method: method,
      accountNumber: accountNumber,
      accountTitle: accountTitle,
      amount: amount,
    );
    return result["success"] ?? false;
  }
}