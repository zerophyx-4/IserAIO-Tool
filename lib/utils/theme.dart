import 'package:flutter/material.dart';

class HSRTheme {
  final String label;
  final Color accent;
  final Color bg;
  final Color bannerStart;
  final Color bannerEnd;

  const HSRTheme({
    required this.label,
    required this.accent,
    required this.bg,
    required this.bannerStart,
    required this.bannerEnd,
  });

  Color get accentSoft => accent.withValues(alpha: 0.15);
  Color get accentBorder => accent.withValues(alpha: 0.3);
  Color get cardBg => accent.withValues(alpha: 0.04);
}

class AppTheme {
  static const Map<String, HSRTheme> themes = {
    'mountains': HSRTheme(
      label: 'Mountains',
      accent: Color(0xFF00C2FF),
      bg: Color(0xFF0A1220),
      bannerStart: Color(0xFF0D1B2A),
      bannerEnd: Color(0xFF2C5F8A),
    ),
    'forest': HSRTheme(
      label: 'Forest',
      accent: Color(0xFF00E5A0),
      bg: Color(0xFF0A150D),
      bannerStart: Color(0xFF0A1A0F),
      bannerEnd: Color(0xFF2A5C35),
    ),
    'city': HSRTheme(
      label: 'City',
      accent: Color(0xFFA78BFA),
      bg: Color(0xFF0E0A18),
      bannerStart: Color(0xFF120D1F),
      bannerEnd: Color(0xFF2D1A60),
    ),
    'ocean': HSRTheme(
      label: 'Ocean',
      accent: Color(0xFF67E8F9),
      bg: Color(0xFF071318),
      bannerStart: Color(0xFF071820),
      bannerEnd: Color(0xFF124A60),
    ),
    'aurora': HSRTheme(
      label: 'Aurora',
      accent: Color(0xFF00FFB2),
      bg: Color(0xFF071510),
      bannerStart: Color(0xFF071A15),
      bannerEnd: Color(0xFF104A3A),
    ),
    'desert': HSRTheme(
      label: 'Desert',
      accent: Color(0xFFFFB347),
      bg: Color(0xFF130E05),
      bannerStart: Color(0xFF1A1005),
      bannerEnd: Color(0xFF5C3A18),
    ),
  };
}