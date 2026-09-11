import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// ENQIVRA premium design tokens — colors, gradients, and the global
/// ThemeData. Purely presentational: no widget in this file touches
/// business logic, network, or state.
///
/// These are the original dark-mode constants, kept exactly as they were
/// so every screen that already references `AppColors.xxx` / `const`
/// widgets built from them keeps compiling unchanged. New, theme-aware
/// work (light mode, the circular reveal switch, the richer backdrop)
/// is layered on top via [AppPalette] below instead of touching these.
class AppColors {
  AppColors._();
  // Near-black stage the logo's gloss-red reads best against.
  static const background = Color(0xFF060607);
  static const backgroundElevated = Color(0xFF121013);
  // Matches the ENQIVRA mark's signature red.
  static const primary = Color(0xFFE31C2B);
  static const primaryBright = Color(0xFFFF5A55);
  // Cool electric-blue counterpoint so red never has to carry every accent.
  static const violet = Color(0xFF2E6BFF);
  static const amber = Color(0xFFF5B25C);
  static const textPrimary = Color(0xFFF8F7F8);
  static const textSecondary = Color(0xFFB9B2B4);
  static const textMuted = Color(0xFF7C767A);
  static const glassFill = Color(0x14FFFFFF);
  static const glassFillStrong = Color(0x1FFFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const danger = Color(0xFFFF4D4D);
  // Text/icon color for anything painted on top of the primary red.
  static const onPrimary = Color(0xFFFFF7F6);
}

class AppGradients {
  AppGradients._();
  static const backdrop = RadialGradient(
    center: Alignment(-0.7, -0.9),
    radius: 1.6,
    colors: [Color(0xFF2B0A0D), Color(0xFF060607)],
    stops: [0.0, 0.7],
  );
  static const primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF3B3F), Color(0xFFB60F1E)],
  );
  // Secondary blue accent — used sparingly for contrast against the red.
  static const accentButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4C86FF), Color(0xFF1A46C9)],
  );
  static const glassSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x22FFFFFF), Color(0x05FFFFFF)],
  );
}

