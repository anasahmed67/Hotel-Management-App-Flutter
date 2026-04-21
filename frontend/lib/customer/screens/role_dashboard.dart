import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RoleDashboard extends StatefulWidget {
  const RoleDashboard({super.key});

  @override
  State<RoleDashboard> createState() => _RoleDashboardState();
}

class _RoleDashboardState extends State<RoleDashboard>
    with SingleTickerProviderStateMixin {

  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                      const Color(0xff0b1220),
                      const Color(0xff162036),
                      _bgController.value)!,
                  Color.lerp(
                      const Color(0xff162036),
                      const Color(0xff0b1220),
                      _bgController.value)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [

                // ✨ FLOATING PARTICLES
                ...List.generate(15, (i) {
                  return Positioned(
                    left: (i * 30.0) % MediaQuery.of(context).size.width,
                    top: (_bgController.value * 700 + i * 50) % 800,
                    child: Opacity(
                      opacity: 0.2,
                      child: const Icon(
                        Icons.circle,
                        size: 6,
                        color: Colors.cyanAccent,
                      ),
                    ),
                  );
                }),

                // 🎯 MAIN UI
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // 🌟 LOGO
                      const Icon(
                        Icons.hotel_rounded,
                        size: 100,
                        color: Colors.cyanAccent,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "GRAND HORIZON",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        "Experience Luxury Like Never Before",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // 🧊 BUTTON
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          minimumSize: const Size(220, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                          shadowColor: Colors.cyanAccent.withOpacity(0.5),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/customer_login");
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "GET STARTED",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded, color: Colors.black),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      const Text(
                        "Admins & Customers use the same portal",
                        style: TextStyle(color: Colors.white24, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}