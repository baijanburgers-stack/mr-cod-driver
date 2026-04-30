import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MR COD Driver — Bright, Airy, Fast Design System
/// ─────────────────────────────────────────────────
/// Matches the MR COD Belgium web platform light theme.
class AppTheme {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color brand = Color(0xFFDC2626); // red-600
  static const Color brandDeep = Color(0xFFB91C1C); // red-700 (pressed)
  static const Color brandLight = Color(0xFFFEE2E2); // red-100 (tint bg)

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color destructive = Color(0xFFDC2626);

  // ── Light Palette ────────────────────────────────────────────────────────
  static const Color bgPrimary = Color(0xFFFAF9F6); // off-white base
  static const Color bgCard = Color(0xFFFFFFFF); // white cards
  static const Color bgMuted = Color(0xFFF1F5F9); // slate-100
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color divider = Color(0xFFE2E8F0);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textMuted = Color(0xFF94A3B8); // slate-400

  // ── Shadows ──────────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow() => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> brandShadow() => [
        BoxShadow(
          color: brand.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // ── Card decoration ──────────────────────────────────────────────────────
  static BoxDecoration cardDecoration = BoxDecoration(
    color: bgCard,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: border),
    boxShadow: cardShadow(),
  );

  // ── Input decoration helper ───────────────────────────────────────────────
  static InputDecoration inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textMuted),
        filled: true,
        fillColor: bgMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: brand, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      );

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: brand,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        brightness: Brightness.light,
        primary: brand,
        surface: bgCard,
        error: destructive,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.outfit(
            fontSize: 26, fontWeight: FontWeight.w900, color: textPrimary),
        headlineMedium: GoogleFonts.outfit(
            fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary),
        titleLarge: GoogleFonts.outfit(
            fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary),
        bodyLarge: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
        bodyMedium: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
        bodySmall: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w400, color: textMuted),
      ),
      iconTheme: const IconThemeData(color: textSecondary),
      dividerColor: divider,
      cardColor: bgCard,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: bgCard),
    );
  }
}
