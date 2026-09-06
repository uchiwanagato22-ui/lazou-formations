import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette basée sur l'identité visuelle de Lazou Formations :
/// - Bleu marine (logo LAZOU, sérieux/institutionnel)
/// - Orange/jaune (affiches, énergie)
/// À ajuster dès qu'on a la charte graphique exacte (logo vectoriel, etc.)
class LazouColors {
  static const primary = Color(0xFF0D3B66); // bleu marine du logo
  static const secondary = Color(0xFFF7A600); // orange affiche
  static const accent = Color(0xFFFFC94A); // jaune
  static const background = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFC62828);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
}

class LazouTheme {
  static ThemeData light() {
    // Poppins pour les titres (plus de caractère), Inter pour le corps de
    // texte (très lisible) — combo courant pour un rendu "SaaS pro" plutôt
    // que la police système par défaut.
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w700),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: LazouColors.primary,
        primary: LazouColors.primary,
        secondary: LazouColors.secondary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: LazouColors.background,
      textTheme: textTheme,
      // Transitions fondu + léger zoom au lieu du slide Android brut par
      // défaut — un des détails qui donne un rendu "app premium" plutôt
      // que "projet étudiant", sur toutes les plateformes.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeScaleTransitionsBuilder(),
          TargetPlatform.iOS: _FadeScaleTransitionsBuilder(),
        },
      ),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: LazouColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: LazouColors.surface,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LazouColors.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LazouColors.primary,
          side: const BorderSide(color: LazouColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LazouColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _FadeScaleTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeScaleTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
        child: child,
      ),
    );
  }
}
