import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryLight = Color(0xFFE91E63);
  static const Color _primaryDark = Color(0xFFF06292);
  static const Color _secondaryLight = Color(0xFF6200EE);
  static const Color _secondaryDark = Color(0xFFBB86FC);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _backgroundLight = Color(0xFFF8FAFC);
  static const Color _backgroundDark = Color(0xFF0F172A);
  static const Color _errorLight = Color(0xFFDC2626);
  static const Color _errorDark = Color(0xFFEF4444);
  static const Color _successLight = Color(0xFF059669);
  static const Color _successDark = Color(0xFF10B981);
  static const Color _warningLight = Color(0xFFD97706);
  static const Color _warningDark = Color(0xFFF59E0B);
  static const Color _infoLight = Color(0xFF0284C7);
  static const Color _infoDark = Color(0xFF0EA5E9);

  static const Color _surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color _surfaceVariantDark = Color(0xFF1E293B);
  static const Color _outlineLight = Color(0xFFE2E8F0);
  static const Color _outlineDark = Color(0xFF334155);
  static const Color _onSurfaceLight = Color(0xFF0F172A);
  static const Color _onSurfaceDark = Color(0xFFF8FAFC);
  static const Color _onSurfaceVariantLight = Color(0xFF475569);
  static const Color _onSurfaceVariantDark = Color(0xFF94A3B8);

  static const Color _shieldPink = Color(0xFFE91E63);
  static const Color _shieldPinkLight = Color(0xFFFCE4EC);
  static const Color _shieldPinkDark = Color(0xFFAD1457);
  static const Color _shieldRed = Color(0xFFDC2626);
  static const Color _shieldOrange = Color(0xFFF59E0B);
  static const Color _shieldAmber = Color(0xFFFBBF24);
  static const Color _shieldGreen = Color(0xFF10B981);
  static const Color _shieldTeal = Color(0xFF14B8A6);
  static const Color _shieldBlue = Color(0xFF3B82F6);
  static const Color _shieldIndigo = Color(0xFF6366F1);
  static const Color _shieldPurple = Color(0xFFA855F7);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: _primaryLight,
      onPrimary: Colors.white,
      primaryContainer: _shieldPinkLight,
      onPrimaryContainer: _shieldPinkDark,
      secondary: _secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE8EAF6),
      onSecondaryContainer: Color(0xFF311B92),
      tertiary: _shieldTeal,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE0F2F1),
      onTertiaryContainer: Color(0xFF004D40),
      error: _errorLight,
      onError: Colors.white,
      errorContainer: Color(0xFFFDECEA),
      onErrorContainer: Color(0xFF7F1D1D),
      surface: _surfaceLight,
      onSurface: _onSurfaceLight,
      surfaceContainerHighest: _surfaceVariantLight,
      onSurfaceVariant: _onSurfaceVariantLight,
      outline: _outlineLight,
      outlineVariant: _outlineLight,
      background: _backgroundLight,
      onBackground: _onSurfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _backgroundLight,
      fontFamily: 'Inter',
      textTheme: _textTheme.apply(
        bodyColor: _onSurfaceLight,
        displayColor: _onSurfaceLight,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: _surfaceLight,
        surfaceTintColor: _surfaceLight,
        foregroundColor: _onSurfaceLight,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: _onSurfaceLight,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _outlineLight, width: 1),
        ),
        color: _surfaceLight,
        surfaceTintColor: _surfaceLight,
        shadowColor: _primaryLight.withOpacity(0.08),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.pressed)
                ? _primaryLight.withOpacity(0.8)
                : null,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          side: BorderSide(color: _outlineLight, width: 1.5),
          foregroundColor: _primaryLight,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          foregroundColor: _primaryLight,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariantLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _outlineLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _errorLight, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _errorLight, width: 2),
        ),
        labelStyle: _textTheme.bodyMedium?.copyWith(color: _onSurfaceVariantLight),
        hintStyle: _textTheme.bodyMedium?.copyWith(color: _onSurfaceVariantLight.withOpacity(0.5)),
        errorStyle: _textTheme.bodySmall?.copyWith(color: _errorLight),
        prefixIconColor: _onSurfaceVariantLight,
        suffixIconColor: _onSurfaceVariantLight,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: _textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        side: BorderSide(color: _outlineLight),
        backgroundColor: _surfaceVariantLight,
        selectedColor: _primaryLight.withOpacity(0.1),
        checkmarkColor: _primaryLight,
        disabledColor: _outlineLight.withOpacity(0.3),
      ),
      dividerTheme: DividerThemeData(
        color: _outlineLight,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: _textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: _textTheme.bodyMedium?.copyWith(color: _onSurfaceVariantLight),
        leadingAndTrailingTextStyle: _textTheme.bodyMedium,
        iconColor: _onSurfaceVariantLight,
        tileColor: Colors.transparent,
        selectedTileColor: _primaryLight.withOpacity(0.05),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _surfaceLight,
        surfaceTintColor: _surfaceLight,
        titleTextStyle: _textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(color: _onSurfaceVariantLight),
        actionsAlignment: MainAxisAlignment.end,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: _surfaceLight,
        surfaceTintColor: _surfaceLight,
        modalBackgroundColor: _surfaceLight,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: _surfaceLight,
        surfaceTintColor: _surfaceLight,
        indicatorColor: _primaryLight.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.all(
          _textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? _primaryLight : _onSurfaceVariantLight,
            size: 24,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: _primaryLight,
        unselectedLabelColor: _onSurfaceVariantLight,
        indicatorColor: _primaryLight,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _primaryLight,
        inactiveTrackColor: _primaryLight.withOpacity(0.2),
        thumbColor: _primaryLight,
        overlayColor: _primaryLight.withOpacity(0.1),
        valueIndicatorColor: _primaryLight,
        valueIndicatorTextStyle: _textTheme.labelSmall?.copyWith(color: Colors.white),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected) ? _primaryLight : Colors.grey[400],
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? _primaryLight.withOpacity(0.3)
              : Colors.grey[300],
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected) ? _primaryLight : null,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: _outlineLight, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected) ? _primaryLight : _onSurfaceVariantLight,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primaryLight,
        linearTrackColor: _primaryLight.withOpacity(0.2),
        circularTrackColor: _primaryLight.withOpacity(0.2),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        extendedTextStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: _onSurfaceLight.withOpacity(0.9),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(color: _surfaceLight),
        actionTextStyle: _textTheme.labelLarge?.copyWith(color: _primaryLight, fontWeight: FontWeight.w600),
        elevation: 4,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _onSurfaceLight.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: _textTheme.bodySmall?.copyWith(color: _surfaceLight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        verticalOffset: 8,
      ),
      extensions: [
        _AppColors(
          shieldPink: _shieldPink,
          shieldRed: _shieldRed,
          shieldOrange: _shieldOrange,
          shieldAmber: _shieldAmber,
          shieldGreen: _shieldGreen,
          shieldTeal: _shieldTeal,
          shieldBlue: _shieldBlue,
          shieldIndigo: _shieldIndigo,
          shieldPurple: _shieldPurple,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: _primaryDark,
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF880E4F),
      onPrimaryContainer: _shieldPinkLight,
      secondary: _secondaryDark,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF37287D),
      onSecondaryContainer: Color(0xFFE8EAF6),
      tertiary: _shieldTeal,
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF004D40),
      onTertiaryContainer: Color(0xFFE0F2F1),
      error: _errorDark,
      onError: Colors.black,
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFDECEA),
      surface: _surfaceDark,
      onSurface: _onSurfaceDark,
      surfaceContainerHighest: _surfaceVariantDark,
      onSurfaceVariant: _onSurfaceVariantDark,
      outline: _outlineDark,
      outlineVariant: _outlineDark,
      background: _backgroundDark,
      onBackground: _onSurfaceDark,
    );

    return lightTheme.copyWith(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _backgroundDark,
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: _surfaceDark,
        surfaceTintColor: _surfaceDark,
        foregroundColor: _onSurfaceDark,
      ),
      cardTheme: lightTheme.cardTheme?.copyWith(
        color: _surfaceDark,
        surfaceTintColor: _surfaceDark,
        side: BorderSide(color: _outlineDark, width: 1),
      ),
      inputDecorationTheme: lightTheme.inputDecorationTheme?.copyWith(
        fillColor: _surfaceVariantDark,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _outlineDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primaryDark, width: 2),
        ),
      ),
      chipTheme: lightTheme.chipTheme?.copyWith(
        side: BorderSide(color: _outlineDark),
        backgroundColor: _surfaceVariantDark,
        selectedColor: _primaryDark.withOpacity(0.2),
      ),
      dividerTheme: lightTheme.dividerTheme?.copyWith(color: _outlineDark),
      listTileTheme: lightTheme.listTileTheme?.copyWith(
        selectedTileColor: _primaryDark.withOpacity(0.1),
      ),
      dialogTheme: lightTheme.dialogTheme?.copyWith(
        backgroundColor: _surfaceDark,
        surfaceTintColor: _surfaceDark,
      ),
      bottomSheetTheme: lightTheme.bottomSheetTheme?.copyWith(
        backgroundColor: _surfaceDark,
        surfaceTintColor: _surfaceDark,
      ),
      navigationBarTheme: lightTheme.navigationBarTheme?.copyWith(
        backgroundColor: _surfaceDark,
        surfaceTintColor: _surfaceDark,
        indicatorColor: _primaryDark.withOpacity(0.2),
      ),
      snackBarTheme: lightTheme.snackBarTheme?.copyWith(
        backgroundColor: _onSurfaceDark.withOpacity(0.9),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(color: _surfaceDark),
      ),
      extensions: [
        _AppColors(
          shieldPink: _shieldPink,
          shieldRed: _shieldRed,
          shieldOrange: _shieldOrange,
          shieldAmber: _shieldAmber,
          shieldGreen: _shieldGreen,
          shieldTeal: _shieldTeal,
          shieldBlue: _shieldBlue,
          shieldIndigo: _shieldIndigo,
          shieldPurple: _shieldPurple,
        ),
      ],
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.33,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    ),
  );
}

