import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../customer/screens/role_dashboard.dart';




class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _mainController;
  late AnimationController _bgController;

  late Animation<double> fade;
  late Animation<double> scale;
  late Animation<double> glow;

  @override
  void initState() {
    super.initState();

    // 🎬 MAIN ANIMATION
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    scale = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    glow = Tween(begin: 0.3, end: 1.2).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _mainController.forward();

    // 🌌 BACKGROUND ANIMATION
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // ⏳ NAVIGATION
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleDashboard()),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
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
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                      AppColors.background,
                      const Color(0xff162036),
                      _bgController.value)!,
                  Color.lerp(
                      const Color(0xff162036),
                      AppColors.background,
                      _bgController.value)!,
                ],

              ),
            ),
            child: Stack(
              children: [

                // ✨ FLOATING PARTICLES
                ...List.generate(15, (i) {
                  return Positioned(
                    left: (i * 25.0) % MediaQuery.of(context).size.width,
                    top: (_bgController.value * 600 + i * 40) % 800,
                    child: Opacity(
                      opacity: 0.2,
                      child: const Icon(
                        Icons.circle,
                        size: 6,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }),


                // 🎯 MAIN CONTENT
                Center(
                  child: FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(
                      scale: scale,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          // 🌟 GLOWING LOGO
                          AnimatedBuilder(
                            animation: glow,
                            builder: (_, __) {
                              return Container(
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primary
                                          .withOpacity(glow.value * 0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withOpacity(glow.value * 0.5),
                                      blurRadius: 50,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.hotel_rounded,
                                  size: 95,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 30),

                          // 🏨 TITLE
                          Text(
                            "GRAND HORIZON",
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 6,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "ELEVATED EXPERIENCE",
                            style: GoogleFonts.outfit(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Text(
                            "Luxury • Comfort • Experience",
                            style: GoogleFonts.outfit(
                              color: AppColors.textDim,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),


                          const SizedBox(height: 40),

                          SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),


                          const SizedBox(height: 15),

                          const Text(
                            "Initializing...",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
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