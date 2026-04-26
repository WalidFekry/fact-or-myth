import 'package:flutter/material.dart';

class AppColors {
  // ========================================
  // DARK THEME - Soft Premium Dark
  // ========================================
  
  // Primary & Secondary
  static const Color primaryDark = Color(0xFF5B7FFF); // Calm modern blue
  static const Color secondaryDark = Color(0xFF7C5CFF); // Subtle purple accent
  
  // Backgrounds & Surfaces (Layered elevation)
  static const Color backgroundDark = Color(0xFF0F0F0F); // Soft black (not pure black)
  static const Color surfaceDark = Color(0xFF1A1A1A); // Elevated surface
  static const Color cardDark = Color(0xFF242424); // Card surface (higher elevation)
  
  // Text Colors (Eye-friendly contrast)
  static const Color textPrimaryDark = Color(0xFFE8E8E8); // Soft white
  static const Color textSecondaryDark = Color(0xFFA0A0A0); // Muted gray
  static const Color textTertiaryDark = Color(0xFF707070); // Subtle gray
  
  // ========================================
  // LIGHT THEME - Soft Calm Light
  // ========================================
  
  // Primary & Secondary
  static const Color primaryLight = Color(0xFF5B7FFF);
  static const Color secondaryLight = Color(0xFF7C5CFF);
  
  // Backgrounds & Surfaces (Soft, not harsh white)
  static const Color backgroundLight = Color(0xFFFAFAFA); // Soft off-white
  static const Color surfaceLight = Color(0xFFF5F5F5); // Subtle gray
  static const Color cardLight = Color(0xFFFFFFFF); // Pure white for cards (contrast)
  
  // Text Colors (Comfortable contrast)
  static const Color textPrimaryLight = Color(0xFF1A1A1A); // Near black
  static const Color textSecondaryLight = Color(0xFF666666); // Medium gray
  static const Color textTertiaryLight = Color(0xFF999999); // Light gray
  
  // ========================================
  // SEMANTIC COLORS (Universal)
  // ========================================
  static const Color success = Color(0xFF4CAF50); // Clean green
  static const Color error = Color(0xFFEF5350); // Clean red
  static const Color warning = Color(0xFFFFA726); // Clean orange
  static const Color info = Color(0xFF42A5F5); // Clean blue
  
  // ========================================
  // SPECIAL COLORS
  // ========================================
  
  // Leaderboard Medals
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  
  // Social Media Brand Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color whatsapp = Color(0xFF25D366);
  
  // Dividers (Low contrast)
  static const Color dividerDark = Color(0xFF2A2A2A);
  static const Color dividerLight = Color(0xFFE8E8E8);
  
  // Overlay Colors (for modals, shadows)
  static const Color overlayDark = Color(0xCC000000); // 80% black
  static const Color overlayLight = Color(0x66000000); // 40% black
  
  // Shimmer Loading Colors
  static const Color shimmerBaseDark = Color(0xFF1A1A1A);
  static const Color shimmerHighlightDark = Color(0xFF2A2A2A);
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  
  // Pure Colors (for specific use cases only)
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);
}