class _AppColors extends ThemeExtension<_AppColors> {
  final Color shieldPink;
  final Color shieldRed;
  final Color shieldOrange;
  final Color shieldAmber;
  final Color shieldGreen;
  final Color shieldTeal;
  final Color shieldBlue;
  final Color shieldIndigo;
  final Color shieldPurple;

  const _AppColors({
    required this.shieldPink,
    required this.shieldRed,
    required this.shieldOrange,
    required this.shieldAmber,
    required this.shieldGreen,
    required this.shieldTeal,
    required this.shieldBlue,
    required this.shieldIndigo,
    required this.shieldPurple,
  });

  @override
  _AppColors copyWith({
    Color? shieldPink,
    Color? shieldRed,
    Color? shieldOrange,
    Color? shieldAmber,
    Color? shieldGreen,
    Color? shieldTeal,
    Color? shieldBlue,
    Color? shieldIndigo,
    Color? shieldPurple,
  }) {
    return _AppColors(
      shieldPink: shieldPink ?? this.shieldPink,
      shieldRed: shieldRed ?? this.shieldRed,
      shieldOrange: shieldOrange ?? this.shieldOrange,
      shieldAmber: shieldAmber ?? this.shieldAmber,
      shieldGreen: shieldGreen ?? this.shieldGreen,
      shieldTeal: shieldTeal ?? this.shieldTeal,
      shieldBlue: shieldBlue ?? this.shieldBlue,
      shieldIndigo: shieldIndigo ?? this.shieldIndigo,
      shieldPurple: shieldPurple ?? this.shieldPurple,
    );
  }

