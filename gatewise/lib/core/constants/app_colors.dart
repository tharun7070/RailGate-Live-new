import 'package:flutter/material.dart';

/// App-wide color constants following Material Design 3 guidelines
class AppColors {
  AppColors._();

  // Primary Colors - Sky Blue Theme
  static const Color primarySkyBlue = Color(0xFF00B4D8);
  static const Color primarySkyBlueLight = Color(0xFF48CAE4);
  static const Color primarySkyBlueDark = Color(0xFF0077B6);
  static const Color primarySkyBlueAccent = Color(0xFF90E0EF);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textTertiaryLight = Color(0xFF999999);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryDark = Color(0xFF707070);

  // Status Colors
  static const Color statusOpen = Color(0xFF2ECC71);
  static const Color statusClosed = Color(0xFFE74C3C);
  static const Color statusLikelyToClose = Color(0xFFF39C12);
  static const Color statusUnknown = Color(0xFF95A5A6);

  // Border & Divider Colors
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color borderDark = Color(0xFF3A3A3A);
  static const Color dividerLight = Color(0xFFF0F0F0);
  static const Color dividerDark = Color(0xFF2A2A2A);

  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.08);
  static Color shadowDark = Colors.black.withOpacity(0.3);

  // Map Marker Colors
  static const Color markerOpen = Color(0xFF2ECC71);
  static const Color markerClosed = Color(0xFFE74C3C);
  static const Color markerSelected = Color(0xFF00B4D8);
}
