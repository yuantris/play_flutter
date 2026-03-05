import 'package:flutter/material.dart';

class DynamicAppColors {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color accent;
  final Color accentDark;
  final Color accentLight;
  
  const DynamicAppColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.accent,
    required this.accentDark,
    required this.accentLight,
  });
  
  factory DynamicAppColors.fromPrimary(Color primary, Color accent) {
    HSLColor primaryHsl = HSLColor.fromColor(primary);
    HSLColor accentHsl = HSLColor.fromColor(accent);
    
    return DynamicAppColors(
      primary: primary,
      primaryDark: primaryHsl.withLightness((primaryHsl.lightness - 0.1).clamp(0.0, 1.0)).toColor(),
      primaryLight: primaryHsl.withLightness((primaryHsl.lightness + 0.1).clamp(0.0, 1.0)).toColor(),
      accent: accent,
      accentDark: accentHsl.withLightness((accentHsl.lightness - 0.1).clamp(0.0, 1.0)).toColor(),
      accentLight: accentHsl.withLightness((accentHsl.lightness + 0.1).clamp(0.0, 1.0)).toColor(),
    );
  }
  
  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
  
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
  static const Color progressBackground = Color(0xFF3D3D5C);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

class DynamicAppTheme {
  static ThemeData createDarkTheme(DynamicAppColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.accent,
        surface: DynamicAppColors.surfaceDark,
        error: DynamicAppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: DynamicAppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: DynamicAppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: DynamicAppColors.textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: DynamicAppColors.cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DynamicAppColors.surfaceDark,
        selectedItemColor: colors.primary,
        unselectedItemColor: DynamicAppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: DynamicAppColors.textPrimaryDark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
        ),
        bodyMedium: TextStyle(
          color: DynamicAppColors.textSecondaryDark,
        ),
        bodySmall: TextStyle(
          color: DynamicAppColors.textSecondaryDark,
        ),
        labelLarge: TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: DynamicAppColors.dividerDark,
        thickness: 0.5,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primary,
        inactiveTrackColor: DynamicAppColors.progressBackground,
        thumbColor: colors.primary,
        overlayColor: colors.primary.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: DynamicAppColors.progressBackground,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DynamicAppColors.surfaceDark,
        contentTextStyle: const TextStyle(color: DynamicAppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DynamicAppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: DynamicAppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: DynamicAppColors.textSecondaryDark,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DynamicAppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withValues(alpha: 0.5);
          }
          return null;
        }),
      ),
    );
  }

  static ThemeData createLightTheme(DynamicAppColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.accent,
        surface: DynamicAppColors.surfaceLight,
        error: DynamicAppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: DynamicAppColors.textPrimaryLight,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: DynamicAppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: DynamicAppColors.textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: DynamicAppColors.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DynamicAppColors.surfaceLight,
        selectedItemColor: colors.primary,
        unselectedItemColor: DynamicAppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: DynamicAppColors.textPrimaryLight,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
        ),
        bodyMedium: TextStyle(
          color: DynamicAppColors.textSecondaryLight,
        ),
        bodySmall: TextStyle(
          color: DynamicAppColors.textSecondaryLight,
        ),
        labelLarge: TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: DynamicAppColors.dividerLight,
        thickness: 0.5,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primary,
        inactiveTrackColor: DynamicAppColors.dividerLight,
        thumbColor: colors.primary,
        overlayColor: colors.primary.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: DynamicAppColors.dividerLight,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DynamicAppColors.surfaceLight,
        contentTextStyle: const TextStyle(color: DynamicAppColors.textPrimaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DynamicAppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: DynamicAppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: DynamicAppColors.textSecondaryLight,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DynamicAppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withValues(alpha: 0.5);
          }
          return null;
        }),
      ),
    );
  }
}
