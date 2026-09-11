import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// ENQIVRA premium design tokens — colors, gradients, and the global
/// ThemeData. Purely presentational: no widget in this file touches
/// business logic, network, or state.
class AppColors {
  AppColors._();
  static const background = Color(0xFF050B09);
  static const backgroundElevated = Color(0xFF0B1714);
  static const primary = Color(0xFF3FE0AD);
  static const primaryBright = Color(0xFF8CFFDB);
  static const violet = Color(0xFF8C7BFA);
  static const amber = Color(0xFFF5B25C);
  static const textPrimary = Color(0xFFF4F8F6);
  static const textSecondary = Color(0xFFA6B7B1);
  static const textMuted = Color(0xFF71847E);
  static const glassFill = Color(0x14FFFFFF);
  static const glassFillStrong = Color(0x1FFFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const danger = Color(0xFFFF6B6B);
}

class AppGradients {
  AppGradients._();
  static const backdrop = RadialGradient(
    center: Alignment(-0.7, -0.9),
    radius: 1.6,
    colors: [Color(0xFF12332B), Color(0xFF050B09)],
    stops: [0.0, 0.7],
  );
  static const primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF52E9B8), Color(0xFF2BB894)],
  );
  static const glassSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x22FFFFFF), Color(0x05FFFFFF)],
  );
}

ThemeData buildTheme() {
  final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.backgroundElevated,
          error: AppColors.danger),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true);

  final display = GoogleFonts.sora(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      height: 1.15);
  final body = GoogleFonts.manrope(color: AppColors.textPrimary, height: 1.45);

  final textTheme = TextTheme(
    displayLarge: display.copyWith(
        fontSize: 46, letterSpacing: -1.2, fontWeight: FontWeight.w700),
    displayMedium: display.copyWith(fontSize: 32, letterSpacing: -0.8),
    displaySmall: display.copyWith(fontSize: 26, letterSpacing: -0.4),
    headlineLarge: display.copyWith(fontSize: 29, letterSpacing: -0.6),
    headlineMedium: display.copyWith(fontSize: 23, letterSpacing: -0.4),
    headlineSmall: display.copyWith(fontSize: 20),
    titleLarge: display.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
    titleMedium: body.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: body.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.6),
    bodyLarge: body.copyWith(fontSize: 16, color: AppColors.textPrimary),
    bodyMedium: body.copyWith(fontSize: 14, color: AppColors.textSecondary),
    bodySmall: body.copyWith(fontSize: 12, color: AppColors.textMuted),
    labelLarge: body.copyWith(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
    labelMedium: body.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
  );

  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.comfortable,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: _PremiumTransitionsBuilder(),
      TargetPlatform.iOS: _PremiumTransitionsBuilder(),
      TargetPlatform.macOS: _PremiumTransitionsBuilder(),
      TargetPlatform.windows: _PremiumTransitionsBuilder(),
      TargetPlatform.linux: _PremiumTransitionsBuilder(),
    }),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.headlineSmall,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.glassFill,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.glassBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.primary,
      textColor: AppColors.textPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
        foregroundColor: const Color(0xFF04140F),
        disabledForegroundColor: const Color(0xFF04140F).withOpacity(0.6),
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.glassBorder, width: 1.2),
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBright,
        textStyle: textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.glassFill,
        padding: const EdgeInsets.all(10),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.glassFill,
      labelStyle: textTheme.bodyMedium,
      hintStyle: textTheme.bodySmall,
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.glassFill,
      selectedColor: AppColors.primary.withOpacity(0.22),
      side: const BorderSide(color: AppColors.glassBorder),
      labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
      secondaryLabelStyle:
          textTheme.bodyMedium?.copyWith(color: AppColors.primaryBright),
      shape: const StadiumBorder(),
    ),
    dividerTheme:
        const DividerThemeData(color: AppColors.glassBorder, space: 32),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      indicatorColor: AppColors.primary.withOpacity(0.18),
      labelTextStyle: WidgetStatePropertyAll(
          textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: AppColors.primary),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.backgroundElevated,
      surfaceTintColor: Colors.transparent,
      textStyle: textTheme.bodyLarge,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.backgroundElevated,
      contentTextStyle: textTheme.bodyLarge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// A soft fade + gentle upward slide — the closest Material analogue to
/// iOS's understated push transition. Applied on every platform so the
/// app feels consistent and deliberate rather than default-Android abrupt.
class _PremiumTransitionsBuilder extends PageTransitionsBuilder {
  const _PremiumTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero)
            .animate(curved),
        child: child,
      ),
    );
  }
}
