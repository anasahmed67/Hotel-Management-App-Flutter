class PaymentModel {
  final String bookingId;
  final String method;
  final String accountNumber;
  final String accountTitle;
  final double amount;

  PaymentModel({
    required this.bookingId,
    required this.method,
    required this.accountNumber,
    required this.accountTitle,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      "bookingId": bookingId,
      "method": method,
      "accountNumber": accountNumber,
      "accountTitle": accountTitle,
      "amount": amount,
    };
  }
}