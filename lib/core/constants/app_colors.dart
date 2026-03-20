import 'package:flutter/material.dart';

abstract class AppColors {
  // Background
  static const background   = Color(0xFFF5F5F5);
  static const surface      = Color(0xFFFFFFFF);

  // Brand / Accent
  static const accent       = Color(0xFF00C896); // green (Groww-style)

  // Text
  static const textPrimary  = Color(0xFF1A1A1A);
  static const textSecondary= Color(0xFF8A8A8A);

  // Price change
  static const gain         = Color(0xFF00C896);
  static const loss         = Color(0xFFFF5252);

  // Row highlight
  static const gainBg       = Color(0xFFE8FAF4);
  static const lossBg       = Color(0xFFFFEBEB);

  // Exchange badge
  static const badgeBg      = Color(0xFFEEEEEE);
}