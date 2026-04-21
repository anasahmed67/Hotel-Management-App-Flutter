import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ================= PROVIDERS =================
import 'providers/auth_provider.dart';
import 'providers/room_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/payment_provider.dart'; // ✅ ADD THIS

import 'core/theme.dart';
import 'core/splash_screen.dart';
import 'customer/screens/role_dashboard.dart';
import 'customer/auth/login_page.dart';
import 'customer/auth/signup_page.dart';
import 'customer/auth/forgot_password.dart';
import 'admin/admin_dashboard.dart';
import 'customer/customer_dashboard.dart';


void main() {
  runApp(const HotelApp());
}

class HotelApp extends StatelessWidget {
  const HotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()), 
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Hotel Booking System",
        theme: AppTheme.dark,
        home: SplashScreen(),



        routes: {
          "/role": (context) => RoleDashboard(),

          // UNIFIED AUTH
          "/customer_login": (context) => LoginPage(),
          "/customer_signup": (context) => SignupPage(),
          "/customer_forgot": (context) => CustomerForgotPassword(),


          // DASHBOARDS
          "/admin_dashboard": (context) =>
              AdminDashboard(adminName: "Admin"),
          "/customer_dashboard": (context) =>
              HomeDashboard(userName: "User"),

        },
      ),
    );
  }
}