  @override
  _AppColors lerp(ThemeExtension<_AppColors>? other, double t) {
    if (other is! _AppColors) return this;
    return _AppColors(
      shieldPink: Color.lerp(shieldPink, other.shieldPink, t)!,
      shieldRed: Color.lerp(shieldRed, other.shieldRed, t)!,
      shieldOrange: Color.lerp(shieldOrange, other.shieldOrange, t)!,
      shieldAmber: Color.lerp(shieldAmber, other.shieldAmber, t)!,
      shieldGreen: Color.lerp(shieldGreen, other.shieldGreen, t)!,
      shieldTeal: Color.lerp(shieldTeal, other.shieldTeal, t)!,
      shieldBlue: Color.lerp(shieldBlue, other.shieldBlue, t)!,
      shieldIndigo: Color.lerp(shieldIndigo, other.shieldIndigo, t)!,
      shieldPurple: Color.lerp(shieldPurple, other.shieldPurple, t)!,
    );
  }
}

extension AppColors on BuildContext {
  _AppColors get appColors => Theme.of(this).extension<_AppColors>()!;

  Color get shieldPink => appColors.shieldPink;
  Color get shieldRed => appColors.shieldRed;
  Color get shieldOrange => appColors.shieldOrange;
  Color get shieldAmber => appColors.shieldAmber;
  Color get shieldGreen => appColors.shieldGreen;
  Color get shieldTeal => appColors.shieldTeal;
  Color get shieldBlue => appColors.shieldBlue;
  Color get shieldIndigo => appColors.shieldIndigo;
  Color get shieldPurple => appColors.shieldPurple;
}

Color getSeverityColor(BuildContext context, String severity) {
  switch (severity.toUpperCase()) {
    case 'CRITICAL':
      return context.shieldRed;
    case 'HIGH':
    case 'HIGH RISK':
      return context.shieldOrange;
    case 'MONITOR':
      return context.shieldAmber;
    case 'SAFE':
      return context.shieldGreen;
    default:
      return context.shieldTeal;
  }
}

IconData getSeverityIcon(String severity) {
  switch (severity.toUpperCase()) {
    case 'CRITICAL':
      return Icons.dangerous_rounded;
    case 'HIGH':
    case 'HIGH RISK':
      return Icons.warning_amber_rounded;
    case 'MONITOR':
      return Icons.monitor_heart_rounded;
    case 'SAFE':
      return Icons.shield_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}