/// Theme-aware token set. This is what all *new* shared chrome (the
/// aurora backdrop, glass panels, the scaffold + dock, the theme toggle)
/// reads from, so it can flip between [dark] and [light] instantly.
/// Registered on [ThemeData.extensions] and reached anywhere via
/// `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.backgroundElevated,
    required this.primary,
    required this.primaryBright,
    required this.violet,
    required this.amber,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.glassFill,
    required this.glassFillStrong,
    required this.glassBorder,
    required this.danger,
    required this.onPrimary,
    required this.backdrop,
    required this.primaryButton,
    required this.accentButton,
    required this.glassSheen,
    required this.brightness,
  });

  final Color background;
  final Color backgroundElevated;
  final Color primary;
  final Color primaryBright;
  final Color violet;
  final Color amber;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color glassFill;
  final Color glassFillStrong;
  final Color glassBorder;
  final Color danger;
  final Color onPrimary;
  final Gradient backdrop;
  final Gradient primaryButton;
  final Gradient accentButton;
  final Gradient glassSheen;
  final Brightness brightness;

  static const dark = AppPalette(
    background: AppColors.background,
    backgroundElevated: AppColors.backgroundElevated,
    primary: AppColors.primary,
    primaryBright: AppColors.primaryBright,
    violet: AppColors.violet,
    amber: AppColors.amber,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    glassFill: AppColors.glassFill,
    glassFillStrong: AppColors.glassFillStrong,
    glassBorder: AppColors.glassBorder,
    danger: AppColors.danger,
    onPrimary: AppColors.onPrimary,
    backdrop: AppGradients.backdrop,
    primaryButton: AppGradients.primaryButton,
    accentButton: AppGradients.accentButton,
    glassSheen: AppGradients.glassSheen,
    brightness: Brightness.dark,
  );

  // A bright, Apple-notes-style light mode: soft warm-white stage, the
  // same brand red/blue accents, dark ink text, black-tinted glass so the
  // frosted panels still read as "glass" rather than flat white cards.
  static const light = AppPalette(
    background: Color(0xFFF4F3F5),
    backgroundElevated: Color(0xFFFFFFFF),
    primary: Color(0xFFD41123),
    primaryBright: Color(0xFFFF3B3F),
    violet: Color(0xFF2E5BEA),
    amber: Color(0xFFC2790E),
    textPrimary: Color(0xFF17151A),
    textSecondary: Color(0xFF57545C),
    textMuted: Color(0xFF8B868F),
    glassFill: Color(0x14000000),
    glassFillStrong: Color(0x1F000000),
    glassBorder: Color(0x1E000000),
    danger: Color(0xFFC22A20),
    onPrimary: Color(0xFFFFFFFF),
    backdrop: RadialGradient(
      center: Alignment(-0.6, -0.9),
      radius: 1.6,
      colors: [Color(0xFFFFE0E2), Color(0xFFF4F3F5)],
      stops: [0.0, 0.75],
    ),
    primaryButton: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF3B3F), Color(0xFFB60F1E)],
    ),
    accentButton: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4C86FF), Color(0xFF1A46C9)],
    ),
    glassSheen: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x30FFFFFF), Color(0x08FFFFFF)],
    ),
    brightness: Brightness.light,
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? backgroundElevated,
    Color? primary,
    Color? primaryBright,
    Color? violet,
    Color? amber,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? glassFill,
    Color? glassFillStrong,
    Color? glassBorder,
    Color? danger,
    Color? onPrimary,
    Gradient? backdrop,
    Gradient? primaryButton,
    Gradient? accentButton,
    Gradient? glassSheen,
    Brightness? brightness,
  }) =>
      AppPalette(
        background: background ?? this.background,
        backgroundElevated: backgroundElevated ?? this.backgroundElevated,
        primary: primary ?? this.primary,
        primaryBright: primaryBright ?? this.primaryBright,
        violet: violet ?? this.violet,
        amber: amber ?? this.amber,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
        glassFill: glassFill ?? this.glassFill,
        glassFillStrong: glassFillStrong ?? this.glassFillStrong,
        glassBorder: glassBorder ?? this.glassBorder,
        danger: danger ?? this.danger,
        onPrimary: onPrimary ?? this.onPrimary,
        backdrop: backdrop ?? this.backdrop,
        primaryButton: primaryButton ?? this.primaryButton,
        accentButton: accentButton ?? this.accentButton,
        glassSheen: glassSheen ?? this.glassSheen,
        brightness: brightness ?? this.brightness,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      backgroundElevated:
          Color.lerp(backgroundElevated, other.backgroundElevated, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryBright: Color.lerp(primaryBright, other.primaryBright, t)!,
      violet: Color.lerp(violet, other.violet, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassFillStrong: Color.lerp(glassFillStrong, other.glassFillStrong, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      backdrop: Gradient.lerp(backdrop, other.backdrop, t)!,
      primaryButton: Gradient.lerp(primaryButton, other.primaryButton, t)!,
      accentButton: Gradient.lerp(accentButton, other.accentButton, t)!,
      glassSheen: Gradient.lerp(glassSheen, other.glassSheen, t)!,
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }
}

/// Ergonomic access: `context.palette.primary` etc.
extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}

/// Legacy entry point — unchanged behaviour (dark theme). Kept so any
/// existing call site (`buildTheme()`) keeps compiling.
ThemeData buildTheme() => _buildTheme(AppPalette.dark);

/// The two real entry points used by [EnqivraApp] now.
ThemeData buildDarkTheme() => _buildTheme(AppPalette.dark);
ThemeData buildLightTheme() => _buildTheme(AppPalette.light);

ThemeData _buildTheme(AppPalette p) {
  final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: p.primary,
          brightness: p.brightness,
          surface: p.backgroundElevated,
          error: p.danger),
      scaffoldBackgroundColor: p.background,
      useMaterial3: true);

  final display =
      GoogleFonts.sora(color: p.textPrimary, fontWeight: FontWeight.w600, height: 1.15);
  final body = GoogleFonts.manrope(color: p.textPrimary, height: 1.45);

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
        color: p.textSecondary,
        letterSpacing: 0.6),
    bodyLarge: body.copyWith(fontSize: 16, color: p.textPrimary),
    bodyMedium: body.copyWith(fontSize: 14, color: p.textSecondary),
    bodySmall: body.copyWith(fontSize: 12, color: p.textMuted),
    labelLarge:
        body.copyWith(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
    labelMedium: body.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
  );

  final overlayStyle =
      p.brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

  return base.copyWith(
    extensions: [p],
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
      systemOverlayStyle: overlayStyle,
      iconTheme: IconThemeData(color: p.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: p.glassFill,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: p.glassBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: p.primary,
      textColor: p.textPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        disabledBackgroundColor: p.primary.withOpacity(0.35),
        foregroundColor: p.onPrimary,
        disabledForegroundColor: p.onPrimary.withOpacity(0.6),
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.textPrimary,
        side: BorderSide(color: p.glassBorder, width: 1.2),
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primaryBright,
        textStyle: textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: p.textPrimary,
        backgroundColor: p.glassFill,
        padding: const EdgeInsets.all(10),
      ),
    ),
    iconTheme: IconThemeData(color: p.textPrimary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.glassFill,
      labelStyle: textTheme.bodyMedium,
      hintStyle: textTheme.bodySmall,
      prefixIconColor: p.textSecondary,
      suffixIconColor: p.textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.danger, width: 1.6),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: p.glassFill,
      selectedColor: p.primary.withOpacity(0.22),
      side: BorderSide(color: p.glassBorder),
      labelStyle: textTheme.bodyMedium?.copyWith(color: p.textPrimary),
      secondaryLabelStyle: textTheme.bodyMedium?.copyWith(color: p.primaryBright),
      shape: const StadiumBorder(),
    ),
    dividerTheme: DividerThemeData(color: p.glassBorder, space: 32),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      indicatorColor: p.primary.withOpacity(0.18),
      labelTextStyle: WidgetStatePropertyAll(
          textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    popupMenuTheme: PopupMenuThemeData(
      color: p.backgroundElevated,
      surfaceTintColor: Colors.transparent,
      textStyle: textTheme.bodyLarge,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: p.glassBorder)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.backgroundElevated,
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
