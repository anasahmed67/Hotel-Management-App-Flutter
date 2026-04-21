import 'package:flutter/material.dart';

class CustomerProfileProvider with ChangeNotifier {
  String _name = "Guest User";
  String _email = "";
  String _phone = "";
  String _address = "";

  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;

  // Jab Customer Signup ya Login kare
  void setCustomerProfile({
    required String name, 
    required String email, 
    String? phone, 
    String? address
  }) {
    _name = name;
    _email = email;
    _phone = phone ?? "";
    _address = address ?? "";
    
    notifyListeners();
  }

  // Profile Edit karne ke liye
  void updatePhone(String newPhone) {
    _phone = newPhone;
    notifyListeners();
  }

  // Logout logic
  void clearCustomer() {
    _name = "User";
    _email = "";
    _phone = "";
    _address = "";
    notifyListeners();
  }
}