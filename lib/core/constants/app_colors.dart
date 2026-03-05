import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color primaryLight = Color(0xFF8B85FF);
  
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentDark = Color(0xFFE55A5A);
  static const Color accentLight = Color(0xFFFF8585);
  
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  static const Color cardDark = Color(0xFF0F3460);
  static const Color cardLight = Color(0xFFF0F0F0);
  
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textSecondaryLight = Color(0xFF666666);
  
  static const Color dividerDark = Color(0xFF2D2D44);
  static const Color dividerLight = Color(0xFFE0E0E0);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  static const Color progressBackground = Color(0xFF3D3D5C);
  static const Color progressValue = Color(0xFF6C63FF);
  
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40FFFFFF);
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, Color(0xFF0D0D1A)],
  );
}
