import 'package:flutter/material.dart';
import 'theme.dart';

class PremiumCard extends StatelessWidget {
   final double? width;
  final double? height;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final Gradient? gradient;


   const PremiumCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.gradient,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: color ?? AppColors.cardBackground,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? 24),
        border: border ?? Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
