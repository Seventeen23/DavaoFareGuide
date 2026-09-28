import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppColors {
  static const Color brand = Color(0xFF0B6E4F);
  static const Color brandDark = Color(0xFF074A34);
  static const Color brandLight = Color(0xFF12855E);
  static const Color brandSurface = Color(0xFFE6F2ED);

  static const Color accent = Color(0xFFFFB020);
  static const Color accentSurface = Color(0xFFFFF4E0);

  static const Color background = Color(0xFFF4F6F5);
  static const Color surface = Colors.white;
  static const Color outline = Color(0xFFE3E8E6);
  static const Color outlineStrong = Color(0xFFCBD5D1);

  static const Color ink = Color(0xFF0F1A16);
  static const Color inkMuted = Color(0xFF63736D);
  static const Color success = Color(0xFF12855E);
  static const Color danger = Color(0xFFD64545);
}

abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;

  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 26;
  static const double radiusPill = 999;
}

abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0D0F1A16), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x080F1A16), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x1A0F1A16), blurRadius: 28, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> none = [];
}

abstract final class AppTheme {
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          primary: AppColors.brand,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.danger,
        ).copyWith(
          surfaceContainerLowest: AppColors.surface,
          surfaceContainerLow: AppColors.background,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlayStyle,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: _inputBorder(AppColors.outline),
        enabledBorder: _inputBorder(AppColors.outline),
        focusedBorder: _inputBorder(AppColors.brand, width: 1.8),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.outlineStrong,
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.outlineStrong,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1.2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base
        .copyWith(
          displaySmall: base.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: AppColors.ink,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: AppColors.ink,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColors.ink,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: AppColors.ink,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          titleSmall: base.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
          bodyLarge: base.bodyLarge?.copyWith(color: AppColors.ink, height: 1.4),
          bodyMedium: base.bodyMedium?.copyWith(color: AppColors.ink, height: 1.4),
          bodySmall: base.bodySmall?.copyWith(color: AppColors.inkMuted, height: 1.35),
          labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);
  }
}
